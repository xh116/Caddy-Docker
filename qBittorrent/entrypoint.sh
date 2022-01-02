#!/bin/sh -e

if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g qbittorrent)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^qbittorrent:\([^:]*\):[0-9]*/qbittorrent:\1:${PGID}/" /etc/group
  sed -i -e "s/^qbittorrent:\([^:]*\):\([0-9]*\):[0-9]*/qbittorrent:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u qbittorrent)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^qbittorrent:\([^:]*\):[0-9]*:\([0-9]*\)/qbittorrent:\1:${PUID}:\2/" /etc/passwd
fi

if [ ! -f /config/qBittorrent.conf ]; then
  echo "Initializing qBittorrent configuration..."
  cat > /config/qBittorrent.conf <<EOL
  
[General]
ported_to_new_savepath_system=true

[LegalNotice]
Accepted=true

[BitTorrent]
Session\DefaultSavePath=/downloads
Session\Port=6881

[Preferences]
WebUI\Enabled=true
WebUI\Address=*
WebUI\ServerDomains=*
Connection\PortRangeMin=6881
Downloads\SavePath=/downloads
Downloads\TempPath=/downloads/incomplete
Downloads\TempPathEnabled=true
EOL
 chown qbittorrent:qbittorrent /config/qBittorrent.conf
fi

echo "Fixing permissions..."
chown qbittorrent:qbittorrent /data \
  /config \
  /downloads  
  
chown -R qbittorrent:qbittorrent /home/qbittorrent

exec su-exec qbittorrent:qbittorrent "$@"
