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

[Preferences]
General\Locale=C
WebUI\Enabled=true
WebUI\Address=*
WebUI\ServerDomains=*
WebUI\AlternativeUIEnabled=${ALT_WEBUI}
WebUI\Port=${WEBUI_PORT}
Downloads\SavePath=/downloads
Connection\PortRangeMin=9881
Downloads\ScanDirsV2=@Variant(\0\0\0\x1c\0\0\0\0)

[LegalNotice]
Accepted=true

[General]
ported_to_new_savepath_system=true

EOL
fi


# Allow groups to change files.
umask 002

exec "$@"
