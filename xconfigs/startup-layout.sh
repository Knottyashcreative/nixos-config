# Workspace and layout setup
swaymsg "workspace 1"
swaymsg "exec firefox"
swaymsg "split v"
swaymsg "exec kitty" # Terminal
swaymsg "split h"
swaymsg "exec dolphin"
swaymsg "move up"
swaymsg "workspace 2"
swaymsg "exec firefox"
swaymsg "split v"
swaymsg "exec kitty"
swaymsg "workspace 1"
swaymsg "exec joplin"
swaymsg "[app_id=\"joplin\"] move scratchp
