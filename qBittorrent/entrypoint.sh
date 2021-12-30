#!/bin/sh -e

 
WEBUI_PORT=${WEBUI_PORT:-8080}
 

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

 
# Allow groups to change files.
umask 002
  
exec "$@"
