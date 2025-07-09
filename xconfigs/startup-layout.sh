#!/bin/sh

# Switch to workspace 1
swaymsg workspace 1

# Column 1, Row 1: Firefox
swaymsg exec "firefox"
sleep 0.2

# Split vertically for column 2
swaymsg split v
swaymsg exec "kitty"
sleep 0.2

# Split vertically for column 3
swaymsg split v
swaymsg exec "dolphin"
sleep 0.2

# Go back to first column
swaymsg focus left
swaymsg focus left

# Split horizontally for row 2 in column 1
swaymsg split h
swaymsg exec "firefox"
sleep 0.2

# Move to second column
swaymsg focus right

# Split horizontally for row 2 in column 2
swaymsg split h
swaymsg exec "kitty"
sleep 0.2

# Move to third column
swaymsg focus right

# Split horizontally for row 2 in column 3
swaymsg split h
swaymsg exec "joplin"
sleep 0.2

# Optionally, move Joplin to the scratchpad after launch
swaymsg '[app_id="joplin"] move to scratchpad'
