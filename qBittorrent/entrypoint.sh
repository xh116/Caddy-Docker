#!/bin/sh -e

# Default configuration file
if [ ! -f /config/qBittorrent.conf ]
then
	cp /tmp/qBittorrent.conf /config/qBittorrent.conf
fi

# Allow groups to change files.
umask 002

exec "$@"
