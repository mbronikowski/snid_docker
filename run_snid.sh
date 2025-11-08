#!/bin/bash
# Cross-platform wrapper for SNID Docker container with X11 forwarding
# Works on Linux and macOS (XQuartz)
# Only revokes xhost permissions if the script added them

ADDED_XHOST=0

# Detect platform
OS="$(uname -s)"

if [[ "$OS" == "Darwin" ]]; then
    # macOS (XQuartz)
    DISPLAY_VAR="host.docker.internal:0"

    # Add xhost permission if not present
    if ! xhost | grep -q "127.0.0.1"; then
        xhost +127.0.0.1 >/dev/null
        ADDED_XHOST=1
    fi

elif [[ "$OS" == "Linux" ]]; then
    # Linux
    DISPLAY_VAR="$DISPLAY"

    if ! xhost | grep -q "local:docker"; then
        xhost +local:docker >/dev/null
        ADDED_XHOST=1
    fi
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Cleanup function for xhost
cleanup() {
    if [[ "$ADDED_XHOST" -eq 1 ]]; then
        if [[ "$OS" == "Darwin" ]]; then
            xhost -127.0.0.1 >/dev/null
        elif [[ "$OS" == "Linux" ]]; then
            xhost -local:docker >/dev/null
        fi
    fi
}
trap cleanup EXIT

# Run Docker container
docker run --rm -it \
    -e DISPLAY="$DISPLAY_VAR" \
    $( [[ "$OS" == "Linux" ]] && echo "-v /tmp/.X11-unix:/tmp/.X11-unix" ) \
    -v "$PWD":/home/sniduser/workdir \
    -w /home/sniduser/workdir \
    snid:5.0-supersnid \
    snid "$@"
