#!/bin/sh

if ! id qbittorrent; then
    echo "[WARNING] User not found. Maybe first bootstrap?"
    echo "[INFO] Try to create user qbittorrent."
    groupadd -g $PGID -o qbittorrent
    useradd -d /config -u $PUID -g $PGID -o qbittorrent
    if [ -d /config ]; then
        echo "[INFO] Try to fix config folder permissions."
        chown -R $PUID:$PGID /config
    fi
    echo "[INFO] User qbittorrent($PUID:$PGID) created."
fi

if [ ! -f /config/qBittorrent.conf ]; then
  echo "Initializing qBittorrent configuration..."
  cat > /config/qBittorrent.conf <<EOL
  
[General]
ported_to_new_savepath_system=true
[Preferences]
WebUI\Enabled=true
WebUI\Address=*
WebUI\ServerDomains=*
Connection\PortRangeMin=6881
Downloads\SavePath=/downloads
Downloads\TempPath=/downloads/incomplete
Downloads\TempPathEnabled=true
[LegalNotice]
Accepted=true
EOL
    chown $PUID:$PGID /config/qBittorrent.conf
fi

exec su-exec qbittorrent:qbittorrent "$@"
