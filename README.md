# Reactive Builder Camp｜MIA_Ether 的学习仓库

记录 Reactive Network Omni 版的共学笔记、测试网验证和后续项目实践。当前以 **Ethereum Sepolia → Lasna → Ethereum Sepolia** 的事件驱动自动化为学习路线。

## 学习进度

| 阶段 | 内容 | 状态 |
| --- | --- | --- |
| 第 0 周 | [环境准备：测试钱包、lREACT、Foundry](notes/day-00-environment.md) | Lasna 余额已验证；模板 `forge test` 8/8 通过 |
| D1 · 11/16 | [用例拆解卡：测试钱包大额转账监控](notes/d1-use-case.md) | 方案已写，合约地址待部署后补充 |
| D2 · 11/17 | [用 `cast` 读取 Lasna 费用参数](notes/day-02-lasna-fees.md) | 三个链上参数已实测 |
| D3 · 11/18 | [第一次 Reactive 部署](notes/d3-first-reactive.md) | Lasna 合约与 `react()` 交易已验证 |

## 当前项目设想

监听 Sepolia 上测试 ERC-20 的 `Transfer` 事件；当测试钱包单笔转出达到阈值时，Lasna 上的 Reactive 合约判断并请求回调，让 Sepolia 的记录合约发出告警事件。[详细流程与简图](notes/d1-use-case.md)在 D1 卡片中。这是待实现的设计，尚无已部署合约或跨链回调交易。

## 参考资料

- [Reactive Contracts](https://dev.reactive.network/reactive-contracts)
- [Callback Contracts](https://dev.reactive.network/callback-contracts)
- [Economy](https://dev.reactive.network/economy)
- [Omni micro-demos](https://github.com/Reactive-Network/reactive-smart-contract-demos/tree/omni/src/micro-demos)

练习仅使用测试网和测试资产。仓库不保存私钥、助记词或钱包签名凭据。
