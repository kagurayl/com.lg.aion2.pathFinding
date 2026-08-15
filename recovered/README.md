# 恢复脚本与逆向分析归档

该目录集中保存后续静态分析、协议追踪、资源下载和脚本恢复所需的第一方项目资料。所有能够从恢复归档中还原为 UTF-8 文本的内容均已原地转换为明文，不再保留 `pathFinding` 内对应的压缩副本。

线上寻路服务器不需要整个 `recovered/`；开发和后续 AI 接手时应保留。

## 目录结构

```text
recovered/
├── scripts/
│   ├── lua_unpacked/                 # library.scp 内容，494 个明文文件
│   └── config_unpacked/              # config.scp 内容，12,136 个明文文件
├── tools/                             # 解包、解压、二进制表转换和运行时辅助工具
├── analysis/
│   ├── reports/                      # 导航、移动协议、场景和转换报告
│   ├── manifests/                    # 已转换为 TSV 的资源清单与依赖
│   └── il2cpp/                       # metadata、dump.cs、IDA script 和字符串表
├── native/arm64-v8a/
│   ├── libgamedll.so
│   ├── libil2cpp.so
│   └── libunity.so
└── SHA256SUMS.txt
```

## 已完成的明文化处理

### `scripts/lua_unpacked`

共 494 个文件，现已全部是 UTF-8 可读文本：

- 428 个 `.lua`；
- 66 个 `.txt`。

原本唯一的二进制文件：

```text
scripts/lua_unpacked/config/csvstring.txt
```

已从“字符串数量 + offset 表 + NUL 字符串池”的二进制格式转换为 TSV：

```text
index<TAB>value
```

共恢复 208,478 个字符串。

任务数据的主要文件：

```text
scripts/lua_unpacked/config/quest.txt
scripts/lua_unpacked/config/queststep.txt
scripts/lua_unpacked/config/string_cn.txt
scripts/lua_unpacked/config/csvstring.txt
```

### `scripts/config_unpacked`

共 12,136 个文件，现已全部解压为 UTF-8 明文：

| 类型 | 数量 | 最终格式 |
|---|---:|---|
| `.html` | 7,900 | 可直接查看的 UTF-8 XML |
| `.txt` | 4,236 | 可直接查看的 UTF-8 表格/配置文本 |

原始 `config.scp` 内每个文件还单独使用了 LZ4 Block。外层 SCP 解包后看到的乱码就是这些内层 LZ4 数据。转换时使用 `config_manifest.json` 的 `tag` 作为解压后大小，并在替换前完成全量校验。

结果：

```text
文件总数：12,136
解压失败：0
UTF-8 校验失败：0
HTML XML 解析失败：0
最终明文大小：72,155,798 字节
```

任务 HTML 不是浏览器页面程序，而是游戏对话状态机使用的 XML，包含：

- 任务接受、拒绝和完成对话；
- 任务摘要与阶段描述；
- 奖励选择；
- NPC 对话分支；
- `HACTION_*` 动作；
- `[%username]`、`[%shoplink]` 等运行时占位符。

游戏加载链：

```text
Lua c_config_loadxml()
→ libgamedll packfile_getfile()
→ unity_loadxml()
→ XML 节点被转换为 Lua 表
→ csvxml.lua 读取文本、步骤和选项
```

### 资源清单与依赖

原来的二进制文件已转换为 UTF-8 TSV，并删除 `pathFinding` 内的二进制副本：

```text
analysis/manifests/localfilelist.tsv
analysis/manifests/filelist.tsv
analysis/manifests/dependencies.tsv
```

统计：

| 数据 | 结果 |
|---|---:|
| 本地资源清单记录 | 50,068 |
| 远程资源清单记录 | 50,068 |
| 依赖表资产 | 50,065 |
| 有依赖的资产 | 18,046 |
| 依赖边 | 69,657 |

资源清单 TSV 字段：

```text
path
xxh64
download_flag
size_bytes
```

依赖表采用一条边一行：

```text
asset_path<TAB>dependency_path
```

没有依赖的资产也保留一行，第二列为空。

## 转换工具

```text
tools/unpack_scp.py
tools/unpack_stream_scp.py
tools/decompress_streamconfig.py
tools/decode_binary_tables.py
tools/pack_scp.py
tools/lua_debug_client.py
tools/frida_lua_eval.py
```

- `decompress_streamconfig.py`：将 `config_unpacked` 中的逐文件 LZ4 数据转换为 UTF-8 XML/TXT；先全量暂存和验证，全部成功后才原地替换。
- `decode_binary_tables.py`：转换 `csvstring`、本地/远程资源清单和资源依赖表。

## IL2CPP 分析资料

```text
analysis/il2cpp/global-metadata.dat
analysis/il2cpp/dump.cs
analysis/il2cpp/script.json
analysis/il2cpp/stringliteral.json
analysis/il2cpp/unity.ver
```

用途：

- `dump.cs`：类型、字段、方法、RVA 和方法签名检索；
- `script.json`：Il2CppDumper 生成的 IDA/Ghidra 符号映射；
- `stringliteral.json`：IL2CPP 字符串常量；
- `global-metadata.dat` + `libil2cpp.so`：重新运行 Il2CppDumper 的输入；
- `unity.ver`：Unity 版本提示。

游戏 Unity 版本：

```text
2022.3.62f3
```

## 重要原生库

| 文件 | 大小 | SHA-256 | 用途 |
|---|---:|---|---|
| `libgamedll.so` | 1,451,064 | `f213e6ae040611d82eb13e80ac2934fde764f2a7e68b8ee0e1b5e481e03ab436` | 游戏逻辑、Lua、下载器和协议桥 |
| `libil2cpp.so` | 58,467,512 | `12f3060603ea77964f9e91b8abf534ab7d1ebe8b0ad6754a8c60367756a208aa` | IL2CPP 原生代码 |
| `libunity.so` | 25,176,264 | `69e92df2e98dc260086e45e77a201df1d6f1759a146b7434667318da2cbbf5b6` | Unity Runtime 与资源/场景实现 |
| `global-metadata.dat` | 7,819,248 | `ee87eabca7bcfff3e00475d93a3dd108348f0ad4ab4bd987f320d7b3bb5332f5` | IL2CPP 元数据 |

Sentry、Burst 空壳和其他与项目目标无关的 `.so` 未复制。

## 保留的固有二进制数据

以下文件不是“压缩文本”，不能无损转换成有同等用途的明文，因此仍保留：

```text
native/arm64-v8a/*.so
analysis/il2cpp/global-metadata.dat
maps/lf1.navmesh（位于项目根 maps/）
data/lf1/collision.npz（位于项目根 data/）
```

- `.so` 和 `global-metadata.dat` 是逆向工具的原始输入；
- `.navmesh` 是 Detour 运行时数据；
- `.npz` 是数百万顶点和三角形的数值数组，展开成文本会显著膨胀且失去直接计算价值。

已扫描整个 `recovered/`：没有剩余可按“四字节原始大小 + LZ4 Block”解压的文件。

## 未保留的原始压缩数据

按当前仓库要求，以下压缩/二进制副本已从 `pathFinding` 删除：

```text
archives/library.scp
archives/config.scp
analysis/manifests/localfilelist.bin
analysis/manifests/filelist.zip
analysis/manifests/dependencies.bin
```

工作目录外的原始项目文件未修改。

另外未复制完整 APK 解包目录、原始 Unity 地图、PCAP、Sentry 库、DummyDll、`il2cpp.h`、凭据或账号信息。

## 转换报告

```text
analysis/reports/streamconfig_plaintext_report.json
analysis/reports/binary_tables_plaintext_report.json
analysis/reports/config_manifest.json
analysis/reports/library_manifest.json
```

其中 `config_manifest.json` 和 `library_manifest.json` 描述原归档布局及原始 hash；其余两个报告描述当前明文转换结果。

## 完整性验证

归档共 12,668 个文件（不含 `SHA256SUMS.txt`），总计 308,447,169 字节。验证全部当前文件：

```bash
cd recovered
sha256sum -c SHA256SUMS.txt
```

## GitHub 注意事项

Git push 的常见单文件硬限制为 100 MB，本目录没有文件超过 100 MB。不过 `script.json`、`libil2cpp.so` 等文件超过 GitHub 网页拖拽上传常见的 25 MB 限制，应使用正常的 `git add`、`git commit`、`git push`。
