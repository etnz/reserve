#!/bin/bash
# set -e removed to allow continuing on failure

echo "Checking Purge..."
EXIT_CODE=0

# 1. Check packages are removed (no ii or rc status)
if dpkg -l 'pbc-*' 2>/dev/null | grep -E '^(ii|rc)'; then
    echo "FAIL: pbc-* packages still present."
    EXIT_CODE=1
else
    echo "OK: pbc-* packages removed."
fi

# 2. Check user 'groom'
if getent passwd groom >/dev/null; then
    echo "FAIL: User 'groom' still exists."
    EXIT_CODE=1
else
    echo "OK: User 'groom' removed."
fi

# 3. Check service file
if [ -f /etc/systemd/system/petitbijou-groom.service ]; then
    echo "FAIL: Service file still exists."
    EXIT_CODE=1
else
    echo "OK: Service file removed."
fi

# 4. Check service status
if systemctl list-units --all | grep -q "petitbijou-groom.service"; then
     echo "FAIL: Service unit still loaded."
     EXIT_CODE=1
else
    echo "OK: Service unit unloaded."
fi

exit $EXIT_CODE
