import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
require("dotenv").config();


const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks : {
    arbitrum: {
      url: process.env.RPC_URL,
      accounts: [process.env.PRIVATE_KEY as string],
      chainId: 421614,
      gasPrice: 5000000
    },
    
  },
  etherscan : {
    apiKey : process.env.ETHERSCAN_API_KEY
  }
  
};

export default config;
