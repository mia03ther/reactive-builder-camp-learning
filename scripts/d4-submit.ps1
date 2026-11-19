param(
    [switch]$NoClipboard
)

$ErrorActionPreference = 'Stop'

$submission = @'
源链事件（Ethereum Sepolia）：https://sepolia.etherscan.io/tx/0xa9c4ca3768e983c91b4236ec39d743665a3c7ab396f480caf7296e22f5579197
Reactive 执行（Lasna）：https://lasna.reactscan.net/tx/0x1248025a4b0940b5330e01ea14ec154c4adf0b1b1e6f664dc6c766dcff13e696
目标链回调（Ethereum Sepolia）：https://sepolia.etherscan.io/tx/0xe17f288c502dd2495baf8cc9daa627482aaa4c934a860167b600691ceefbd108
失败实验：我的测试钱包直接调用 Callback.onEvent，返回 NotAuthorized。因为 onlyServiceProvider 只允许 Sepolia Callback Proxy 作为直接调用者，普通钱包会被拒绝。报错截图见上传附件。
'@

Write-Host '=== D4 提交文本（下面同时复制到剪贴板）===' -ForegroundColor Cyan
Write-Output $submission
if (-not $NoClipboard) {
    Set-Clipboard -Value $submission
}

if (-not (Get-Command cast -ErrorAction SilentlyContinue)) {
    Write-Error '未找到 cast。请先确认 Foundry 已加入 PATH。'
}

Write-Host '=== 失败实验：从我的钱包地址直接调用 Callback（只读模拟）===' -ForegroundColor Cyan
Write-Host '下面预期出现 NotAuthorized。请截取本段命令和报错上传 WCB；此调用不广播交易。'
Write-Host 'cast call 0x7059b2E456CaC1e1aF94bc42e400dD4E6EA35d06 "onEvent(address,uint256,uint256,uint256)" 0x6020bEd0aE09fc439DD52f2514B83f1282D263F7 11155111 0 500 --from 0x17cB337e22e6B0F1471a8ff0491198dfF2882913 --rpc-url https://ethereum-sepolia-rpc.publicnode.com'

cast call 0x7059b2E456CaC1e1aF94bc42e400dD4E6EA35d06 `
    'onEvent(address,uint256,uint256,uint256)' `
    0x6020bEd0aE09fc439DD52f2514B83f1282D263F7 `
    11155111 0 500 `
    --from 0x17cB337e22e6B0F1471a8ff0491198dfF2882913 `
    --rpc-url https://ethereum-sepolia-rpc.publicnode.com

if ($LASTEXITCODE -ne 0) {
    Write-Host '已显示预期的拒绝报错。现在把剪贴板内容粘贴到 WCB 提交文本框，再上传终端截图。' -ForegroundColor Green
} else {
    Write-Warning '调用没有被拒绝，请勿按预期失败提交；先核对合约与网络。'
}
