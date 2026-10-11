# 进度报告 - WoW 至暗之夜 -> iPhone 单机版垂直切片

更新: 2026-10-12 凌晨 (第 16 轮)

## 已完成

### 1. REA / Ghidra 深度解析（已完成并持久化）
- REA 6.4.0 + Ghidra 12.1.4 + JDK 21，`rea doctor` healthy
- Wow.exe 静态身份: PE32+ x86_64 / not-managed / SHA-256 fe40cacf...
- **Ghidra 全量分析完成并保存** (ghidra-proj, 314 MB)
  - functions = 106,399
  - symbols   = 117,269
  - data      = 749,118
  - language  = x86:LE:64:default / compiler = windows / imagebase = 0x140000000
- 统计脚本: ghidra-scripts/WowStats.java

### 2-4. 客户端转移 / 资产提取 / 转换管线
(见前几轮记录，全部打通)

### 5. Godot 工程 (完整可玩切片)
- 地形 + WMO + 道具 + 敌人 + BOSS + 治疗拾取 + HUD + 触屏 + 菜单 + 音效 + 存档
- 测试/截图参数触发 (`--gametest` / `--screenshot`)
- 玩法自动化: 9/9 PASS

### 6. 构建产物
- **Windows 版**: build/windows/WoWMobile.exe (540 MB, 实测启动并保持运行)
- **iOS 工程**: build/ios/WoWMobile.xcodeproj + WoWMobile.pck (436 MB) + xcframework + MoltenVK

## 唯一剩余阻塞
- MacBook Air (192.168.5.55) 不可达 -> 无法产出 .ipa（需 macOS + Xcode）

## 如何试玩
直接运行 C:\Users\admin\wow-mobile\build\windows\WoWMobile.exe

## 关键路径备忘
- CASC 必须用映射盘 Z:; 内部路径反斜杠
- ADT/WMO FourCC 反序; WMO MOGP 头 0x44
- M2 是 MD21 容器, 需 unwrap 成 MD20; skin 索引在 0x0C/0x10
- GitHub 必须走 Clash 代理 127.0.0.1:17891
- REA analyze 对 93MB 二进制超时(330s)，需直接 Ghidra headless
- Godot 4 用 OS.get_cmdline_user_args() 读 `--` 之后的参数
- 构建输出目录在项目内需加 .gdignore