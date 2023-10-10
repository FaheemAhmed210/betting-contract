// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Betting Contract
/// @author Faheem Ahmed
/// @notice This smart contract allows users to participate in a betting game where they can bet on either 'heads' or 'tails.'

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";
    
contract Betting  is VRFV2WrapperConsumerBase{

    event RequestSent(uint256 requestId, uint32 numWords);

    event betPlaced(address better, uint256 amount);

    event tokensClaimed(address better, uint256 amount);

    /// @notice Address of the contract admin
    address public manager;

    /// @notice Total number of bets placed
    uint256 public totalBets;

    /// @notice Number of tokens required to place a bet
    uint256 public tokensRequired;

    /// @notice Maximum number of bets allowed
    uint256 public maxBets;

    uint256 public randomResult;

    /// @notice Start time for betting
    uint256 public startTime;

    /// @notice End time for betting
    uint256 public endTime;

    /// @notice The winner of the betting round is selected or not
    bool public winnerSelected;

    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
    uint32 numWords = 2;

    // Address LINK - hardcoded for Sepolia
    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // address WRAPPER - hardcoded for Sepolia
    address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

    /// @notice The enum to bet on Heads or tails
    enum betOn {
        HEADS,
        TAILS
    }

    /// @notice The winner of the betting round
    betOn public winner;

    /// @notice The ERC-20 token used for betting
    IERC20 public token;

 

    /// @member betterAddress Address of the better
    /// @member placed Flag indicating whether a bet has been placed by the user
    /// @member amount Amount of tokens bet
    /// @member choice The outcome (either 0 for 'HEADS' or 1 for 'TAILS') bet on by the user
    struct Better {
        address betterAddress;
        bool placed;
        bool claimed;
        uint256 amount;
        betOn choice;
    }

    /*
     *  Storage
     */
    mapping(address => Better) private _bets; // Mapping to track individual bets

    /*
     *  Modifiers
     */

    /// @notice Modifier to restrict access to only the contract admin
    modifier restricted() {
        require(msg.sender == manager, "Only the admin can call this function");
        _;
    }

    /// @notice Modifier to ensure that bets are still available within the limit
    modifier betsAvailable() {
        require(totalBets < maxBets, "Betting limit has been reached");
        _;
    }

    /// @notice Modifier to check if the sender has enough tokens to place a bet
    modifier tokensAvailable() {
        require(
            token.allowance(msg.sender, address(this)) >= tokensRequired,
            "Insufficient tokens to place a bet"
        );
        _;
    }

    /// @dev Constructor sets initial owners and required number of confirmations.
    /// @param _tokenAddress the contract Address of the token being used
    /// @param _maxBets Max bets that can be placed in this contract
    /// @param _startTime the start time of the contract
    /// @param _endTime the end time of the contract
    /// @param _tokensRequired token required to place each bet
    constructor(
        address _tokenAddress,
        uint256 _maxBets,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _tokensRequired
    ) 
      VRFV2WrapperConsumerBase(linkAddress, wrapperAddress) {
        /// @notice Set the contract creator as the admin
        manager = msg.sender;
        totalBets = 0;
        maxBets = _maxBets;
        startTime = _startTime;
        endTime = _endTime;
        /// @notice Initialize the ERC-20 token used for betting
        token = IERC20(_tokenAddress);
        /// @notice Set the required number of tokens to place a bet
        tokensRequired = _tokensRequired;
    }

    /// @notice Function for users to place bets
    function claim() public {
        if (betInProgress()) {
            revert("Betting Still in progress");
        }
        if (!winnerSelected) {
            revert("winner not selected");
        }
        if (!_bets[msg.sender].placed) {
            revert(" Bet not placed");
        }
        if (_bets[msg.sender].claimed) {
            revert("Bet already claimed");
        }

        if (_bets[msg.sender].choice == winner) {
            token.transfer(msg.sender, tokensRequired);
            _bets[msg.sender].claimed = true;

              emit betPlaced(msg.sender, tokensRequired);
        } else {
            revert("Your Bet did not win");
        }
    }

    function bet(betOn betCoice) public betsAvailable tokensAvailable {
        if (_bets[msg.sender].placed) {
            revert("Bet has already been placed");
        } else {
            if (betInProgress()) {
                token.transferFrom(msg.sender, address(this), tokensRequired);
                _bets[msg.sender] = Better({
                    betterAddress: msg.sender,
                    placed: true,
                    amount: tokensRequired,
                    claimed: false,
                    choice: betCoice
                });
                totalBets = totalBets + 1;

                  emit tokensClaimed(msg.sender, tokensRequired);
            } else {
                revert("Betting has ended");
            }
        }
    }

    /// @notice Internal function to generate a random number
    function requestRandomNumber() internal  {
        uint256 requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        emit RequestSent(requestId,numWords);
    }

    /// @notice Function for the admin to pick the winner
    function pickWinner() public restricted {
        if (betInProgress()) {
            revert("Betting has not ended yet");
       } 
        requestRandomNumber();
    }

    // @notice Internal function to check if betting is in progress
    function betInProgress() internal view returns (bool) {
        return block.timestamp > startTime && block.timestamp < endTime;
    }

    /// @notice CHAINLINK callback function for fullfillment of random words request, it will recive random word, and determine winner
   function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords ) internal override {
        randomResult = _randomWords[0];
        uint256 index = randomResult % 2;
        winner = index == 0 ? betOn.HEADS : betOn.TAILS;
        winnerSelected = true;
    }

    /// @notice Internal function to check if user has allowed any funds to contract or not 
    function allowance() public view returns (uint256) {
        return token.allowance(msg.sender,address(this));
    }
}
