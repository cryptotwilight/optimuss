//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./OptimusTokenBoundAccount.sol";
import "../interfaces/IOptimusTokenBoundAccountFactory.sol";

contract OptimusTokenBoundAccountFactory is IOptimusTokenBoundAccountFactory { 

    address owner; 
    address plant; 

    constructor(address _owner) {
        owner = _owner; 
    }   

    function getImplementation(uint256 _chainId, address _tokenContract, uint256 _nftId) external returns (address _implementation){
        onlyPlant();
        return address( new OptimusTokenBoundAccount(_chainId, _tokenContract, _nftId )); 
    }

    function setPlant(address _plant) external returns (bool _set) {
        onlyOwner(); 
        plant = _plant;
        return true; 
    }

    function onlyOwner() view internal returns (bool) {
        require(msg.sender == owner, "only owner");
        return true; 
    }   

    function onlyPlant() view internal returns (bool) {
        require(msg.sender == plant, "only plant");
        return true; 
    }

}