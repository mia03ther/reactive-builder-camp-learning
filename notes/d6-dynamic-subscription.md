# 场景小实验｜动态订阅：停止事件触发退订

选择 **B 动态订阅**。在 Ethereum Sepolia 的 `CampOrigin` 发出 `Ping(uint256)`；Lasna 上的 `DynamicPingMonitor` 在构造时订阅该源合约的事件。`Ping(1)` 只计数，`Ping(0)` 是停止信号，收到后在 `react()` 中调用 `SYSTEM.unsubscribe()`。

## 合约

- [Lasna `DynamicPingMonitor`：`0x3Dd2785B6Daf12909D9037621060055a0B816AC0`](https://lasna.reactscan.net/address/0x3dd2785b6daf12909d9037621060055a0b816ac0)
- [Sepolia `CampOrigin`：`0x0Bc1351934dA6Ab4b035220C7216af79F637730a`](https://sepolia.etherscan.io/address/0x0Bc1351934dA6Ab4b035220C7216af79F637730a)
- [合约源码](../src/DynamicPingMonitor.sol)与[测试](../test/DynamicPingMonitor.t.sol)

## 两次触发证据

1. 第一次 `Ping(1)`：[Sepolia 源链交易](https://sepolia.etherscan.io/tx/0x8f63e9d714e982b7f0d5a2470b1bad4efb89b651974bff6511b1af8e876b767a) → [Lasna `react()` 交易](https://lasna.reactscan.net/tx/0xe3b2510bbecf008406d0413cb8557038bbb27077be6827db85b1760e4339b85c)。`PingSeen` 记录源链哈希、`value=1`、`count=1`；合约保持 `active=true`。
2. 第二次 `Ping(0)`：[Sepolia 源链交易](https://sepolia.etherscan.io/tx/0x1328a5b9bb939df9db2bae029cf93bf866689620ebbd817bc2e4e129a7899d2e) → [Lasna `react()` 交易](https://lasna.reactscan.net/tx/0x56e09bd9deceb3af681188814fe1ad0675bf2a3f02328c0242ef96b325a88533)。同一笔 Lasna 交易包含 `PingSeen(value=0,count=2)`、系统退订和 `MonitoringStopped(count=2)`；随后 `active=false`。

## 如何防止无限执行或耗尽余额

订阅只匹配 **Sepolia 上这个源合约的 `Ping` 事件**，不监听全链所有日志。收到 `Ping(0)` 立即退订；即使没有停止信号，累计处理 **2 次**也自动退订。`react()` 有 `onlySystem`，无关日志正常 `return`，避免因过滤而回滚收费。部署时预存 0.06 lREACT；实验结束后合约余额约 0.0333 lREACT，`debt=0`。退订后不再为这个订阅产生后续执行费。

## 调试记录

最初版本误把 `Ping` 的 topic 数写成 3，导致第一笔通知被过滤但仍收费。`Ping(address indexed who,uint256 value)` 的实际 topic 数是 **2**（签名和一个 indexed 参数）。已修正代码、增加 topic 数测试，并用新的源合约与监控合约完成以上两次有效触发；不要把旧合约 `0x406558720EF6d8bEa31C6aB7c1131E5406Bc2a2e` 当作本实验提交证据。
