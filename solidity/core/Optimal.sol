//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "../interfaces/IOptimal.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "https://github.com/ethereum-attestation-service/eas-contracts/blob/master/contracts/IEAS.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol"; 

contract Optimal is IOptimal { 

    uint256 index = 1; 
    bool locked; 
    uint256 constant NO_ASSET_ID = 0; 
    uint64 constant DEFAULT_ATTESTATION_EXPIRY = 24*60*60*365;
    address NATIVE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; 

    address owner; 
    address nftContract; 
    uint256 nftId; 
    address self; 

    uint256 [] assetIds; 
    uint256 [] removedAssetIds; 
    mapping(uint256=>bool) isRemoved; 
    mapping(address=>mapping(uint256=>bool)) isKnownAssetByContractById;
    mapping(address=>mapping(uint256=>uint256)) aIdByAssetIdByAssetContract; 
    mapping(uint256=>Asset) assetById; 

    IEAS attestationService;
    bytes32 [] uidHistory; 
    enum AttestationAction{ ADD, REMOVE, LOCK, UNLOCK}
    bytes32 attestationSchema; 

    constructor(address _ownerAccount, address _owningNFTContract, 
                uint256 _owningNFT, address _attestationServiceAddress, 
                bytes32 _attestationSchema) {
        owner               = _ownerAccount; 
        nftContract         = _owningNFTContract; 
        nftId               = _owningNFT; 
        attestationService  = IEAS(_attestationServiceAddress);
        attestationSchema   = _attestationSchema; 
        self = address(this);
    }

    function getOwner() view external returns (address _owner){
        return owner; 
    }

    function getRootOwner() view external returns (address _rootOwner){
        return rootOwner();
    }

    function getAssets() view external returns (Asset [] memory _assets){ 
        return getAssetsInternal(); 
    }

    function getAttestationService() view external returns (address _attestationService){
        return address(attestationService);
    }   

    function getAttestationSchema() view external returns (bytes32 schema){
        return attestationSchema; 
    }

    function updateAttestationManual() external returns (bool _updated){
        updateAttestation(); 
        return true; 
    }

    function addAsset(Asset memory _asset) external returns (bool _added){
        require(!locked, "optimal locked");
        require(!isKnownAssetByContractById[_asset.assetContract][_asset.assetId], "asset already added");
        isKnownAssetByContractById[_asset.assetContract][_asset.assetId];
        transferAssetIn(_asset);
        uint256 aId_ = index++; 
        assetById[aId_] = _asset; 
        assetIds.push(aId_);
        // updateAttestation();
        return true; 
    }


    function removeAsset(Asset memory _asset) external returns (bool _removed) {
        require(!locked, "optimal locked");
        require(isKnownAssetByContractById[_asset.assetContract][_asset.assetId], "unknown asset");
        onlyOwner();
        uint256 aId_ = aIdByAssetIdByAssetContract[_asset.assetContract][_asset.assetId];
        delete assetById[aId_];
        removedAssetIds.push(aId_);
        isRemoved[aId_] = true; 
        transferAssetOut(_asset);
        // updateAttestation();
        return true; 
    }

    function lock() external returns (bool _locked){
        onlyOwner(); 
        locked = true; 
        // updateAttestation(); 
        return locked; 
    }

    function unlock() external returns (bool _unlocked){
        onlyOwner(); 
        locked = false; 
        // updateAttestation(); 
        return locked; 
    }

    function isLocked() view external returns (bool _isLocked){
        return locked; 
    }

    function getAttestation() view external returns (Attestation memory _attestation){
        return attestationService.getAttestation(getLatestUid());
    }

    //==================================== INTERNAL ===========================================

    function transferAssetIn(Asset memory _asset) internal returns (bool _transfered) {
        return transferAsset(_asset, self);
    }

    function transferAssetOut(Asset memory _asset) internal returns (bool _transferred) {
        return transferAsset(_asset, owner);
    }

    function transferAsset(Asset memory _asset, address _destination) internal returns (bool _transferred) {
        AssetType type_ = _asset.assetType; 

        if(type_ == AssetType.ERC20) {
            transferERC20(_asset, _destination);
            return true; 
        }
        if(type_ == AssetType.ERC20) {
            transferERC721(_asset, _destination);
            return true; 
        }
          if(type_ == AssetType.ERC20) {
            transferERC1155(_asset, _destination);
            return true; 
        }
    }

    function transferERC20(Asset memory _asset, address _destination) internal returns (bool _transferred) {
        if(_asset.assetContract == NATIVE && _destination != self) {
            payable(_destination).transfer(_asset.quantity);
        }
        else {
            IERC20 erc20 = IERC20(_asset.assetContract);
            erc20.transfer(_destination, _asset.quantity);
        }
        return true; 
    }

    function transferERC721(Asset memory _asset, address _destination) internal returns (bool _transferred) {
        IERC721 erc721 = IERC721(_asset.assetContract);
        if(_destination == self) {
            erc721.transferFrom(msg.sender, self, _asset.assetId);
        }
        else {
            erc721.transferFrom(self, _destination, _asset.assetId);
        }
        return true; 
    }

    function transferERC1155(Asset memory _asset, address _destination) internal returns (bool _transferred) {
        IERC1155 erc1155 = IERC1155(_asset.assetContract);
        if(_destination == self) {
            erc1155.safeTransferFrom(msg.sender, self, _asset.assetId, _asset.quantity ,"");
        }
        else {
            erc1155.safeTransferFrom(self, msg.sender, _asset.assetId, _asset.quantity ,"");
        }
        
        return true; 
    }
    function updateAttestation()  internal returns (bool _updated) {
        // revoke the existing attestation first
        RevocationRequestData memory revocationData_ = RevocationRequestData({uid : getLatestUid(), 
                                                                                  value : 0 });
        RevocationRequest memory revocationRequest_ = RevocationRequest({ schema : attestationSchema,
                                                                              data : revocationData_ });
        attestationService.revoke(revocationRequest_);
       
       uint64 expiryTime_ = uint64(block.timestamp) + uint64(DEFAULT_ATTESTATION_EXPIRY);

        // create a new attestation
        AttestationRequestData memory attestationData_ = AttestationRequestData({
                                                                                    recipient       : msg.sender, // The recipient of the attestation.
                                                                                    expirationTime  : expiryTime_, // The time when the attestation expires (Unix timestamp).
                                                                                    revocable       : true,  // Whether the attestation is revocable.
                                                                                    refUID          : bytes32(0x0000000000000000000000000000000000000000000000000000000000000000), // The UID of the related attestation.
                                                                                    data            : getOptimalAttestationData(), // Custom attestation data.
                                                                                    value           : 0 
                                                                        });
        
        AttestationRequest memory attestationRequest_ = AttestationRequest({ schema : attestationSchema, 
                                                                            data : attestationData_});
        uidHistory.push(attestationService.attest(attestationRequest_));
        
        return true; 
    }

    function getOptimalAttestationData() view internal returns (bytes memory _optimalAttestationData) { 
        OptimalAttestationData memory oad_ = OptimalAttestationData({
                                                                    locked      : locked, 
                                                                    assetCount  : getAssetCount(),
                                                                    assetsHash  : getAssetsHash(), 
                                                                    updatedAt   : block.timestamp
                                                                    }); 

        _optimalAttestationData = abi.encode(oad_.locked, oad_.assetCount, oad_.assetsHash, oad_.updatedAt);
        
        return _optimalAttestationData; 
    }

    function getAssetsInternal() view internal returns (Asset [] memory _assets) {
        uint256 assetCount_ = getAssetCount(); 
        _assets = new Asset[](assetCount_);
        uint256 y = 0; 
        for(uint256 x = 0; x < assetIds.length; x++){
            uint256 aId_ = assetIds[x];
            if(!isRemoved[aId_]) {
                _assets[y] = assetById[aId_];
                y++;
            }
        }
        return _assets; 
    }

     function getAssetsHash() view internal returns (bytes32 _assetsHash) {
        
        
        for(uint256 x = 0; x < assetIds.length; x++){
            uint256 aId_ = assetIds[x];
            if(!isRemoved[aId_]) {
                Asset memory asset_ = assetById[aId_];
                bytes32 assetHash_ =  convertAssetToHash(asset_);
                _assetsHash = keccak256(abi.encode(_assetsHash, assetHash_));
            }
        }
        
        return _assetsHash; 
    }

    function convertAssetToHash(Asset memory _asset) pure internal returns (bytes32 _hash){
        _hash = keccak256(abi.encode(_asset));
        return _hash; 
    }

    function getAssetCount() view internal returns (uint256 _count) {
        if(assetIds.length > 0){
            return assetIds.length - removedAssetIds.length; 
        }
        return 0;
    }

    function getLatestUid() view internal returns (bytes32 _uid){
        return uidHistory[uidHistory.length-1];
    }

    function onlyOwner() view internal returns (bool _isOwner) {
        require(msg.sender == owner || msg.sender == rootOwner(), "owner only");
        return true; 
    }

    function rootOwner() view internal returns (address _rootOwner) {
        return IERC721(nftContract).ownerOf(nftId);
    }

    function concat(string memory a_, string memory b_) pure  internal returns (string memory c_){
        return string(abi.encodePacked(a_,b_));
    }

    function toHash(string memory a_) pure internal returns (bytes32 _hash) {
        return keccak256(bytes(a_));
    } 
}