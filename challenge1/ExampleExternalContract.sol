// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ExampleExternalContract {
    bool public completed; // Tracks if the contract is completed

    // This function marks the contract as complete and accepts ETH
    function complete() external payable {
        require(!completed, "Already completed");
        //require(condition, errorMessage) syntax of require , if condition is not true display error
        // if it is true go to next line
        completed = true;
    }

    // Function to check if the contract has been completed
    function isCompleted() external view returns (bool) {
        //function -keyword , iscompleted-function name , external-contract visibility it is external 
        // view - read only permission , returns bool - datatype return in boolean
        return completed;
    }
}
