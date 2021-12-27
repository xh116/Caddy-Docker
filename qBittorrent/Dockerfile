FROM alpine:latest AS builder


# Compiling qBitTorrent following instructions on
# https://github.com/qbittorrent/qBittorrent/wiki/Compiling-qBittorrent-on-Debian-and-Ubuntu#Libtorrent
RUN set -x \
    # Install build dependencies
 && apk add --no-cache -t .build-deps \
        boost-dev \
        jq \
        unzip \
        cmake \
        g++ \
        git \
        libressl-dev \
        make \
        qt5-qttools-dev 

    # Build lib rasterbar from source code (required by qBittorrent)
 RUN cd /tmp \      
 && LIBTORRENT_RASTERBAR_URL=$(curl -sSL https://api.github.com/repos/arvidn/libtorrent/releases/latest | grep -E 'browser_download_url.*libtorrent-rasterbar'  | head -n 1 | cut -d '"' -f 4) \
 && mkdir /tmp/libtorrent-rasterbar \
 && curl -sSL $LIBTORRENT_RASTERBAR_URL | tar xzC /tmp/libtorrent-rasterbar \
 && cd /tmp/libtorrent-rasterbar/* \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make \
 && make DESTDIR=/ install \
 && mv /usr/local/lib64/* /usr/local/lib \
 && rmdir /usr/local/lib64 

    # Build qBittorrent from source code
 RUN cd /tmp \   
 && git clone https://github.com/qbittorrent/qBittorrent.git /tmp/qbittorrent \
 && cd /tmp/qbittorrent \
 && ./configure --disable-gui --disable-stacktrace \
 && make -j$(nproc) \
 && make install \
 && ls -al /usr/local/bin/ \
 && qbittorrent-nox --help

 RUN mkdir /tmp/vuetorrent && cd /tmp/vuetorrent \
 && export version=$(curl -s "https://api.github.com/repos/WDaan/VueTorrent/releases/latest" | jq -r .tag_name)  \
 && wget -P /home/qbittorrent https://github.com/WDaan/VueTorrent/releases/download/${version}/vuetorrent.zip \
 && unzip vuetorrent.zip \
  # Clean-up
 && rm vuetorrent.zip \ 
 && ls -la \
 && apk del --purge .build-deps \
 && rm -rf /tmp/* /var/cache/apk/*


FROM alpine:latest


COPY --from=builder /usr/local/lib/libtorrent-rasterbar.so.10.0.0 /usr/lib/libtorrent-rasterbar.so.10
COPY --from=builder /usr/local/bin/qbittorrent-nox /usr/bin/qbittorrent-nox
COPY --from=builder /tmp/vuetorrent /


# Install required packages
RUN apk --update --no-cache add \
        boost-system \
        boost-thread \
        ca-certificates \
        curl \
        dumb-init \
        libressl \
        qt5-qtbase \
        && rm -rf /tmp/* /var/cache/apk/*

ENV HOME=/home/qbittorrent
ENV PUID=1500
ENV PGID=1500
ENV WEBUI_PORT=8080        


# Copy files

COPY qBittorrent/qBittorrent.conf /default/qBittorrent.conf
COPY qBittorrent/entrypoint.sh /

RUN chmod a+x /usr/local/bin/qbittorrent-nox \
  && mkdir -p /home/qbittorrent/.config/qBittorrent \
  && mkdir -p /home/qbittorrent/.local/share/qBittorrent \
  && mkdir /downloads \
  && ln -s /home/qbittorrent/.config/qBittorrent /config \
  && ln -s /home/qbittorrent/.local/share/qBittorrent /torrents        


VOLUME ["/config", "/torrents", "/downloads"]
 

RUN chmod a+x /entrypoint.sh \
  && addgroup -g ${PGID} qbittorrent \
  && adduser -D -h ${HOME} -u ${PUID} -G qbittorrent -s /bin/sh qbittorrent \
  && qbittorrent-nox --version


EXPOSE 8080 6881

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
CMD qbittorrent-nox --webui-port=$WEBUI_PORT

HEALTHCHECK --interval=5s --timeout=2s --retries=20 CMD curl --connect-timeout 15 --silent --show-error --fail http://localhost:8080/ >/dev/null || exit 1
