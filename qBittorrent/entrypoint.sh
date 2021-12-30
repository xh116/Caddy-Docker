#!/bin/sh -e


if [ ! -f /config/qBittorrent.conf ]; then
  echo "Initializing qBittorrent configuration..."
  cat > /config/qBittorrent.conf <<EOL
  
[General]
ported_to_new_savepath_system=true

[Preferences]
WebUI\Enabled=true
WebUI\Address=*
WebUI\ServerDomains=*
WebUI\Port=${WEBUI_PORT}
Connection\PortRangeMin=9881
Downloads\SavePath=/downloads
Downloads\TempPath=/downloads/incomplete
Downloads\TempPathEnabled=true

[LegalNotice]
Accepted=true

EOL
fi

sed -i "s!ported_to_new_savepath_system.*!ported_to_new_savepath_system=true!g"  /config/qBittorrent.conf
sed -i "s!WebUI\\\Port=.*!WebUI\\\Port=${WEBUI_PORT}!g"  /config/qBittorrent.conf
sed -i "s!Downloads\\\SavePath=.*!Downloads\\\SavePath=/downloads!g" /config/qBittorrent.conf
sed -i "s!Downloads\\\TempPath=.*!Downloads\\\TempPath=/downloads/incomplete!g"  /config/qBittorrent.conf
sed -i "s!Downloads\\\TempPathEnabled=.*!Downloads\\\TempPathEnabled=true!g"  /config/qBittorrent.conf

chown qbittorrent:qbittorrent  /config/qBittorrent.conf


# Allow groups to change files.
umask 002
  
  
exec "$@"
