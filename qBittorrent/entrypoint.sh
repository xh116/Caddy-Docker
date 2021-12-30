#!/bin/sh -e

 
# Default configuration file
WEBUI_PORT=${WEBUI_PORT:-8080}
ALT_WEBUI=${ALT_WEBUI:-false}
if [ "${ALT_WEBUI}" != "true" ]; then
  ALT_WEBUI=false
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
WebUI\AlternativeUIEnabled=${ALT_WEBUI}


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

chown -R qbittorrent:qbittorrent "${HOME}" /var/log/qbittorrent

# Allow groups to change files.
umask 002
  
exec "$@"
