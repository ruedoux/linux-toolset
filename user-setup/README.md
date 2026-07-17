# USER SETUP

Prepares user environment, doesnt require sudo - everything is self contained to an invidual user.

## First Time Use

Run [setup.sh](setup.sh) - prepares everything, UI, copies dots - safe to run multiple times, but overrides dots changes - excluding files like wallpaper and user created bashrc-extension.sh.

## User maintanance and utils

All user wide commands that could be useful are in [setup.sh](.config/simple-linux). They are safe to run multiple times, but override **some** dots files (look [templates](.config/simple-linux/templates)).

[update.sh](.config/simple-linux/update.sh) - updates everything.
[update-wallpaper.sh](.config/simple-linux/update-wallpaper.sh) - updates wallpaper and extracts colors for themes, updates templates.
[update-packages.sh](.config/simple-linux/update.sh) - updates/installs [packages](.config/simple-linux/packages).
[install-packages.sh](.config/simple-linux/update.sh) - updates/installs a single [package](.config/simple-linux/packages).

You can manually edit some of the settings that influence update commands in [config.env](.config/simple-linux/config.env).