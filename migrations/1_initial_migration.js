const Migrations = artifacts.require('Migrations');
const CoolCars = artifacts.require('CoolCars');

module.exports = async deployer => {
  await deployer.deploy(Migrations);
  await deployer.deploy(CoolCars, 'Cool Cars', 'BP', 10, 'IU');
};
