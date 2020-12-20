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

  constructor(address _luckyBetAddress) public {
    luckyBetAddress = _luckyBetAddress;
  }
  
  address public luckyBetAddress;
  Token public constant luckyToken = Token(luckyBetAddress);


  function luckyBet(uint256 amount) public {
    require(IERC20(balanceOf(_msgSender()) >= 5e18, "Cannot stake less than 5 LBT");
    require(amount.add(balanceOf(_msgSender())) <= 50e18, "Cannot stake more than 50 LBT");
    chonkBalance[_msgSender()] = chonkBalance[_msgSender()].add(amount);
    IERC20(ChonkAddress).transferFrom(_msgSender(), address(this), amount);
    emit Staked(_msgSender(), amount);
  }

}