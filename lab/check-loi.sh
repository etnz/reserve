#!/bin/bash
# set -e removed to allow continuing on failure

echo "Checking Letter of Introduction..."
EXIT_CODE=0

# 1. Check package installation via dpkg
PKG_NAME=$(dpkg-query -W -f='${Package}' '*letter-of-introduction*' 2>/dev/null || true)
if [ -z "$PKG_NAME" ]; then
    echo "FAIL: No package matching '*letter-of-introduction*' is installed."
    EXIT_CODE=1
else
    echo "OK: Package '$PKG_NAME' is installed."
fi

# 2. Check sources file
SOURCES_FILE="/etc/apt/sources.list.d/reserve.sources"
KEY_PATH="/etc/apt/keyrings/reserve.gpg"

if [ ! -f "$SOURCES_FILE" ]; then
    echo "FAIL: $SOURCES_FILE does not exist."
    ls /etc/apt/sources.list.d/
    EXIT_CODE=1
else
    echo "OK: $SOURCES_FILE exists."
    if ! grep -q "$KEY_PATH" "$SOURCES_FILE"; then
        echo "FAIL: $SOURCES_FILE does not reference $KEY_PATH."
        EXIT_CODE=1
    else
        echo "OK: Sources file references correct key."
    fi
fi

# 3. Check public key path and identity
if [ ! -f "$KEY_PATH" ]; then
    echo "FAIL: Key file $KEY_PATH does not exist."
    EXIT_CODE=1
else
    echo "OK: Key file $KEY_PATH exists."
    # Try to read identity if gpg is available
    if command -v gpg >/dev/null; then
        echo "Key Identity:"
        gpg --show-keys "$KEY_PATH" 2>/dev/null | grep "uid" || echo "  (No uid found)"
    fi
fi

exit $EXIT_CODE
