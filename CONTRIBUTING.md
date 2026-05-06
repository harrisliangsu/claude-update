# Contributing

Thanks for taking the time. This is a tiny project with one rule: **prove it works
on bash 3.2 (macOS) and bash 5+ (Linux).** CI runs on both.

## Local checks

```bash
bash -n claude-update          # syntax
npm run syntax                 # syntax via package script
npm run version:check          # package.json version matches CLI version
./test/test.sh                 # offline behavior suite, no network, no deps
npm pack --dry-run             # verify npm tarball contents
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
- [ ] `npm pack --dry-run` contains only the intended package files
- [ ] CI green on ubuntu + macos
- [ ] README files in sync
- [ ] One commit per logical change; subject in imperative mood

## Publishing to npm

The npm package is intentionally a thin wrapper around the existing Bash CLI.
`package.json` exposes `claude-update` through the `bin` field; no JavaScript
shim or runtime npm dependencies are required.

Before publishing:

```bash
npm login
npm test
npm pack --dry-run
npm publish
```

If the unscoped `claude-update` name becomes unavailable, publish under a scope
instead, for example `@harrisliangsu/claude-update`, and update the README
install commands in the same change.

## Reporting bugs

Open an issue with:
- `claude --version` output
- `bash --version` (first line)
- The exact command you ran and the full output

For ideas / questions, prefer
[Discussions](https://github.com/harrisliangsu/claude-update/discussions).
