# WoW Mobile — 影牙城堡单机垂直切片

用 REA 逆向《魔兽世界》12.1.0.69404（至暗之夜）国服客户端，提取真实游戏资产，
在 Godot 4.7 中复刻的可玩单机切片。

## 成果

| 产物 | 位置 | 状态 |
|---|---|---|
| **iPhone 版 .ipa（未签名）** | [Release v1.0-ios](https://github.com/wubing733-prog/wow-mobile-ios/releases/tag/v1.0-ios) | ✅ arm64 真机包 64.91 MB |
| iOS Xcode 工程 | `build/ios/WoWMobile.xcodeproj` | ✅ |
| Windows 版 | `build/windows/WoWMobile.exe` | ✅ 实测可运行 |
| 玩法自动化测试 | `--gametest` | ✅ 9/9 PASS（Windows + macOS 双端） |
| 逆向报告 | `docs/REA-FINDINGS.md` | ✅ Ghidra 全量分析 |

## 快速开始

```
# Windows 直接试玩
build\windows\WoWMobile.exe

# 编辑器打开
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64.exe --path .

# 玩法自测
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --gametest
```

操作：WASD 移动 · 左键/1 攻击 · 2 旋风斩 · 3 冲锋 · Shift 疾跑 · ESC 暂停
移动端：左半屏虚拟摇杆 + 右侧技能按钮

## iPhone 安装

.ipa 是未签名的，用 **Sideloadly / AltStore** 自签安装，或拿 Xcode 工程自己 Run。
详见 [docs/IOS-BUILD.md](docs/IOS-BUILD.md)。

## 目录

```
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
```

## 工具链

- REA 6.4.0 + Ghidra 12.1.4 + JDK 21（客户端二进制分析）
- @jamiephan/casclib（CASC 提取）
- wow.export 0.2.19（备用）
- Godot 4.7.2（游戏引擎）

## 数据来源

- 客户端: `\\192.168.5.19\电脑文件\World of Warcraft`（NAS，Z: 映射）
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
