#!/bin/bash

# --- Uptime ---
uptime_formatted=$(uptime -p)

# --- Time ---
date=$(date "+%I:%M %p")

# --- Keyboard Layout ---
keyboard=$(layout=$(swaymsg -t get_inputs | grep "xkb_active_layout_name"); if echo "$layout" | grep -q "English"; then echo "EN"; else echo "RU"; fi)

# --- Volume ---
volume_level=$(pamixer --get-volume)
is_muted=$(pamixer --get-mute)
volume=$( [ "$is_muted" = "true" ] && echo "<span color='#ff0000'>muted</span>" || echo "vol $volume_level%")

# --- Bluetooth ---
bluetooth_powered=$(bluetoothctl show | grep -q "Powered: yes" && echo "yes" || echo "no")
if [ "$bluetooth_powered" = "yes" ]; then
    connected_devices=$(bluetoothctl devices Connected | wc -l)
    if [ "$connected_devices" -gt 0 ]; then
        bluetooth="<span color='#0096FF'>bt ON ($connected_devices)</span>"
    else
        bluetooth="bt ON"
    fi
else
    bluetooth="bt OFF"
fi

# --- RAM Usage ---
ram_total=$(free -m | awk '/Mem:/ {print $2}')
ram_used_h=$(free -h | awk '/Mem:/ {print $3}')
ram_used=$(free -m | awk '/Mem:/ {print $3}')
ram_percent=$(( ram_used * 100 / ram_total ))

if [ $ram_percent -lt 50 ]; then
    ram_color="#ffffff"  
elif [ $ram_percent -lt 75 ]; then
    ram_color="#f5a623"  
else
    ram_color="#ff0000"  
fi

ram="<span color='$ram_color'>${ram_used_h}B(${ram_percent}%)</span>"

# --- Network Speed ---
get_network_speed() {
    interface=$(ip route | awk '/default/ {print $5}' | head -n1)
    if [ -z "$interface" ]; then
        echo ""
        return
    fi

    read rx1 tx1 < <(awk -v iface="$interface" '$0 ~ iface {print $2,$10}' /proc/net/dev)
    sleep 1
    read rx2 tx2 < <(awk -v iface="$interface" '$0 ~ iface {print $2,$10}' /proc/net/dev)

    rx_speed=$(( (rx2 - rx1) / 1024 ))
    tx_speed=$(( (tx2 - tx1) / 1024 ))

    echo "(↓${rx_speed}KiB/s ↑${tx_speed}KiB/s)"
}

# --- Network Status ---
net=""
active_connection=$(nmcli -t -f NAME,DEVICE,TYPE con show --active | grep -v "lo")
if [[ -n "$active_connection" ]]; then
    network_speed=$(get_network_speed)
    if echo "$active_connection" | grep -q "ethernet"; then
        net="eth $network_speed"
    elif echo "$active_connection" | grep -q "wireless"; then
        SSID=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d':' -f2)
        net="wlan $SSID $network_speed"
    fi
else
    net="<span color='#ff0000'>! no connection</span>"
fi

# --- Battery ---
battery=""
battery_info=$(upower -i $(upower -e | grep BAT) | grep -E 'percentage|state')

if [[ -n "$battery_info" ]]; then
    battery_percentage=$(echo "$battery_info" | grep 'percentage' | awk '{print $2}' | tr -d '%')
    battery_state=$(echo "$battery_info" | grep 'state' | awk '{print $2}')

    if (( battery_percentage >= 60 )); then
        color="#25ad76"
    elif (( battery_percentage >= 20 )); then
        color="#ffff00"
    else
        color="#ff0000" 
    fi

    if [[ "$battery_state" == "charging" ]]; then
        battery="<span color='$color'>chrg $battery_percentage%</span>"
    elif [[ "$battery_state" == "discharging" ]]; then
        battery="<span color='$color'>bat $battery_percentage%</span>"
    else
        battery="<span color='$color'>? $battery_state</span>"
    fi
else
    battery="<span color='#ff0000'>! No bat info</span>"
fi

# --- Backlight ---
backlight=$(brightnessctl | grep 'brightness' | awk '{print $4}' | tr -d '()')

# --- Modules ---
echo "<span color='#00ff00'>$net</span> | \
$ram | \
bri $backlight | \
$battery | \
$bluetooth | \
$volume | \
$keyboard | \
$date"
