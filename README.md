# claude-update

一个把 `claude update` 和「这次更新带来了什么」拼在一起的小工具。

执行 `claude update`，然后从官方仓库拉取
[CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md)，
精确截取「旧版本 → 新版本」之间所有版本的更新说明并彩色打印。

## 使用

```bash
./claude-update              # 默认：逐版本浏览（每个版本独立一页）
./claude-update --combined   # 合并所有版本到一页里滚动
./claude-update --no-pager   # 直接打印全部，不进入交互
./claude-update -h           # 帮助
```

### 逐版本浏览（默认）

把 `(旧版本, 新版本]` 区间内的每个版本切到独立页面，交给 `less` 多文件模式。
状态栏会显示 `(2/5)` 这样的进度。

| 按键 | 作用 |
| --- | --- |
| `:n` 或 `Space` | 下一版本 |
| `:p` | 上一版本 |
| `↑ ↓ PgUp PgDn` | 当前版本内滚动 |
| `g` / `G` | 跳到首/末行 |
| `/pattern` | 搜索 |
| `q` | 退出 |

非 TTY（管道、CI）下自动回退到直接打印。

输出示例：

```
当前版本：2.1.126
▶ 执行 claude update ...
▶ 拉取 CHANGELOG ...

━━━ 更新内容 ━━━

## 2.1.129
• Added `--plugin-url <url>` ...
## 2.1.128
• Bare `/color` (no args) ...
## 2.1.127
• ...
```

如果当前已是最新版本，会展示该版本的 CHANGELOG 单节。

## 安装到 PATH

```bash
./install.sh                       # 默认链接到 ~/.local/bin
PREFIX=/usr/local ./install.sh     # 或自定义前缀
```

之后可在任意目录直接执行 `claude-update`。

## 环境变量

- `CLAUDE_UPDATE_CHANGELOG_URL`：覆盖 CHANGELOG 来源（用于内网镜像或测试）。
- `CLAUDE_UPDATE_PAGER` / `PAGER`：覆盖 pager 命令，默认 `less -RFX`。

## 依赖

- `claude` CLI
- `curl`
- `awk`、`bash 3.2+`（macOS 系统 bash 即可）
- `less`（逐版本浏览模式需要；缺失时会回退到合并模式）

## 许可

MIT
