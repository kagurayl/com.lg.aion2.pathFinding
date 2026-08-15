# 地图下载与提取协议

## 1. 精确地图数

`localfilelist.bin` 中符合以下规则的独立场景共有 78 个：

```text
levels/<map_id>/<map_id>.unity.scene
```

当前状态：

```text
已下载：3（lf1、df1、login2）
已提取和烘焙：1（lf1）
未下载：75
未下载场景总大小：8,366,434,603 字节，约 7.79 GiB
```

78 张中包含开放世界、主城、副本、竞技场、地牢、变体和大厅，不应全部当作开放世界主地图。

## 2. CDN 来源

工作机 `device_snapshot/remoteversion.txt` 提供：

```text
version_online:2026-08-13
cdn:http://download10.sglt.asia/assets_android
```

无需登录凭据。不要把游戏服务器地址或任何账号信息写进仓库。

## 3. localfilelist.bin 格式

小端序：

```text
int32 record_count
repeat record_count:
    char path[] + NUL
    uint64 xxh64
    int32 download_flag
    int32 size_bytes
```

本次清单解析得到 50,068 条记录，文件正好消费到末尾，说明结构匹配。

## 4. URL 算法

远程对象名：

```text
<relative_path>_<xxh64:016x>.zip
```

完整 URL：

```text
<cdn>/<relative_path>_<xxh64:016x>.zip
```

例：

```text
relative_path = levels/df2/df2.unity.scene
xxh64         = a7f54fd229f6d6a7
size_bytes    = 566194294
flag          = 220020000
url           = http://download10.sglt.asia/assets_android/levels/df2/df2.unity.scene_a7f54fd229f6d6a7.zip
```

该 URL 已验证返回：

```text
HTTP 200
Content-Length: 566194294
Accept-Ranges: bytes
```

未加 XXH64 后缀的直接路径会返回 404；不能据此判断资源不存在。

## 5. `.zip` 后缀陷阱

CDN 对象虽以后缀 `.zip` 返回，内容实际是原始 UnityFS 场景，不是 ZIP 容器。

验证过 `lf1` CDN 内容的前 64 字节与设备上的 `lf1.unity.scene` 完全相同，且：

```text
本地 XXH64 = cef390d361d6cd9e
清单 XXH64 = cef390d361d6cd9e
```

下载时可先保存到 `.part`，完成并校验后直接移动为清单中的相对路径，例如：

```text
levels/df2/df2.unity.scene
```

不要对响应执行 unzip。

## 6. 推荐下载流程

单张地图：

1. 在根目录 `map_download_links.txt` 找到 map ID。
2. 读取 URL、`size_bytes`、XXH64 和 `relative_path`。
3. 使用支持断点续传的 HTTP 客户端下载到 `<relative_path>.part`。
4. 检查文件大小。
5. 计算 XXH64；不匹配则删除或重试。
6. 原子改名到 `relative_path`。
7. 运行 UnityPy inventory，确认场景可加载。
8. 再执行碰撞导出和 navmesh 烘焙。

示例命令：

```bash
curl -L --fail --continue-at - \
  -o levels/df2/df2.unity.scene.part \
  "http://download10.sglt.asia/assets_android/levels/df2/df2.unity.scene_a7f54fd229f6d6a7.zip"
```

校验 XXH64 可使用 Python `xxhash` 包：

```bash
uv run --isolated --with xxhash python -c \
  "import xxhash,pathlib; p=pathlib.Path('levels/df2/df2.unity.scene.part'); print(f'{xxhash.xxh64(p.read_bytes()).intdigest():016x}')"
```

大文件校验实现应使用流式读取，避免一次读入内存。

## 7. 游戏自身下载接口

Lua 包装确认游戏提供：

```lua
c_scene_downloadfile(filename)
c_scene_downloadflag(flag)
c_scene_downloadqueryfile(filename)
c_scene_downloadqueryflag(flag)
```

`loading.lua` 在进图时调用 `downloading_startflag(mapid)`。外部离线下载更适合批处理；客户端接口更适合让游戏自行维护本地清单状态。

## 8. 依赖注意事项

当前未下载地图的场景记录各自是对应下载 flag 的主要记录，且场景本身已包含大量 Unity 对象。不要仍然假设所有跨场景共享对象都内嵌：

- 先用 UnityPy 加载场景；
- 统计无法解析的 PPtr/外部文件；
- 只有发现缺失依赖时，再根据资源清单和 `dependencies.bin` 补充下载；
- 不要靠文件名盲扫整个 CDN。
