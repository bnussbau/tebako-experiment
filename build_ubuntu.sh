#!/bin/zsh

docker buildx build --platform linux/amd64 --tag bnussbau/trmnl-liquid-cli:latest -f=Dockerfile_ubuntu .