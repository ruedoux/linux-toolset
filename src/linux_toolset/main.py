from linux_toolset.logger import SimpleLogger
from linux_toolset.toolset import Toolset


def main() -> None:
    Toolset(logger=SimpleLogger(level="DEBUG")).parse_commands()


if __name__ == "__main__":
    main()
