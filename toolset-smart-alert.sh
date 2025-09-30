#!/bin/bash

# Setup via smartd 
# Add this to `/etc/smartd.conf`: "DEVICESCAN -m your@email.com -M exec /path/toolset-smart-alert.sh"
local script_dir="$(dirname "$(realpath "$0")")"
"$script_dir/toolset-alerts.sh" create -d ${script_dir}/alerts -m "Fail type: $SMARTD_FAILTYPE\n$SMARTD_MESSAGE"