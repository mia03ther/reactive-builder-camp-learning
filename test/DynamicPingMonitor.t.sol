// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Test} from "forge-std/Test.sol";
import {IReactive} from "@reactive/src/interfaces/IReactive.sol";
import {DynamicPingMonitor} from "../src/DynamicPingMonitor.sol";

contract DynamicSubscriptionSystem {
    uint256 public subscriptions;
    uint256 public unsubscriptions;

    function subscribe(uint256, address, uint256, uint256, uint256, uint256) external {
        subscriptions++;
    }

    function unsubscribe(uint256, address, uint256, uint256, uint256, uint256) external {
        unsubscriptions++;
    }
}

contract DynamicPingMonitorTest is Test {
    address constant SYSTEM = 0x8888888888888888888888888888888888888888;
    address constant ORIGIN = address(0x1234);
    DynamicPingMonitor monitor;

    function setUp() public {
        DynamicSubscriptionSystem mock = new DynamicSubscriptionSystem();
        vm.etch(SYSTEM, address(mock).code);
        monitor = new DynamicPingMonitor{value: 0.1 ether}(ORIGIN);
    }

    function testKeepThenStopUnsubscribes() public {
        assertEq(DynamicSubscriptionSystem(SYSTEM).subscriptions(), 1);
        vm.startPrank(SYSTEM);
        monitor.react(_ping(1, 11));
        assertEq(monitor.seen(), 1);
        assertTrue(monitor.active());
        assertEq(DynamicSubscriptionSystem(SYSTEM).unsubscriptions(), 0);

        monitor.react(_ping(0, 22));
        assertEq(monitor.seen(), 2);
        assertFalse(monitor.active());
        assertEq(DynamicSubscriptionSystem(SYSTEM).unsubscriptions(), 1);

        monitor.react(_ping(1, 33));
        vm.stopPrank();
        assertEq(monitor.seen(), 2);
        assertEq(DynamicSubscriptionSystem(SYSTEM).unsubscriptions(), 1);
    }

    function testHardCapStopsEvenWithoutSignal() public {
        vm.startPrank(SYSTEM);
        monitor.react(_ping(1, 11));
        monitor.react(_ping(1, 22));
        vm.stopPrank();
        assertFalse(monitor.active());
        assertEq(DynamicSubscriptionSystem(SYSTEM).unsubscriptions(), 1);
    }

    function testOnlySystemAndUnrelatedLogIgnored() public {
        IReactive.LogRecord memory direct = _ping(1, 11);
        vm.expectRevert();
        monitor.react(direct);

        IReactive.LogRecord memory wrong = _ping(1, 22);
        wrong.contractAddress = address(0x5678);
        vm.prank(SYSTEM);
        monitor.react(wrong);
        assertEq(monitor.seen(), 0);
    }

    function _ping(uint256 value, uint256 txHash) internal view returns (IReactive.LogRecord memory) {
        return IReactive.LogRecord({
            chainId: 11155111,
            contractAddress: ORIGIN,
            topic0: monitor.PING_TOPIC_0(),
            topic1: uint256(uint160(address(this))),
            topic2: 0,
            topic3: 0,
            data: abi.encode(value),
            blockNumber: 1,
            opCode: 3,
            blockHash: 10,
            txHash: txHash,
            logIndex: 0
        });
    }
}
