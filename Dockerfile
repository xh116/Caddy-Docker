FROM caddy:2.4.1-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive \
    --with github.com/imgk/caddy-trojan 

FROM alpine:latest

RUN apk add --no-cache --purge --clean-protected -u ca-certificates \
 && mkdir -p /etc/caddy /usr/share/caddy \
 && rm -rf /var/cache/apk/*

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

EXPOSE 80
EXPOSE 443

WORKDIR /Server

ENTRYPOINT ["caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
