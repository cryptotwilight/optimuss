// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./Optimal.sol";

import "../interfaces/IOptimalFactory.sol";
import "../interfaces/IOptimusTokenBoundAccountFactory.sol";
import "../interfaces/IOptimusERC6551Plant.sol";


contract OptimusERC6551Plant is IOptimusERC6551Plant { 

    address self; 
    address owner; 
    address attestationService; 
    bytes32 attestationSchema; 
    uint256 chainId; 

    IOptimusTokenBoundAccountFactory tbaFactory; 
    IOptimalFactory optimalFactory;

    mapping(address=>mapping(uint256=>address)) tokenBoundAccountByNftIdByTokenContract;  

    mapping(address=>TokenBoundAccountDescriptor) tokenBoundAccountDescriptorByTokenBoundAccount;

    mapping(address=>address) optimalByTokenBoundAccount; 

    mapping(address=>bool) hasOptimalByTokenBoundAccount; 
    mapping(address=>mapping(uint256=>bool)) hasTokenBoundAccountByNftIdByTokenContract; 


    constructor(address _tbaFactory, address _optimalFactory, uint256 _chainId, address _owner, address _attestationService, bytes32 _attestationSchema) {
        tbaFactory          = IOptimusTokenBoundAccountFactory(_tbaFactory);
        optimalFactory      = IOptimalFactory(_optimalFactory);
        owner               = _owner; 
        attestationService  = _attestationService; 
        attestationSchema   = _attestationSchema; 
        chainId             = _chainId; 
        self                = address(this);
    }

    function getOptimal(address _tokenBoundAccount) view external returns (address _optimal) {
        if(hasOptimalByTokenBoundAccount[_tokenBoundAccount]) {
            return optimalByTokenBoundAccount[_tokenBoundAccount];
        }
        return address(0);
    }

    function getTokenBoundAccount(address _erc721, uint256 _nftId) view external returns (address _tokenBoundAccount){
        if(hasTokenBoundAccountByNftIdByTokenContract[_erc721][_nftId]) {
            return tokenBoundAccountByNftIdByTokenContract[_erc721][_nftId];
        }
        return address(0);
    }

    function hasOptimal(address _tokenBoundAccount) view external returns (bool _hasTokenBoundAccount) {
        return hasOptimalByTokenBoundAccount[_tokenBoundAccount];
    }

    function hasTokenBoundAccount(address _tokenContract, uint256 _nftId) view external returns (bool _hasTokenBoundAccount) {
        return hasTokenBoundAccountByNftIdByTokenContract[_tokenContract][_nftId];
    }

    function createOptimal(address _tokenBoundAccount) external returns (address _optimal){
        if(hasOptimalByTokenBoundAccount[_tokenBoundAccount]) {
            return optimalByTokenBoundAccount[_tokenBoundAccount];
        }
        TokenBoundAccountDescriptor memory descriptor_ = tokenBoundAccountDescriptorByTokenBoundAccount[_tokenBoundAccount];
        _optimal = optimalFactory.getOptimal(_tokenBoundAccount, descriptor_.tokenContract, descriptor_.nftId, attestationService, attestationSchema);
        optimalByTokenBoundAccount[_tokenBoundAccount] = _optimal; 
        hasOptimalByTokenBoundAccount[_tokenBoundAccount] = true;
        return _optimal; 
    }

    function createTokenBoundAccount(address _erc721, uint256 _nftId) external returns (address _tokenBoundAccount){
       if(hasTokenBoundAccountByNftIdByTokenContract[_erc721][_nftId]) {
            return tokenBoundAccountByNftIdByTokenContract[_erc721][_nftId];
        }
        _tokenBoundAccount = tbaFactory.getImplementation(chainId, _erc721, _nftId); 
        TokenBoundAccountDescriptor memory descriptor_ = TokenBoundAccountDescriptor({
            tokenContract : _erc721,
            nftId : _nftId, 
            tokenBoundAccount : _tokenBoundAccount
        });
        tokenBoundAccountDescriptorByTokenBoundAccount[_tokenBoundAccount] = descriptor_;

        tokenBoundAccountByNftIdByTokenContract[_erc721][_nftId] = _tokenBoundAccount; 
        hasTokenBoundAccountByNftIdByTokenContract[_erc721][_nftId] = true; 
        return _tokenBoundAccount; 
    }

    function setAttestationSchema(bytes32 _schema) external returns (bool _set) {
        onlyOwner();
        attestationSchema = _schema; 
        return true; 
    }

    function setTBAFactory(address _tbaFactory) external returns (bool) {
        onlyOwner(); 
        tbaFactory = IOptimusTokenBoundAccountFactory(_tbaFactory);
        return true; 
    }

    function setOptimalFactory(address _optimalFactory) external returns (bool) {
        onlyOwner(); 
        optimalFactory = IOptimalFactory(_optimalFactory); 
        return true; 
    }

//============================================================ INTERNAL ==========================================================


    function onlyOwner() view internal returns (bool) {
        require(msg.sender == owner, "only owner");
        return true; 
    }

}