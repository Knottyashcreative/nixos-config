#!/usr/bin/env bash
trap "exit" SIGPIPE
while true; do
  #option 1
  #date_formatted=$(TZ='ETC/GMT-1' date '+%F -- %T')

  date_formatted=$(TZ='Europe/London' date '+%H:%M:%S -- %d/%m/%Y')

  cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}')
  mem_usage=$(free -h | awk '/^Mem/ {print $3 "/" $2}')
  # option 1
  # ip_addr=$(ip -4 addr show wlan0 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1)

ip_addr=$(ip -4 addr show wlan0 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1)
ip_addr=${ip_addr:-$(ip -4 addr show eth0 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1)}

echo "IP address: $ip_addr"


  # WiFi strength: fallback to empty if not available
  wifi_strength=""
  if command -v iw > /dev/null && iw dev wlan0 link 2>/dev/null | grep -q 'SSID'; then
    ssid=$(iw dev wlan0 link | awk '/SSID/ {print $2}')
    wifi_strength=$(grep "$ssid" /proc/net/wireless 2>/dev/null | awk '{print int($3 * 100 / 70) "%"}')
  fi

  # Volume: fallback to empty if not available
  volume=""
  if command -v wpctl > /dev/null; then
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%.0f%%", $2*100}')
  fi

  uptime=$(uptime -p)
  disk_usage=$(df -h / | awk 'NR==2 {print $3 "/" $2 " used"}')

  # Music placeholder (if you want to integrate playerctl or similar)
  music=""

  echo "📆 $date_formatted | 🖥️ CPU: $cpu_usage | 🧠 Mem: $mem_usage | 🌐 IP: $ip_addr | 📶 WiFi: $wifi_strength | 🔊 Vol: $volume | ⏱️ $uptime | 💾 Disk: $disk_usage | 🎵 $music"
  
  sleep 1
done

