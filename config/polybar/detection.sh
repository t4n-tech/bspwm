#!/bin/bash

# Auto-detection script for Polybar
# Designed to be called from launch.sh

# ============================================
# SECTION 1: CONFIGURATION
# ============================================

# Use same directory as launch.sh (PERBAIKAN: Konsisten dengan launch.sh)
POLYBAR_DIR="$HOME/.config/polybar"
SYSTEM_INI="$POLYBAR_DIR/system.ini"
LOG_FILE="$POLYBAR_DIR/auto-detect.log"

# Ensure directory exists
mkdir -p "$POLYBAR_DIR"

# ============================================
# SECTION 2: LOGGING FUNCTION
# ============================================

log() {
    local timestamp=$(date '+%H:%M:%S')
    local message="$1"
    echo "[$timestamp] $message" >> "$LOG_FILE"
    
    # Also print to stdout if not in quick mode
    if [ "$1" != "--quick" ] && [ "$1" != "-q" ]; then
        echo "$message"
    fi
}

# ============================================
# SECTION 3: QUICK MODE HANDLING
# ============================================

# Quick mode for launch.sh
if [ "$1" = "--quick" ] || [ "$1" = "-q" ]; then
    # PERBAIKAN: Cek apakah system.ini ada
    if [ -f "$SYSTEM_INI" ]; then
        # Check if already ran today
        TODAY=$(date '+%Y%m%d')
        
        # Try to get file modification date
        if command -v stat >/dev/null 2>&1; then
            # Linux
            FILE_DATE=$(stat -c %y "$SYSTEM_INI" 2>/dev/null | cut -d' ' -f1 | tr -d '-')
        elif command -v date >/dev/null 2>&1; then
            # BSD/macOS
            FILE_DATE=$(date -r "$SYSTEM_INI" '+%Y%m%d' 2>/dev/null)
        else
            FILE_DATE=""
        fi
        
        # Jika file sudah diupdate hari ini, skip
        if [ "$FILE_DATE" = "$TODAY" ]; then
            log "Quick check: Already configured today, skipping..."
            exit 0
        fi
    fi
    # Jika sampai di sini, lanjutkan dengan detection
    log "Quick check: Running detection..."
fi

# Force mode
if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
    log "Force mode: Running full detection..."
fi

# ============================================
# SECTION 4: DETECTION FUNCTIONS
# ============================================

detect_adapter() {
    local adapter="AC"
    
    # Try multiple possible locations
    if [ -d "/sys/class/power_supply" ]; then
        for path in /sys/class/power_supply/*; do
            if [ -d "$path" ]; then
                local name=$(basename "$path")
                if [[ "$name" =~ ^(AC|ADP|ac_adapter|ADP1|ACAD)$ ]]; then
                    adapter="$name"
                    break
                fi
            fi
        done
    fi
    
    # Alternative detection using upower
    if [ "$adapter" = "AC" ] && command -v upower >/dev/null 2>&1; then
        local upower_adapter=$(upower -e 2>/dev/null | grep -i 'ac\|adapter' 2>/dev/null | head -1)
        if [ -n "$upower_adapter" ]; then
            adapter=$(basename "$upower_adapter")
        fi
    fi
    
    echo "$adapter"
}

detect_battery() {
    local battery="BAT0"
    
    # Try multiple possible locations
    if [ -d "/sys/class/power_supply" ]; then
        for path in /sys/class/power_supply/*; do
            if [ -d "$path" ]; then
                local name=$(basename "$path")
                if [[ "$name" =~ ^(BAT|battery) ]]; then
                    battery="$name"
                    break
                fi
            fi
        done
    fi
    
    # Alternative detection using upower
    if [ "$battery" = "BAT0" ] && command -v upower >/dev/null 2>&1; then
        local upower_bat=$(upower -e 2>/dev/null | grep -i battery 2>/dev/null | head -1)
        if [ -n "$upower_bat" ]; then
            battery=$(basename "$upower_bat")
        fi
    fi
    
    echo "$battery"
}

detect_backlight() {
    local backlight="intel_backlight"
    
    # Check for backlight interface
    if [ -d "/sys/class/backlight" ]; then
        for path in /sys/class/backlight/*; do
            if [ -d "$path" ]; then
                backlight=$(basename "$path")
                break
            fi
        done
    fi
    
    echo "$backlight"
}

detect_wireless() {
    local wireless="wlan0"
    local found=0
    
    # Modern detection using ip command
    if command -v ip >/dev/null 2>&1; then
        local iface=$(ip link show 2>/dev/null | awk -F': ' '/^[0-9]+:/ {print $2}' | while read ifname; do
            if [ -d "/sys/class/net/$ifname/wireless" ]; then
                echo "$ifname"
                exit 0
            fi
        done)
        
        if [ -n "$iface" ]; then
            wireless="$iface"
            found=1
        fi
    fi
    
    # Fallback to old method if not found
    if [ $found -eq 0 ] && [ -d "/sys/class/net" ]; then
        for iface in /sys/class/net/*; do
            if [ -d "$iface/wireless" ]; then
                wireless="${iface##*/}"
                break
            fi
        done
    fi
    
    echo "$wireless"
}

detect_wired() {
    local wired="eth0"
    local found=0
    
    # Modern detection using ip command
    if command -v ip >/dev/null 2>&1; then
        local iface=$(ip link show 2>/dev/null | awk -F': ' '/^[0-9]+:/ {print $2}' | while read ifname; do
            if [ ! -d "/sys/class/net/$ifname/wireless" ] && [[ "$ifname" =~ ^(en|eth) ]]; then
                echo "$ifname"
                exit 0
            fi
        done)
        
        if [ -n "$iface" ]; then
            wired="$iface"
            found=1
        fi
    fi
    
    # Fallback to old method if not found
    if [ $found -eq 0 ] && [ -d "/sys/class/net" ]; then
        for iface in /sys/class/net/*; do
            local ifname="${iface##*/}"
            if [[ "$ifname" =~ ^(en|eth) ]] && [ ! -d "$iface/wireless" ]; then
                wired="$ifname"
                break
            fi
        done
    fi
    
    echo "$wired"
}

# ============================================
# SECTION 5: MAIN DETECTION LOGIC
# ============================================

log "=== Starting system detection ==="
[ "$1" = "--force" ] && log "Mode: FORCE detection"
[ "$1" = "--quick" ] && log "Mode: QUICK check"

# Run detections
ADAPTER=$(detect_adapter)
log "Adapter: $ADAPTER"

BATTERY=$(detect_battery)
log "Battery: $BATTERY"

BACKLIGHT=$(detect_backlight)
log "Backlight: $BACKLIGHT"

WIRELESS=$(detect_wireless)
log "Wireless interface: $WIRELESS"

WIRED=$(detect_wired)
log "Wired interface: $WIRED"

# ============================================
# SECTION 6: CREATE/UPDATE CONFIGURATION FILE
# ============================================

# PERBAIKAN: Buat file system.ini JIKA BELUM ADA, atau update isinya jika file sudah ada
log "Updating system configuration..."

# Backup existing file if it exists
if [ -f "$SYSTEM_INI" ]; then
    cp "$SYSTEM_INI" "$SYSTEM_INI.backup.$(date +%s)" 2>/dev/null
    log "Backup created for existing system.ini"
fi

# Create/update system.ini
cat > "$SYSTEM_INI" << EOF
# ============================================
# Polybar System Configuration
# Auto-generated on $(date '+%Y-%m-%d %H:%M:%S')
# Run '$0 --force' to regenerate
# ============================================

[system]
# Power adapter (AC) detection
adapter = $ADAPTER

# Battery detection
battery = $BATTERY

# Backlight control (for brightness module)
backlight = $BACKLIGHT

# Network interfaces
network_interface_wireless = $WIRELESS
network_interface_wired = $WIRED

# Additional detected information
detection_date = $(date '+%Y-%m-%d %H:%M:%S')
detection_mode = ${1:-normal}
EOF

# Set proper permissions
chmod 644 "$SYSTEM_INI"

log "Configuration saved to: $SYSTEM_INI"

# ============================================
# SECTION 7: VERIFICATION & SUMMARY
# ============================================

if [ -f "$SYSTEM_INI" ]; then
    if [ "$1" != "--quick" ] && [ "$1" != "-q" ]; then
        echo ""
        echo "✅ System detection completed successfully!"
        echo ""
        echo "📁 Config directory: $POLYBAR_DIR"
        echo "📄 Config file:      $SYSTEM_INI"
        echo "📝 Log file:         $LOG_FILE"
        echo ""
        echo "Detected hardware:"
        echo "  • Adapter:        $ADAPTER"
        echo "  • Battery:        $BATTERY"
        echo "  • Backlight:      $BACKLIGHT"
        echo "  • Wireless:       $WIRELESS"
        echo "  • Wired:          $WIRED"
        echo ""
        
        # Show last log entries
        echo "Last 3 log entries:"
        tail -3 "$LOG_FILE" 2>/dev/null | sed 's/^/  /' || echo "  (No log entries yet)"
    fi
else
    log "ERROR: Failed to create system.ini"
    echo "❌ Failed to create configuration file!" >&2
    exit 1
fi

exit 0