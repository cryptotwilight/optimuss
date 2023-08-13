//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "../interfaces/IOptimusERC6551Plant.sol";

import "./Optimal.sol";
import "../interfaces/IOptimusTokenBoundAccountFactory.sol";

contract OptimusERC6551Plant is IOptimusERC6551Plant { 

    address self; 
    address owner; 
    address attestationService; 
    bytes32 attestationSchema; 
    uint256 chainId; 
    IOptimusTokenBoundAccountFactory factory; 

    mapping(address=>mapping(uint256=>address)) tokenBoundAccountByNftIdByTokenContract;  

    mapping(address=>TokenBoundAccountDescriptor) tokenBoundAccountDescriptorByTokenBoundAccount;

    mapping(address=>address) optimalByTokenBoundAccount; 

    mapping(address=>bool) hasOptimalByTokenBoundAccount; 
    mapping(address=>mapping(uint256=>bool)) hasTokenBoundAccountByNftIdByTokenContract; 

    constructor(address _factory, uint256 _chainId, address _owner, address _attestationService, bytes32 _attestationSchema) {
        owner = _owner; 
        self = address(this);
        attestationService = _attestationService; 
        attestationSchema = _attestationSchema; 
        chainId = _chainId; 
        factory = IOptimusTokenBoundAccountFactory(_factory);
    }

    function hasOptimal(address _tokenBoundAccount) view external returns (bool _hasTokenBoundAccount) {
        return hasOptimalByTokenBoundAccount[_tokenBoundAccount];
    }

    function hasTokenBoundAccount(address _tokenContract, uint256 _nftId) view external returns (bool _hasTokenBoundAccount) {
        return hasTokenBoundAccountByNftIdByTokenContract[_tokenContract][_nftId];
    }

    function getOptimal(address _tokenBoundAccount) external returns (address _optimal){
        if(hasOptimalByTokenBoundAccount[_tokenBoundAccount]) {
            return optimalByTokenBoundAccount[_tokenBoundAccount];
        }
        TokenBoundAccountDescriptor memory descriptor_ = tokenBoundAccountDescriptorByTokenBoundAccount[_tokenBoundAccount];
        Optimal optimal_ = new Optimal(_tokenBoundAccount, descriptor_.tokenContract, descriptor_.nftId, attestationService, attestationSchema);
        _optimal = address(optimal_);
        optimalByTokenBoundAccount[descriptor_.tokenBoundAccount] = _optimal; 
        hasOptimalByTokenBoundAccount[_tokenBoundAccount] = true; 
        return _optimal; 
    }

    function getTokenBoundAccount(address _erc721, uint256 _nftId) external returns (address _tokenBoundAccount){
        if(hasTokenBoundAccountByNftIdByTokenContract[_erc721][_nftId]) {
            return tokenBoundAccountByNftIdByTokenContract[_erc721][_nftId];
        }
        _tokenBoundAccount = factory.getImplementation(chainId, _erc721, _nftId); 
        tokenBoundAccountByNftIdByTokenContract[_erc721][_nftId] = _tokenBoundAccount; 
        hasTokenBoundAccountByNftIdByTokenContract[_erc721][_nftId] = true; 
        return _tokenBoundAccount; 
    }

}