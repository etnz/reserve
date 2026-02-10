#!/bin/bash
set -e

# Groom service postrm script

if [ "$1" = "purge" ]; then
	if getent passwd "{{ .USER }}" >/dev/null; then
		userdel "{{ .USER }}" || true
	fi
fi

if [ -d /run/systemd/system ]; then
	systemctl daemon-reload || true
fi
