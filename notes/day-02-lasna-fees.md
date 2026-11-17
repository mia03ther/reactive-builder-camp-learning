# Reactive Builder Camp：Lasna 计费笔记

2026-11-17，通过 Lasna RPC 实际读取系统合约 `0x8888888888888888888888888888888888888888`。

```bash
cast call 0x8888888888888888888888888888888888888888 '_gasPriceCoeffPer1000()' --rpc-url https://lasna-rpc.rnk.dev/ | cast to-dec
# 1000

cast call 0x8888888888888888888888888888888888888888 '_extraGas()' --rpc-url https://lasna-rpc.rnk.dev/ | cast to-dec
# 100000

cast call 0x8888888888888888888888888888888888888888 '_maxChargeGas()' --rpc-url https://lasna-rpc.rnk.dev/ | cast to-dec
# 50000
```

1. 一次 `react()` 的费用按 `max(tx.gasprice, block.basefee) × (_gasPriceCoeffPer1000 / 1000) × (实际消耗 gas + _extraGas)` 计算。当前系数为 `1000 / 1000 = 1`，固定附加量为 `100000 gas`。`_maxChargeGas = 50000` 是结算付款时允许使用的 gas 上限，不是费用公式中的额外收费项。实际金额还取决于当次交易的 gas 价格和消耗。

2. `balance` 是 Reactive 合约自己持有、可支配的资金；`reserves` 是预存在系统合约中、用于抵扣执行费的余额；`debt` 是已经产生但未结清的费用。系统在调用 `react()` 前先检查 debt，只要大于零就不执行，避免继续产生无法支付的费用。直接向合约转账只增加 balance，不会自动消除 debt；可通过系统合约的 `depositTo(address)` 为目标合约清债并补充 reserves。

3. `react()` 回滚仍然收费。系统合约会捕获回滚、记录 `ReactiveContractReverted`，然后按已消耗的 gas 结算。因此不该用 `require` 或 `revert` 过滤不相关事件；应在 `react()` 中判断后正常返回。还要尽量减少无谓计算、测试失败路径、准备足够费用，否则反复回滚会耗尽资金，产生 debt 后停止执行。

参考：[Reactive Network 官方 Economy 文档](https://dev.reactive.network/economy)、[官方 Debugging 文档](https://dev.reactive.network/debugging)。
