# claude-update

[![CI](https://github.com/harrisliangsu/claude-update/actions/workflows/ci.yml/badge.svg)](https://github.com/harrisliangsu/claude-update/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![bash 3.2+](https://img.shields.io/badge/bash-3.2%2B-yellow.svg)](#%E4%BE%9D%E8%B5%96)
[![macOS | Linux](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](#%E4%BE%9D%E8%B5%96)

> 把 `claude update` 和「这次更新带来了什么」拼在一起。
> [English README](README.md) · [Discussions](https://github.com/harrisliangsu/claude-update/discussions) · [Issues](https://github.com/harrisliangsu/claude-update/issues)

执行 `claude update`，再从官方仓库拉取
[CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md)，
精确截取「旧版本 → 新版本」之间所有版本的更新说明，每个版本独立一页可滚动。

CHANGELOG 与升级**并发拉取**，关键路径只有升级本身。

## 使用

```bash
./claude-update              # 默认：逐版本浏览（每个版本独立一页）
./claude-update --combined   # 合并所有版本到一页里滚动
./claude-update --no-pager   # 直接打印全部，不进入交互
./claude-update -h           # 帮助
```

### 逐版本浏览（默认）

把 `(旧版本, 新版本]` 区间内的每个版本切到独立页面，交给 `less` 多文件模式。
状态栏会显示当前版本号 + 进度 `(2/5)`。

| 按键 | 作用 |
| --- | --- |
| `:n` 或 `Space` | 下一版本 |
| `:p` | 上一版本 |
| `↑ ↓ PgUp PgDn` | 当前版本内滚动 |
| `g` / `G` | 跳到首/末行 |
| `/pattern` | 搜索 |
| `q` | 退出 |

非 TTY（管道、CI）下自动回退到直接打印。

### 输出示例

```
current version: 2.1.126
▶ running claude update ...
▶ fetching CHANGELOG ...

Claude Code 2.1.129   (1/3)   :n next  :p prev  q quit
```

如果当前已是最新版本，仍展示该版本的 CHANGELOG 单节。

### 已处理的边界

- **跳号升级**：旧版本没出现在 CHANGELOG 中（Anthropic 并非每个补丁都发布）也能用
  semver 数值比较收敛。
- **首次安装**：未检测到旧版本时，只展示最新版本一节，不会把整个历史砸到屏上。
- **预发布版本**：`2.1.130-beta1` 按 release 部分排序，stderr 单行提示存在 prerelease。
- **升级成功但 CHANGELOG 拉取失败**：升级仍完成，只在展示阶段报错。

## 安装到 PATH

```bash
./install.sh                       # 默认链接到 ~/.local/bin
PREFIX=/usr/local ./install.sh     # 自定义前缀
```

之后任意目录直接执行 `claude-update`。

## 环境变量

- `CLAUDE_UPDATE_CHANGELOG_URL`：覆盖 CHANGELOG 来源（内网镜像、测试）。
- `CLAUDE_UPDATE_PAGER` / `PAGER`：覆盖 pager 命令，默认 `less -RFX`。

## 测试

```bash
./test/test.sh
```

纯 bash，零测试框架依赖。Stub `claude` CLI、`file://` 本地 fixture CHANGELOG，
完全离线。CI 在 Ubuntu（bash 5）+ macOS（系统 bash 3.2）每次 push 都跑。

## 依赖

- `claude` CLI（Claude Code）
- `curl`
- `awk`、`bash 3.2+`（macOS 系统 bash 即可）
- `less`（逐版本浏览模式需要；缺失时自动回退到合并模式）

## 许可

[MIT](LICENSE)
