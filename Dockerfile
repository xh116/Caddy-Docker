FROM golang:alpine AS builder

RUN set -e \
    && apk upgrade \
    && apk add jq curl git \
    && export version=$(curl -s "https://api.github.com/repos/caddyserver/caddy/releases/latest" | jq -r .tag_name) \
    && echo ">>>>>>>>>>>>>>> ${version} ###############" \
    && go get -u github.com/caddyserver/xcaddy/cmd/xcaddy \
    && xcaddy build ${version} --output /caddy \ 
        --with github.com/caddy-dns/cloudflare \
        --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive \        
        --with github.com/imgk/caddy-trojan \
        --with github.com/mholt/caddy-webdav 
         

FROM alpine:latest AS dist

LABEL maintainer="cx@tinyserve.com"


 
# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

ENV TZ Asia/Shanghai

COPY --from=builder /caddy /usr/bin/caddy
ADD https://raw.githubusercontent.com/caddyserver/dist/master/config/Caddyfile /etc/caddy/Caddyfile
ADD https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html /usr/share/caddy/index.html

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

RUN set -e \
    && apk upgrade \
    && apk add bash tzdata mailcap \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /var/cache/apk/*

VOLUME /config
VOLUME /data

EXPOSE 80
EXPOSE 443
# EXPOSE 2019

WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
