const fs = require("fs");
const path = require("path");
const TruffleContract = require("@truffle/contract");


const gestore_generale_contract_json = JSON.parse(fs.readFileSync(path.join(__dirname, './build/contracts/GestoreGenerale.json'), 'utf8'));
const gestione_ruoli_contract_json = JSON.parse(fs.readFileSync(path.join(__dirname, './build/contracts/GestioneRuoli.json'), 'utf8'));

const GestoreGeneraleContract = TruffleContract(gestore_generale_contract_json);
GestoreGeneraleContract.setProvider(web3.currentProvider);
const GestioneRuoliContract = TruffleContract(gestione_ruoli_contract_json);
GestioneRuoliContract.setProvider(web3.currentProvider);

module.exports = {
  GestoreGeneraleContract,
  GestioneRuoliContract
}
