// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract GestioneRuoli{

    enum Negozio{ 
        CONAD,
        CARREFOUR,
        GS,
        COOP,
        TODIS,
        INS,
        PENNYS,
        PEWEX,
        LIDL,
        PANORAMA
    }
// le enum sono numerate da 0 a n
    enum Ruolo{
        Funzionario,
        Cliente
    }

    struct Funzionario{
        address id;
        Negozio negozio;
    }

    struct Cliente {
        bytes32 id;
        string nome;
        string cognome;
        string dataDiNascita;
        string note;
    }

    struct Carta {
        bytes32 id;
        bytes32 cliente;
        uint punti;
        Negozio negozio;
    }

    
    mapping(Ruolo => address[]) public ruoli;  //associa ad ogni ruolo una lista di indirizzi
    mapping(address => Negozio) public negozio_funzionario;//associa un indirizzo (di un funzionario) a un negozio
    mapping(address => Funzionario) public funzionari;//associa un indirizzo a un ruolo funzionario
    mapping(bytes32 => Cliente) public clienti;//associa un indirizzo creato a un ruolo cliente


    address admin; //chi fa il deploy del contratto è il proprietario, ci servirà per gestire i permessi

    constructor(){
        admin = msg.sender;
        addFunzionario(msg.sender, Negozio.LIDL);
    }


    function contains(address[] memory a, address x) public pure returns(bool){ //pure non modifica la blockchain, funzionale al codice
        bool check = false;
    
        for (uint i=0; i < a.length; i++) {
            if (x == a[i]) {
                check = true;
            }
        }
        return check;
    }

    /**
    * @dev Funzione che crea un nuovo funzionario e gli assegna un codice univoco
    * Questa funzione può essere invocata solo dal proprietario
    * @param id address del funzionario
    * @param n negozio nel quale opera il funzionario
    */
    function addFunzionario(address id, Negozio n) public onlyOwner{
        Funzionario memory f = Funzionario(address(id), Negozio (n));
        funzionari[id] = f;
        ruoli[Ruolo.Funzionario].push(f.id);
        negozio_funzionario[f.id] = n;
    }

    event NuovoCliente(
        bytes32 id,
        string nome,
        string cognome,
        string dataDiNascita
    );

    /**
    * @dev Funzione che crea un nuovo cliente e gli assegna un codice univoco
    * Questa funzione può essere invocata dal proprietario o da un funzionario
    * @param nome nome del cliente
    * @param cognome cognome del cliente
    * @param data_nascita data di nascita del cliente
    * @return ID generato
    */
    function addCliente(string memory nome, string memory cognome, string memory data_nascita) public onlyFunzionarioOrOwner returns(bytes32){
        bytes32 ID = keccak256(abi.encodePacked(nome, cognome, data_nascita));
        Cliente memory c = Cliente(ID, nome, cognome, data_nascita, "null");
        clienti[c.id] = c;
        emit NuovoCliente(ID, nome, cognome, data_nascita);
        return ID;
    }

    modifier onlyOwner{
        require(msg.sender == admin, "Solo il proprietario puo' svolgere questa operazione");
        _; //esegue il codice che viene dopo, forse
    }

    // modifier onlyFunzionario{
    //     require(contains(ruoli[Ruolo.Funzionario], msg.sender), "Solo il funzionario puo' svolgere questa operazione");
    //     _;
    // }

    modifier onlyFunzionarioOrOwner{
        require(msg.sender == admin || contains(ruoli[Ruolo.Funzionario], msg.sender), "Solo un funzionare oppure un owner possono svolgere questa operazione");
        _;
    }


    
}