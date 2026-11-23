// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IReactive} from "@reactive/src/interfaces/IReactive.sol";
import {AbstractReactive} from "@reactive/src/base/AbstractReactive.sol";

/// @notice Camp dynamic-subscription experiment: Ping(0) stops monitoring.
contract DynamicPingMonitor is AbstractReactive {
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant PING_TOPIC_0 =
        0xfd8d0c1dc3ab254ec49463a1192bb2423b3b851adedec1aa94dcd362dc063c9d;
    uint256 public constant MAX_EVENTS = 2;

    address public immutable ORIGIN;
    uint256 public seen;
    bool public active = true;

    event PingSeen(uint256 indexed sourceTxHash, uint256 value, uint256 count);
    event MonitoringStopped(uint256 indexed sourceTxHash, uint256 count);

    constructor(address origin_) payable {
        require(origin_ != address(0), "zero origin");
        require(msg.value > 0, "fund at deployment");
        ORIGIN = origin_;
        SYSTEM.subscribe(
            SEPOLIA_CHAIN_ID, origin_, PING_TOPIC_0,
            REACTIVE_IGNORE, REACTIVE_IGNORE, REACTIVE_IGNORE
        );
    }

    /// @inheritdoc IReactive
    function react(LogRecord calldata log_) external onlySystem {
        if (!active || log_.chainId != SEPOLIA_CHAIN_ID ||
            log_.contractAddress != ORIGIN || log_.topic0 != PING_TOPIC_0 ||
            log_.opCode != 3 || log_.data.length != 32) return;

        uint256 value = abi.decode(log_.data, (uint256));
        seen += 1;
        emit PingSeen(log_.txHash, value, seen);

        // A stop signal or the hard cap cancels the exact subscription.
        if (value == 0 || seen >= MAX_EVENTS) {
            active = false;
            SYSTEM.unsubscribe(
                SEPOLIA_CHAIN_ID, ORIGIN, PING_TOPIC_0,
                REACTIVE_IGNORE, REACTIVE_IGNORE, REACTIVE_IGNORE
            );
            emit MonitoringStopped(log_.txHash, seen);
        }
    }
}
