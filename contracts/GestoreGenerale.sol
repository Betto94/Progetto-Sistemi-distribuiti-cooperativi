// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./GestioneRuoli.sol";

/**
* @title GestoreGenerale
* @author Gabriele Benedetti, Giulia Pascale 
* @notice Contratto che offre strumenti utili per la gestione di tessere per la raccolta punti di supermercati e negozi
*/
contract GestoreGenerale is GestioneRuoli{

    mapping(bytes32 => Carta) public carte;

    event NuovaCarta(
        bytes32 id,
        bytes32 id_cliente
    );

    /**
    * @dev Funzione che crea una nuova carta per un cliente e gli assegna un codice univoco
    * Questa funzione può essere invocata dal proprietario o da un funzionario
    * @param c cliente per il quale va creata la carta
    */
    function addCarta(Cliente memory c) public onlyFunzionarioOrOwner returns(bytes32) {
        uint date = block.timestamp;
        bytes32 ID = keccak256(abi.encodePacked(c.nome, c.cognome, c.dataDiNascita, date));
        Carta memory i = Carta(ID, c.id, 0, funzionari[msg.sender].negozio);
        carte[ID] = i;
        emit NuovaCarta(ID, c.id);
        return ID;
    }


    /**
    * @dev Funzione che aggiunge nuovi punti ad una carta
    * @param id_carta codice univoco della carta
    * @param numeroPunti numero dei punti da aggiungere alla carta
    */
    function addPunti(bytes32 id_carta, uint numeroPunti) public {
        if(checkAuthority(id_carta) == true)
            carte[id_carta].punti += numeroPunti;  
    }

    /**
    * @dev Funzione che decrementa i punti ad una carta
    * @param id_carta codice univoco della carta
    * @param numeroPunti numero dei punti da decrementare dalla carta
    */
    function removePunti(bytes32 id_carta, uint numeroPunti) public {
        if(checkAuthority(id_carta) == true)
            carte[id_carta].punti -= numeroPunti;
    }

    /**
    * @dev Funzione che permette di leggere l'ammontare di punti di una carta
    * @param id_carta codice univoco della carta
    */
    function getPunti(bytes32 id_carta) public view returns(uint){
        return carte[id_carta].punti;
    }

    /**
    * @dev Funzione che inserisce una notazione nei dati di un cliente, 
    * utile qualora si dovesse inserire notazioni su un cliente che ha avuto problemi con la carta o il negozio
    * @param id codice univoco del cliente
    * @param notazione la notazione o descrizione che si vuole inserire su un cliente
    */
    function addNote(bytes32 id, string memory notazione) public {
        if(checkAuthority(id) == true)
            clienti[id].note = notazione;
    }

    /**
    * @dev Funzione che azzera i punti di una carta
    * @param id codice univoco della carta
    */
    function azzeraPunti(bytes32 id) public{
        if(checkAuthority(id) == true)
            carte[id].punti = 0;
    }

    /**
    * @dev Funzione che sposta i punti da una specifica carta ad un'altra. 
    * Utile qualora serva la sostituzione di una carta (Es: carta smagnetizzata, ne occorre fare una nuova)
    * oppure un cliente con più carte volesse unirle
    * @param id_from codice univoco della carta dalla quale prendere i punti
    * @param id_destinatario codice univoco della carta alla quale saranno aggiunti i punti
    */
    function movePunti(bytes32 id_from, bytes32 id_destinatario) public {
        uint ammontare = carte[id_from].punti;
        if(checkAuthority(id_from) && checkAuthority(id_destinatario))
            carte[id_destinatario].punti += ammontare;
    }

    /**
    * @dev Funzione che elimina una carta
    * @param id codice univoco della carta
    */
    function deleteCarta(bytes32 id) public {
        if(checkAuthority(id) == true)
            delete carte[id];
    }

    /**
    * @dev Funzione che elimina un cliente
    * @param id_cliente codice univoco del cliente
    */
    function deleteCliente(bytes32 id_cliente) public onlyOwner{
        delete clienti[id_cliente];
    }

    struct Consorzio{
        bytes32 id;
        string nome;
        Negozio[] negozi;
    }

    mapping(Negozio => bytes32) public consorzioNegozi;
    mapping(bytes32 => Consorzio) public consorzi;

    event NuovoConsorzio(
        bytes32 id,
        string nome
    );

    function addConsorzio(string memory nome) public onlyOwner {
        bytes32 ID = keccak256(abi.encodePacked(nome));
        Negozio[] memory n;
        Consorzio memory c = Consorzio(ID, nome, n);
        consorzi[ID] = c;
        emit NuovoConsorzio(ID, nome);
    }

    function addNegozioConsorzio(Negozio negozio, bytes32 id_consorzio) public onlyOwner{
        consorzioNegozi[negozio] = id_consorzio;
        consorzi[id_consorzio].negozi.push(negozio);
    }

    function removeNegozioConsorzio(Negozio negozio) public onlyOwner{
        bytes32 id_consorzio = consorzioNegozi[negozio];
        delete consorzioNegozi[negozio];
        for (uint i = 0; i < consorzi[id_consorzio].negozi.length; i++){
            if (consorzi[id_consorzio].negozi[i] == negozio){
                delete consorzi[id_consorzio].negozi[i];
            }
        }
    }

    /**
    *@dev Funzione che controlla se c'è l'autorità di operare
    * [1] la carta deve essere dello stesso negozio in cui opera il funzionario
    * Oppure
    * [2] la carta deve appartenere allo stesso consorzio di negozi in cui opera il funzionario (carta di un negozio diverso, stesso consorzio)
    *@param id_carta id univoco della carta su cui si vuole effettuare l'operazione
    */
    function checkAuthority(bytes32 id_carta) public view returns (bool){
        bytes32 id_consorzio_carta = consorzioNegozi[carte[id_carta].negozio];
        bytes32 id_consorzio_funzionario = consorzioNegozi[funzionari[msg.sender].negozio];
        return (carte[id_carta].negozio == funzionari[msg.sender].negozio || id_consorzio_carta == id_consorzio_funzionario);
    }

}


