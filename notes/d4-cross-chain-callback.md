# D4｜跨链回调三步走（Ethereum Sepolia → Lasna → Ethereum Sepolia）

使用共学营模板 `starter/` 中的 `CampOrigin`、`CampReactive`、`CampCallback` 完成测试网链路。源链与目标链均为 Ethereum Sepolia（chain ID 11155111），Reactive 侧为 Lasna（chain ID 5318007）。

## 合约地址

- 源链 `CampOrigin`：[`0x175b1Ff50cd871698a9a96706800eFb2425d6245`](https://sepolia.etherscan.io/address/0x175b1Ff50cd871698a9a96706800eFb2425d6245)
- Reactive `CampReactive`：[`0x6020bEd0aE09fc439DD52f2514B83f1282D263F7`](https://lasna.reactscan.net/address/0x6020bEd0aE09fc439DD52f2514B83f1282D263F7)
- 目标链 `CampCallback`：[`0x7059b2E456CaC1e1aF94bc42e400dD4E6EA35d06`](https://sepolia.etherscan.io/address/0x7059b2E456CaC1e1aF94bc42e400dD4E6EA35d06)

Reactive 合约在构造时订阅 `CampOrigin.Ping(address,uint256)`，设置阈值 100、处理上限 1，并在部署时存入 0.5 lREACT。Callback 部署时存入 0.02 Sepolia ETH，使用 Sepolia Callback Proxy `0xAa14d9Cd0f788Ca23d11805986C1d8bd035D23b4`。完成 `setRecipient` 后调用 `ping(500)`。

## 三笔链路交易

1. **源链事件**：[Sepolia `ping(500)` 交易](https://sepolia.etherscan.io/tx/0xa9c4ca3768e983c91b4236ec39d743665a3c7ab396f480caf7296e22f5579197)，回执包含 `Ping`，事件数据为 500。
2. **Reactive 执行**：[Lasna `react()` 交易](https://lasna.reactscan.net/tx/0x1248025a4b0940b5330e01ea14ec154c4adf0b1b1e6f664dc6c766dcff13e696)，`Seen` 事件记录上述源链交易哈希及数值 500。
3. **目标链回调**：[Sepolia Callback Proxy 交易](https://sepolia.etherscan.io/tx/0xe17f288c502dd2495baf8cc9daa627482aaa4c934a860167b600691ceefbd108)，`CampCallback.Handled` 记录同一个源链交易哈希、数值 500，`count()` 变为 1。

## 失败实验：钱包直接调用 Callback

从测试钱包 `0x17cB337e22e6B0F1471a8ff0491198dfF2882913` 发起只读调用模拟：

```powershell
cast call 0x7059b2E456CaC1e1aF94bc42e400dD4E6EA35d06 "onEvent(address,uint256,uint256,uint256)" 0x6020bEd0aE09fc439DD52f2514B83f1282D263F7 11155111 0 500 --from 0x17cB337e22e6B0F1471a8ff0491198dfF2882913 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

输出：

```text
Error: execution reverted: NotAuthorized(0x17cB337e22e6B0F1471a8ff0491198dfF2882913, 0xAa14d9Cd0f788Ca23d11805986C1d8bd035D23b4)
```

原因：`onEvent` 的 `onlyServiceProvider` 要求直接调用者必须是 Sepolia Callback Proxy；普通钱包不符合，因此在修改状态前回滚。`cast call` 仅模拟执行，不广播失败交易，也不消耗测试币。

合约来源：[ETHPanda 共学营模板](https://github.com/ethpanda-org/reactive-builder-camp/tree/main/starter)。
