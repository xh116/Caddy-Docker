FROM alpine:latest AS builder

# Install required packages
RUN apk add --update --no-cache \
    autoconf \
    automake \
    binutils \
    boost-dev \
    build-base \
    cppunit-dev \
    git \
    libtool \
    linux-headers \
    ncurses-dev \
    openssl-dev \
    zlib-dev \
    qt5-qtbase \
    qt5-qttools-dev \
  && rm -rf /tmp/* /var/cache/apk/*

# Compiling libtorrent following instructions on

RUN cd /tmp \
    && git clone --recurse-submodules https://github.com/arvidn/libtorrent.git \
    && cd libtorrent \
    && ./autotool.sh \
    && ./configure CXXFLAGS="-std=c++14" --with-libiconv \
    && make -j$(nproc) \
    && make install-strip \
    && ls -al /usr/local/lib/  
    

# Compiling qBitTorrent following instructions on
RUN cd /tmp \
  && git clone  https://github.com/qbittorrent/qBittorrent.git \
  && cd qBittorrent \
  && ./configure --disable-gui \
  && make -j$(nproc) \
  && make install \
  && ls -al /usr/local/bin/ 
  
  
FROM alpine:latest 

COPY --from=builder /usr/local/lib/libtorrent-rasterbar.so.10.0.0 /usr/lib/libtorrent-rasterbar.so.10
COPY --from=builder /usr/local/bin/qbittorrent-nox /usr/bin/qbittorrent-nox
 
RUN apk --update --no-cache add \
    bind-tools \
    curl \
    openssl \
    qt5-qtbase \
    shadow \
    tzdata \
    unrar \
    unzip \
    zlib \
  && rm -rf /tmp/* /var/cache/apk/* 
 
RUN set -x \
    # Add non-root user
 && adduser -S -D -u 520 -g 520 -s /sbin/nologin qbittorrent \
    # Create symbolic links to simplify mounting
 && mkdir -p /home/qbittorrent/.config/qBittorrent \
 && mkdir -p /home/qbittorrent/.local/share/qBittorrent \
 && mkdir /downloads \
 && chmod go+rw -R /home/qbittorrent /downloads \
 && ln -s /home/qbittorrent/.config/qBittorrent /config \
 && ln -s /home/qbittorrent/.local/share/qBittorrent /torrents \
    # Check it works
 && su qbittorrent -s /bin/sh -c 'qbittorrent-nox -v'

# Default configuration file.
COPY qBittorrent/qBittorrent.conf /default/qBittorrent.conf
COPY qBittorrent/entrypoint.sh /

VOLUME ["/config", "/torrents", "/downloads"]

ENV HOME=/home/qbittorrent

USER qbittorrent

EXPOSE 8080 6881

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
CMD ["qbittorrent-nox"]

HEALTHCHECK --interval=5s --timeout=2s --retries=20 CMD curl --connect-timeout 15 --silent --show-error --fail http://localhost:8080/ >/dev/null || exit 1
