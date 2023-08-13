//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./Optimal.sol";
import "../interfaces/IOptimalFactory.sol";

contract OptimalFactory is IOptimalFactory { 

    address owner;
    address plant;  

    constructor(address _owner) {
        owner = _owner; 
    }

    function getOptimal(address _ownerAccount, address _owningNFTContract, 
                uint256 _owningNFT, address _attestationServiceAddress, 
                bytes32 _attestationSchema) external returns (address _optimal) {
             onlyPlant();
            _optimal = address(new Optimal(_ownerAccount, _owningNFTContract, _owningNFT, _attestationServiceAddress, _attestationSchema));
        return _optimal; 
    }

    function onlyOwner() view internal returns (bool) {
        require(msg.sender == owner, "only owner");
        return true; 
    }   

    function onlyPlant() view internal returns (bool) {
        require(msg.sender == plant, "only plant");
        return true; 
    }

    function setPlant(address _plant) external returns (bool _set) {
        onlyOwner(); 
        plant = _plant;
        return true; 
    }

}