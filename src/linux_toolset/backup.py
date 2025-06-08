import getpass
import os
import subprocess

from linux_toolset.logger import SimpleLogger


class BackupCreator:
    def __init__(self, logger: SimpleLogger) -> None:
        self.logger = logger

    def restic_backup(
        self, backup_target: str, include_file: str, exclude_file: str
    ) -> None:
        self._check_repo_exists(backup_target)
        self.logger.info(msg=f"Backup to local repository: {backup_target}")
        subprocess.run(
            [
                "restic",
                "-r",
                backup_target,
                "backup",
                "--files-from",
                include_file,
                "--iexclude-file",
                exclude_file,
                "--tag",
                "main",
                "--compression",
                "max",
            ],
            check=True,
        )
        self.logger.info(f"Prune old snapshots: {backup_target}")
        subprocess.run(
            [
                "restic",
                "-r",
                backup_target,
                "forget",
                "--keep-within-daily",
                "7d",
                "--keep-within-weekly",
                "1m",
                "--prune",
            ],
            check=True,
        )
        self.logger.info(msg=f"Snapshots for {backup_target}:")
        subprocess.run(["restic", "-r", backup_target, "snapshots"], check=True)

    def copy(self, repo_path: str, destination_path: str) -> None:
        self.logger.info(f"Copying repository '{repo_path}' to '{destination_path}'")
        subprocess.run(
            ["rsync", "-arz", "--delete", f"{repo_path}/", destination_path],
            check=True,
        )
        self.logger.info(f"Finished copying '{destination_path}'")

    def backup_all(
        self,
        local_repositories: list[str],
        include_file_path: str,
        exclude_file_path: str,
        copy_destinations: dict[str, str],
    ) -> None:
        if not local_repositories:
            self.logger.error("No repo for backup")
            return
        if not os.path.exists(include_file_path):
            self.logger.error(f"File does not exist '{include_file_path}'")
            return
        if not os.path.exists(exclude_file_path):
            self.logger.error(f"File does not exist '{include_file_path}'")
            return

        os.environ["RESTIC_PASSWORD"] = getpass.getpass("Input password: ")
        try:
            for repository_path in local_repositories:
                self.restic_backup(
                    repository_path, include_file_path, exclude_file_path
                )
        except Exception as e:
            self.logger.error("Could not backup to repository: %s", e, exc_info=True)
        os.environ["RESTIC_PASSWORD"] = ""

        for repo_path, destination_path in copy_destinations.items():
            try:
                self.copy(repo_path, destination_path)
            except Exception as e:
                self.logger.error(
                    f"Could copy from {repo_path} to {destination_path} to path: %s",
                    e,
                    exc_info=True,
                )

    def _check_repo_exists(self, backup_target: str) -> None:
        repo_exists = True
        try:
            subprocess.run(
                ["restic", "-r", backup_target, "snapshots"],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except subprocess.CalledProcessError:
            repo_exists = False

        if repo_exists:
            return

        decision = input(
            f"Repo '{backup_target}' not found, do you want to create one? [Y/n]"
        )
        if decision != "" and decision.lower() != "y":
            return

        self.logger.info(f"Initializing restic repo at: {backup_target}")
        subprocess.run(
            ["restic", "-r", backup_target, "init"],
            check=True,
        )
