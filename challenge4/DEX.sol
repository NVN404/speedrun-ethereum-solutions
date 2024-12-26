// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DEX Template
 * @author stevepham.eth and m00npapi.eth
 * @notice Empty DEX.sol that just outlines what features could be part of the challenge (up to you!)
 * @dev We want to create an automatic market where our contract will hold reserves of both ETH and 🎈 Balloons. These reserves will provide liquidity that allows anyone to swap between the assets.
 * NOTE: functions outlined here are what work with the front end of this challenge. Also return variable names need to be specified exactly may be referenced (It may be helpful to cross reference with front-end code function calls).
 */
contract DEX {
	/* ========== GLOBAL VARIABLES ========== */

	IERC20 token; //instantiates the imported contract
	//initiate the global variables below
	uint256 public totalLiquidity;
    mapping (address => uint256) public liquidity;

	/* ========== EVENTS ========== */
	// events are iniiated to keep track of the transactions and the changes in the contract

	/**
	 * @notice Emitted when ethToToken() swap transacted
	 */
	event EthToTokenSwap(
		address swapper,
		uint256 tokenOutput,
		uint256 ethInput
	);

	/**
	 * @notice Emitted when tokenToEth() swap transacted
	 */
	event TokenToEthSwap(
		address swapper,
		uint256 tokensInput,
		uint256 ethOutput
	);

	/**
	 * @notice Emitted when liquidity provided to DEX and mints LPTs.
	 */
	event LiquidityProvided(
		address liquidityProvider,
		uint256 liquidityMinted,
		uint256 ethInput,
		uint256 tokensInput
	);

	/**
	 * @notice Emitted when liquidity removed from DEX and decreases LPT count within DEX.
	 */
	event LiquidityRemoved(
		address liquidityRemover,
		uint256 liquidityWithdrawn,
		uint256 tokensOutput,
		uint256 ethOutput
	);

	/* ========== CONSTRUCTOR ========== */

	constructor(address tokenAddr) {
		token = IERC20(tokenAddr); //specifies the token address that will hook into the interface and be used through the variable 'token'
	}

	/* ========== MUTATIVE FUNCTIONS ========== */

	/**
	 * @notice initializes amount of tokens that will be transferred to the DEX itself from the erc20 contract mintee (and only them based on how Balloons.sol is written). Loads contract up with both ETH and Balloons.
	 * @param tokens amount to be transferred to DEX
	 * @return totalLiquidity is the number of LPTs minting as a result of deposits made to DEX contract
	 * NOTE: since ratio is 1:1, this is fine to initialize the totalLiquidity (wrt to balloons) as equal to eth balance of contract.
	 */
	function init(uint256 tokens) public payable returns (uint256) {
		// Question One
        // How can we check and prevent liquidity being added if the contract already has liquidity?
		require(totalLiquidity==0, "DEX: Liquidity already initialized");
		// 		Question Two
		// What should the value of totalLiquidity be, how do we access the balance that our contract has and assign the variable a value?
		totalLiquidity = address(this).balance;
		// 		Question Three
		// How would we assign our address the liquidity we just provided? How much liquidity have we provided? The totalLiquidity? Just half? Three quarters?
		liquidity[msg.sender] = totalLiquidity;
		// Question Four
		// Now we need to take care of the tokens init() is receiving. How do we transfer the tokens from the sender (us) to this contract address? How do we make sure the transaction reverts if the sender did not have as many tokens as they wanted to send?
		require(token.transferFrom(msg.sender, address(this), tokens), "DEX: Token transfer failed");
		return totalLiquidity;
	}

	/**
	 * @notice returns yOutput, or yDelta for xInput (or xDelta)
	 * @dev Follow along with the [original tutorial](https://medium.com/@austin_48503/%EF%B8%8F-minimum-viable-exchange-d84f30bd0c90) Price section for an understanding of the DEX's pricing model and for a price function to add to your contract. You may need to update the Solidity syntax (e.g. use + instead of .add, * instead of .mul, etc). Deploy when you are done.
	 */
	function price(
		uint256 xInput,
		uint256 xReserves,
		uint256 yReserves
	) public pure returns (uint256 yOutput) {
		// we cant use decimals so it is used as 997/1000 * input . instead of using 3% that is 0.03 fee.
		// refer the mathemetical section in the speedrun challenge 4 website to understand better with examples
		uint256 xInputWithFee = xInput * 997;
        uint256 numerator = xInputWithFee * yReserves;
        uint256 denominator = (xReserves * 1000) + xInputWithFee;
        return (numerator / denominator);
	}

	/**
	 * @notice returns liquidity for a user.
	 * NOTE: this is not needed typically due to the `liquidity()` mapping variable being public and having a getter as a result. This is left though as it is used within the front end code (App.jsx).
	 * NOTE: if you are using a mapping liquidity, then you can use `return liquidity[lp]` to get the liquidity for a user.
	 * NOTE: if you will be submitting the challenge make sure to implement this function as it is used in the tests.
	 */
	function getLiquidity(address lp) public view returns (uint256) {
		return liquidity[lp];

	}

	/**
	 * @notice sends Ether to DEX in exchange for $BAL
	 */
	function ethToToken() public payable returns (uint256 tokenOutput) {
		//		Question One
		// How would we make sure the value being swapped for balloons is greater than 0?
		require(msg.value>0, "DEX: Value must be greater than 0");
		// Is xReserves ETH or $BAL tokens? Use a variable name that best describes which one it is. When we call this function, it will already have the value we sent it in it's liquidity. How can we make sure we are using the balance of the contract before any ETH was sent to it?
		uint256 ethReserves = address(this).balance - msg.value;
		// 		Question Three
		// For yReserves we will also want to create a new more descriptive variable name. How do we find the other asset balance this address has?
		uint256 tokenReserves = token.balanceOf(address(this));
		// 		Question Four
		//Now that we have all our arguments, how do we call price() and store the returned value in a new variable? What kind of name would best describe this variable?	
		uint256 tokenOutput = price(msg.value, ethReserves, tokenReserves);
		// 		Question Five
		// After getting how many tokens the sender should receive, how do we transfer those tokens to the sender?
		require(token.transfer(msg.sender, tokenOutput), "DEX: Token transfer failed");
		// 		Question Six
		// Which event should we emit for this function?
		emit EthToTokenSwap(msg.sender, tokenOutput, msg.value);
		// 		Question Seven
		// Last, what do we return?
		return tokenOutput;// why? what is the purpose of this return?
			}

	/**
	 * @notice sends $BAL tokens to DEX in exchange for Ether
	 */
	function tokenToEth(
		uint256 tokenInput
	) public returns (uint256 ethOutput) {
		//same as eth to token
		  require(tokenInput > 0, "cannot swap 0 tokens");
        uint256 tokenReserve = token.balanceOf(address(this));
        ethOutput = price(tokenInput, tokenReserve, address(this).balance);
        require(token.transferFrom(msg.sender, address(this), tokenInput), "tokenToEth(): reverted swap.");
		// this line is used to recieve token from the user and transfer it to the contract address
        (bool sent, ) = msg.sender.call{ value: ethOutput }("");
		//The call function sends Ether to the recipient.
        require(sent, "tokenToEth: revert in transferring eth to you!");
		//checks whether the transaction has happened or not 
        emit TokenToEthSwap(msg.sender, tokenInput, ethOutput);
        return ethOutput;
	}

	/**
	 * @notice allows deposits of $BAL and $ETH to liquidity pool
	 * NOTE: parameter is the msg.value sent with this function call. That amount is used to determine the amount of $BAL needed as well and taken from the depositor.
	 * NOTE: user has to make sure to give DEX approval to spend their tokens on their behalf by calling approve function prior to this function call.
	 * NOTE: Equal parts of both assets will be removed from the user's wallet with respect to the price outlined by the AMM.
	 */
	function deposit() public payable returns (uint256 tokensDeposited) {
		require(msg.value > 0, "Must send value when depositing");
		//first through payable we send eth that is added 
		// -msg.value bcoz we are sent eth to the contract so we need to subtract it from the balance to get the existing balance
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 tokenDeposit;

        tokenDeposit = (msg.value * tokenReserve / ethReserve) + 1;
		//formula to calculate the amount of tokens to be deposited +1 to do ceiling division not to truncate the value
		// the thing is the user have to deposit both eth and token in equal value 1:1 ratio 
       

        uint256 liquidityMinted = msg.value * totalLiquidity / ethReserve;
		//update the calulation of liquidity minted to the actual liquidity 
        liquidity[msg.sender] += liquidityMinted;
        totalLiquidity += liquidityMinted;
		//liquidity and total liquidity is global variables that should be updated after each deposit

        require(token.transferFrom(msg.sender, address(this), tokenDeposit));
        emit LiquidityProvided(msg.sender, liquidityMinted, msg.value, tokenDeposit);
        return tokenDeposit;
	}

	/**
	 * @notice allows withdrawal of $BAL and $ETH from liquidity pool
	 * NOTE: with this current code, the msg caller could end up getting very little back if the liquidity is super low in the pool. I guess they could see that with the UI.
	 */
	function withdraw(
		uint256 amount
	) public returns (uint256 ethAmount, uint256 tokenAmount) {
		require(liquidity[msg.sender] >= amount, "withdraw: sender does not have enough liquidity to withdraw.");
        uint256 ethReserve = address(this).balance;
        uint256 tokenReserve = token.balanceOf(address(this));
		//store the balances of eth and token in the contract in the above variables
        uint256 ethWithdrawn; // initialize ethWithdrawn

        ethWithdrawn = amount * ethReserve / totalLiquidity;
		// amount is multiplied with the eth reserve and divided by the total liquidity to get the eth withdrawn bcoz it also contains the profits of the 
		//transaction of the users liquidity pool
        uint256 tokenAmount = amount * tokenReserve / totalLiquidity;
        liquidity[msg.sender] -= amount;
        totalLiquidity -= amount;
		//updating the liquidity and total liquidity after the withdrawal
        (bool sent, ) = payable(msg.sender).call{ value: ethWithdrawn }("");
		// the above line is to send eth to the user
        require(sent, "withdraw(): revert in transferring eth to you!");
		//check whether the transaction has happened or not ^
        require(token.transfer(msg.sender, tokenAmount));
		// the above line is to send token to the user 
        emit LiquidityRemoved(msg.sender, amount, tokenAmount, ethWithdrawn);
        return (ethWithdrawn, tokenAmount);
	}
}
