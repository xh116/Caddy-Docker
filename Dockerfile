FROM caddyserver/xcaddy as build

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
