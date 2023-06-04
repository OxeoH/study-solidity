// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract ModStudy{
    address owner;

    constructor(){
        owner = msg.sender;
    }

    event Paid(address indexed _from, uint _amount, uint _timestamp);

    modifier isOwner(address _to){
        require(msg.sender == owner, "Error: You are not an Owner!");
        require(_to != address(0), "Error: Address cannot be 0");
        _;
    }

    receive() external payable{
        pay();
    }

    function pay() public payable {
        require(msg.value > 0, "Error: transaction value cannot be 0!");
        emit Paid(msg.sender, msg.value, block.timestamp);
    }

    function withdraw(address payable _to) external isOwner(_to){
        //require(msg.sender == owner, "Error: You are not an Owner!");
        _to.transfer(address(this).balance);
    }
}