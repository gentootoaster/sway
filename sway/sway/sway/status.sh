# --- Uptime  ---
uptime_formatted=$(uptime -p)

# --- Time  ---
date_formatted=$(date "+%I:%M %p")

# --- Keyboard Layout ---
keyboard_formatted=$(layout=$(swaymsg -t get_inputs | grep "xkb_active_layout_name"); if echo "$layout" | grep -q "English"; then echo "EN"; else echo "RU"; fi)

# --- Volume ---
volume_level=$(pamixer --get-volume)
is_muted=$(pamixer --get-mute)
volume_formatted="$( [ "$is_muted" = "true" ] && echo "🔇 Muted" || echo "🔊" $volume_level%)"

# --- Bluetooth ---
bluetooth_state=$(bluetoothctl show | grep -q "Powered: yes" && echo "ON" || echo "OFF")
if [ "$bluetooth_state" = "ON" ]; then
    connected_devices=$(bluetoothctl devices Connected | wc -l)
    [ "$connected_devices" -gt 0 ] && bluetooth_formatted="$bluetooth_state ($connected_devices)" || bluetooth_formatted="$bluetooth_state"
else
    bluetooth_formatted="$bluetooth_state"
fi

# --- Network ---
net_indicator=""
active_connection=$(nmcli -t -f NAME,DEVICE,TYPE con show --active | grep -v "lo")
if [[ -n "$active_connection" ]]; then
    if echo "$active_connection" | grep -q "ethernet"; then
        net_indicator="✅ ETH"  
    elif echo "$active_connection" | grep -q "wifi"; then
	SSID=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d:' -f2')
	net_indicator="🛜 $SSID" 
    fi
else
    net_indicator="❌ No connection" 
fi

# --- Modules Layout ---
echo "↑ $uptime_formatted | 🔵 bluetooth: $bluetooth_formatted | $volume_formatted | $net_indicator | 🌐 $keyboard_formatted | ⏰ $date_formatted "
