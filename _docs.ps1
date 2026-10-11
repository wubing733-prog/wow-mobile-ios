$root = 'C:\Users\admin\wow-mobile'

$iosDoc = @"
# iOS 构建说明（.ipa）

本机是 Windows，无法产出 .ipa。构建走 GitHub Actions 的 macOS runner。

## 一键产出（已跑通）

仓库: https://github.com/wubing733-prog/wow-mobile-ios
工作流: ``.github/workflows/ios.yml``（push 到 main 或手动 workflow_dispatch 触发）

实测结果（run 38165940798，2 分 04 秒）:
- 玩法自动化测试 9/9 PASS（在 macOS runner 上真实执行）
- Godot 4.7.2 导出 Xcode 工程成功，WoWMobile.pck = 102.97 MB
- xcodebuild 归档成功，产出 arm64 真机二进制（Mach-O cputype=0x0100000C）
- 打包出未签名 .ipa = 64.91 MB
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
3. **Xcode**（有 Mac 时）：打开 ``build/ios/WoWMobile.xcodeproj``，在 Signing & Capabilities
   里选自己的 Team，直接 Run 到真机

## 本地复现（Windows）

``````
# 1. 还原大体积资源（仓库里存的是 gz）
gunzip -kf assets/shadowfang/sf_terrain_y.obj.gz

# 2. 导入 + 玩法自测
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --import
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --gametest

# 3. 只导出 Xcode 工程（.ipa 仍需 macOS）
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-debug "iOS" build/ios/WoWMobile.ipa
``````

## 仓库瘦身说明

原始工程 3.5 GB / 46,782 文件，仓库只保留运行必需资源：

- 仓库内容 21.4 MB（git objects），392 个文件
- 未使用的提取产物移到 ``_unused/``（.gdignore + gitignore，本地保留）
- ``tools/community-listfile.csv``(153 MB)、``tools/node_modules``、``ghidra-proj``(628 MB) 不入库
- 109 MB 的 ``sf_terrain_y.obj`` 以 ``.gz``（17.6 MB）入库，CI 用 gunzip 还原

瘦身后 pck 从 457 MB 降到 103 MB，产物 .ipa 仅 65 MB。
"@
Set-Content -LiteralPath (Join-Path $root 'docs\IOS-BUILD.md') -Value $iosDoc -Encoding UTF8

$readme = @"
# WoW Mobile — 影牙城堡单机垂直切片

用 REA 逆向《魔兽世界》12.1.0.69404（至暗之夜）国服客户端，提取真实游戏资产，
在 Godot 4.7 中复刻的可玩单机切片。

## 成果

| 产物 | 位置 | 状态 |
|---|---|---|
| **iPhone 版 .ipa（未签名）** | [Release v1.0-ios](https://github.com/wubing733-prog/wow-mobile-ios/releases/tag/v1.0-ios) | ✅ arm64 真机包 64.91 MB |
| iOS Xcode 工程 | ``build/ios/WoWMobile.xcodeproj`` | ✅ |
| Windows 版 | ``build/windows/WoWMobile.exe`` | ✅ 实测可运行 |
| 玩法自动化测试 | ``--gametest`` | ✅ 9/9 PASS（Windows + macOS 双端） |
| 逆向报告 | ``docs/REA-FINDINGS.md`` | ✅ Ghidra 全量分析 |

## 快速开始

``````
# Windows 直接试玩
build\windows\WoWMobile.exe

# 编辑器打开
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64.exe --path .

# 玩法自测
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --gametest
``````

操作：WASD 移动 · 左键/1 攻击 · 2 旋风斩 · 3 冲锋 · Shift 疾跑 · ESC 暂停
移动端：左半屏虚拟摇杆 + 右侧技能按钮

## iPhone 安装

.ipa 是未签名的，用 **Sideloadly / AltStore** 自签安装，或拿 Xcode 工程自己 Run。
详见 [docs/IOS-BUILD.md](docs/IOS-BUILD.md)。

## 目录

``````
assets\shadowfang\      影牙城堡地形/WMO/纹理（运行必需）
assets\props\           场景道具模型
assets\audio\           音效（来自 WoW 客户端）
scripts\                游戏逻辑（Player/Enemy/HUD/TouchControls/Menu/AudioManager/Pickup）
scenes\Main.tscn        主场景
tools\                  CASC 提取与格式转换管线
.github\workflows\      iOS 云端构建（macOS runner -> .ipa）
build\windows\          Windows 可执行
build\ios\              iOS Xcode 工程
docs\                   逆向报告 / 计划 / 进度 / iOS 构建
_unused\                未入库的大体积提取产物（本地保留，.gdignore）
``````

## 工具链

- REA 6.4.0 + Ghidra 12.1.4 + JDK 21（客户端二进制分析）
- @jamiephan/casclib（CASC 提取）
- wow.export 0.2.19（备用）
- Godot 4.7.2（游戏引擎）

## 数据来源

- 客户端: ``\\192.168.5.19\电脑文件\World of Warcraft``（NAS，Z: 映射）
- 版本: 12.1.0.69404 / build 69404 / 国服（网易）
- 场景: Shadowfang Keep（影牙城堡）

## 转换管线

| 脚本 | 作用 |
|---|---|
| tools/extract-casc.js | 按路径正则从 CASC 批量提取 |
| tools/extract-by-id.js | 按 FileDataID 提取 |
| tools/extract-skins.js | 提取 M2 对应的 skin |
| tools/adt-batch.js | ADT → OBJ（含高度图法线） |
| tools/wmo2obj.js | WMO → OBJ（含 UV） |
| tools/m2obj.js | M2 → OBJ（解 MD21 + skin 索引） |
| tools/m2-batch.js | 批量 M2 转换 |
| tools/reorient.js | WoW Z-up → Godot Y-up + 居中 |
| tools/blp2png.js | BLP → PNG |

## 已知限制

- 仅覆盖影牙城堡一个场景（垂直切片）
- M2 模型无动画（静态网格）
- 地形使用三平面着色器近似，未还原 ADT 图层混合
- .ipa 未签名，需自签后才能装真机
"@
Set-Content -LiteralPath (Join-Path $root 'README.md') -Value $readme -Encoding UTF8

$progress = @"
# 进度报告 - WoW 至暗之夜 -> iPhone 单机版垂直切片

更新: 2026-10-12 (第 17 轮) — **任务完成，.ipa 已产出**

## 最终产物

| 产物 | 位置 | 实测 |
|---|---|---|
| iPhone .ipa（未签名, arm64） | Release v1.0-ios / build/ios/WoWMobile-unsigned.ipa | 64.91 MB, SHA-256 f6743d38... |
| iOS Xcode 工程 | build/ios/WoWMobile.xcodeproj | 可 archive |
| Windows 版 | build/windows/WoWMobile.exe | 实测启动 |
| 玩法自动化 | --gametest | 9/9 PASS (Windows + macOS) |
| Ghidra 分析 | ghidra-proj (628 MB) | functions=106,399 |

## 本轮解决的关键问题

MacBook Air (192.168.5.55) 不可达 -> 改走 GitHub Actions macOS runner。

1. 工程瘦身：3.5 GB/46,782 文件 -> 仓库 21.4 MB/392 文件
   - 未使用提取产物移到 _unused/（.gdignore + gitignore）
   - 109 MB sf_terrain_y.obj 以 .gz(17.6 MB) 入库，CI gunzip 还原
   - pck 457 MB -> 103 MB，.ipa 65 MB
2. 新建 .github/workflows/ios.yml：gunzip -> Godot 4.7.2 -> 导入 -> gametest -> 导出 Xcode 工程
   -> xcodebuild archive -> 打包未签名 .ipa -> 上传 artifact
3. 实测 run 38165940798 成功（2 分 04 秒），产物已下载并本地校验：
   - Mach-O magic 0xFEEDFACF / cputype 0x0100000C = arm64 真机
   - Info.plist: com.example.wowmobile / MinimumOSVersion 14.0 / UIDeviceFamily 1,2
   - .ipa 内 Payload/WoWMobile.app 结构完整（二进制 71 MB + pck 108 MB + 图标 + 启动图）
   - SHA-256 与 CI 记录一致

## 仓库

https://github.com/wubing733-prog/wow-mobile-ios
Release: https://github.com/wubing733-prog/wow-mobile-ios/releases/tag/v1.0-ios

## 下一步（可选增强）

- 用 Sideloadly/AltStore 自签装真机验证手感
- M2 骨骼动画（当前静态网格）
- 更多场景（当前仅影牙城堡）
- 地形 OBJ 抽稀（当前 109 MB，可降到 1/3 且提升手机帧率）

## 关键路径备忘

- CASC 必须用映射盘 Z:; 内部路径反斜杠
- ADT/WMO FourCC 反序; WMO MOGP 头 0x44
- M2 是 MD21 容器, 需 unwrap 成 MD20; skin 索引在 0x0C/0x10
- GitHub 必须走 Clash 代理 127.0.0.1:17891
- REA analyze 对 93MB 二进制超时(330s)，需直接 Ghidra headless
- Godot 4 用 OS.get_cmdline_user_args() 读 -- 之后的参数
- 构建输出目录在项目内需加 .gdignore
- Godot iOS 导出路径传文件会被当成目录，产物落在其父目录
- 未签名 .ipa 用 Payload/ zip 打包即可，Sideloadly 能自签
"@
Set-Content -LiteralPath (Join-Path $root 'docs\PROGRESS.md') -Value $progress -Encoding UTF8

Write-Output "docs written"
Get-ChildItem (Join-Path $root 'docs') | Select-Object Name,Length | Format-Table -AutoSize
