//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

struct TokenBoundAccountDescriptor {
    address tokenContract;
    uint256 nftId;
    address tokenBoundAccount;
}

interface IOptimusERC6551Plant { 

    function hasOptimal(address _tokenBoundAccount) view external returns (bool _hasOptimal);

    function hasTokenBoundAccount(address _erc721, uint256 _nftid) view external returns (bool _hasTokenBoundAccount);

    function getOptimal(address _tokenBoundAccount) external returns (address _optimal);

    function getTokenBoundAccount(address _erc721, uint256 _nftid) external returns (address _tokenBoundAccount);

}