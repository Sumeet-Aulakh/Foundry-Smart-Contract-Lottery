// Layout of Contract
// version
// imports
// errors
// interfaces, libraries, contracts
// type declarations
// state variables
// events
// modifiers
// function

// Layout of Function
// contructor
//  receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view and pure functions

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title A Sample Raffle Contract
 * @author Sumeet Singh Aulakh
 * @notice This Contract is for creating a sample raffle.
 * @dev Implements Chainlink VRFv2
 */
contract Raffle {
    error Raffle__NotEnoughEthSend();

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    /** Events */
    event EnteredRaffle(address indexed player);

    /** Functions */

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, "Not enough ETH sent");
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSend();
        }
        s_players.push(payable(msg.sender));
        // 1. Makes Migration easier
        // 2. Make front-end "indexing" easier
        emit EnteredRaffle(msg.sender);
    }

    // 1. Get a random number
    // 2. Use random number to pick a winner
    // 3. Be automatically called
    function pickWinner() public {
        // Check to see if enough time has passed
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
        // Random Number: From VRFv2
    }

    /** Getter Functions */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
