#!/usr/bin/env sh


if [ $# -lt 1 ]; then
    echo "Must pass either 'start' or 'stop' action"
    exit 1
fi

ACTION=$1
DISABLE_MONITOR="DP-3"
MAIN_MONITOR="DP-2"
RESOLUTION_FILE=/tmp/monitor-resolution
STREAM_WIDTH=${SUNSHINE_CLIENT_WIDTH}
STREAM_HEIGHT=${SUNSHINE_CLIENT_HEIGHT}
REFRESH=${SUNSHINE_CLIENT_FPS}
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

echo "Performing action: $ACTION for $DESKTOP_SESSION"
echo "Width: ${STREAM_WIDTH}"
echo "Height: ${STREAM_HEIGHT}"
echo "Refresh: ${REFRESH}"
if [[ $XDG_CURRENT_DESKTOP == "sway" || $XDG_SESSION_DESKTOP == "sway" ]]; then
    if [[ $ACTION == "start" ]]; then
        if [ ! -f "$RESOLUTION_FILE" ]; then
            store_old_resolution
        fi
        swaymsg output "$DISABLE_MONITOR" disable
        swaymsg output "$MAIN_MONITOR" mode "${STREAM_WIDTH}x${STREAM_HEIGHT}@${REFRESH}Hz"
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
elif [[ $XDG_CURRENT_DESKTOP == "gnome" ]]; then
    if [[ $ACTION == "start" ]]; then
        gnome-monitor-config set -LpM DP-3 -m "${STREAM_WIDTH}x${STREAM_HEIGHT}@${REFRESH}"
    elif [[ $ACTION == "stop" ]]; then
        gnome-monitor-config set -LpM DP-3 -m "2560x1440@120.049" -LM DP-2 -x 2560 -y 0 -m "2560x1440@59.951"
    fi
elif [[ $XDG_CURRENT_DESKTOP == "Hyprland" ]]; then
    if [[ $ACTION == "start" ]]; then
        hyprctl keyword monitor ${DISABLE_MONITOR},disable
        hyprctl keyword monitor ${MAIN_MONITOR},"${STREAM_WIDTH}x${STREAM_HEIGHT}@${REFRESH}",auto,1
    elif [[ $ACTION == "stop" ]]; then
        hyprctl keyword monitor ${DISABLE_MONITOR},preferred,auto,1
        hyprctl keyword monitor ${MAIN_MONITOR},2560x1440@120,auto,1
    fi
elif [[ $XDG_CURRENT_DESKTOP == "KDE" ]]; then
    if [[ $ACTION == "start" ]]; then
        kscreen-doctor output.${MAIN_MONITOR}.mode.${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}
        kscreen-doctor output.${DISABLE_MONITOR}.disable
    elif [[ $ACTION == "stop" ]]; then
        kscreen-doctor output.${MAIN_MONITOR}.mode.2560x1440@144
        kscreen-doctor output.${DISABLE_MONITOR}.enable
    fi
else
    echo "Only sway is currently supported"
fi

exit  0
