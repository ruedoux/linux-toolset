from setuptools import setup, find_packages

setup(
    name="linux-toolset",
    version="0.1",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[],
    entry_points={
        "console_scripts": [
            "linux-toolset = linux_toolset.main:main",
        ],
    },
)
