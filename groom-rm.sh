#!/bin/bash
set -e

# Groom service postrm script. Previously the package:
#  - Created a groom user {{ .USER }}
#  - started the service {{ .SERVICE }}

if [ -d /run/systemd/system ]; then
	systemctl stop "{{ .SERVICE }}" || true
fi

if [ "$1" = "remove" ] && [ -d /run/systemd/system ]; then
	systemctl disable "{{ .SERVICE }}" || true
fi
