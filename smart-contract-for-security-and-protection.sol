// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecurityContract {
    address public owner;
    uint256 public withdrawalLimit;
    mapping(address => bool) public authorizedUsers;

    event FundsDeposited(address indexed depositor, uint256 amount);
    event FundsWithdrawn(address indexed beneficiary, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyAuthorized() {
        require(authorizedUsers[msg.sender], "You are not authorized to call this function");
        _;
    }

    constructor(uint256 _withdrawalLimit) {
        owner = msg.sender;
        withdrawalLimit = _withdrawalLimit;
        authorizedUsers[owner] = true;
    }

    function depositFunds() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }

    function withdrawFunds(address payable _beneficiary, uint256 _amount) external onlyOwner {
        require(_amount <= withdrawalLimit, "Withdrawal amount exceeds the limit");
        require(address(this).balance >= _amount, "Insufficient funds in the contract");

        _beneficiary.transfer(_amount);
        emit FundsWithdrawn(_beneficiary, _amount);
    }

    function grantAccess(address _user) external onlyOwner {
        authorizedUsers[_user] = true;
    }

    function revokeAccess(address _user) external onlyOwner {
        authorizedUsers[_user] = false;
    }

    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }
}
