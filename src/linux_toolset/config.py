import json
import os

from linux_toolset.logger import SimpleLogger


class BackupConfig:
    repository_paths: list[str]
    includes: list[str]
    excludes: list[str]
    remotes: list[str]

    def __init__(self, json_dict: dict[str, list[str]]) -> None:
        self.repository_paths = json_dict.get("repository-paths", [])
        self.includes = json_dict.get("includes", [])
        self.excludes = json_dict.get("excludes", [])
        self.remotes = json_dict.get("remotes", [])


class CommandDefinition:
    command: str
    comment: str

    def __init__(self, command: str, comment: str) -> None:
        self.command = command
        self.comment = comment


class CustomCommandsConfig:
    custom_commands: dict[str, list[CommandDefinition]]

    def __init__(self, json_dict: dict[str, list[dict[str, str]]]) -> None:
        self.custom_commands = {}

        for command, custom_commands_json in json_dict.items():
            self.custom_commands[command] = []
            for dict_json in custom_commands_json:
                self.custom_commands[command].append(
                    CommandDefinition(dict_json["command"], dict_json["comment"])
                )


class Config:
    backup: BackupConfig
    custom_commands_config: CustomCommandsConfig

    def __init__(self, config_path: str, logger: SimpleLogger) -> None:
        if not os.path.exists(path=config_path):
            logger.error(f"File does not exist: '{config_path}'")
            exit(1)

        with open(config_path) as f:
            config_json = json.load(fp=f)

        self.backup = BackupConfig(json_dict=config_json.get("backup", {}))
        self.custom_commands_config = CustomCommandsConfig(
            json_dict=config_json.get("custom-commands", {})
        )
