// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;
// For compiling with Truffle use imports bellow and comment out Remix imports
// Truffle Imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// For compiling with Remix use imports below
// Remix Imports
/*
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";
*/
contract Token is ERC20("Lucky Bet", "LBT"), AccessControl {
    using SafeMath for uint256;

    bytes32 private constant SETTER_ROLE = keccak256("SETTER_ROLE");

    uint256 public _totalSupply = 50000e18; //50,000
    
    address internal _moderator = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address internal _owner = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    
    uint256 internal _teamFund = 0;
    mapping(address => gameData) addressGameHistory;
    mapping(uint256 => gameData) sessionGameHistory;
    
        uint256 moderatorPercent = 100; // 2%
        uint256 teamPercent = 100; // 1%
        uint256 ownersPercent = 300; // 3%
    
        // 300 point range
        uint256 smallBetSmallWin = 70; // .7
        uint256 smallBetMediumWin = 90; // .9
        uint256 smallBetBigWin = 140; // 1.4
        
        // 200 point range
        uint256 mediumBetSmallWin = 50; // .5
        uint256 mediumBetMediumWin = 80; // .8
        uint256 mediumBetBigWin = 200; // 2
        
        // 100 point range
        uint256 largeBetSmallWin = 30; // .3
        uint256 largeBetMediumWin = 70; // .7
        uint256 largeBetBigWin = 300; // 3

    struct gameData { 
        address account;
        uint256 amount; 
        uint256 number;
        uint256 loss;
        uint256 session;
    }
    
    modifier onlySetter() {
        require(hasRole(SETTER_ROLE, _msgSender()), "Caller is not a setter");
        _;
    }

    constructor() public {
        _setupRole(SETTER_ROLE, msg.sender);

        _mint(msg.sender, _totalSupply);
    }

    function getSetterRole() external pure returns (bytes32) {
        return SETTER_ROLE;
    }

    function getBalance(address account) public view {
        balanceOf(account);
    }

    function luckyBet(uint256 amount) public {
        require(amount >= 2, "Cannot stake less than 5 LBT");
        require(amount <= 100, "Cannot stake more than 100 LBT");
        
        
        uint256 luckyNumber;
        luckyNumber = rand();
        uint256 reward;
        uint256 loss;
        uint256 moderatorCut;
        uint256 ownerCut;
        uint256 teamCut;

        
        // ------------------------------------------------------------------------
        //                             Small Bet
        // ------------------------------------------------------------------------
        if(amount >= 2 && amount <= 10){
            // Small win
            if(luckyNumber <= 1000 && luckyNumber >= 900 || luckyNumber <= 100 && luckyNumber > 0){
                reward = percentageOf(amount, smallBetBigWin);
                loss = 0;
            }else if (luckyNumber >= 800 || luckyNumber <= 200){
                reward = percentageOf(amount, smallBetMediumWin);
                loss = amount.sub(smallBetMediumWin);
            }else if(luckyNumber >= 700 || luckyNumber <= 300){
                reward = percentageOf(amount, smallBetSmallWin);
                loss = amount.sub(smallBetSmallWin);
            }
        }
        
        // ------------------------------------------------------------------------
        //                             Medium Bet
        // ------------------------------------------------------------------------
        if(amount >= 11 && amount <= 50){
            // Small win
            if(luckyNumber >= 900 || luckyNumber <= 100 ){
                reward = percentageOf(amount, mediumBetBigWin);
                loss = 0;
            }else if (luckyNumber >= 800 || luckyNumber <= 200){
                reward = percentageOf(amount, mediumBetMediumWin);
                loss = amount.sub(mediumBetMediumWin);
            }else if(luckyNumber >= 700 || luckyNumber <= 300){
                reward = percentageOf(amount, mediumBetSmallWin);
                loss = amount.sub(mediumBetSmallWin);
            }
        }
        
        // ------------------------------------------------------------------------
        //                             Large Bet
        // ------------------------------------------------------------------------
        if(amount >= 51 && amount <= 100){
            // Small win
            if(luckyNumber >= 900 || luckyNumber <= 100 ){
                reward = percentageOf(amount, largeBetBigWin);
                loss = 0;
            }else if (luckyNumber >= 800 || luckyNumber <= 200){
                reward = percentageOf(amount, largeBetMediumWin);
                loss = amount.sub(largeBetMediumWin);
            }else if(luckyNumber >= 700 || luckyNumber <= 300){
                reward = percentageOf(amount, largeBetSmallWin);
                loss = amount.sub(largeBetSmallWin);
            }
        }
        
            loss = amount.sub(reward);
            moderatorCut = percentageOf(loss, moderatorPercent);
            teamCut = percentageOf(loss, teamPercent);
            ownerCut = percentageOf(loss, ownersPercent);
            
            // Transfer reward
            Transfer(address(0), msg.sender, reward);
            
            transfer(_moderator, moderatorCut);
            transfer(_owner, ownerCut);

    }
    
    function returnSessionInfo(uint256 sessionID) public view returns (address account, uint256 amount, uint256 loss, uint256 session){
        return (sessionGameHistory[sessionID].account,
                sessionGameHistory[sessionID].amount,
                sessionGameHistory[sessionID].loss,
                sessionGameHistory[sessionID].session
        );
    }

    function rand() public view returns(uint256){
        uint256 seed = uint256(keccak256(abi.encodePacked(
        block.timestamp + block.difficulty +
        ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
        block.gaslimit + 
        ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
        block.number)));

        return (seed - ((seed / 1000) * 1000));
    }
    
    function percentageOf(uint amount, uint basisPoints) internal pure returns (uint) {
        return amount.mul(basisPoints).div(10000);
    }
}