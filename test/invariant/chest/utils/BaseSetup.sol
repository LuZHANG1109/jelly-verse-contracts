// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ChestHandler} from "./ChestHandler.sol";
import {Chest} from "../../../../contracts/Chest.sol";
import {ERC20Token} from "../../../../contracts/test/ERC20Token.sol";

contract BaseSetup is Test {
    uint256 constant JELLY_MAX_SUPPLY = 1_000_000_000 ether;

    uint32 constant MAX_FREEZING_PERIOD_REGULAR_CHEST = 3 * 365 days;
    uint32 constant MAX_FREEZING_PERIOD_SPECIAL_CHEST = 5 * 365 days;
    uint32 constant MIN_FREEZING_PERIOD_REGULAR_CHEST = 7 days;

    uint64 private constant DECIMALS = 1e18;
    uint64 private constant INITIAL_BOOSTER = 1 * DECIMALS;

    uint256 positionIndex;
    address ownerOfChest;

    address allocator = makeAddr("allocator");
    address distributor = makeAddr("distributor");
    address testAddress = makeAddr("testAddress");
    address approvedAddress = makeAddr("approvedAddress");
    address nonApprovedAddress = makeAddr("nonApprovedAddress");
    address transferRecipientAddress = makeAddr("transferRecipientAddress");
    address beneficiary = makeAddr("beneficiary");

    Chest public chest;
    ERC20Token public jellyToken;
    ChestHandler public chestHandler;

    function setUp() public virtual {
        uint256 fee = 10;
        uint128 maxBooster = 2e18;
        address owner = msg.sender;
        address pendingOwner = testAddress;
        uint32 timeFactor = 7 days;

        jellyToken = new ERC20Token("Jelly", "JELLY");
        chest = new Chest(
            address(jellyToken),
            allocator,
            distributor,
            fee,
            maxBooster,
            timeFactor,
            owner,
            pendingOwner
        );
        chestHandler = new ChestHandler(
            beneficiary,
            chest,
            jellyToken,
            allocator,
            distributor
        );

        excludeContract(address(jellyToken));
        excludeContract(address(chest));

        vm.prank(allocator);
        jellyToken.mint(1000);

        vm.prank(distributor);
        jellyToken.mint(1000);

        vm.prank(testAddress);
        jellyToken.mint(1000);

        vm.prank(approvedAddress);
        jellyToken.mint(1000);

        // @dev open regular positions so handler has always position to work with
        uint256 amount = 100;
        uint32 freezingPeriod = MIN_FREEZING_PERIOD_REGULAR_CHEST;

        vm.startPrank(testAddress);
        jellyToken.approve(address(chest), amount + chest.fee());
        chest.stake(amount, testAddress, freezingPeriod);

        positionIndex = chest.totalSupply() - 1;
        ownerOfChest = chest.ownerOf(positionIndex);
        vm.stopPrank();
    }
}