// Carico alcune informazioni utili dal file .env
require("dotenv").config();

// inizializzo web3
const Web3 = require("web3");
var web3;

switch (process.argv[2]) {
    case "ropsten":
        const truffle_config = require('./truffle-config');
        web3 = new Web3( truffle_config.networks.ropsten.provider() );
        break;
    case "dev":
        web3 = new Web3(new Web3.providers.HttpProvider(`http://${process.env.HOST}:${process.env.PORT}`));
        break;
    default:
        console.log("Usage: node main.js <network> <command> <params...>");
        console.log("Network: [ropsten|dev]");
        process.exit(1);
}
global.web3 = web3;

// carico i Truffle Contracts
const Contracts = require("./contracts");

// Recupero il comando e i suoi parametri
const [command, ...params] = process.argv.slice(3);

switch (command) {
 
  case "--add-funzionario":
    let [address, negozio] = params;

    async function addFunzionario(_address, _negozio) {
      const contract = await getDeployedContract();
      const transaction = await contract.addFunzionario(
        _address,
        Contracts.GestioneRuoliContract.Negozio[_negozio.toUpperCase()],
        {from: process.env.FROM}
      );
      return transaction;
    }

    addFunzionario(address, negozio)
    .then((transaction) => {
        console.log("Transazione:");
        console.log(transaction);
        process.exit(1);
      }).catch((e) => {
        console.error("Errore!\n", e);
      });
    break;

  case "--add-cliente":
    let [nome, cognome, dataNascita] = params;

    async function addCliente(_nome, _cognome, _dataNascita) {
      const contract = await getDeployedContract();
      const transaction = await contract.addCliente(
        _nome.toLowerCase(),
        _cognome.toLowerCase(),
        _dataNascita,
        {from: process.env.FROM}
      );
      return {
        transaction,
        idCliente: transaction.logs[0].args.id
      };
    }

    addCliente(nome, cognome, dataNascita)
    .then((result) => {
        console.log("Transazione:");
        console.log(result.transaction);
        console.log(`ID CLIENTE: ${result.idCliente}`);
        process.exit(1);
      }).catch((e) => {
        console.error("Errore!\n", e);
      });
    break;
  
  case "--get-id-cliente":
    async function getIdCliente(_nome, _cognome, _dataNascita) {
      const contract = await getDeployedContract();
      const idCliente = await contract.retIdCliente(
        _nome.toLowerCase(),
        _cognome.toLowerCase(),
        _dataNascita
      );
      return idCliente
    }

    getIdCliente(params[0], params[1], params[2])
    .then((idCliente) => {
        console.log(`ID CLIENTE: ${idCliente}`);
        process.exit(1);
      }).catch((e) => {
        console.error("Errore!\n", e);
      });
    break;

  case "--add-carta":
    async function addCarta(_idCliente) {
      const contract = await getDeployedContract();
      const cliente = await contract.clienti(_idCliente);
      const transaction = await contract.addCarta(cliente, {from: process.env.FROM});
      return {
        transaction,
        idCarta: transaction.logs[0].args.id
      };

    }
    
    addCarta(params[0])
    .then((result) => {
        console.log("Transazione:");
        console.log(result.transaction);
        console.log(`ID CARTA: ${result.idCarta}`);
        process.exit(1);
      }).catch((e) => {
        console.error("Errore!\n", e);
      });
    break;

  case "--add-punti":
    async function addPunti(_idCarta, _punti) {
      const contract = await getDeployedContract();
      const transaction = await contract.addPunti(_idCarta, _punti, {from: process.env.FROM});
      return transaction;

    }
    
    addPunti(params[0], params[1])
    .then((transaction) => {
        console.log("Transazione:");
        console.log(transaction);
        process.exit(1);
      }).catch((e) => {
        console.error("Errore!\n", e);
      });
    break;

  case "--remove-punti":
    async function removePunti(_idCarta, _punti) {
      const contract = await getDeployedContract();
      const transaction = await contract.removePunti(_idCarta, _punti, {from: process.env.FROM});
      return transaction;

    }
    
    removePunti(params[0], params[1])
    .then((transaction) => {
        console.log("Transazione:");
        console.log(transaction);
        process.exit(1);
      }).catch((e) => {
        console.error("Errore!\n", e);
      });
    break;

  case "--get-punti":
    async function getPunti(_idCarta) {
      const contract = await getDeployedContract();
      const transaction = await contract.getPunti(_idCarta, {from: process.env.FROM});
      return transaction.toNumber();

    }
    
    getPunti(params[0])
    .then((n) => {
        console.log(`Punti: ${n}`)
        process.exit(1);
      }).catch((e) => {
        console.error("Errore!\n", e);
      });
    break;

  case "--add-consorzio":
    async function addConsorzio(_nome) {
      const contract = await getDeployedContract();
      const transaction = await contract.addConsorzio(_nome, {from: process.env.FROM});
      return {
        transaction,
        idConsorzio: transaction.logs[0].args.id
      };

    }
    
    addConsorzio(params[0])
    .then((result) => {
        console.log("Transazione:");
        console.log(result.transaction);
        console.log(`ID CONSORZIO: ${result.idConsorzio}`);
        process.exit(1);
      }).catch((e) => {
        console.error("Errore!\n", e);
      });
    break;

  case "--add-negozio-consorzio":
    async function addNegozioConsorzio(_negozio, _idConsorzio) {
      const contract = await getDeployedContract();
      const transaction = await contract.addNegozioConsorzio(
          Contracts.GestioneRuoliContract.Negozio[_negozio.toUpperCase()],
          _idConsorzio,
          {from: process.env.FROM}
        );
      return transaction;
    }
    
    addNegozioConsorzio(params[0], params[1])
    .then((transaction) => {
        console.log(transaction);
        process.exit(1);
      }).catch(console.error);
    break;

  case "--remove-negozio-consorzio":
    async function removeNegozioConsorzio(_negozio) {
      const contract = await getDeployedContract();
      const transaction = await contract.removeNegozioConsorzio(
          Contracts.GestioneRuoliContract.Negozio[_negozio.toUpperCase()],
          {from: process.env.FROM}
        );
      return transaction;
    }
    
    removeNegozioConsorzio(params[0])
    .then((transaction) => {
        console.log(transaction);
        process.exit(1);
      }).catch(console.error);
    break;

  case "--help":
    console.log("Ruoli:");
    console.log("\t--add-funzionario <address> <negozio>");
    console.log("\t--add-cliente <nome> <cognome> <data-nascita>");
    console.log("\t--get-id-cliente <nome> <cognome> <data-nascita>");
    console.log("Carte:");
    console.log("\t--add-carta <id-cliente>");
    console.log("\t--add-punti <id-carta> <punti>");
    console.log("\t--remove-punti <id-carta> <punti>");
    console.log("\t--get-punti <id-carta>");
    console.log("Consorzi:");
    console.log("\t--add-consorzio <nome>");
    console.log("\t--add-negozio-consorzio <nome-negozio> <id-consorzio>");
    console.log("\t--remove-negozio-consorzio <nome-negozio>");
    break;
  default:
    console.log("Comando sconosciuto");
    process.exit(1);
}

// ---------------
async function getDeployedContract() {
    try {
        return await Contracts.GestoreGeneraleContract.deployed();
    } catch (e) {
        return await Contracts.GestoreGeneraleContract.at(process.env.CONTRACT_ADDR);
    }
}
