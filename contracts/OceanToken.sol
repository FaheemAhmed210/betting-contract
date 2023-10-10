// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Simple ERC20
// just a tax on transfer.
// If you can implement buy/sell tax then 1% on buy and 2% on sell.
// Other just simple 2% on every transfer.
contract OceanToken is ERC20 {
    uint256 public taxRate = 1; // 1% tax rate
    uint256 public taxAmount;
    address taxWallet;

    /**
     * @dev Sets the values for {name} and {symbol}.
     * mints the value of tokens and assign them to the contract creators Address
     * All two of these values are immutable: they can only be set once during
     * construction.
     * the taxWallet recieves the tax during the transfer of tokens
     */
    constructor() ERC20("OceanToken", "OCN") {
        _mint(msg.sender, 1000000);
        taxWallet = msg.sender;
    }

     /**
     * @dev takes the {recipient} Address to which the tokens need to be ssend and the {amount} to be sent
     * it restricts the minimum amount of tokens to more than a 100
     * it reverts if the senders balance is insufficient
     * it deducts the taxAmount from the amount sent
     * transfers the net amount to recipient and the tax amount to taxWallet
     
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
         require(balanceOf(_msgSender()) >= amount, "insufficient balance");
        // require(amount > 100, "not enough tokens");
        
        taxAmount = (amount * taxRate) / 100;
        uint256 netAmount = amount - taxAmount;

       

        _transfer(_msgSender(), recipient, netAmount);
        _transfer(_msgSender(), taxWallet, taxAmount);

        emit Transfer(msg.sender, recipient, netAmount);
        emit Transfer(msg.sender, taxWallet, taxAmount);

        return true;
    }
}
