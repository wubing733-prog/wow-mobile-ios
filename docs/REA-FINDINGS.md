# REA 逆向报告 — World of Warcraft 至暗之夜

目标: C:\迅雷下载\《魔兽世界》至暗之夜绿色客户端\World of Warcraft
工具: REA (rea-agents) 6.4.0 | 日期: 2026-10-11

## 证据

- inspect_artifact (Wow.exe): ev_1d8e60fef0d80cf94ec24b637df622874c05b9e5cd664f5d7216b54ae699a855
- inspect_managed_artifact (Wow.exe): ev_273040c0e8e4aaa99d92b5d5c1bcc82dcefd7437381818c70a10bab18f938513
- inventory (Wow.exe): ev_00a4ec06659ff900860de7b9af6d7c7aad4b0d8296a0efeeaf0959bf7880c2fe

## 客户端身份

- 版本 12.1.0.69404 (至暗之夜 = Midnight 资料片)
- 分支 cn (国服/网易), CDN blzdist-wow.necdn.leihuo.netease.com
- Build Key cfacf8406f26370199753c06462477ff

## 二进制 (REA 确认)

- _retail_\Wow.exe : PE32+ / x86_64 / 7 sections / not-managed (原生 C++) / 97864400 B / SHA-256 fe40cacf41462613010563db5b54efb27cc33e3a0af99df0bcc12c3a801b9024
- _retail_\wow_loader.dll : 39.1 MB, 含 RT_MANIFEST 资源
- _retail_\GFSDK_Aftermath_Lib.x64.dll : NVIDIA Aftermath (GPU 崩溃捕获)
- _retail_\Utils\ : 内嵌 CEF 浏览器 (BlizzardBrowser.exe + cef*.pak)

## 数据存储

Data/ 128.5 GB
- data/ : 129 x ~1GB .dat + 16 x .idx (28MB)  <- CASC 内容寻址存储
- indices/ config/ ecache/ wow/

## REA 能力边界 (实测)

- inspect-artifact : OK (PE 身份)
- inspect-managed-artifact : OK (确认 not-managed)
- inspect-pe-resources : 失败, 超 64 MB 上限 (Wow.exe 93 MB)
- analyze (原生反编译) : 失败, capability_unavailable (provider_id=ida, operation=list_documents)
- inspect-binary-layout : 失败, 仅支持 Linux x64 ELF
- CASC 数据 : 不支持, REA 归档支持仅 ZIP/APK/IPA/MSIX/AppX/DMG

根因: analysis_provider_binding = null, 无原生分析引擎 (Ghidra 未装 / IDA 未运行)

## 结论

REA 能给出 Wow.exe 的静态身份, 但深层反编译需要 Ghidra, 游戏内容需要 CASC 提取器.