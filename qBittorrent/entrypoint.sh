#!/bin/sh -e

# base on https://github.com/crazy-max/docker-qbittorrent/blob/master/entrypoint.sh

if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g qbittorrent)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^qbittorrent:\([^:]*\):[0-9]*/qbittorrent:\1:${PGID}/" /etc/group
  sed -i -e "s/^qbittorrent:\([^:]*\):\([0-9]*\):[0-9]*/qbittorrent:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u qbittorrent)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^qbittorrent:\([^:]*\):[0-9]*:\([0-9]*\)/qbittorrent:\1:${PUID}:\2/" /etc/passwd
fi

if [ ! -f  /config/qBittorrent.conf ]; then
  echo "Initializing qBittorrent configuration..."
  cat >  /config/qBittorrent.conf <<EOL  
[General]
ported_to_new_savepath_system=true

[AutoRun]
enabled=false
program=

[BitTorrent]
Session\DefaultSavePath=/downloads
Session\Port=6881
Session\QueueingSystemEnabled=true
Session\TempPath=/downloads/incomplete
Session\TempPathEnabled=true

[Core]
AutoDeleteAddedTorrentFile=Never

[LegalNotice]
Accepted=true

[Meta]
MigrationVersion=2

[Preferences]
Connection\PortRangeMin=6881
Connection\ResolvePeerCountries=true
Downloads\SavePath=/downloads
Downloads\TempPath=/downloads/incomplete
Downloads\TempPathEnabled=true
General\Locale=
Queueing\QueueingEnabled=true
WebUI\Address=*
WebUI\AlternativeUIEnabled=false
WebUI\Enabled=true
WebUI\HostHeaderValidation=true
WebUI\LocalHostAuth=true
WebUI\RootFolder=
WebUI\SecureCookie=true
WebUI\ServerDomains=*
WebUI\UseUPnP=true
EOL
fi

echo "Fixing permissions..."
chown qbittorrent:qbittorrent /data \
  /config \
  /downloads
  
chown -R qbittorrent:qbittorrent /home/qbittorrent

exec su-exec qbittorrent:qbittorrent "$@"
