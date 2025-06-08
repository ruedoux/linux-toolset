import argparse
import subprocess
import tempfile
from argparse import Namespace
from linux_toolset.logger import SimpleLogger
from linux_toolset.config import Config
from linux_toolset.backup import BackupCreator


class Toolset:
    def __init__(self, logger: SimpleLogger) -> None:
        self.logger = logger

    def backup(self, args: Namespace) -> None:
        self.logger.info(f"Running backup...")
        config_path: str = args.config
        config = Config(config_path, logger=self.logger)
        with tempfile.TemporaryDirectory() as temp_dir_path:
            include_file_path = f"{temp_dir_path}/i.txt"
            exclude_file_path = f"{temp_dir_path}/e.txt"
            includes = config.backup.includes.copy()
            excludes = config.backup.excludes.copy()

            excludes = excludes + config.backup.matched_excludes
            with open(include_file_path, "w") as f:
                for line in includes:
                    f.write(line + "\n")
            with open(exclude_file_path, "w") as f:
                for line in excludes:
                    f.write(line + "\n")

            self.logger.info("Include paths:")
            for path in includes:
                self.logger.info(f"\t{path}")
            self.logger.info("Exclude paths:")
            for path in excludes:
                self.logger.info(f"\t{path}")
            self.logger.info("Local repository targets:")
            for path in config.backup.target_repositories:
                self.logger.info(f"\t{path}")
            self.logger.info("Copy repository targets:")
            for path in config.backup.copy_destinations:
                self.logger.info(f"\t{path}")

            BackupCreator(logger=self.logger).backup_all(
                local_repositories=config.backup.target_repositories,
                include_file_path=include_file_path,
                exclude_file_path=exclude_file_path,
                copy_destinations=config.backup.copy_destinations,
            )

        self.logger.info(f"Done!")

    def run_custom(self, args: Namespace) -> None:
        self.logger.info(f"Running custom commands...")
        config_path: str = args.config
        config = Config(config_path, logger=self.logger)
        custom_commands = config.custom_commands_config.custom_commands

        if not args.procedure in custom_commands:
            self.logger.error(f"No procedure called: {args.procedure}")
            return

        command_definitions = custom_commands[args.procedure]
        self.logger.info(f"Running command procedure: '{args.procedure}'")
        for command_definition in command_definitions:
            self.logger.info(f"Running command: '{command_definition.command}'")
            self.logger.info(f"Comment: '{command_definition.comment}'")
            try:
                subprocess.run(command_definition.command, shell=True)
            except Exception as e:
                self.logger.error("Could not run command: %s", e, exc_info=True)

        self.logger.info(f"Done!")

    def parse_commands(self) -> None:
        main_parser = argparse.ArgumentParser(add_help=False)
        main_parser.add_argument(
            "-c", "--config", default="config.json", help="Path to config file"
        )

        parser = argparse.ArgumentParser(
            description="A toolset for GNU/Linux",
            formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        )

        subparsers = parser.add_subparsers(dest="command", required=True)

        backup_parser = subparsers.add_parser(
            "backup", parents=[main_parser], help="Run the backup routine"
        )
        backup_parser.set_defaults(func=self.backup)

        custom_parser = subparsers.add_parser(
            "custom-command", parents=[main_parser], help="Run custom command"
        )
        custom_parser.add_argument("procedure", help="Custom string to provide")
        custom_parser.set_defaults(func=self.run_custom)

        args = parser.parse_args()
        args.func(args)
