#!/bin/bash
# Config Polybar For Multi-Monitor with Auto-Detection

# ============================================
# SECTION 1: TERMINATE EXISTING POLYBAR
# ============================================

# Turn off all polybars that are still running
killall -q polybar

# Wait until the polybar process is completely dead
while pgrep -u $UID -x polybar >/dev/null; do 
    sleep 0.5
done

echo "✅ polybar has been discontinued"

# ============================================
# SECTION 2: CONFIGURATION PATHS
# ============================================

POLYBAR_DIR="$HOME/.config/polybar"
AUTO_DETECT_SCRIPT="$POLYBAR_DIR/detection.sh"
SYSTEM_INI="$POLYBAR_DIR/system.ini"
CONFIG="$POLYBAR_DIR/config.ini"

# ============================================
# SECTION 3: SYSTEM DETECTION & VERIFICATION
# ============================================

echo "🔍 Running automatic system detection..."

# Function to run detection script
run_detection() {
    local mode="${1:---quick}"
    
    echo "📦 Running system detection ($mode)..."
    
    # Check if detection script exists
    if [ ! -f "$AUTO_DETECT_SCRIPT" ]; then
        echo "❌ Detection script not found: $AUTO_DETECT_SCRIPT"
        return 1
    fi
    
    # Ensure script is executable
    if [ ! -x "$AUTO_DETECT_SCRIPT" ]; then
        echo "🔧 Making script executable..."
        if ! chmod +x "$AUTO_DETECT_SCRIPT"; then
            echo "❌ Failed to make script executable"
            return 1
        fi
    fi
    
    # Run detection
    if "$AUTO_DETECT_SCRIPT" "$mode"; then
        echo "✅ System detection completed successfully"
        return 0
    else
        echo "❌ System detection failed"
        return 1
    fi
}

# LOGIKA PERBAIKAN BERDASARKAN PERMINTAAN:
# 1. Jika system.ini TIDAK ada, jalankan detection.sh --force
# 2. Jika system.ini ada, jalankan detection.sh --quick (hanya update jika perlu)
# 3. Jika keduanya sudah ada, lanjut tanpa perubahan

if [ ! -f "$SYSTEM_INI" ]; then
    echo "⚠️  system.ini not found, running full detection..."
    if ! run_detection --force; then
        echo "❌ Cannot continue without system.ini"
        exit 1
    fi
else
    echo "📝 System configuration found, running quick check..."
    run_detection --quick
fi

# Final verification of system.ini (Wajib ada untuk melanjutkan)
if [ ! -f "$SYSTEM_INI" ]; then
    echo "❌ CRITICAL: system.ini still not found after detection!"
    echo "   Check: $POLYBAR_DIR/auto-detect.log for errors"
    exit 1
fi

echo "✅ System configuration verified: $SYSTEM_INI"

# ============================================
# SECTION 4: MONITOR DETECTION & POLYBAR LAUNCH
# ============================================

echo "🖥️  Detecting monitors..."

# Check if xrandr is available
if ! command -v xrandr &> /dev/null; then
    echo "⚠️  xrandr not found, using default monitor"
    polybar -c "$CONFIG" --reload main &
    echo "✅ Polybar runs on the default monitor"
else
    # Primary monitor detection
    PRIMARY=$(xrandr --query | awk '/ connected.*primary/ {print $1}' 2>/dev/null)
    
    if [ -n "$PRIMARY" ]; then
        echo "📺 Primary monitor: $PRIMARY"
        MONITOR=$PRIMARY polybar -c "$CONFIG" --reload main &
        echo "✅ Polybar launched on primary monitor: $PRIMARY"
        
        # Also run on non-primary monitors
        NON_PRIMARY=$(xrandr --query | awk '/ connected/ && !/primary/ {print $1}' 2>/dev/null)
        if [ -n "$NON_PRIMARY" ]; then
            for MON in $NON_PRIMARY; do
                echo "📺 Additional monitor: $MON"
                MONITOR=$MON polybar -c "$CONFIG" --reload secondary &
                sleep 0.3
            done
            echo "✅ Polybar launched on additional monitors"
        fi
    else
        # Fallback: use all connected monitors
        CONNECTED=$(xrandr --query | awk '/ connected/ {print $1}' 2>/dev/null)
        if [ -n "$CONNECTED" ]; then
            echo "📺 Connected monitors: $(echo $CONNECTED | tr '\n' ' ')"
            
            # First monitor as main
            FIRST=$(echo "$CONNECTED" | head -n1)
            echo "📺 Using as main: $FIRST"
            MONITOR=$FIRST polybar -c "$CONFIG" --reload main &
            
            # Rest as secondary
            OTHERS=$(echo "$CONNECTED" | tail -n +2)
            for MON in $OTHERS; do
                echo "📺 Additional monitor: $MON"
                MONITOR=$MON polybar -c "$CONFIG" --reload secondary &
                sleep 0.3
            done
        else
            echo "⚠️  No monitors detected via xrandr"
            polybar -c "$CONFIG" --reload main &
        fi
    fi
fi

# ============================================
# SECTION 5: VERIFICATION
# ============================================

echo ""
echo "⏳ Waiting for polybar to start..."

# Give polybar time to start
sleep 2

# Count running polybar instances
POLYBAR_COUNT=$(pgrep -u $UID -c polybar 2>/dev/null || echo 0)

if [ "$POLYBAR_COUNT" -gt 0 ]; then
    echo ""
    echo "========================================"
    echo "✅ POLYBAR SUCCESSFULLY LAUNCHED!"
    echo "========================================"
    echo "Config file:    $CONFIG"
    echo "System config:  $SYSTEM_INI"
    echo "Running instances: $POLYBAR_COUNT"
    echo ""
    echo "For logs:"
    echo "  tail -f $POLYBAR_DIR/auto-detect.log"
    echo ""
    echo "For re-detection:"
    echo "  $AUTO_DETECT_SCRIPT --force"
    echo ""
    echo "To kill polybar:"
    echo "  pkill polybar"
else
    echo ""
    echo "❌ FAILED to launch Polybar!"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check config: $CONFIG"
    echo "2. Check logs: journalctl -xe | grep polybar"
    echo "3. Run detection manually: $AUTO_DETECT_SCRIPT --force"
    echo "4. Test polybar manually: polybar -c \"$CONFIG\" main"
    exit 1
fi