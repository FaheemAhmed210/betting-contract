require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
module.exports = {
  etherscan: {
    apiKey: "HVEHYKP67BIPNJV14E4GEHB9HN6AIGRI5T",
  },
  networks: {
    hardhat: {},
    bscTest: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545", // BSC Testnet URL
      chainId: 97, // BSC Testnet chain ID
      accounts: {
        mnemonic: process.env.MNEMONIC || "", // Your wallet mnemonic for testnet accounts
      },
    },
    sepolia: {
      url: "https://sepolia.infura.io/v3/279a795cde264fcdb37ce3321cd49d78", // Sepolia Testnet URL
      chainId: 11155111, // Sepolia Testnet chain ID
      accounts: {
        mnemonic: process.env.MNEMONIC || "", // Your wallet mnemonic for testnet accounts
      },
    },
  },
  solidity: "0.8.20",
};
