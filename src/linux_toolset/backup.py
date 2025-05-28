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

    def remote_backup(self, backup_target_repo: str, remote_target: str) -> None:
        self.logger.info(
            f"Performing remote backup from '{backup_target_repo}' to '{remote_target}'"
        )
        subprocess.run(
            ["rsync", "-arz", "--delete", f"{backup_target_repo}/", remote_target],
            check=True,
        )
        self.logger.info(f"Finished remote backup to '{remote_target}'")

    def backup_all(
        self,
        repository_paths: list[str],
        include_file_path: str,
        exclude_file_path: str,
        remote_targets: list[str],
    ) -> None:
        if not repository_paths:
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
            for repository_path in repository_paths:
                self.restic_backup(
                    repository_path, include_file_path, exclude_file_path
                )
        except Exception as e:
            self.logger.error("Could not backup to repository: %s", e, exc_info=True)
        os.environ["RESTIC_PASSWORD"] = ""

        for remote in remote_targets:
            try:
                self.remote_backup(repository_paths[0], remote)
            except Exception as e:
                self.logger.error(
                    "Could not backup into remote target: %s", e, exc_info=True
                )
