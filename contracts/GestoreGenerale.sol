// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./GestioneRuoli.sol";

/**
* @title GestoreGenerale
* @author Gabriele Benedetti, Giulia Pascale 
* @notice Contratto che offre strumenti utili per la gestione di tessere per la raccolta punti di supermercati e negozi
*/
contract GestoreGenerale is GestioneRuoli{

    
    //mapping(bytes32 => mapping(bytes32 => Carta)) public listaCarte_clienti; //
    mapping(bytes32 => Carta) public carte;

    function addCarta(Cliente memory c) public onlyFunzionarioOrOwner returns(bytes32) {
        uint date = block.timestamp;
        bytes32 ID = keccak256(abi.encodePacked(c.nome, c.cognome, c.dataDiNascita, date));
        Carta memory i = Carta(ID, c.id, 0, funzionari[msg.sender].negozio);
        //listaCarte_clienti[c.id][ID] = i;
        carte[ID] = i;
        return ID;
    }

    function addPunti(bytes32 id_carta, uint numeroPunti) public onlyFunzionarioOrOwner{
        carte[id_carta].punti += numeroPunti;
        //listaCarte_clienti[id_cliente][id_carta].punti += numeroPunti;
    }

    function removePunti(bytes32 id_carta, uint numeroPunti) public onlyFunzionarioOrOwner{
        //listaCarte_clienti[id_cliente][id_carta].punti -= numeroPunti;
        carte[id_carta].punti -= numeroPunti;
    }

    function getPunti(bytes32 id_carta) public view returns(uint){
        return carte[id_carta].punti;
        //return listaCarte_clienti[id_cliente][id_carta].punti;
    }


    //Prende in input una carstringa e la inserisce nei dati di un cliente. Utile qualora si dovesse inserire notazioni su un cliente che ha avuto problemi con la carta o il negozio
    function addNote(bytes32 id, string memory descrizione) public onlyFunzionarioOrOwner{
        clienti[id].note = descrizione;
    }

    //Prende in input una carta e ne azzera i punti
    function azzeraPunti(bytes32 id) public onlyFunzionarioOrOwner{
        carte[id].punti = 0;
    }

    //Prende in input due carte e trasferisce i punti da una alla seconda. (Es: carta smagnetizzata, ne occorre fare una nuova)
    function movePunti(bytes32 id_from, bytes32 id_destinatario) public onlyFunzionarioOrOwner{
        uint ammontare = carte[id_from].punti;
        carte[id_destinatario].punti += ammontare;
    }

    //Dato in input un id di una carta, la cancella
    function deleteCarta(bytes32 id) public onlyFunzionarioOrOwner{
        delete carte[id];
    }

    //Dato in input un id di una carta, la cancella
    function deleteCliente(bytes32 id_cliente) public onlyFunzionarioOrOwner{
        delete clienti[id_cliente];
    }

}


