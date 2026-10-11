# WoW Mobile — 影牙城堡单机垂直切片

用 REA 逆向《魔兽世界》12.1.0.69404（至暗之夜）国服客户端，提取真实游戏资产，
在 Godot 4.7 中复刻的可玩单机切片。

## 快速开始

```
# 直接试玩（Windows）
build\windows\WoWMobile.exe

# 编辑器打开
C:\Users\admin\tools\godot\Godot_v4.7.2-stable_win64.exe --path .
```

操作：WASD 移动 · 左键/1 攻击 · 2 旋风斩 · 3 冲锋 · Shift 疾跑 · ESC 暂停
移动端：左半屏虚拟摇杆 + 右侧技能按钮

## 目录

```
assets\shadowfang\      影牙城堡地形/WMO/纹理 (185 MB)
assets\m2obj\           400 个 M2 模型转出的 OBJ
assets\props\           场景道具模型
assets\audio\           音效 (来自 WoW 客户端)
assets\db2\             游戏数据表 (Map/AreaTable/Creature/...)
scripts\                游戏逻辑 (Player/Enemy/HUD/TouchControls/Menu/AudioManager/Pickup)
scenes\Main.tscn        主场景
tools\                  CASC 提取与格式转换管线
build\windows\          Windows 可执行
build\ios\              iOS Xcode 工程
docs\                   逆向报告 / 计划 / 进度
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
- iOS .ipa 需在 macOS + Xcode 上构建（Windows 只能生成 Xcode 工程）