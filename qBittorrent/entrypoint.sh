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


echo "Creating folders..."
mkdir -p  /config \
   /data \
   /downloads \
  /downloads/incomplete \
  ${QBITTORRENT_HOME}/.config \
  ${QBITTORRENT_HOME}/.local/share \
  /var/log/qbittorrent
if [ ! -e "${QBITTORRENT_HOME}/.config/qBittorrent" ]; then
  ln -s  /config "${QBITTORRENT_HOME}/.config/qBittorrent"
fi
if [ ! -e "${QBITTORRENT_HOME}/.local/share/qBittorrent" ]; then
  ln -s /data "${QBITTORRENT_HOME}/.local/share/qBittorrent"
fi



if [ ! -f /config/qBittorrent.conf ]; then
  echo "Initializing qBittorrent configuration..."
  cat > /config/qBittorrent.conf <<EOL  
[General]
ported_to_new_savepath_system=true

[Application]
FileLogger\Enabled=true
FileLogger\Path=/var/log/qbittorrent

[LegalNotice]
Accepted=true

[Preferences]
Bittorrent\AddTrackers=false
Connection\PortRangeMin=9881
Downloads\PreAllocation=true
Downloads\StartInPause=false
Downloads\SavePath=/downloads
Downloads\TempPathEnabled=true
Downloads\TempPath=/downloads/incomplete
WebUI\Enabled=true
WebUI\Address=*
WebUI\Port=${WEBUI_PORT}

EOL
fi

echo "Overriding required parameters..."
sed -i "s!FileLogger\\\Enabled=.*!FileLogger\\\Enabled=true!g"  /config/qBittorrent.conf
sed -i "s!FileLogger\\\Path=.*!FileLogger\\\Path=/var/log/qbittorrent!g"  /config/qBittorrent.conf
sed -i "s!ported_to_new_savepath_system.*!ported_to_new_savepath_system=true!g"  /config/qBittorrent.conf
sed -i "s!Downloads\\\SavePath=.*!Downloads\\\SavePath=/downloads!g" /config/qBittorrent.conf
sed -i "s!Downloads\\\TempPath=.*!Downloads\\\TempPath=/downloads/incomplete!g"  /config/qBittorrent.conf
sed -i "s!Downloads\\\TempPathEnabled=.*!Downloads\\\TempPathEnabled=true!g"  /config/qBittorrent.conf
sed -i "s!WebUI\\\Port=.*!WebUI\\\Port=${WEBUI_PORT}!g"  /config/qBittorrent.conf


echo "Fixing permissions..."
chown qbittorrent:qbittorrent  /config \
/data \
/downloads 
chown -R qbittorrent:qbittorrent "${QBITTORRENT_HOME}" /var/log/qbittorrent
  
exec "$@"
