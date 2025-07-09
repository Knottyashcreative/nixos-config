#!/usr/bin/env bash

date_formatted=$(TZ='Etc/GMT-1' date '+%F -- %T')
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}')
mem_usage=$(free -h | awk '/^Mem/ {print $3 "/" $2}')
battery_percent=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
battery_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
ip_addr=$(ip -4 addr show wlan0 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1)
wifi_strength=$(grep $(iw dev wlan0 link | awk '/SSID/ {print $2}') /proc/net/wireless 2>/dev/null | awk '{print int($3 * 100 / 70) "%"}')
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%.0f%%", $2*100}')
uptime=$(uptime -p)
disk_usage=$(df -h / | awk 'NR==2 {print $3 "/" $2 " used"}')
brightness=$(cat /sys/class/backlight/intel_backlight/actual_brightness 2>/dev/null)
music=$(mpc current 2>/dev/null)

echo "📆 $date_formatted | 🖥️ CPU: $cpu_usage | 🧠 Mem: $mem_usage | 🔋 $battery_percent% ($battery_status) | 🌐 IP: $ip_addr | 📶 WiFi: $wifi_strength | 🔊 Vol: $volume | ⏱️ $uptime | 💾 Disk: $disk_usage | 💡 Bright: $brightness | 🎵 $music"

# --- Command Explanations ---
# date_formatted: Current date and time in ETC/GMT-1 timezone.
# cpu_usage: CPU usage percentage from 'top'.
# mem_usage: Used/total memory from 'free -h'.
# battery_percent: Battery percentage from system battery info.
# battery_status: Charging/discharging state from system battery info.
# ip_addr: IPv4 address of wlan0 interface.
# wifi_strength: Wi-Fi signal strength as a percentage.
# volume: Current audio output volume using wpctl.
# uptime: System uptime in a human-readable format.
# disk_usage: Used/total disk space on root filesystem.
# brightness: Current screen brightness value.
# music: Currently playing track from MPD (Music Player Daemon).


