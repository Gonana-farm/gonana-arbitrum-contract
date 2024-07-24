import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Gonana", (m) => {
  const marketplace = m.contract("Marketplace", []);

  return { marketplace };
});