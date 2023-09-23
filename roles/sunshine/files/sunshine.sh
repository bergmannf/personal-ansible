#!/usr/bin/env sh

if [ $# -lt 1 ]; then
    echo "Must pass either 'start' or 'stop' action"
    exit 1
fi

ACTION=$1
DISABLE_MONITOR="HDMI-A-1"
MAIN_MONITOR="DP-3"
RESOLUTION_FILE=/tmp/monitor-resolution
SWAY_GAMING_WORKSPACE=6

function store_old_resolution {
    echo "Saving original resolution to $RESOLUTION_FILE"
    # Refreshrate is not in Hz but Hz * 1000
    swaymsg -t get_outputs | jq -r ".[] | select(.name ==\"$MAIN_MONITOR\").current_mode | {\"width\": .width,\"height\": .height, \"refresh\": (.refresh/1000)}" > $RESOLUTION_FILE
}

function restore_old_resolution {
    WIDTH=$(jq '.width' < $RESOLUTION_FILE)
    HEIGHT=$(jq '.height' < $RESOLUTION_FILE)
    REFRESH=$(jq '.refresh' < $RESOLUTION_FILE)
    echo "Restoring original resolution to ${WIDTH}x${HEIGHT}@${REFRESH}Hz"
    # Try to restore and remove the restore file if successful
    swaymsg output "$MAIN_MONITOR" mode "${WIDTH}x${HEIGHT}@${REFRESH}Hz" && rm "$RESOLUTION_FILE"
}

echo "Performing action: $ACTION"
if [[ $DESKTOP_SESSION == "sway" ]]; then
    if [[ $ACTION == "start" ]]; then
        if [ ! -f "$RESOLUTION_FILE" ]; then
            store_old_resolution
        fi
        swaymsg output "$DISABLE_MONITOR" disable
        echo "Changing output resolution to 1920x1080@60Hz"
        swaymsg output "$MAIN_MONITOR" mode "1920x1080@60Hz"
        swaymsg workspace number $SWAY_GAMING_WORKSPACE
        exit 0
    elif [[ $ACTION == "stop" ]]; then
        swaymsg output "$DISABLE_MONITOR" enable
        if [ -f "$RESOLUTION_FILE" ]; then
            restore_old_resolution
        fi
        exit 0
    else
        echo "Received unknown command: $ACTION"
        exit 1
    fi
else
    echo "Only sway is currently supported"
fi

exit  0
