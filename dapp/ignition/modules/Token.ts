import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Gona", (m) => {
  const gona = m.contract("GonaToken", []);

  return { gona };
});