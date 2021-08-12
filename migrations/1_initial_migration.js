const Migrations = artifacts.require("Migrations");
const CoolCats = artifacts.require("CoolCats");

module.exports = async (deployer) => {
  await deployer.deploy(Migrations);
  await deployer.deploy(CoolCats, "baseURI");
};
