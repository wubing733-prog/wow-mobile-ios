# WoW Mobile - 垂直切片构建计划 (方案 A)

## 目标

把 World of Warcraft 12.1.0.69404 (至暗之夜) 复刻为 iPhone 单机版的可玩垂直切片。

## 范围 (方案 A)

- 1 个新手区地形 (ADT/WMO 提取后重建)
- 1 个可玩角色 (移动 + 相机)
- 简化战斗: 普攻 + 3 个技能
- 单机任务链 (1 条)
- 目标平台: iOS (需 Mac + Xcode 出包)

## 技术栈

- Godot 4.7 (mobile 渲染器)
- GDScript (避免 .NET SDK 依赖; 如需 C# 可后续切 mono 版)
- 资产: wow.export 从 CASC 导出 glTF + PNG

## 阶段

### P0 工具链 (进行中)
- [x] WoW 客户端转移到 NAS (释放本机 125 GB)
- [ ] Ghidra 12.1.4 (REA 原生反编译引擎)
- [ ] wow.export 0.2.19 (CASC 提取)
- [ ] Godot 4.7

### P1 资产提取
- [ ] 定位新手区地图 ID (从 DB2 表 Map / AreaTable)
- [ ] 导出地形 (ADT) + 建筑 (WMO) + 道具 (M2)
- [ ] 导出贴图 (BLP -> PNG)
- [ ] 导出角色模型 + 动画

### P2 引擎接入
- [ ] Godot 场景: 地形网格 + 材质
- [ ] 角色控制器 (移动/跳跃/相机)
- [ ] 骨骼动画播放

### P3 玩法
- [ ] 战斗系统 (普攻/技能/冷却)
- [ ] 简单敌人 AI
- [ ] UI (血条/技能栏/小地图)

### P4 出包
- [ ] Mac 上 Xcode 导出 iOS
- [ ] 真机测试

## 目录

- assets/   提取的游戏资产 (体积大, 不进 git)
- docs/     文档
- scenes/   Godot 场景
- scripts/  游戏逻辑
- tools/    提取/转换脚本