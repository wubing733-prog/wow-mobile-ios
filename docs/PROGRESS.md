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
