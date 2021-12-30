#!/bin/sh 


if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g qbittorrent)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^qbittorrent:\([^:]*\):[0-9]*/qbittorrent:\1:${PGID}/" /etc/group
  sed -i -e "s/^qbittorrent:\([^:]*\):\([0-9]*\):[0-9]*/qbittorrent:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u qbittorrent)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^qbittorrent:\([^:]*\):[0-9]*:\([0-9]*\)/qbittorrent:\1:${PUID}:\2/" /etc/passwd
fi

WEBUI_PORT=${WEBUI_PORT:-8080}

echo "Creating folders..."
mkdir -p /downloads/incomplete \
  /config \
  /data  \
  ${QBITTORRENT_HOME}/.config \
  ${QBITTORRENT_HOME}/.local/share \
  /var/log/qbittorrent
if [ ! -e "${QBITTORRENT_HOME}/.config/qBittorrent" ]; then
  ln -s /config "${QBITTORRENT_HOME}/.config/qBittorrent"
fi
if [ ! -e "${QBITTORRENT_HOME}/.local/share/qBittorrent" ]; then
  ln -s /data "${QBITTORRENT_HOME}/.local/share/qBittorrent"
fi
 

if [ ! -f /config/qBittorrent.conf ]; then
  echo "Initializing qBittorrent configuration..."
  cat > /config/qBittorrent.conf <<EOL  
[General]
ported_to_new_savepath_system=true
[LegalNotice]
Accepted=true
[Preferences]
Bittorrent\AddTrackers=false
Connection\PortRangeMin=9881
Downloads\PreAllocation=true
Downloads\StartInPause=false
Downloads\TempPathEnabled=true
Downloads\SavePath=/downloads
Downloads\TempPath=/downloads/incomplete
WebUI\Enabled=true
WebUI\Address=*
WebUI\Port=${WEBUI_PORT}
WebUI\AlternativeUIEnabled=${ALT_WEBUI}
EOL
fi

echo "Overriding required parameters..."
sed -i "s!ported_to_new_savepath_system.*!ported_to_new_savepath_system=true!g"  /config/qBittorrent.conf
sed -i "s!Downloads\\\SavePath=.*!Downloads\\\SavePath=/downloads!g" /config/qBittorrent.conf
sed -i "s!Downloads\\\TempPath=.*!Downloads\\\TempPath=/downloads/incomplete!g"  /config/qBittorrent.conf
sed -i "s!Downloads\\\TempPathEnabled=.*!Downloads\\\TempPathEnabled=true!g"  /config/qBittorrent.conf
sed -i "s!WebUI\\\Port=.*!WebUI\\\Port=${WEBUI_PORT}!g"  /config/qBittorrent.conf

echo "Fixing perms..."
chown qbittorrent:qbittorrent /config/qBittorrent.conf \
   /downloads/incomplete \
   /config \
   /data 

chown -R qbittorrent:qbittorrent "${QBITTORRENT_HOME}"
  
exec "$@"
