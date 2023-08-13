//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IOptimusTokenBoundAccountFactory {

    function getImplementation(uint256 _chainId, address _tokenContract, uint256 _nftId) external returns (address _implementation);

}