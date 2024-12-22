 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract; 
    //is a declaration of a variable that references another contract.
    uint256 public constant threshold = 1 ether;
    // set the threshold 
    uint256 public deadline;
    bool public openForWithdraw;

    mapping(address => uint256) public balances;
    // mapping - connects the addresses with thier respective balance in the contract

    constructor(address _exampleExternalContract) {
        //_exampleExternalContract is a state variable to access across this contract
        exampleExternalContract = ExampleExternalContract(_exampleExternalContract); 
        // basically left variable communicates with the external contract by passing this contract's state variable to the ext. contract 
        deadline = block.timestamp + 30 seconds; 
        //set the deadline of the staking app
    }

    function stake() public payable {
        require(block.timestamp < deadline, "Stake period has ended");
        //block.timestamp is a builtin var hold the time value of the block mined
        require(msg.value > 0, "Must send some ETH to stake"); 
        balances[msg.sender] += msg.value;//update balance
        emit Stake(msg.sender, msg.value);
        //this above line emits the data of the sender and his balance to everyone
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    function execute() external {
        require(block.timestamp >= deadline, "Deadline has not passed");
        require(!openForWithdraw, "Already in withdraw state");

        if (address(this).balance >= threshold) {
            // Call the complete() function of the external contract
            (bool success, ) = address(exampleExternalContract).call{value: address(this).balance}(
                abi.encodeWithSignature("complete()")
                //Low-level functions like .call require manually encoded data to specify the complete function of ext. contract
            );
            require(success, "External contract call failed"); 
            // so overall if balance is more than threshold it will send the external contract success 
            //or else it reverts and sets withdraw true
        } else {
            openForWithdraw = true;
        }
    }

    function withdraw() external {
        require(openForWithdraw, "Withdrawals are not allowed yet");
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");

        balances[msg.sender] = 0;
        // after withdrawing set the sender balance to 0
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        // call is done without sending any data so this is empty ("")
        require(success, "Transfer failed"); // Check for success
    }

    event Stake(address indexed user, uint256 amount);

    receive() external payable {
        stake();
    }

    fallback() external payable {
        stake();
    }

    // these lines prevents losing of eth in this contract if anyone send eth to this contract , the transaction wont be missed
}
