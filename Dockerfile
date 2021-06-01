FROM caddy:2.4.1-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive \
    --with github.com/imgk/caddy-trojan \
    --with github.com/mholt/caddy-webdav 

FROM 2.4.1-builder-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
