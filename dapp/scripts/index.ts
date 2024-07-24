import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { expect } from "chai";
import hre, { ignition } from "hardhat";
import { getAddress, parseGwei } from "viem";



async function main() {
    let signer = hre.viem.getWalletClient("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
    let market = await hre.viem.getContractAt("Marketplace","0x5FbDB2315678afecb367f032d93F642f64180aa3");
    // let result = await market.write.createProduct(        
    //     ["0x3e7ad5cc",BigInt(1000), "Micheal", "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"] 
    // )
    // console.log(result);

    let result = await market.write.orderProduct(
        ["0x3e7ad5cc", BigInt(1000) , "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"],
        {value: BigInt(1000)}
    )
    console.log(result);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });