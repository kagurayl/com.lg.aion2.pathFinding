# AI HANDOFF：Aion2 离线寻路项目

## 1. 最终目标

建立独立、可部署的 Python 寻路后端：

```text
游戏客户端下载的 Unity 地图场景
→ 离线导出 Terrain、MeshCollider、BoxCollider 和世界 Transform
→ Recast/Detour tiled navmesh 烘焙
→ 服务器只加载预处理后的 .navmesh
→ HTTP 输入地图 ID、起点 XYZ、终点 XYZ
→ 返回绕过静态障碍的 Unity 世界 XYZ 路径点
→ 游戏侧 packetwalk 按节点执行
```

线上服务器不得依赖游戏客户端、模拟器、Unity Runtime、Lua VM、Frida、游戏网络连接或原始 Unity 场景。

## 2. 当前已完成

### Unity 碰撞导出

实现：`pathfinding/unity_export.py`

支持：

- `TerrainCollider / TerrainData`，包括高度和 holes；
- `MeshCollider`；
- `BoxCollider`；
- 完整父子 Transform、四元数旋转、非均匀缩放；
- 负缩放时修正三角形绕序；
- Mesh 去重和 NPZ/JSON 元数据输出。

`lf1` 已导出：

```text
世界坐标顶点：4,367,712
三角形：4,995,938
MeshCollider：4,729
TerrainCollider：1
唯一 Mesh：520
解析错误：0
```

碰撞数据：

```text
data/lf1/collision.npz
data/lf1/collision.json
```

Terrain 高度解码采用：

```text
raw_height / 32767 * scale.y
```

坐标为 Unity 世界 XYZ，Y-up，不要交换 Y/Z，也不要把坐标当屏幕像素。

### Recast/Detour

原生模块源文件：

```text
native/src/recast_native.cpp
native/CMakeLists.txt
third_party/recastnavigation/
```

接口：

```text
NavMesh.build
NavMesh.save
NavMesh.load
NavMesh.sample_position
NavMesh.find_path
NavMesh.line_of_sight
NavMesh.tile_count
```

使用 tiled Recast、PartitionedMesh tile 空间筛选、多线程 tile 构建、NumPy 连续数组输入，并在长时间原生构建期间释放 Python GIL。

Detour corridor 若未到达目标 poly，必须报错，不能把部分路径伪装成完整路径。

### lf1 导航产物

```text
maps/lf1.navmesh
maps/lf1.json
```

关键数据：

```text
Tile：625
大小：50,868,520 字节
SHA-256：a3e82ae09186b5bfbef2736c621d5f41d1b7ada27c2ef0da395112a0675996ed
```

烘焙参数：

```text
cell_size = 0.5
cell_height = 0.2
agent_height = 1.8
agent_radius = 0.45
agent_max_climb = 0.6
agent_max_slope = 45
tile_size = 256
```

### HTTP 服务

实现：

```text
pathfinding/runtime.py
pathfinding/http_server.py
pathfinding/serve.py
```

端点：

```text
GET /health
POST /path
OPTIONS
```

路径默认约每 1.8 米加密一个节点。真实 `lf1` 验证：

```text
start  = [1231.380371094, 143.960220337, 1040.371582031]
target = [1146.451660156, 129.992004395, 1046.642333984]
Detour 原始转折点：6
HTTP 返回节点：52
```

清理构建产物之前，完整测试最后一次结果为：

```text
17 passed
```

## 3. 当前地图状态

资源清单精确登记 78 张 `levels/<map>/<map>.unity.scene`：

```text
已物理下载：lf1、df1、login2
已完成碰撞导出和导航烘焙：lf1
已下载但未处理：df1、login2
尚未下载：75 张
```

完整 URL 见根目录 `map_download_links.txt`。

当前仓库不包含原始 `.unity.scene`。原场景在工作机仓库外的 `device_snapshot/levels/`；服务器部署也不需要它们。

## 4. 当前仓库状态

为上传 GitHub，已删除所有生成型构建产物：

- `native/build/`；
- `.venv/`；
- `.pytest_cache/`、`__pycache__/`、`*.pyc`；
- `*.pyd`、`*.so`、`*.dll`、`*.obj`、`*.lib`、`*.exp`、`*.pdb`；
- Python egg-info。

因此刚 clone 后不能直接启动 HTTP，必须先按根目录 `README.md` 编译 `recast_native`。源码、最小 Recast/Detour vendor、CMake 和测试仍保留，构建可复现。

## 5. 后续建议顺序

1. 从 `df1` 开始运行 `unity_export.py` 和 `build_navmesh.py`，验证第二张地图完整闭环。
2. `login2` 是登录场景，优先级低。
3. 使用 `map_download_links.txt` 下载所需地图，不要一次默认下载全部 75 张（约 7.79 GiB）。
4. 每张下载后先核验 `size_bytes` 和 XXH64，再交给 UnityPy。
5. 为每张地图生成：
   - `data/<map>/collision.npz`
   - `data/<map>/collision.json`
   - `maps/<map>.navmesh`
   - `maps/<map>.json`
6. 用地图内真实游戏坐标验证地形高度、投影、路径连通和 HTTP。
7. 最后才批量化，不要在单张地图闭环失败时直接扩成 78 张。

## 6. 已知限制

- 静态 navmesh 不自动处理玩家、NPC、怪物、门、电梯和移动平台。
- 79 个 `lf1` BoxCollider 全是 trigger，默认未纳入；其中可能包含事件区或空气墙，不能无条件全作为障碍。
- 水面、特殊材质和不可行走区域可能需要后续语义过滤。
- Windows 二进制不能部署到 Linux；Linux 必须重编译扩展。
- GitHub 单文件限制通常为 100 MB。现有最大文件 `maps/lf1.navmesh` 约 50.9 MB，可普通提交；未来大地图产物可能需要 Git LFS 或 Release。
