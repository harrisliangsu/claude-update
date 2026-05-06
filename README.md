# claude-update

[![CI](https://github.com/harrisliangsu/claude-update/actions/workflows/ci.yml/badge.svg)](https://github.com/harrisliangsu/claude-update/actions/workflows/ci.yml)
[![npm version](https://img.shields.io/npm/v/claude-update.svg)](https://www.npmjs.com/package/claude-update)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![bash 3.2+](https://img.shields.io/badge/bash-3.2%2B-yellow.svg)](#dependencies)
[![macOS | Linux](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](#dependencies)

> Run `claude update` and read what actually changed, in one shot.
> [中文 README](README.zh.md) · [npm](https://www.npmjs.com/package/claude-update) · [Discussions](https://github.com/harrisliangsu/claude-update/discussions) · [Issues](https://github.com/harrisliangsu/claude-update/issues)

`claude-update` runs `claude update`, then pulls the official
[CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md)
and prints the entries covering exactly the `(old_version, new_version]` range —
each version on its own scrollable page so you can step through them with `:n` / `:p`.

The CHANGELOG is fetched in parallel with the upgrade, so the only thing on the
critical path is the upgrade itself.

## Install

Run once from the npm registry:

```bash
npx claude-update
```

Install globally from the npm registry:

```bash
npm install -g claude-update
claude-update
```

Install from a local checkout:

```bash
./install.sh                       # symlink into ~/.local/bin (default)
PREFIX=/usr/local ./install.sh     # or pick another prefix
```

## Usage

```bash
claude-update              # default: per-version browsing (one page per version)
claude-update --combined   # merge all versions into a single scrollable buffer
claude-update --no-pager   # plain print, no interactive pager
claude-update -h           # help
```

### Per-version browsing (default)

Each version in `(old_version, new_version]` is written to its own page and handed
to `less` in multi-file mode. The status bar shows the current version and progress
(e.g. `(2/5)`).

| Key | Action |
| --- | --- |
| `:n` or `Space` | next version |
| `:p` | previous version |
| `↑ ↓ PgUp PgDn` | scroll within the current version |
| `g` / `G` | jump to first / last line |
| `/pattern` | search |
| `q` | quit |

Non-TTY contexts (pipes, CI) automatically fall back to plain print.

### Output example

```
current version: 2.1.126
▶ running claude update ...
▶ fetching CHANGELOG ...

Claude Code 2.1.129   (1/3)   :n next  :p prev  q quit
```

If you are already on the latest version, the CHANGELOG section for that version
is still shown.

### Edge cases handled

- **Skipped releases** — if your old version isn't listed in the CHANGELOG (Anthropic
  doesn't publish every patch), the slicer still terminates correctly using semver
  numeric comparison.
- **First install** — when no previous version is detected, only the newest version's
  section is shown instead of dumping the entire history.
- **Prereleases** — entries like `2.1.130-beta1` are sorted by their release version
  and a one-line note is printed to stderr so you know they exist.
- **Update succeeds, CHANGELOG fails** — the upgrade still completes; only the
  CHANGELOG display step errors out.

## Environment variables

- `CLAUDE_UPDATE_CHANGELOG_URL` — override the CHANGELOG source (mirrors,
  testing).
- `CLAUDE_UPDATE_PAGER` / `PAGER` — pager command for `--combined` mode
  (default `less -RFX`).

## Testing

```bash
./test/test.sh
npm pack --dry-run
```

Pure bash, no external test framework. Stubs the `claude` CLI and serves a
local fixture CHANGELOG via `file://` so the suite runs offline. CI runs it on
both Ubuntu (bash 5) and macOS (system bash 3.2) on every push.

## Dependencies

- `claude` CLI (Claude Code)
- `curl`
- `awk`, `bash 3.2+` (macOS system bash works)
- `less` (only needed for per-version browsing; absent → falls back to combined mode)

## License

[MIT](LICENSE)
