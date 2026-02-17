# mscrub — Project Context

CLI tool that scrubs personal and proprietary details from text before passing to AI agents. Single bash script, no heavy dependencies.

## Key decisions

- **No regex** — `find` values are treated as literal strings only
- **`jq`** for JSON parsing, **`sed`** for replacements (replaced Python early on)
- **`jq`** is the only external dependency (besides bash)
- Config lives at `~/.mscrub.json` by default, overridable with `-c`
- `defaultCaseSensitive` at top level, per-rule `caseSensitive` overrides it

## Config format (`~/.mscrub.json`)

```json
{
  "defaultCaseSensitive": false,
  "resolutions": [
    {
      "description": "optional human note",
      "find": "literal string to find",
      "replacement": "[REDACTED_LABEL]",
      "caseSensitive": true
    }
  ]
}
```

## Script structure

- `VERSION` — bump this when releasing
- `do_update()` — downloads latest from GitHub main, replaces installed binary
- `do_config()` — pretty-prints config via jq
- Subcommands handled before `getopts`: `update`, `config`
- Long flags handled via manual loop: `--help`, `--version`
- Input → temp file → sed passes → output (avoids shell mangling)
- `set -euo pipefail` — fail loud and early

## Versioning

- Version string is hardcoded at the top of `mscrub` as `VERSION="x.x.x"`
- Releases are created manually on GitHub with the `mscrub` script attached as an asset
- `mscrub update` pulls from `main` branch raw URL

## Repo

- Public: https://github.com/hinkley-dev/mscrub
- README: https://github.com/hinkley-dev/mscrub/blob/main/README.md
- Do not co-author commits
- Do not use `gh` CLI — use git command line
