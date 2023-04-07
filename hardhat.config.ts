import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@openzeppelin/hardhat-upgrades";
import * as dotenv from 'dotenv';


dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.18",

  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    testnet: {
      // url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      url: process.env.ANKR_URL,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },


    // etherscan: {
  //   apiKey: process.env.BSCSCAN_API_KEY,
  // },



};

export default config;
