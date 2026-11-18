# D3：第一次部署（准备中）

监控合约：[OneShotXfers.sol](../src/OneShotXfers.sol)。它采用 Omni 写法，参考 [Xfers micro-demo](https://github.com/Reactive-Network/reactive-smart-contract-demos/tree/omni/src/micro-demos/Xfers.sol)。

订阅过滤条件：**Ethereum Sepolia（chainId 11155111）上任意合约发出的 `Transfer(address,address,uint256)` 事件**。合约地址使用 `address(0)` 通配；不关心的 topic 使用 `REACTIVE_IGNORE`。`react()` 只接受系统合约调用，只处理 `LOG3` 且有一个 32 字节金额的事件；最多处理 1 次，随后自动取消订阅。该合约只记录事件，不请求跨链回调。

本地验证：`forge test`，3 passed、0 failed。当前还没有部署地址或 `react()` 交易链接；链上部署后补齐。

部署时使用共学专用测试钱包，在 Lasna 支付 gas 并给构造函数附带少量 lREACT。私钥和助记词不写入命令行参数、仓库或本笔记；签名由钱包持有人在本地完成。
