FROM alpine:latest AS builder


# Compiling qBitTorrent following instructions on
# https://github.com/qbittorrent/qBittorrent/wiki/Compilation%3A-Alpine-Linux
RUN set -x \
    # Install build dependencies
 && apk add --no-cache -t .build-deps \
    autoconf \
    automake \
    build-base \
    cmake \
    curl \
    git \
    libtool \
    linux-headers \
    perl \
    pkgconf \
    python3 \
    python3-dev \
    re2c \
    tar  \
    icu-dev \
    libexecinfo-dev \
    openssl-dev \
    qt6-qtbase-dev \
    qt6-qttools-dev \
    zlib-dev \
    qt6-qtsvg-dev




  # Build Ninja from source
RUN cd /tmp \ 
&& git clone --shallow-submodules --recurse-submodules https://github.com/ninja-build/ninja.git  /tmp/ninja \
&& cd /tmp/ninja \
&& cmake -Wno-dev -B build  \
    -D CMAKE_CXX_STANDARD=17 \
    -D CMAKE_INSTALL_PREFIX="/usr/local" \
&& cmake --build build \
&& cmake --install build 


  #Download boost
RUN cd /tmp \ 
&& curl -sNLk https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.gz -o "/tmp/boost_1_77_0.tar.gz" \
&& tar xf "/tmp/boost_1_77_0.tar.gz" -C "/tmp"


    # Build lib rasterbar from source code (required by qBittorrent)
 RUN cd /tmp \      
 && LIBTORRENT_RASTERBAR_URL=$(curl -sSL https://api.github.com/repos/arvidn/libtorrent/releases/latest | grep -E 'browser_download_url.*libtorrent-rasterbar'  | head -n 1 | cut -d '"' -f 4) \
 && mkdir /tmp/libtorrent-rasterbar \
 && curl -sSL $LIBTORRENT_RASTERBAR_URL | tar xzC /tmp/libtorrent-rasterbar \
 && cd /tmp/libtorrent-rasterbar/* \
 && cmake -Wno-dev -G Ninja -B build \
    -D CMAKE_BUILD_TYPE="Release" \
    -D CMAKE_CXX_STANDARD=17 \
    -D BOOST_INCLUDEDIR="/tmp/boost_1_77_0/" \
    -D CMAKE_INSTALL_LIBDIR="lib" \
    -D CMAKE_INSTALL_PREFIX="/usr/local" \
 && cmake --build build \
 && cmake --install build \
 && mkdir /lib64 \
 && cp -P /usr/local/lib/libtorrent-rasterbar.so*  /lib64 
 


    # Build qBittorrent from source code
 RUN cd /tmp \   
 && git clone https://github.com/qbittorrent/qBittorrent.git /tmp/qbittorrent \
 && cd /tmp/qbittorrent \
&& cmake -Wno-dev -G Ninja -B build \
    -D QT6=ON \
    -D STACKTRACE=OFF \
    -D GUI=OFF \
    -D CMAKE_BUILD_TYPE="release" \
    -D CMAKE_CXX_STANDARD=17 \
    -D BOOST_INCLUDEDIR="/tmp/boost_1_77_0/" \
    -D CMAKE_CXX_STANDARD_LIBRARIES="/usr/lib/libexecinfo.so" \
    -D CMAKE_INSTALL_PREFIX="/usr/local" \
&& cmake --build build \
&& cmake --install build \  
# Clean-up
&& apk del --purge .build-deps \
&& rm -rf /tmp/* /var/cache/apk/*


FROM alpine:latest


# Install required packages
RUN apk --update --no-cache add \
        bind-tools \
        openssl \
        qt6-qtbase \
        zlib \ 
        mktorrent \
        && rm -rf /tmp/* /var/cache/apk/*


COPY --from=builder /lib64 /usr/lib/
COPY --from=builder /usr/local/bin/qbittorrent-nox /usr/bin/qbittorrent-nox


# Default configuration file.
COPY qBittorrent/qBittorrent.conf /default/qBittorrent.conf
COPY qBittorrent/entrypoint.sh / 


RUN chmod a+x /usr/bin/qbittorrent-nox \
  && chmod a+x /entrypoint.sh \
  && mkdir -p /home/qbittorrent/.config/qBittorrent \
  && mkdir -p /home/qbittorrent/.local/share/data/qBittorrent \
  && mkdir /downloads \
  && ln -s /home/qbittorrent/.config/qBittorrent /config \
  && ln -s /home/qbittorrent/.local/share/data/qBittorrent /data       

RUN addgroup -g ${PGID} qbittorrent \
  && adduser -D -h ${HOME} -u ${PUID} -G qbittorrent -s /bin/sh qbittorrent \
  && qbittorrent-nox --version

ENV HOME=/home/qbittorrent
ENV PUID=1500
ENV PGID=1500
ENV WEBUI_PORT=8080   

EXPOSE 9881 9881/udp 8080
VOLUME ["/config", "/data", "/downloads"]


ENTRYPOINT ["/entrypoint.sh"]

CMD ["qbittorrent-nox", "--webui-port=$WEBUI_PORT"]
