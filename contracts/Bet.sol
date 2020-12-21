// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Bet is Ownable, ReentrancyGuard {
  using SafeMath for uint256;

  address public luckyBetAddress; 

  constructor(address _luckyBetAddress) public {
    luckyBetAddress = _luckyBetAddress;
  }
  
  
  Token public constant luckyToken = Token(luckyBetAddress);


  function luckyBet(uint256 amount) public {
    require(amount >= 5e18), "Cannot stake less than 5 LBT");
    require(amount <= 50e18), "Cannot stake more than 50 LBT");

    IERC20(luckyToken).transfer()
  }

}