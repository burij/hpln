#!/usr/bin/env sh
APP="hpln"
# Get the absolute path of the script itself
SCRIPT_PATH="$(realpath "$0")"
# Get the bin directory containing the script
BIN_DIR="$(dirname "$SCRIPT_PATH")"
# Get the app directory (parent of bin)
APP_DIR="$(dirname "$BIN_DIR")"

PID_FILE="/tmp/$APP/nginx.pid"
ERROR_LOG="/tmp/$APP/error.log"

# Ensure required directories exist
mkdir -p "/tmp/$APP"
touch "$ERROR_LOG"

# Change to the app directory so Lua can find its modules
cd "$APP_DIR" || exit 1

# Stop any existing server
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$PID" ]; then
        kill "$PID" 2>/dev/null && echo "Server (PID: $PID) stopped." \
        || echo "Server was not running."
    else
        echo "PID file is empty."
    fi
else
    echo "No PID file found."
fi

sleep 2

echo "Server starting. Check http://localhost:8111/"

# Start the server with absolute paths
exec "$APP_DIR/bin/appserver" \
    -p "$APP_DIR" \
    -c "$APP_DIR/nginx.conf" \
    -e "$ERROR_LOG" \
    "$@"

