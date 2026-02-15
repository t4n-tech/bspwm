#!/bin/bash
# ~/.config/picom/auto.sh

# Cek apakah picom sudah berjalan
if pgrep -x "picom" >/dev/null; then
    echo "Picom sudah berjalan, menghentikan..."
    pkill -x picom
    sleep 0.5
fi

# Pastikan benar-benar mati
while pgrep -x picom >/dev/null; do 
    sleep 0.1
done

# Start picom dengan config jika ada, jika tidak pakai default
if [[ -f "$HOME/.config/picom/picom.conf" ]]; then
    echo "Memulai picom dengan config..."
    picom --config "$HOME/.config/picom/picom.conf" --daemon
else
    echo "Config tidak ditemukan, memulai picom default..."
    picom --daemon
fi

exit 0