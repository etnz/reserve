#!/bin/bash
set -e

# Groom service installation script
# Creates a groom user {{ .USER }}
# starts the service {{ .SERVICE }}


if ! getent passwd "{{ .USER }}" >/dev/null; then
	useradd --system --home-dir /nonexistent --no-create-home --shell /bin/false --user-group "{{ .USER }}"
fi

if [ -d /run/systemd/system ]; then
	systemctl daemon-reload || true
	systemctl enable "{{ .SERVICE }}" || true
	systemctl restart "{{ .SERVICE }}" || true
fi
