# --- Uptime  ---
uptime_formatted=$(uptime | cut -d ',' -f1  | cut -d ' ' -f4,5)

# --- Time  ---
date_formatted=$(date "+ %I:%M %p")

# --- Keyboard Layout ---
keyboard_formatted=$(layout=$(swaymsg -t get_inputs | grep "xkb_active_layout_name"); if echo "$layout" | grep -q "English"; then echo "EN"; else echo "RU"; fi)

# --- Volume ---
volume_level=$(pamixer --get-volume)
volume_formatted="$volume_level%"

# --- Bluetooth ---
bluetooth_state=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
if [ "$bluetooth_state" = "yes" ]; then
    connected_devices=$(bluetoothctl devices Connected)
    if [ -n "$connected_devices" ]; then
        device_info=""
        while IFS= read -r line; do
            mac_address=$(echo "$line" | awk '{print $2}')
            device_name=$(echo "$line" | awk '{$1=""; $2=""; print $0}' | sed 's/^ *//')
            battery_percent=$(upower -d | grep -A10 "$mac_address" | grep "percentage" | awk '{print $2}' | tr -d '%')
            if [ -n "$battery_percent" ] && [ "$battery_percent" != "0" ]; then
                device_info="$device_info($battery_percent%)$device_name "
            else
                device_info="$device_info$device_name "
            fi
        done <<< "$connected_devices"
        bluetooth_formatted=" ${device_info%% }"
    else
        bluetooth_formatted=" No bl devices"
    fi
else
    bluetooth_formatted=" OFF"
fi

# --- Network ---
net_indicator=""
active_connection=$(nmcli -t -f NAME,DEVICE,TYPE con show --active | grep -v "lo")
if [[ -n "$active_connection" ]]; then
    if echo "$active_connection" | grep -q "ethernet"; then
        net_indicator="✅ Network is up :3 "  
    elif echo "$active_connection" | grep -q "wifi"; then
	net_name="nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d\' -f2"
	net_indicator="🛜:$net_name" 
    fi
else
    net_indicator="❌ Network is down T-T" 
fi

# --- Kernel Version ---
linux_version=$(uname -r | cut -d '-' -f1)

# --- Modules Layout ---
echo ↑ $uptime_formatted "|" 🐧 $linux_version "|" 🔵 $bluetooth_formatted "|" 🔊 $volume_formatted "|" $net_indicator "|" 🌐 $keyboard_formatted "|" ⏰ $date_formatted ""
