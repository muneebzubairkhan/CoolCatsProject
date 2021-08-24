const Migrations = artifacts.require('Migrations');
const CoolCars = artifacts.require('CoolCars');

module.exports = async deployer => {
  await deployer.deploy(Migrations);
  await deployer.deploy(
    CoolCars,
    'Cool Cars',
    'CC',
    10,
    1629740587,
    'https://gateway.pinata.cloud/ipfs/QmZqDyH57xnzHhS78L178S3iTmQnavWQcAj5hzrXPGZeYe/',
  );
};

// 11PM, 23-8-21,
// https://rinkeby.etherscan.io/address/0x1637071826B4FF55e89547eFD57f9f8C16D63952#contracts
