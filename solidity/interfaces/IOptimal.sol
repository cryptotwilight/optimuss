// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import {Attestation} from "https://github.com/ethereum-attestation-service/eas-contracts/blob/master/contracts/IEAS.sol";

enum AssetType {ERC721, ERC1155, ERC20}

struct Asset { 
    AssetType assetType; 
    address assetContract; 
    uint256 assetId; 
    uint256 quantity; 
}

struct OptimalAttestationData {
    bool locked; 
    uint256 assetCount; 
    bytes32 assetsHash; 
    uint256 updatedAt; 
}

interface IOptimal { 

    function getOwner() view external returns (address _owner);

    function getRootOwner() view external returns (address _rootOwner);

    function getAssets() view external returns (Asset [] memory _assets);

    function addAsset(Asset memory _asset) external returns (bool _added);

    function removeAsset(Asset memory _asset) external returns (bool _removed);

    function lock() external returns (bool _locked); 

    function unlock() external returns (bool _unlocked);

    function isLocked() view external returns (bool isLocked);

    function getAttestation() view external returns (Attestation memory _attestation); 

}