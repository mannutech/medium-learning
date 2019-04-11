/**
TO DO in below smart contract:
-- Asking user Bank details while transferring and depositing
-- Maintaining One to one mapping between customer and bank
-- Add multiple banks to a single customer
-- Balance deduction from BANK Accounts 
-- Pending approvals behavior
-- EVENT Emitting, however the structure is ready
-- Customer specific changes
-- UI to actually demonstrate this smart contract beautifully

 */

pragma solidity ^0.5.2;
import './openzeppelin-solidity/contracts/math/SafeMath.sol';
contract BankUser {
    using SafeMath for uint;
    using SafeMath for uint8;
    using SafeMath for uint16;
    address payable public owner;
    uint max_withdrawal_allowed = 0.25 ether;


    struct Bank{
        uint8 id;
        string name;
        bool isActive;
        // uint balance; NOT TAKING THIS INTO ACCOUNT currently to avoid complexities
        uint16 uniqueCode;
    }

    struct Customer{
        uint16 id;
        string name;
        mapping (uint16 => Bank) bank;  
        bool isActive;
        uint balance;

    }
    mapping (address => Bank) private Banks;
    mapping (address => Customer) private Customers;
    address[] public BanksAddress;
    address[] private CustomerAddress;

 // Log the event about a deposit being made by an address and its amount
    event newBankAdded(address indexed bankAddr, uint16 uniqueCode);
    event newCustomerAdded(address indexed accountAddress, uint16 id, uint8 bank_name);
    event Transfer(address indexed source, address indexed destination, uint amount);
    event MoneyAdded(address indexed account, uint amount);
    event CustomerStatusChanged(address indexed account, bool oldStatus, bool newStatus);
    event BankStatusChanged(address indexed account,bool oldStatus, bool newStatus);


    constructor() public payable {
        require(msg.value == 1 ether, "Bank Account Balance initial is 5 Ether");
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    modifier onlyBank(){
        // require(Banks[msg.sender].isActive); COMMENTING TO EASE OUT TESTING
        _;
    } 
    modifier customerAuth(address source){
        require(msg.sender == source);
        require(Customers[source].isActive);
        _;
    }  

    modifier notOwner(address A){
        require((A != address(owner)) && (A != address(this)));
        _;
    }
    modifier notExistingBank(address A){
        require(!Banks[A].isActive);
        _;
    }
    modifier notExistingCustomer(address A){
        require(!Customers[A].isActive);
        _;
    }
//@purpose: Adding a new bank
function addBank(address _address, string memory bankName, uint16 uniqueCode) public notOwner(_address)  notExistingCustomer(_address) onlyOwner() returns (bool) {
        require(!Banks[_address].isActive && Banks[_address].uniqueCode != uniqueCode);
        Banks[_address].id += 1;
        Banks[_address].name = bankName;
        Banks[_address].uniqueCode = uniqueCode;
        Banks[_address].isActive = true;

        BanksAddress.push(_address) -1;
        return true;
    }

// @purpose: Adding a  new customer with requisite details
function addCustomer(address _address, string memory name, address _bankAddr) public notOwner(_address) notExistingBank(_address) returns (bool) {
        require(!Customers[_address].isActive);
        // Customer storage cust = Customers[_address];
        Customers[_address].id += 1;
        Customers[_address].name = name;
        Customers[_address].bank[Customers[_address].id] = Banks[_bankAddr];
        Customers[_address].balance = 0;
        Customers[_address].isActive = true;
        CustomerAddress.push(_address) -1;
        return true;
    }  

// @purpose: Add money to account from bank
function addMoney(address accountAddress) public payable /* customerAuth(accountAddress) */ returns (bool) {
        require(accountAddress != address(0), 'address cannot be 0x0');
        require((msg.value > 0), 'Value must be greater than 0');
        require(Customers[accountAddress].isActive, 'Customer is not active');
        Customers[accountAddress].balance += msg.value;
        // owner.transfer(msg.value);
        return true;
    }

//@purpose: getting balance of a customer
function getBalance(address user) view public returns (uint) {
        require(user != address(0));
        require(Customers[user].isActive);
        return Customers[user].balance;
    }


//@purpose: Transfer request from user
function transferTo(address source,address destination, uint amount) public payable customerAuth(source) returns (uint remainingBal) {
        // Check enough balance available, otherwise just return balance
        require(source != address(0) && destination != address(0), 'address cannot be 0x0');
        require(amount <= max_withdrawal_allowed && amount == msg.value);
        require(Customers[destination].isActive && Customers[source].balance >= amount);
        Customers[source].balance -= amount;
        Customers[destination].balance += amount;
        // owner.transfer(msg.value);
        return Customers[source].balance;
    }

//@purpose: getting list of banks addresses     
function getBanks() view public returns(address[] memory) {
        return BanksAddress;
    }

//@purpose: getting details about a bank at a address
function getBank(address _address) view public returns (uint, string memory, uint16, bool) {
        return (Banks[_address].id, Banks[_address].name, Banks[_address].uniqueCode,Banks[_address].isActive);
    }

//@purpose: getting a customer details only callble by bank
function getCustomer(address _address) view public onlyBank() onlyOwner() returns (uint, string memory, string memory, bool, uint) {
        Customer storage c = Customers[_address];
        return (c.id, c.name, c.bank[c.id].name,c.isActive, c.balance);
    }

//@purpose: Check for an existing customer
function isExistingCustomer(address A) view public returns (bool) {
        if(Customers[A].isActive) {
            return true;
            }
        else{
            return false;
            }
    }

//@purpose: Check for an existing bank
function isExistingBank(address A) view public returns (bool) {
        if(Banks[A].isActive) {
            return true;
            }
        else{
            return false;
            }
    }

//@purpose: Check for contract balance
function contractBalance() view internal returns (uint) {
        return address(this).balance;
    }
/**
    Currently only contract owner can change status for a customer and bank
 */
function changeCustomerStatus(address A, bool status) onlyOwner() public returns (bool newStatus) {
        require(A != address(0));
        Customers[A].isActive = status;
        return Customers[A].isActive;
    }

function changeBankStatus(address A, bool status) onlyOwner() public returns (bool newStatus) {
        require(A != address(0));
        Banks[A].isActive = status;
        return Banks[A].isActive;
    }
}