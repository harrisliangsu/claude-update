# claude-update

一个把 `claude update` 和「这次更新带来了什么」拼在一起的小工具。

执行 `claude update`，然后从官方仓库拉取
[CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md)，
精确截取「旧版本 → 新版本」之间所有版本的更新说明并彩色打印。

## 使用

```bash
./claude-update
```

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

## 依赖

- `claude` CLI
- `curl`
- `awk`、`bash 4+`

## 许可

MIT
