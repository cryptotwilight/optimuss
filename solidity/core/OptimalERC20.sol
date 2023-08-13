// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract OptimusERC20 is ERC20 { 

    uint256 constant DEFAULT_MINT = 100000000000000000000;
    mapping(address=>uint256) lastMintByAddress; 

    uint256 constant DAY = 24*60*60;
    address owner;
    
    constructor(address _owner) ERC20("Optimus ERC20", "OERC20") {
        owner = _owner; 
    }

    function mint() external returns (uint256 _mintedAmount){
        require(isOver24hrs(), "minting again too early");
        _mintedAmount = DEFAULT_MINT;
        _mint(msg.sender, _mintedAmount);
        return _mintedAmount;
    }

     function isOver24hrs() view internal returns (bool) {
        uint256 lastMint_ = lastMintByAddress[msg.sender];
        if(block.timestamp - lastMint_ > DAY) {
            return true; 
        }
        return false; 
    }

}