# 第 0 周：环境准备记录

- 测试钱包地址：`0x17cB337e22e6B0F1471a8ff0491198dfF2882913`
- [Lasna 区块浏览器钱包页](https://lasna.reactscan.net/address/0x17cB337e22e6B0F1471a8ff0491198dfF2882913)
- [Sepolia 测试币兑换交易](https://sepolia.etherscan.io/tx/0x7499137572020b3c5ab2e318c19318234a7cba2954189317444ca4903fd5c37e)：转给速查表中的 faucet 合约，链上状态 `success`。
- 2026-11-17 使用 `cast balance 0x17cB337e22e6B0F1471a8ff0491198dfF2882913 -r https://lasna-rpc.rnk.dev/ -e` 查询：`1.050000000000000000` lREACT。
- [公开学习仓库](https://github.com/mia03ther/reactive-builder-camp-learning)

Foundry 版本输出：

```text
forge Version: 1.9.0
Commit SHA: 6056c5845d34205a83cf7108042adb137325c9df
Build Timestamp: 2026-11-02T20:11:29.162616900Z (1793650289)
Build Profile: dist
```

模板仓库 `starter/` 执行 `forge test`：8 passed，0 failed，0 skipped。

注意：本文件记录的是公开测试钱包地址与命令输出，不含私钥或助记词。WCB 要求的 `forge --version` 截图仍需从本机终端实际截取并上传。
