# D3：第一次 Reactive 部署（已完成）

监控合约：[OneShotXfers.sol](../src/OneShotXfers.sol)。它采用 Omni 写法，参考 [Xfers micro-demo](https://github.com/Reactive-Network/reactive-smart-contract-demos/tree/omni/src/micro-demos/Xfers.sol)。

订阅过滤条件：**Ethereum Sepolia（chainId 11155111）上任意合约发出的 `Transfer(address,address,uint256)` 事件**。合约地址使用 `address(0)` 通配；不关心的 topic 使用 `REACTIVE_IGNORE`。`react()` 只接受系统合约调用，只处理 `LOG3` 且有一个 32 字节金额的事件；最多处理 1 次，随后自动取消订阅。该合约只记录事件，不请求跨链回调。

本地验证：`forge test`，3 passed、0 failed。

## Lasna 链上证明

- [合约地址：OneShotXfers](https://lasna.reactscan.net/address/0x77728ac3bc5b1eb9712f374d10ca3e449eacc3fa)
- [部署交易](https://lasna.reactscan.net/tx/0xcc30e8432315b2fdd38335289282da53769bc94d22a1f3925cdae27cd90a6f37e)：成功；构造函数附带 `0.1 lREACT` 并完成订阅。
- [`react()` 执行交易](https://lasna.reactscan.net/tx/0x0146ed35880eb07c33c00c75e1bc5b26cc20c51a08815a52016bc7516da0bfc3)：成功；区块 `8620823`，发出 `TransferSeen`。
- 链上读取 `lastReactBlock() = 8620823`、`remaining() = 0`，说明至少处理过一次并达到自动退订上限。

提交时的一句话：**订阅 Ethereum Sepolia 上任意合约的 ERC-20 `Transfer` 事件（topic0 精确匹配，其余 topic 用 `REACTIVE_IGNORE`），只处理 `LOG3` 且金额数据为 32 字节的事件，处理一次后自动退订。**

部署使用共学专用测试钱包，在 Lasna 支付 gas，构造函数附带 `0.1 lREACT`。签名由钱包持有人通过浏览器钱包批准，私钥和助记词没有写入命令行参数、仓库或本笔记。
