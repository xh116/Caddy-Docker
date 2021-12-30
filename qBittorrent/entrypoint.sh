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

[BitTorrent]
Session\Port=59881
Session\QueueingSystemEnabled=true

[Preferences]
WebUI\Enabled=true
WebUI\Address=*
WebUI\ServerDomains=*
WebUI\AlternativeUIEnabled=${ALT_WEBUI}
WebUI\Port=${WEBUI_PORT}
Downloads\SavePath=/downloads
Downloads\TempPath=/downloads/incomplete
Downloads\TempPathEnabled=true
Downloads\ScanDirsV2=@Variant(\0\0\0\x1c\0\0\0\0)

[LegalNotice]
Accepted=true

EOL
fi

sed -i "s!WebUI\\\Port=.*!WebUI\\\Port=${WEBUI_PORT}!g"  /config/qBittorrent.conf
sed -i "s!Downloads\\\SavePath=.*!Downloads\\\SavePath=/downloads!g" /config/qBittorrent.conf
sed -i "s!Downloads\\\TempPath=.*!Downloads\\\TempPath=/downloads/incomplete!g"  /config/qBittorrent.conf
sed -i "s!Downloads\\\TempPathEnabled=.*!Downloads\\\TempPathEnabled=true!g"  /config/qBittorrent.conf


# Allow groups to change files.
umask 002

exec "$@"
