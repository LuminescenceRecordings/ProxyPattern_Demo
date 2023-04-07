import { ethers, upgrades } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const StakingRewardsFactory = await ethers.getContractFactory("StakingRewardsV1");

    const arg1 = "0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee"; //BUSD
    const arg2 = "0x399f1318D837185798d574361c92C43D59449794"; //Zero2Hero
    
    const stakingRewards = await upgrades.deployProxy(StakingRewardsFactory, [arg1, arg2], { initializer: 'initialize' });
    await stakingRewards.deployed();
    console.log("StakingRewardsV1 deployed to:", stakingRewards.address);
    
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });