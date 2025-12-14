#!/bin/bash

# List of supported outputs for VRR
output_vrr_whitelist=(
    "DP-3"
)

# Toggle VRR for fullscreened apps in prespecified displays to avoid stutters while in desktop
swaymsg -t subscribe -m '[ "window" ]' | while read window_json; do
    window_event=$(echo ${window_json} | jq -r '.change')

    # Process only focus change and fullscreen toggle
    if [[ $window_event = "focus" || $window_event = "fullscreen_mode" ]]; then
        output_json=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true)')
        output_name=$(echo ${output_json} | jq -r '.name')

        # Use only VRR in whitelisted outputs
        if [[ ${output_vrr_whitelist[*]} =~ ${output_name} ]]; then
            output_vrr_status=$(echo ${output_json} | jq -r '.adaptive_sync_status')
            window_fullscreen_status=$(echo ${window_json} | jq -r '.container.fullscreen_mode')

            # Only update output if nesseccary to avoid flickering
            [[ $output_vrr_status = "disabled" && $window_fullscreen_status = "1" ]] && swaymsg output "${output_name}" adaptive_sync 1
            [[ $output_vrr_status = "enabled" && $window_fullscreen_status = "0" ]] && swaymsg output "${output_name}" adaptive_sync 0
        fi
    fi
done
