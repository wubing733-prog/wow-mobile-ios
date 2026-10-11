$env:HTTPS_PROXY='http://127.0.0.1:17891'
Set-Location C:\Users\admin\wow-mobile
New-Item -ItemType Directory -Force -Path build\ios | Out-Null
Copy-Item -LiteralPath build\ci-artifact\build\ios\WoWMobile-unsigned.ipa -Destination build\ios\WoWMobile-unsigned.ipa -Force
Copy-Item -LiteralPath build\ci-artifact\build\ios\WoWMobile-unsigned.ipa.sha256 -Destination build\ios\WoWMobile-unsigned.ipa.sha256 -Force
$notes = @"
# WoW Mobile - iOS 未签名构建 (v1.0)

《魔兽世界》12.1.0.69404（至暗之夜）影牙城堡场景 -> iPhone 单机版垂直切片。

- 由 GitHub Actions 的 macOS runner 用 Xcode 26.5 / iphoneos26.5 SDK 构建
- 架构: arm64 (真机) / 最低 iOS 14.0
- Bundle ID: com.example.wowmobile
- **未签名**：需用 Sideloadly / AltStore / Xcode 重新签名后才能装到真机
- 玩法自动化测试: 9/9 PASS

## 安装（任选其一）
1. **Sideloadly**（Windows 可用）：连上 iPhone，把 .ipa 拖进去，填 Apple ID 自签
2. **AltStore**：导入 .ipa 后自签安装
3. **Xcode**：打开 build/ios/WoWMobile.xcodeproj，配置自己的 Team 后直接 Run

## 操作
WASD 移动 / 左键攻击 / 1 普攻 / 2 旋风斩 / 3 冲锋 / Shift 疾跑 / ESC 暂停
移动端：左半屏虚拟摇杆 + 右侧技能按钮
"@
$notes | Set-Content -Path build\release-notes.md -Encoding UTF8
gh release create "v1.0-ios" build\ios\WoWMobile-unsigned.ipa --title "WoW Mobile iOS v1.0 (unsigned .ipa)" --notes-file build\release-notes.md
Write-Output "EXIT=$LASTEXITCODE"
gh release view v1.0-ios --json url,assets --jq '.url, (.assets[] | "\(.name)  \(.size) bytes")'
