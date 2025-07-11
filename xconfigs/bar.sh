# Get current date and time in Etc/GMT-1 timezone
date_formatted=$(TZ='Etc/GMT-1' date '+%F -- %T')

# Get CPU usage (user + system) from top command
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}')

# Get memory usage used/total
mem_usage=$(free -h | awk '/^Mem/ {print $3 "/" $2}')

# Get battery percentage and status, suppress errors if files don't exist
# battery_percent=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
# battery_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "N/A")

# Auto-detect active network interface for IPv4 address
iface=$(ip route | awk '/default/ {print $5; exit}')
ip_addr=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 || echo "N/A")

# Get WiFi SSID
wifi_ssid=$(iw dev "$iface" link 2>/dev/null | awk '/SSID/ {print $2}')

# Get WiFi strength as percentage, handle missing SSID or /proc/net/wireless
if [ -n "$wifi_ssid" ] && [ -r /proc/net/wireless ]; then
    wifi_strength=$(grep "$wifi_ssid" /proc/net/wireless 2>/dev/null | awk '{print int($3 * 100 / 70) "%"}')
else
    wifi_strength="N/A"
fi

# Get volume percentage using wpctl
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%.0f%%", $2*100}')

# Get system uptime in human-readable format, with fallback
uptime=$(uptime -p 2>/dev/null || uptime)

# Get disk usage of root filesystem
disk_usage=$(df -h / | awk 'NR==2 {print $3 "/" $2 " used"}')

# Get screen brightness
# brightness=$(cat /sys/class/backlight/intel_backlight/actual_brightness 2>/dev/null || echo "N/A")

# Get currently playing music track from MPD
music=$(mpc current 2>/dev/null || echo "No music")

# Output the status line
echo "📆 $date_formatted | 🖥️ CPU: $cpu_usage | 🧠 Mem: $mem_usage | 🌐 IP: $ip_addr | 📶 WiFi: $wifi_strength | 🔊 Vol: $volume | ⏱️ $uptime | 💾 Disk: $disk_usage | 🎵 $music"

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
# Output the status line
