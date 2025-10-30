# Multi-stage Dockerfile to build a Tebako-packed CLI and produce a tiny runtime image
# Build stage: use Tebako official image (GNU/glibc). This image includes Ruby 3.3.7 and 3.4.1 toolchains.
FROM ghcr.io/tamatebako/tebako-ubuntu-20.04:latest AS builder
WORKDIR /app

# Copy app sources
COPY . /app

# Use tebako press and explicitly select Ruby 3.3.7 so gems that require >= 3.2 resolve correctly
# This will install gems as needed and produce a single self-contained binary
RUN tebako press \
  --root=/app \
  --entry-point=liquid.rb \
  --output=/app/dist/liquid-cli \
  --Ruby=3.3.7

# Runtime stage: minimal Debian (glibc based). Ruby is NOT required at runtime when using Tebako.
FROM debian:bookworm-slim AS runtime
WORKDIR /usr/local/bin
# helpful base utilities
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/dist/liquid-cli /usr/local/bin/liquid-cli

# Default command; you can override with docker run args
ENTRYPOINT ["/usr/local/bin/liquid-cli"]
