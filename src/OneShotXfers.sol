// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IReactive} from "@reactive/src/interfaces/IReactive.sol";
import {AbstractReactive} from "@reactive/src/base/AbstractReactive.sol";

/// @notice D3 exercise: count one Sepolia ERC-20 Transfer, then unsubscribe.
contract OneShotXfers is AbstractReactive {
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant TRANSFER_TOPIC_0 =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

    event TransferSeen(address indexed token, uint256 indexed sourceTxHash, uint256 amount);

    uint256 public remaining;
    uint256 public lastSourceTxHash;
    uint256 public lastReactBlock;

    constructor(uint256 limit_) payable {
        require(limit_ > 0, "zero limit");
        require(msg.value > 0, "fund at deployment");
        remaining = limit_;
        SYSTEM.subscribe(
            SEPOLIA_CHAIN_ID,
            address(0),
            TRANSFER_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
    }

    /// @inheritdoc IReactive
    function react(LogRecord calldata log_) external onlySystem {
        if (
            log_.chainId != SEPOLIA_CHAIN_ID ||
            log_.topic0 != TRANSFER_TOPIC_0 ||
            log_.opCode != 3 ||
            log_.data.length != 32 ||
            remaining == 0
        ) return;

        uint256 amount = abi.decode(log_.data, (uint256));
        lastSourceTxHash = log_.txHash;
        lastReactBlock = block.number;
        emit TransferSeen(log_.contractAddress, log_.txHash, amount);

        remaining -= 1;
        if (remaining == 0) {
            SYSTEM.unsubscribe(
                SEPOLIA_CHAIN_ID,
                address(0),
                TRANSFER_TOPIC_0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
    }
}
