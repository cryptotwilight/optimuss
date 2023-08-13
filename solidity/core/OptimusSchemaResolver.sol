//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


import "../interfaces/IOptimal.sol";
import "https://github.com/ethereum-attestation-service/eas-contracts/blob/master/contracts/resolver/SchemaResolver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";

contract OptimalSchemaResolver is SchemaResolver { 
    address owner; 
    address self; 
    address payable SAFE_HARBOUR = payable(0x919104F6711782581CdBB95F66D26A6813589f76);

    constructor(address _owner, IEAS _eas) SchemaResolver(_eas) {
        owner = _owner; 
        self = address(this);
    }

    /// @notice A resolver callback that should be implemented by child contracts.
    /// @param attestation The new attestation.
    /// @param value An explicit ETH amount that was sent to the resolver. Please note that this value is verified in
    ///     both attest() and multiAttest() callbacks EAS-only callbacks and that in case of multi attestations, it'll
    ///     usually hold that msg.value != value, since msg.value aggregated the sent ETH amounts for all the
    ///     attestations in the batch.
    /// @return Whether the attestation is valid.
    function onAttest(Attestation calldata attestation, uint256 value) override internal virtual returns (bool){
        if(attestation.revocationTime > 0) { // ensure the attestation is not revoked
            return false; 
        }
        if(value != 0) {
           SAFE_HARBOUR.transfer(self.balance);
        }
        IOptimal optimal_ = IOptimal(attestation.attester);
        return isHashMatch(optimal_, attestation);
    }

    /// @notice Processes an attestation revocation and verifies if it can be revoked.
    /// @param attestation The existing attestation to be revoked.
    /// @param value An explicit ETH amount that was sent to the resolver. Please note that this value is verified in
    ///     both revoke() and multiRevoke() callbacks EAS-only callbacks and that in case of multi attestations, it'll
    ///     usually hold that msg.value != value, since msg.value aggregated the sent ETH amounts for all the
    ///     attestations in the batch.
    /// @return Whether the attestation can be revoked.
    function onRevoke(Attestation calldata attestation, uint256 value) override internal virtual returns (bool){
        IOptimal optimal = IOptimal(attestation.attester);
        Attestation memory oAttestation_ = optimal.getAttestation(); 
        OptimalAttestationData memory oad_ = getOAD(attestation.data);
        OptimalAttestationData memory ooad_ = getOAD(oAttestation_.data);

       if(value != 0) {
           SAFE_HARBOUR.transfer(self.balance);
        }
        // if we have a hash match and it's the same Uid and the optimal is looked (so only owner can change it)
        if(oad_.assetsHash == ooad_.assetsHash && attestation.uid == oAttestation_.uid && optimal.isLocked()){
            return false; // attestation can't be revoked
        }
        return true; // all other cases revocation is allowed
    }

    function isHashMatch(IOptimal optimal, Attestation memory attestation_) view internal returns (bool _isMatch){
        Asset [] memory assets_ = optimal.getAssets();
        bytes32 assetsHash_ = computeHash(assets_); // calculate the hash based on the assets presented in the optimal 
        OptimalAttestationData memory oad_ = getOAD(attestation_.data);
        return oad_.assetsHash == assetsHash_;
    }

    function computeHash(Asset [] memory _assets) pure internal returns (bytes32 _assetsHash){
        for(uint256 x = 0; x < _assets.length; x++) {
            Asset memory asset_ = _assets[x];
            bytes32 assetHash_ =  convertAssetToHash(asset_);
            _assetsHash = keccak256(abi.encode(_assetsHash, assetHash_)); 
        }
        return _assetsHash;  
    }

    function convertAssetToHash(Asset memory _asset) pure internal returns (bytes32 _hash){
        _hash = keccak256(abi.encode(_asset));
        return _hash; 
    }

    function getOAD(bytes memory _data) pure internal returns (OptimalAttestationData memory _oad){

        ( bool locked_, uint256 assetCount_, bytes32 assetsHash_, uint256 updatedAt_ ) = abi.decode(_data, ( bool, uint256, bytes32, uint256 ));

        _oad = OptimalAttestationData({ locked : locked_, 
                                        assetCount : assetCount_, 
                                        assetsHash : assetsHash_,
                                        updatedAt : updatedAt_ });
        return _oad; 
    }

    function convertAssetToString(Asset memory _asset) pure internal returns (string memory _assetString) {
        string memory tokenContract_ = Strings.toHexString(_asset.assetContract); 
        string memory assetType_ = Strings.toString(uint(_asset.assetType));
        string memory assetId_ = Strings.toString(_asset.assetId);
        string memory assetQuantity_ = Strings.toString(_asset.quantity);
        _assetString = string(abi.encodePacked(assetType_, "-",tokenContract_,"-",assetType_,"-", assetId_, "-",assetQuantity_));
        return _assetString; 
    } 

    function concat(string memory a_, string memory b_) pure  internal returns (string memory c_){
        return string(abi.encodePacked(a_,b_));
    }

    function toHash(string memory a_) pure internal returns (bytes32 _hash) {
        return keccak256(bytes(a_));
    } 
}