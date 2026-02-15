#!/bin/bash
# ~/.config/picom/pause.sh

# Tunggu sebentar agar WM stabil
sleep 2

while true; do
    # Cek apakah ada window fullscreen
    if xprop -root 2>/dev/null | grep -q "_NET_ACTIVE_WINDOW(WINDOW)"; then
        WINID=$(xprop -root 2>/dev/null | grep "_NET_ACTIVE_WINDOW(WINDOW)" | awk -F' ' '{print $5}')
        
        if [[ -n "$WINID" && "$WINID" != "0x0" ]]; then
            # Cek apakah window dalam keadaan fullscreen
            if xprop -id "$WINID" 2>/dev/null | grep -q "_NET_WM_STATE_FULLSCREEN"; then
                # Fullscreen ditemukan, pause picom
                if pgrep -x picom >/dev/null; then
                    echo "Fullscreen terdeteksi, menghentikan picom..."
                    pkill -x picom
                fi
            else
                # Tidak fullscreen, pastikan picom berjalan
                if ! pgrep -x picom >/dev/null; then
                    echo "Keluar dari fullscreen, memulai picom..."
                    if [[ -f "$HOME/.config/picom/picom.conf" ]]; then
                        picom --config "$HOME/.config/picom/picom.conf" --daemon
                    else
                        picom --daemon
                    fi
                fi
            fi
        fi
    fi
    
    # Check interval
    sleep 1
done