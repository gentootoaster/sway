#!/bin/bash

interface="eth0"  # Замените на ваш интерфейс (например, enp0s3, wlan0)

# Функция для получения текущих значений переданных/принятых байтов
get_bytes() {
    line=$(grep "$interface" /proc/net/dev)
    receive=$(echo "$line" | awk '{print $2}')
    transmit=$(echo "$line" | awk '{print $10}')
    echo "$receive $transmit"
}

# Первый замер
read r1 t1 <<< $(get_bytes)
sleep 1  # Ждём 1 секунду
# Второй замер
read r2 t2 <<< $(get_bytes)

# Вычисляем разницу и переводим в KiB/s (1 KiB = 1024 байта)
rx_speed=$(( (r2 - r1) / 1024 ))
tx_speed=$(( (t2 - t1) / 1024 ))

echo "↓ ${rx_speed}KiB/s ↑ ${tx_speed}KiB/s"
