#!/bin/bash
# Working macOS + Linux wrapper for SNID with XQuartz

ADDED_XHOST=0
OS=$(uname -s)

if [[ "$OS" == "Darwin" ]]; then
    DISPLAY_VAR="host.docker.internal:0"

    # launch XQuartz if needed
    if ! pgrep XQuartz >/dev/null; then
        open -a XQuartz
        sleep 2
    fi

    # XQuartz needs network access or Docker can't connect
    defaults write org.xquartz.X11 enable_iglx -bool true
    defaults write org.xquartz.X11 no_auth -bool true

    xhost +127.0.0.1
    ADDED_XHOST=1

elif [[ "$OS" == "Linux" ]]; then
    DISPLAY_VAR="$DISPLAY"
    xhost +local:docker
    ADDED_XHOST=1

else
    echo "Unsupported OS: $OS"
    exit 1
fi

cleanup() {
    if [[ "$ADDED_XHOST" -eq 1 ]]; then
        if [[ "$OS" == "Darwin" ]]; then
            xhost -127.0.0.1
        else
            xhost -local:docker
        fi
    fi
}
trap cleanup EXIT

docker run --rm -it \
    -e DISPLAY="$DISPLAY_VAR" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$PWD":/home/sniduser/workdir \
    -w /home/sniduser/workdir \
    snid:5.0-supersnid \
    snid "$@"
