const GestoreGenerale = artifacts.require("GestoreGenerale");

module.exports = function (deployer) {
  deployer.deploy(GestoreGenerale);
};
