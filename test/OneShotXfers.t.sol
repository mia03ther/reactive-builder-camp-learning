// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Test} from "forge-std/Test.sol";
import {IReactive} from "@reactive/src/interfaces/IReactive.sol";
import {OneShotXfers} from "../src/OneShotXfers.sol";

contract MockSystem {
    uint256 public subscriptions;
    uint256 public unsubscriptions;

    function subscribe(uint256, address, uint256, uint256, uint256, uint256) external {
        subscriptions++;
    }

    function unsubscribe(uint256, address, uint256, uint256, uint256, uint256) external {
        unsubscriptions++;
    }
}

contract OneShotXfersTest is Test {
    address constant SYSTEM = 0x8888888888888888888888888888888888888888;
    OneShotXfers monitor;

    function setUp() public {
        MockSystem mock = new MockSystem();
        vm.etch(SYSTEM, address(mock).code);
        monitor = new OneShotXfers{value: 0.1 ether}(1);
    }

    function testSubscribesAndUnsubscribesAfterOneTransfer() public {
        assertEq(MockSystem(SYSTEM).subscriptions(), 1);
        IReactive.LogRecord memory log_ = IReactive.LogRecord({
            chainId: 11155111,
            contractAddress: address(0x1234),
            topic0: monitor.TRANSFER_TOPIC_0(),
            topic1: uint256(uint160(address(0xA))),
            topic2: uint256(uint160(address(0xB))),
            topic3: 0,
            data: abi.encode(uint256(100)),
            blockNumber: 1,
            opCode: 3,
            blockHash: 11,
            txHash: 22,
            logIndex: 0
        });
        vm.prank(SYSTEM);
        monitor.react(log_);
        assertEq(monitor.remaining(), 0);
        assertEq(monitor.lastSourceTxHash(), 22);
        assertEq(MockSystem(SYSTEM).unsubscriptions(), 1);
    }

    function testRejectsCallerOtherThanSystem() public {
        IReactive.LogRecord memory empty;
        vm.expectRevert();
        monitor.react(empty);
    }

    function testUnrelatedLogReturnsWithoutCounting() public {
        IReactive.LogRecord memory empty;
        vm.prank(SYSTEM);
        monitor.react(empty);
        assertEq(monitor.remaining(), 1);
        assertEq(MockSystem(SYSTEM).unsubscriptions(), 0);
    }
}
