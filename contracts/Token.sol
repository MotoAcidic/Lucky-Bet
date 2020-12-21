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

    uint256 public _totalSupply = 5000000000e18; //5,000,000,000
    
    address internal _moderator = 0x583031D1113aD414F02576BD6afaBfb302140225;
    address internal _owner = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    address payable internal _contractOwner;
    uint256 internal _teamFund = 0;
    
    uint256 moderatorPercent = 100; // 2%
    uint256 teamPercent = 100; // 1%
    uint256 ownersPercent = 300; // 3%
    
    // 300 point range
    uint256 smallBetSmallWin = 7000; // 70%
    uint256 smallBetMediumWin = 9000; // 90%
    uint256 smallBetBigWin = 14000; // 140%
        
    // 200 point range
    uint256 mediumBetSmallWin = 5000; // 50%
    uint256 mediumBetMediumWin = 8000; // 80%
    uint256 mediumBetBigWin = 20000; // 200%
        
    // 100 point range
    uint256 largeBetSmallWin = 3000; // 30%
    uint256 largeBetMediumWin = 7000; // 70%
    uint256 largeBetBigWin = 30000; // 300%

    uint256 private _sessionsIds;
    
    mapping(address => gameData) addressGameHistory;
    mapping(uint256 => gameData) sessionGameHistory;
    
    struct gameData { 
        address account;
        uint256 session;
        uint256 amount;
        uint256 reward;
        uint256 loss;
        uint256 teamFee;
        uint256 luckyNumber;
    }
    

    
    modifier onlySetter() {
        require(hasRole(SETTER_ROLE, _msgSender()), "Caller is not a setter");
        _;
    }

    constructor() public {
        _setupRole(SETTER_ROLE, msg.sender);
        _contractOwner = msg.sender;
        _mint(msg.sender, _totalSupply);
    }
    
    function transferLoss(address account, uint256 amount) internal{
        transfer(account, amount);
    }
    
    function transferProfit(uint256 amount) public payable{
        transferFrom(_contractOwner, address(this), amount);
        
    }

    function getSetterRole() external pure returns (bytes32) {
        return SETTER_ROLE;
    }

    function getBalance(address account) public view returns (uint256){
        balanceOf(account);
    }

    function luckyBet(uint256 amount) public payable{
        require(amount >= 2, "Cannot stake less than 2 LBT");
        require(amount <= 100, "Cannot stake more than 100 LBT");
        
        _sessionsIds = _sessionsIds.add(1);
        
        uint256 sessionId = _sessionsIds;
        uint256 luckyNumber;
        luckyNumber = rand();
        uint256 totalFees;
        uint256 reward;
        uint256 loss;
        uint256 profit;
        uint256 moderatorCut;
        uint256 ownerCut;
        //uint256 teamCut;
        uint256 feeAfterCuts;

        
        // ------------------------------------------------------------------------
        //                             Small Bet
        // ------------------------------------------------------------------------
        if(amount >= 2 && amount <= 10){
            // Small win
            if(luckyNumber >= 900 || luckyNumber <= 100 ){
                reward = amount.mul(smallBetBigWin).div(10000);
                loss = 0;
                profit = reward.sub(amount);
            }else if (luckyNumber >= 800 || luckyNumber <= 200){
                reward = amount.mul(smallBetMediumWin).div(10000);
                loss = amount.sub(reward);
                profit = 0;
            }else if(luckyNumber >= 700 || luckyNumber <= 600){
                reward = amount.mul(smallBetSmallWin).div(10000);
                loss = amount.sub(reward);
                profit = 0;
            }
        }
        
        // ------------------------------------------------------------------------
        //                             Medium Bet
        // ------------------------------------------------------------------------
        if(amount >= 11 && amount <= 50){
            // Small win
            if(luckyNumber >= 900 || luckyNumber <= 100 ){
                reward = amount.mul(mediumBetBigWin).div(10000);
                loss = 0;
            }else if (luckyNumber >= 800 || luckyNumber <= 200){
                reward = amount.mul(mediumBetMediumWin).div(10000);
                loss = amount.sub(reward);
            }else if(luckyNumber >= 700 || luckyNumber <= 600){
                reward = amount.mul(mediumBetSmallWin).div(10000);
                loss = amount.sub(reward);
            }
        }
        
        // ------------------------------------------------------------------------
        //                             Large Bet
        // ------------------------------------------------------------------------
        if(amount >= 51 && amount <= 100){
            // Small win
            if(luckyNumber >= 900 || luckyNumber <= 100 ){
                reward = amount.mul(mediumBetBigWin).div(10000);
                loss = 0;
            }else if (luckyNumber >= 800 || luckyNumber <= 200){
                reward = amount.mul(mediumBetBigWin).div(10000);
                loss = amount.sub(reward);
            }else if(luckyNumber >= 700 || luckyNumber <= 600){
                reward = amount.mul(mediumBetBigWin).div(10000);
                loss = amount.sub(reward);
            }
        }
        
        
        if (profit > 0){
            transferFrom(_contractOwner, msg.sender, profit);
        }else if(profit < 1 && moderatorCut < 1 && ownerCut < 1){
            transfer(_contractOwner, loss);
        }else if(profit < 1 && moderatorCut >= 1 && ownerCut >= 1){
            
            moderatorCut = loss.mul(moderatorPercent).div(10000);
            
            ownerCut = loss.mul(ownersPercent).div(10000);
        
            totalFees = moderatorCut.add(ownerCut);
            feeAfterCuts = loss.sub(totalFees);
        
            transferLoss(_moderator, moderatorCut);
            transfer(_owner, ownerCut);
            transfer(_contractOwner, feeAfterCuts);
        }

        
        gameData memory gameData_ = gameData({
            account: msg.sender,
            session: sessionId,
            amount: amount,
            reward: profit,
            loss: loss,
            teamFee: totalFees,
            luckyNumber: luckyNumber
        });  
        
        addressGameHistory[msg.sender] = gameData_;
        sessionGameHistory[sessionId] = gameData_;

    }
    
    function returnSessionInfo(uint256 sessionID) public view returns (
        address account, 
        uint256 session, 
        uint256 amount, 
        uint256 reward,
        uint256 loss,
        uint256 teamFee,
        uint256 luckyNumber){
        return (sessionGameHistory[sessionID].account,
                sessionGameHistory[sessionID].session,
                sessionGameHistory[sessionID].amount,
                sessionGameHistory[sessionID].reward,
                sessionGameHistory[sessionID].loss,
                sessionGameHistory[sessionID].teamFee,
                sessionGameHistory[sessionID].luckyNumber
                
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
        /**
     * @dev bankersRoundedDiv method that is used to divide and round the result 
     * (AKA round-half-to-even)
     *
     * Bankers Rounding is an algorithm for rounding quantities to integers, 
     * in which numbers which are equidistant from 
     * the two nearest integers are rounded to the nearest even integer. 
     *
     * Thus, 0.5 rounds down to 0; 1.5 rounds up to 2. 
     * Other decimal fractions round as you would expect--0.4 to 0, 0.6 to 1, 1.4 to 1, 1.6 to 2, etc. 
     * Only x.5 numbers get the "special" treatment.
     * @param a What to divide
     * @param b Divide by this number
     */
    function bankersRoundedDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "div by 0"); 

        uint256 halfB = 0;
        if ((b % 2) == 1) {
            halfB = (b / 2) + 1;
        } else {
            halfB = b / 2;
        }
        bool roundUp = ((a % b) >= halfB);

        // now check if we are in the center!
        bool isCenter = ((a % b) == (b / 2));
        bool isDownEven = (((a / b) % 2) == 0);

        // select the rounding type
        if (isCenter) {
            // only in this case we rounding either DOWN or UP 
            // depending on what number is even 
            roundUp = !isDownEven;
        }

        // round
        if (roundUp) {
            return ((a / b) + 1);
        }else{
            return (a / b);
        }
    }
    
     /**
     * @dev Division, round to nearest integer (AKA round-half-up)
     * @param a What to divide
     * @param b Divide by this number
     */
    function roundedDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity automatically throws, but please emit reason
        require(b > 0, "div by 0"); 

        uint256 halfB = (b % 2 == 0) ? (b / 2) : (b / 2 + 1);
        return (a % b >= halfB) ? (a / b + 1) : (a / b);
    }
}