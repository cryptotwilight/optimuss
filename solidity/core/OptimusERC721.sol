// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";


contract OptimusERC721 is ERC721 {

    constructor()ERC721("OPTIMUS TEST NFT", "OTN"){
        
    }


}