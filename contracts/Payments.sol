// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

contract Payments{
    struct Payment{
        uint amount;
        uint timestamp;
        address from;
        string message;
    }

    struct Balance{
        uint totalPayments;
        mapping(uint => Payment) paymentsList;
    }

    mapping (address => Balance) public balancesList;
    
    constructor(){

    }

    function getPayment(address _addr, uint _index) public view returns(Payment memory) {
        return balancesList[_addr].paymentsList[_index];
    }

    function getCurrentBalance() public view returns(uint){
        return address(this).balance;
    }

    function pay(string memory message) public payable{
        uint paymentNum = balancesList[msg.sender].totalPayments;
        balancesList[msg.sender].totalPayments++;

        Payment memory newPayment = Payment(
            msg.value,
            block.timestamp,
            msg.sender,
            message
        );

        balancesList[msg.sender].paymentsList[paymentNum] = newPayment;
    }


}