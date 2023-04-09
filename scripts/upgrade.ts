import { ethers, upgrades } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();
    
    console.log("Upgrading contract with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const StakingRewardsFactory = await ethers.getContractFactory("StakingRewardsV2");

    const existingContract = await upgrades.upgradeProxy("0x8C0FAeF1864923DAECa52103e9872130F6f23629", StakingRewardsFactory);

    console.log("StakingRewardsV2 upgraded at:", existingContract.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });