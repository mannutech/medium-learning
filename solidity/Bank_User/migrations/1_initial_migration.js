const Migrations = artifacts.require("Migrations");
const BankUser = artifacts.require("BankUser");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(BankUser, { value: '1000000000000000000' });
};
