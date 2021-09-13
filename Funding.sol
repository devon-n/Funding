// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol"; // Import Aggregator contract 
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol"; // Import Safemath contract

contract Funding {
    
    using SafeMathChainlink for uint256;
    uint256 amount;
    address payable public owner;
    address[] public funders; 
    mapping (address => uint256) public addressToAmountFunded;
    
    constructor() public {
        owner = msg.sender; // Initialise the deployer as the owner
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "You are not authorized."); // Modifier for functions only the owner can call
        _;
    }
    
    function fund() public payable { // payable Fund function
        uint256 minimumUSD = 50 * 10 ** 18; // Initialise minimum amoutn as 50 USD
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!"); // Require at least 50 USD
        addressToAmountFunded[msg.sender] += msg.value; // Map the sender to the amount they sent
        funders.push(msg.sender); // Add sender to funders array
    }
    
    function getVersion() public view returns (uint256) { // Function to get version of aggregator
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331); // Init the price feed 
        return priceFeed.version(); // return price feed
    }
    
    function getPrice() public view returns(uint256) { // Get price of eth
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331); // init price feed
            (,int256 answer,,,)  = priceFeed.latestRoundData(); // get the latest price 
        return uint256(answer); // return price
    }
    
    function getConversionRate(uint256 ethAmount) public view returns (uint256) { // Function to get conversion rate 
        uint256 ethPrice = getPrice(); // Call get price function 
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 10000000000; // Convert amount to USD 
        return ethAmountInUsd; // Return USD
    }
    
    function withdraw() payable public onlyOwner { // Function to withdraw eth at contract address // Requires onlyOwner 
        msg.sender.transfer(address(this).balance); // Transfer contracts eth to callers address
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) { // For each funder in funder array 
            address funder = funders[funderIndex]; 
            addressToAmountFunded[funder] = 0; // Set funder amount to 0
        }
        funders = new address[](0);
    }
    
    function viewValue (address _address) public view returns(uint256) { // Function to view funder amounts 
        return addressToAmountFunded[_address]; // return the amount mapped to that address
    }
    
    
}

