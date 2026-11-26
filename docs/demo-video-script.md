# 90 秒演示视频脚本｜Wallet Transfer Watch

目标时长 **1 分 30 秒左右**，录屏加口述即可；导出 MP4 后检查能正常播放、浏览器链接可由未登录者打开。上传前再核对 DoraHacks 表单的视频格式与时长限制。

| 时间 | 屏幕画面 | 可直接照读的讲解 |
| --- | --- | --- |
| 0:00–0:15 | 打开仓库 README 标题、项目问题段 | “我是 MIA_Ether，单人参加 Set It and Forget It。这个项目监控测试钱包的大额代币转出，并自动在目标链留下告警记录。” |
| 0:15–0:32 | 滚到 README 的 Mermaid 时序图 | “源链是 Ethereum Sepolia，监听我部署的 WWTT 代币 Transfer。Lasna 上的 Reactive 合约检查转出钱包和 100 枚阈值，再通过 Callback Proxy 调用 Sepolia 的 AlertRecorder。” |
| 0:32–0:52 | 打开[源链交易](https://sepolia.etherscan.io/tx/0x1a2b0d1b0bfc84f645b2a00ec3e7b46e1895f907b55e3205967e67c5afd2cdbe)，指向 Transfer 日志 | “这里是实际的 150 枚 WWTT 转出，交易哈希以 1a2b 开头。” |
| 0:52–1:10 | 打开[Lasna 交易](https://lasna.reactscan.net/tx/0x45200ea9a4af6a324eea94e0176c7e7291d823c6e1b2baec1ecfc14b1919df9c)，指向 AlertRequested | “Reactive 收到同一个源交易，判断达到阈值，请求回调，并在一次处理后退订。” |
| 1:10–1:25 | 打开[目标链交易](https://sepolia.etherscan.io/tx/0xeb72216d529ede6bad86c9b33d02bdbb2995cc1e5e4bf33e4448268f3238db65)，指向 LargeTransferAlert | “目标链回调成功，告警事件记录了相同的源交易哈希、地址和数量。” |
| 1:25–1:35 | 打开 README 的保护与出问题怎么办、测试结果 | “我还测试了误触发、重复事件和金额上限。这里使用测试币，AI 帮我写代码，但运行时判断由合约执行。” |

录制提示：浏览器标签提前打开并放大关键日志；不要展示钱包私钥、助记词或签名弹窗。历史三笔链路来自已部署 MVP；当前增强版源码新增了金额上限与显式去重，README 已标注版本差异。视频里不要把增强版保护说成已在旧合约上链。
