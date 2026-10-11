# iOS 构建说明（.ipa）

本机是 Windows，无法产出 .ipa。构建走 GitHub Actions 的 macOS runner。

## 一键产出（已跑通）

仓库: https://github.com/wubing733-prog/wow-mobile-ios
工作流: `.github/workflows/ios.yml`（push 到 main 或手动 workflow_dispatch 触发）

实测结果（run 38165940798，2 分 04 秒）:
- 玩法自动化测试 9/9 PASS（在 macOS runner 上真实执行）
- Godot 4.7.2 导出 Xcode 工程成功，WoWMobile.pck = 102.97 MB
- xcodebuild 归档成功，产出 arm64 真机二进制（Mach-O cputype=0x0100000C）
- 打包出未签名 .ipa = 64.91 MB（构建不可复现：Xcode 会写入时间戳，不同 run 的哈希不同；下面这个哈希对应 run 38165940798 产出、并已发布到 Release 的那份文件）
  - SHA-256: f6743d38b259774d7e7d0224d63479fd904bdd2b9d678a876a6b26119b562a0f
  - Bundle ID: com.example.wowmobile / MinimumOSVersion 14.0 / UIDeviceFamily 1,2

## 下载

- Release（可直接下载 .ipa）:
  https://github.com/wubing733-prog/wow-mobile-ios/releases/tag/v1.0-ios
- CI 产物（Actions Artifacts）:
  https://github.com/wubing733-prog/wow-mobile-ios/actions/runs/38165940798

## 安装到 iPhone

.ipa 是**未签名**的（CODE_SIGNING_ALLOWED=NO），必须重新签名才能装到真机：

1. **Sideloadly**（Windows 可用，推荐）：连上 iPhone，把 .ipa 拖进去，填 Apple ID 自签
2. **AltStore**：导入 .ipa 后自签安装
3. **Xcode**（有 Mac 时）：打开 `build/ios/WoWMobile.xcodeproj`，在 Signing & Capabilities
   里选自己的 Team，直接 Run 到真机

## 本地复现（Windows）

```
# 1. 还原大体积资源（仓库里存的是 gz）
gunzip -kf assets/shadowfang/sf_terrain_y.obj.gz

# 2. 导入 + 玩法自测
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --gametest

# 3. 只导出 Xcode 工程（.ipa 仍需 macOS）
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-debug "iOS" build/ios/WoWMobile.ipa
```

## 仓库瘦身说明

原始工程 3.5 GB / 46,782 文件，仓库只保留运行必需资源：

- 仓库内容 21.4 MB（git objects），392 个文件
- 未使用的提取产物移到 `_unused/`（.gdignore + gitignore，本地保留）
- `tools/community-listfile.csv`(153 MB)、`tools/node_modules`、`ghidra-proj`(628 MB) 不入库
- 109 MB 的 `sf_terrain_y.obj` 以 `.gz`（17.6 MB）入库，CI 用 gunzip 还原

瘦身后 pck 从 457 MB 降到 103 MB，产物 .ipa 仅 65 MB。
