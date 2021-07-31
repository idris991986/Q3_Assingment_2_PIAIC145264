pragma solidity ^0.8.0;

/**
Create Crypto Bank Contract

    1) The owner can start the bank with initial deposit/capital in ether (min 50 eths)
    2) Only the owner can close the bank. Upon closing the balance should return to the Owner
    3) Anyone can open an account in the bank for Account opening they need to deposit ether with address
    4) Bank will maintain balances of accounts
    5) Anyone can deposit in the bank
    6) Only valid account holders can withdraw
    7) First 5 accounts will get a bonus of 1 ether in bonus
    8) Account holder can inquiry balance
The depositor can request for closing an account

 */

contract MyCryptoBank{
    
    address public owner;
    mapping (address => uint) private accountBalance;
    uint8 topFiveAccounts;
    event startingBank(address, string);
    event accountOpening(address, string, uint);
    event allowance(address, string);
    event deposit(address, string, uint);
    event withdraw(address, string, uint);
    event accountClosing(address, string);
    event closingBank(address, string);
    
    receive() external payable{
        
    }
    
  constructor () payable {
        owner = msg.sender;
        require(msg.value >= 50 ether);
        topFiveAccounts = 0;
        emit startingBank(owner, "has started MyCryptoBank with 50 ether initial capital");
    }    
    
    modifier onlyOwner(){
        require (owner == msg.sender);
        _;
    }
    
    modifier accountOpened{
        require(accountBalance[msg.sender] == 0,"This account address have already opened an account in MyCryptoBank");
        _;
    }
    
    modifier accountExist{
        require(accountBalance[msg.sender] > 0,"This account address doesn't exist in MyCryptoBank database");
        _;
    }
    
    modifier validAddress(){
        require (msg.sender != address(0), "Only valid addresses can make a transaction");
        _;
    }
    
    function depositFunds() payable external validAddress() accountExist(){
        accountBalance[msg.sender] += msg.value;
        emit deposit(msg.sender, " has deposited ", msg.value);
    }
    
    function openAccount() payable external accountOpened(){
        uint bonus;
        if (topFiveAccounts <= 4){
            bonus = 1 ether;
            emit allowance(msg.sender, "Congratulations! You have earned a reward of 1 ether");
        }
        else{
            bonus = 0;
        }
        accountBalance[msg.sender] = msg.value + bonus;
        emit accountOpening(msg.sender, "has opended an account in MyCryptoBank with ", accountBalance[msg.sender]);
        topFiveAccounts++;
    }
    
    function withdrawFunds(address payable _accountHolder, uint _amount) external validAddress() accountExist(){
        require (_amount <= accountBalance[_accountHolder], "You insufficient balance in your account");
            accountBalance[_accountHolder] -= _amount;
            _accountHolder.transfer(_amount);
            emit withdraw(_accountHolder, "has withdrawn ",_amount);
    }
    
    function closeCryptoAccount() payable external validAddress() accountExist(){
            payable(msg.sender).transfer(accountBalance[msg.sender]);
            delete accountBalance[msg.sender];
            emit accountClosing(msg.sender, " has closed his account in MyCryptoBank");
    }
    
    function getAccountBalance(address _accountHolder) external view accountExist() returns(uint){
        return accountBalance[_accountHolder];
    }
    
    function getCryptoBankBalance() external view onlyOwner() returns(uint){
        return address(this).balance;
    }
    
    function closeBank() onlyOwner() external{
        selfdestruct(payable(owner));
        emit closingBank(owner, " has closed MyCryptoBank");
    }
}