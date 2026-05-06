# Contributing

Thanks for taking the time. This is a tiny project with one rule: **prove it works
on bash 3.2 (macOS) and bash 5+ (Linux).** CI runs on both.

## Local checks

```bash
bash -n claude-update          # syntax
./test/test.sh                 # 8 cases / 37 assertions, no network, no deps
shellcheck claude-update       # optional but appreciated
```

## Adding a feature

1. If it changes user-facing behavior, **add a test case** in `test/test.sh`.
   The runner is plain bash; copy any existing case and adapt.
2. If it changes the CHANGELOG slicer (`awk` block in `claude-update`), update
   `test/fixtures/changelog.md` so the new path is exercised.
3. Update **both** `README.md` (English) and `README.zh.md` (Chinese) if you
   touch behavior or flags.
4. Keep dependencies to: `bash 3.2+`, `awk`, `curl`, `less`. No extras.

## PR checklist

- [ ] `./test/test.sh` passes locally
- [ ] CI green on ubuntu + macos
- [ ] README files in sync
- [ ] One commit per logical change; subject in imperative mood

## Reporting bugs

Open an issue with:
- `claude --version` output
- `bash --version` (first line)
- The exact command you ran and the full output

For ideas / questions, prefer
[Discussions](https://github.com/harrisliangsu/claude-update/discussions).
