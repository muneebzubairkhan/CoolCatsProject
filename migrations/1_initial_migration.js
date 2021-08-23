const Migrations = artifacts.require('Migrations');
const CoolCats = artifacts.require('CoolCats');

module.exports = async deployer => {
  await deployer.deploy(Migrations);
  await deployer.deploy(CoolCats, 'baseURI');
  await deployer.deploy(GOATZ, 'someUrl', '0xcf01...', 'GOATZ', 'GTZ');
  await deployer.deploy(GOATZ, 'someUrl', '0xcf01...', 'OI', 'IU');
};
