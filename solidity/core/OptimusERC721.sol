// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";


contract OptimusERC721 is ERC721 {

    uint256 index; 
    mapping(address=>uint256) lastMintByAddress; 

    uint256 constant DAY = 24*60*60;

    constructor()ERC721("OPTIMUS TEST NFT", "OTN"){
    }

    function mint() external returns (uint _idx){
        require(isOver24hrs(), "less than 24 hrs since last mint");
        lastMintByAddress[msg.sender] = block.timestamp;
        _idx  = getIndex(); 
        _mint(msg.sender, _idx);
        return _idx; 
    }

    function isOver24hrs() view internal returns (bool) {
        uint256 lastMint_ = lastMintByAddress[msg.sender];
        if(block.timestamp - lastMint_ > DAY) {
            return true; 
        }
        return false; 
    }

    function getIndex() internal returns (uint256 _idx) {
        _idx = index++;
        return _idx; 
    }

}