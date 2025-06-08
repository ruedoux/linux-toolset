# linux-toolset

Utility tool made in Python to simplify backup and other mundane commands.

## Installation

The tool uses these cli tools to perform backups: `restic` and `rsync`.
Tested on `python 3.10.6`

```sh
# Clone the repository and cd into it
git clone https://github.com/ruedoux/linux-toolset.git
cd linux-toolset
pip install .
```

## Usage

```
usage: linux-toolset [-h] [-c CONFIG] {backup,custom-command} ...
```

## Examples

```sh
linux-toolset backup --config /path/to/config.json
# Performs a backup based on config.json

linux-toolset custom-command health --config /path/to/config.json
# Runs the "health" custom command as defined in config.json
```

Example config.json:

```json
{
  "backup": {
    "target-repositories": ["/repository/path"],
    "includes": ["/file/path/or/folder/path"],
    "excludes": [
      "**/.git",
      "**/bin",
      "**/obj",
      "**/build",
      "**/*.egg-info",
      "**/__pycache__"
    ],
    "copy-destinations": ["my-server:/path/on/server", "/some/local/path"]
  },
  "custom-commands": {
    "health": [
      {
        "command": "echo works",
        "comment": "health check"
      }
    ]
  }
}
```
