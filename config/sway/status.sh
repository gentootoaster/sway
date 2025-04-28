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
volume=$( [ "$is_muted" = "true" ] && echo "muted" || echo "vol $volume_level%")

# --- Bluetooth ---
bluetooth_powered=$(bluetoothctl show | grep -q "Powered: yes" && echo "yes" || echo "no")
if [ "$bluetooth_powered" = "yes" ]; then
    connected_devices=$(bluetoothctl devices Connected | wc -l)
    if [ "$connected_devices" -gt 0 ]; then
        bluetooth="<span color='#0096FF'>bluetooth: ON ($connected_devices)</span>"
    else
        bluetooth="bluetooth ON"
    fi
else
    bluetooth="bluetooth OFF"
fi

# --- RAM Usage ---
ram_total=$(free -m | awk '/Mem:/ {print $2}')
ram_used=$(free -m | awk '/Mem:/ {print $3}')
ram_free=$(free -m | awk '/Mem:/ {print $7}')
ram_percent=$(( ram_used * 100 / ram_total ))

if [ $ram_percent -lt 50 ]; then
    ram_color="#ffffff"  
elif [ $ram_percent -lt 75 ]; then
    ram_color="#f5a623"  
else
    ram_color="#ff0000"  
fi

ram="<span color='$ram_color'>${ram_used}MiB/${ram_free}MiB(${ram_percent}%)</span>"

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
        net="ETH $network_speed"
    elif echo "$active_connection" | grep -q "wireless"; then
        SSID=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d':' -f2)
        net="WiFi $SSID $network_speed"
    fi
else
    net="<span color='#ff0000'>No connection</span>"
fi

# --- Modules ---
echo "<span color='#25ad76'>$net</span> | \
$bluetooth | \
$ram | \
$volume | \
$keyboard | \
$date"
