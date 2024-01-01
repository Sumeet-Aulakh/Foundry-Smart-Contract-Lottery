//SPDX-License-Idnetifier: MIT

pragma solidity ^0.8.18;

import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    /** State Variables  */

    Raffle raffle;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public STARTING_USER_BALANCE = 10 ether;

    /** Events */

    event EnteredRaffle(address indexed player);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        ) = helperConfig.activeNetworkConfig();
    }

    function testRaffleInitilizesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    /////////////////
    // enterRaffle //
    /////////////////

    function testRaffleFailsWhenNotEnoughEthIsNotProvided() public {
        //Arrange
        vm.prank(PLAYER);
        //Act n Assert
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSend.selector);
        raffle.enterRaffle{value: 0}(); // Explicity Sending 0 ETH
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        raffle.enterRaffle{value: entranceFee}();
        //Assert
        assert(raffle.getPlayer(0) == address(PLAYER));
    }

    function testEmitsEventOnEntrance() public {
        // Arrance
        vm.prank(PLAYER);
        // Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(address(PLAYER));
        // Assert
        raffle.enterRaffle{value: entranceFee}();
    }

    // vm.warp is to set block time
    // vm.roll is to set block number

    function testCantEnterRaffleWhenCalculating() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");
        // Assert
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }
}
