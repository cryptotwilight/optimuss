//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IOptimalFactory { 

    function getOptimal(address _ownerAccount, address _owningNFTContract, 
                            uint256 _owningNFT, address _attestationServiceAddress, 
                                    bytes32 _attestationSchema) external returns (address _optimal);

}