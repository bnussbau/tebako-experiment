FROM ghcr.io/tamatebako/tebako-alpine-3.17:latest AS builder
WORKDIR /app

# Copy app sources
COPY . /app

RUN tebako press \
  --root=/app \
  --entry-point=liquid-cli.rb \
  --output=/app/dist/liquid-cli \
  --Ruby=3.3.7

FROM alpine:3.17 AS runtime
WORKDIR /usr/local/bin
COPY --from=builder /app/dist/liquid-cli /usr/local/bin/liquid-cli
ENTRYPOINT ["/usr/local/bin/liquid-cli"]
