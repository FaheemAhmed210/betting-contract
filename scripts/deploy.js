// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const tokenAddress = "0x1e937363d22ec930d599f5220a374c157cde5325";
const maxBets = 200;
const minBets = 10;

async function main() {
  // const oceanToken = await hre.ethers.deployContract("Betting", [
  //   tokenAddress,
  //   maxBets,
  //   minBets,
  // ]);

  // const contract = await oceanToken.waitForDeployment();

  // console.log("contract deployed", contract);

  await hre.run("verify:verify", {
    address: "0xf9fFDcCd3ae1432fE898eC3074Eb2Cb166be2D24",
    constructorArguments: [tokenAddress, maxBets, minBets],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
