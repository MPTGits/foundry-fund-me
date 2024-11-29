// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("USER");
    uint constant SEND_VALUE = 0.1 ether;
    uint8 constant GAS_PRICE = 10;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 100 ether);
    }

    function testMinDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSameAsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIs4() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWhenNotEnoughETHIsSent() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStrucures() public funded {
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        assertEq(fundMe.getFunder(0), USER);
    }

    function testWithdrawsRevertsWhenUserIsNotOwner() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testWithdrawsWorksWhenUserIsOwner() public funded {
        vm.txGasPrice(GAS_PRICE);
        uint256 startingBalance = fundMe.getOwner().balance;
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        assertEq(fundMe.getAddressToAmountFunded(USER), 0);
        assertEq(fundMe.getOwner().balance, startingBalance + SEND_VALUE);
    }

    function testWithdrawsCheaperWorksWhenUserIsOwner() public funded {
        vm.txGasPrice(GAS_PRICE);
        uint256 startingBalance = fundMe.getOwner().balance;
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        assertEq(fundMe.getAddressToAmountFunded(USER), 0);
        assertEq(fundMe.getOwner().balance, startingBalance + SEND_VALUE);
    }
}
