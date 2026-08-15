# 仓库结构与保留策略

## 应保留

```text
README.md                       使用、编译、导出、烘焙、HTTP 说明
map_download_links.txt          78 张地图的精确 CDN URL
handoff/                        后续 AI 接手说明
pathfinding/                    Python 业务代码
native/src/recast_native.cpp    原生模块源码
native/CMakeLists.txt           跨平台构建配置
native/build_module.bat         Windows 构建入口
third_party/recastnavigation/   最小化 Recast/Detour/PartitionedMesh 源码和许可证
tests/                          回归测试
data/lf1/                       已验证碰撞数据
maps/lf1.navmesh                已验证服务器导航数据
maps/lf1.json                   烘焙参数和哈希
pyproject.toml
uv.lock
requirements*.txt
.gitignore
```

## 不提交/已清理

```text
.venv/
native/build/
build/
dist/
.pytest_cache/
**/__pycache__/
*.pyc
*.pyd
*.so
*.dll
*.obj
*.lib
*.exp
*.pdb
*.egg-info/
原始 *.unity.scene
下载中的 *.part
```

`*.pyd` 和 `*.so` 是机器、Python ABI 和平台相关的构建产物。clone 后应从源码重建，不把本机二进制当成可维护源文件。

## 开发仓库与服务器部署包

开发仓库保留完整可重建能力：Python 源码、native 源码、最小第三方源码、测试、碰撞数据和 navmesh。

服务器最小部署包只需要：

```text
pathfinding/*.py
当前服务器平台编译出的 recast_native 扩展
maps/*.navmesh
必要 Python 依赖
```

服务器不需要：

```text
third_party/
native/
tests/
data/*/collision.npz
原始 Unity 场景
模拟器或游戏客户端
```

## 大文件策略

当前 GitHub 最大文件：

```text
maps/lf1.navmesh 约 50.9 MB
data/lf1/collision.npz 约 18.5 MB
```

两者低于常见 100 MB 单文件限制。后续若某张 navmesh 或 collision 文件超过限制：

- `maps/*.navmesh` 优先放 Git LFS 或 Release；
- `collision.npz` 是可重新生成的离线中间数据，可只保留元数据和生成说明；
- 不要把 100 MB 以上原始 Unity 场景直接提交普通 Git。
