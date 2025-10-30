#!/usr/bin/env bash
set -euo pipefail

# Build a self-contained executable using Tebako on the host (requires tebako installed)
# Usage: bin/build-tebako.sh

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT_DIR"

if ! command -v tebako >/dev/null 2>&1; then
  echo "Error: tebako is not installed. Try the Docker build instead: docker build -t liquid-cli ." >&2
  exit 1
fi

# Ensure dependencies resolved
if [ -f Gemfile ]; then
  if ! command -v bundle >/dev/null 2>&1; then
    echo "Error: bundler not found" >&2
    exit 1
  fi
  bundle install --path vendor/bundle
fi

# Pack
OUT_DIR="$ROOT_DIR/dist"
mkdir -p "$OUT_DIR"

echo "Packing with Tebako..."
# Use config; override output path
tebako pack --config tebako.toml --output "$OUT_DIR/liquid-cli"

echo "Built $OUT_DIR/liquid-cli"
