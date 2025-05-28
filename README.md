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
linux-toolset: error: the following arguments are required: command
```

## Examples

```sh
linux-toolset --config /path/to/config.json backup
# Performs a backup based on config.json

linux-toolset --config /path/to/config.json custom-command health
# Runs the "health" custom command as defined in config.json
```

Example config.json:

```json
{
  "backup": {
    "repository-paths": ["/repository/path"],
    "includes": ["/file/path/or/folder/path"],
    "excludes": ["/exclude/file/path"],
    "remotes": ["my-server:/path/on/server/to/repository"]
  },
  "custom-commands": {
    "health": [
      {
        "command": "echo works",
        "comment": "health check"
      }
    ],
    "ports": [
      {
        "command": "sudo  ss -lpntu",
        "comment": "Listing open ports via 'ss -lpntu'"
      },
      {
        "command": "sudo netstat -lpntu",
        "comment": "Listing open ports via 'netstat -lpntu'"
      }
    ]
  }
}
```
