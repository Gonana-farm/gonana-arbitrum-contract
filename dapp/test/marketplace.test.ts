import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { expect } from "chai";
import hre, { ignition } from "hardhat";
import { getAddress, parseGwei } from "viem";


const Marketplace = buildModule("Gonana", (m) => {
  const market = m.contract("Marketplace", []);
  return { market };
});


  describe("Deployment", function () {
      it("Should set the right owner", async function () {
        const { market } = await ignition.deploy(Marketplace);


      let owner = await market.read.Owner();
    });

    it("Should set a listing correctly", async function () {
      const { market } = await ignition.deploy(Marketplace);
      let product = await market.write.createProduct(
        ["0x3e7ad5cc",BigInt(1000), "Micheal", "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"]
      );
      expect(product).to.be.rejectedWith("InvalidProductState()");
    });

    it("Should revert if product already exists", async function () {
      const { market } = await ignition.deploy(Marketplace);
      let product = await market.write.createProduct(
        ["0x3e7ad5cc",BigInt(1000), "Micheal", "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"]
      );
      expect(product).to.be.ok;
    });

    it("Should reject if amount is not paid", async function () {
      const { market } = await ignition.deploy(Marketplace);
      let response = market.write.orderProduct(
        ["0x3e7ad5cc", BigInt(1000) , "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"]
      );
      expect(response).to.be.rejectedWith('InvalidPrice()');
    });

    it("Should be succesful if amount is paid", async function () {
      const { market } = await ignition.deploy(Marketplace);
      let response = market.write.orderProduct(
        ["0x3e7ad5cc", BigInt(1000) , "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"],
        {value: BigInt(1000)}
      );
      expect(response).not.be.rejected;
    });

    // it("Should fail if the unlockTime is not in the future", async function () {
    //   // We don't use the fixture here because we want a different deployment
    //   const latestTime = BigInt(await time.latest());
    //   await expect(
    //     hre.viem.deployContract("Lock", [latestTime], {
    //       value: 1n,
    //     })
    //   ).to.be.rejectedWith("Unlock time should be in the future");
    // });
  });
