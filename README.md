# mscrub
Command line tool for scrubbing personal and proprietary details from text — useful for safely passing error messages and logs.

```
$ mscrub error.log
```

```
Error: connection refused at /home/jsmith/projects/apollo-backend/db/client.js:42
    at /home/jsmith/projects/apollo-backend/node_modules/pg/lib/connection.js:54
```
↓
```
Error: connection refused at /home/[REDACTED_USER]/projects/[REDACTED_PROJECT]/db/client.js:42
    at /home/[REDACTED_USER]/projects/[REDACTED_PROJECT]/node_modules/pg/lib/connection.js:54
```

## Installation

### Direct download (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/hinkley-dev/mscrub/main/mscrub -o ~/.local/bin/mscrub && chmod +x ~/.local/bin/mscrub
```

This downloads the script directly to `~/.local/bin`. You can open it and read it before running it.

If `~/.local/bin` isn't on your `PATH` yet, add this to your `~/.bashrc` or `~/.zshrc` and restart your shell:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### System-wide install (requires sudo)

```bash
curl -fsSL https://raw.githubusercontent.com/hinkley-dev/mscrub/main/mscrub -o /usr/local/bin/mscrub && chmod +x /usr/local/bin/mscrub
```

### Releases

Versioned releases with the script attached as a download are available on the [releases page](https://github.com/hinkley-dev/mscrub/releases).

### From a cloned repo

```bash
git clone https://github.com/hinkley-dev/mscrub.git
cd mscrub
./install.sh           # installs to ~/.local/bin
./install.sh --system  # installs to /usr/local/bin
```

### Requirements

- `bash`
- [`jq`](https://jqlang.github.io/jq/)

---

Then create your config file at `~/.mscrub.json` (see [Configuration](#configuration) below).

## Usage

```
mscrub [OPTIONS] [INPUT]
```

**INPUT** can be:
- A file path — if the path exists as a file, it is read as the input
- A literal string — passed directly
- Omitted — reads from stdin

**SUBCOMMANDS:**

| Subcommand | Description |
|------------|-------------|
| `mscrub update` | Update mscrub to the latest version from GitHub |
| `mscrub config` | Print the current config file |
| `mscrub config -c <file>` | Print a specific config file |

**OPTIONS:**

| Flag | Description |
|------|-------------|
| `-o <file>` | Write output to a file instead of stdout |
| `-c <file>` | Use a custom config file (default: `~/.mscrub.json`) |
| `-h`, `--help` | Show help |
| `--version` | Show the current version |

### Examples

```bash
# Scrub a string directly
mscrub "Error reported by jsmith on project apollo-backend"

# Scrub a log file, print to stdout
mscrub error.log

# Scrub a log file and write the result to a new file
mscrub error.log scrubbed.log

# Same thing using the -o flag
mscrub -o scrubbed.log error.log

# Pipe input
cat error.log | mscrub

# Paste a multi-line error message directly (single quotes around EOF prevent special characters being interpreted)
mscrub << 'EOF'
paste your error here
EOF

# Use a custom config file
mscrub -c ~/work/.mscrub.json error.log
```

## Configuration

mscrub looks for its config at `~/.mscrub.json` by default.

### Top-level properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `resolutions` | array | required | List of find-and-replace rules |
| `defaultCaseSensitive` | boolean | `true` | Default case sensitivity for all rules. Can be overridden per rule. |

### Resolution rule properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `find` | string | yes | The text to search for |
| `replacement` | string | yes | The text to replace it with |
| `caseSensitive` | boolean | no | Overrides `defaultCaseSensitive` for this rule |
| `description` | string | no | Human-readable note about what this rule scrubs. Not used by the tool. |

Rules are applied in order from top to bottom.

### Example `~/.mscrub.json`

```json
{
  "defaultCaseSensitive": false,
  "resolutions": [
    {
      "description": "Developer email address",
      "find": "jsmith@acme.com",
      "replacement": "[REDACTED_EMAIL]"
    },
    {
      "description": "Internal project name",
      "find": "apollo-backend",
      "replacement": "[REDACTED_PROJECT]",
      "caseSensitive": true
    },
    {
      "description": "Developer username",
      "find": "jsmith",
      "replacement": "[REDACTED_USER]"
    }
  ]
}
```

> **Tip:** Put more specific rules (like an email address) before more general ones (like a username) so the specific match runs first. In the example above, `jsmith@acme.com` is replaced before `jsmith`, preventing a partial match from mangling the email.

## How it works

mscrub reads the input, then walks through the `resolutions` array in order, applying each `find`/`replacement` pair as a plain string substitution. No regex is used — `find` values are treated as literal strings.
