// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;
// For compiling with Truffle use imports bellow and comment out Remix imports
// Truffle Imports
/*
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
*/
// For compiling with Remix use imports below
// Remix Imports

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol";



contract LuckyBet is ERC20("Lucky Bet", "LBT"), AccessControl {
    using SafeMath for uint256;

    bytes32 private constant SETTER_ROLE = keccak256("SETTER_ROLE");

    address[] internal teamMembers;
    uint256 internal teamCount;
    uint256 public teamFund;
    
    uint256 public _totalSupply = 5000000000e18; //5,000,000,000
    uint256 internal _premine = 1000000;
    
    address internal _owner = 0x583031D1113aD414F02576BD6afaBfb302140225;

    uint256 moderatorPercent = 100; // 2%
    uint256 projectsPercent = 2000; // 20%
    uint256 ownersPercent = 3000; // 30%
    
    // Jackpot
    uint256 jackpot777 = 77777; // 777%
    
    // 300 point range
    uint256 smallBetSmallWin = 7000; // 70%
    uint256 smallBetMediumWin = 9000; // 90%
    uint256 smallBetBigWin = 20000; // 200%
        
    // 200 point range
    uint256 mediumBetSmallWin = 5000; // 50%
    uint256 mediumBetMediumWin = 8000; // 80%
    uint256 mediumBetBigWin = 30000; // 300%
        
    // 100 point range
    uint256 largeBetSmallWin = 3000; // 30%
    uint256 largeBetMediumWin = 7000; // 70%
    uint256 largeBetBigWin = 40000; // 400%

    uint256 private _sessionsIds;
    
    mapping(uint256 => gameData) sessionGameHistory;
    mapping(address => gameData) addressGameHistory;
    mapping (address => uint256) balances;
    mapping(address => uint256) internal rewards;
    
    struct gameData { 
        address account;
        uint256 session;
        uint256 amount;
        uint256 takeHome;
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
    }

    function getSetterRole() external pure returns (bytes32) {
        return SETTER_ROLE;
    }
    
    function addTeamMember(address _address) public onlySetter{
        (bool _isTeamMember, ) = isTeamMember(_address);
        if(!_isTeamMember) teamMembers.push(_address);
        teamCount = teamCount + 1;
    }
    
    function removeTeamMember(address _address) public {
        (bool _isTeamMember, uint256 s) = isTeamMember(_address);
        if(_isTeamMember){
            teamMembers[s] = teamMembers[teamMembers.length - 1];
            teamMembers.pop();
            teamCount = teamCount - 1;
        } 
    }
    
    function isTeamMember(address _address) public view returns(bool, uint256) {
        for (uint256 s = 0; s < teamMembers.length; s += 1){
            if (_address == teamMembers[s]) return (true, s);
        }
        return (false, 0);
    }
    
    function distributeRewards() public onlySetter {
        for (uint256 s = 0; s < teamMembers.length; s += 1){
            address teamMember = teamMembers[s];
            uint256 reward = teamFund.div(teamCount);
            rewards[teamMember] = rewards[teamMember].add(reward);
        }
    }

    function luckyBet(uint256 amount) public payable{
        require(amount >= 2, "Cannot stake less than 2 LBT");
        require(amount <= 100, "Cannot stake more than 100 LBT");
        //_burn(msg.sender, amount);
        _sessionsIds = _sessionsIds.add(1);
        
        uint256 sessionId = _sessionsIds;
        uint256 luckyNumber;
        luckyNumber = rand();
        uint256 totalFees;
        uint256 reward;
        uint256 loss;
        uint256 ownersCut;
        uint256 projectsCut;
        uint256 feeAfterCuts;

        
        // ------------------------------------------------------------------------
        //                             Small Bet
        // ------------------------------------------------------------------------
        if(amount >= 2 && amount <= 10){
            if(luckyNumber == 777){
                reward = amount.mul(jackpot777).div(10000);
                loss = 0;
                
                _mint(msg.sender, reward);
                
            }else if(luckyNumber >= 900 || luckyNumber <= 100 ){
                reward = amount.mul(smallBetBigWin).div(10000);
                loss = 0;
                
                _mint(msg.sender, reward);
                
            }else if (luckyNumber >= 800 || luckyNumber <= 200){
                reward = amount.mul(smallBetMediumWin).div(10000);
                loss = amount.sub(reward);
                
                _burn(msg.sender, loss);
                
            }else if(luckyNumber >= 700 || luckyNumber <= 600){
                reward = amount.mul(smallBetSmallWin).div(10000);
                loss = amount.sub(reward);
                
                _burn(msg.sender, loss);
                
            }else if(luckyNumber < 700 && luckyNumber > 600){
                reward = 0;
                loss = amount;
                
                if (amount < 5){
                    ownersCut = loss.mul(ownersPercent).div(10000);
                    projectsCut = loss.mul(projectsPercent).div(10000);
                    totalFees = ownersCut.add(projectsCut);
                    feeAfterCuts = loss.sub(totalFees);
                
                    transfer(_owner, ownersCut);
                    teamFund = teamFund.add(projectsCut);
                
                    _burn(msg.sender, feeAfterCuts);
                }else {
                    _burn(msg.sender, loss);
                }

        
            }
        }
        
        // ------------------------------------------------------------------------
        //                             Medium Bet
        // ------------------------------------------------------------------------
        if(amount >= 11 && amount <= 50){
            if(luckyNumber == 777){
                reward = amount.mul(jackpot777).div(10000);
                loss = 0;
                
                _mint(msg.sender, reward);
                
            }else if(luckyNumber >= 900 || luckyNumber <= 100 ){
                reward = amount.mul(mediumBetBigWin).div(10000);
                loss = 0;
                
                _mint(msg.sender, reward);
                
            }else if (luckyNumber >= 800 || luckyNumber <= 200){
                reward = amount.mul(mediumBetMediumWin).div(10000);
                loss = amount.sub(reward);
                
                _burn(msg.sender, loss);
                
            }else if(luckyNumber >= 700 || luckyNumber <= 600){
                reward = amount.mul(mediumBetSmallWin).div(10000);
                loss = amount.sub(reward);
                
                _burn(msg.sender, loss);
                
            }else if(luckyNumber < 700 && luckyNumber > 600){
                reward = 0;
                loss = amount;
                
                ownersCut = loss.mul(ownersPercent).div(10000);
                projectsCut = loss.mul(projectsPercent).div(10000);
                totalFees = ownersCut.add(projectsCut);
                feeAfterCuts = loss.sub(totalFees);
                
                transfer(_owner, ownersCut);
                teamFund = teamFund.add(projectsCut);
                
                _burn(msg.sender, feeAfterCuts);
        
            }
        }
        
        // ------------------------------------------------------------------------
        //                             Large Bet
        // ------------------------------------------------------------------------
        if(amount >= 51 && amount <= 100){
            if(luckyNumber == 777){
                reward = amount.mul(jackpot777).div(10000);
                loss = 0;
                
                _mint(msg.sender, reward);
                
            }else if(luckyNumber >= 900 || luckyNumber <= 100 ){
                reward = amount.mul(largeBetBigWin).div(10000);
                loss = 0;
                
                _mint(msg.sender, reward);
                
            }else if (luckyNumber >= 800 || luckyNumber <= 200){
                reward = amount.mul(largeBetMediumWin).div(10000);
                loss = amount.sub(reward);
                
                _burn(msg.sender, loss);
                
            }else if(luckyNumber >= 700 || luckyNumber <= 600){
                reward = amount.mul(largeBetSmallWin).div(10000);
                loss = amount.sub(reward);
                
                _burn(msg.sender, loss);
                
            }else if(luckyNumber < 700 && luckyNumber > 600){
                reward = 0;
                loss = amount;
                
                ownersCut = loss.mul(ownersPercent).div(10000);
                projectsCut = loss.mul(projectsPercent).div(10000);
                totalFees = ownersCut.add(projectsCut);
                feeAfterCuts = loss.sub(totalFees);
                
                transfer(_owner, ownersCut);
                teamFund = teamFund.add(projectsCut);
                
                _burn(msg.sender, feeAfterCuts);
        
            }
        }
        
        //_gameData.push(gameData(msg.sender, sessionId, amount, reward, loss, totalFees, luckyNumber));
        
        
        gameData memory gameData_ = gameData({
            account: msg.sender,
            session: sessionId,
            amount: amount,
            takeHome: reward,
            loss: loss,
            teamFee: totalFees,
            luckyNumber: luckyNumber
        });  
        
        
        sessionGameHistory[sessionId] = gameData_;

    }
    
    function returnSessionInfo(uint256 sessionID) public view returns (
        address account, 
        uint256 session, 
        uint256 amount, 
        uint256 takeHome,
        uint256 loss,
        uint256 teamFee,
        uint256 luckyNumber){
        return (sessionGameHistory[sessionID].account,
                sessionGameHistory[sessionID].session,
                sessionGameHistory[sessionID].amount,
                sessionGameHistory[sessionID].takeHome,
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
    
}