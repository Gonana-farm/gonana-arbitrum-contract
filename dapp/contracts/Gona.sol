// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


//0x2f1c1b061c34d16E6C939736A0E955BFe64A585d
contract GonaToken is ERC20, Ownable {
    
    constructor() ERC20("Gonana", "GONA") {
        _mint(msg.sender, 1000000 * (10**decimals()));
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

}