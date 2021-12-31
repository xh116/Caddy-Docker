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

# Default configuration file
if [ ! -f /config/qBittorrent.conf ]
then
	cp /tmp/qBittorrent.conf /config/qBittorrent.conf
fi

chown qbittorrent:qbittorrent /data \
   /config \
   /downloads \ 
chown -R qbittorrent:qbittorrent /home/qbittorrent

# Allow groups to change files.
umask 002

exec "$@"
