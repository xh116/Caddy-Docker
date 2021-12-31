#!/bin/sh -e

getent group qbittorrent >/dev/null || addgroup -g ${PGID} qbittorrent
getent passwd qbittorrent >/dev/null || adduser -S -D -u ${PUID} -G qbittorrent -g qbadmin -s /sbin/nologin qbittorrent

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
	chown -R qbittorrent:qbittorrent /downloads
fi

chown -R qbittorrent:qbittorrent /home/qbittorrent

exec su-exec qbittorrent:qbittorrent "$@"
