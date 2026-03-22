#!/bin/bash
# Show eww widgets when workspace 6 is active on DP-3, hide otherwise

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

active_ws_on_dp3() {
    hyprctl monitors -j 2>/dev/null \
        | python3 -c "
import sys, json
for m in json.load(sys.stdin):
    if m['name'] == 'DP-3':
        print(m['activeWorkspace']['id'])
" 2>/dev/null
}

apply_state() {
    local ws
    ws=$(active_ws_on_dp3)
    if [[ "$ws" == "6" ]]; then
        eww open stats-widget   2>/dev/null
        eww open weather-widget 2>/dev/null
    else
        eww close stats-widget   2>/dev/null
        eww close weather-widget 2>/dev/null
    fi
}

# Apply initial state
apply_state

# Watch for workspace/monitor changes
socat - "UNIX-CONNECT:$SOCKET" 2>/dev/null | while IFS= read -r line; do
    event="${line%%>>*}"
    case "$event" in
        workspace|workspacev2|focusedmon|monitoraddedv2|monitorremoved)
            apply_state
            ;;
    esac
done
