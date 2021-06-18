#!/bin/sh
set -e

# node_exporter install script
# curl -fsSL https://exporter.accelf.net/ | sh

VERSION="1.1.2"

# GOOS & GOARCH mapping
# https://github.com/mutagen-io/mutagen/blob/f772d556fb270df36c2fe6f824d5c79100fd4885/pkg/agent/probe.go

case $(uname -s) in
  "Darwin") GOOS="darwin";;
  "Linux") GOOS="linux";;
  "NetBSD") GOOS="netbsd";;
  "OpenBSD") GOOS="openbsd";;
  *)
    echo "Unsupported OS, exiting..."
    exit 1;;
esac

case $(uname -m) in
  "i386" | "i486" | "i586" | "i686") GOARCH="386";;
  "x86_64" | "amd64") GOARCH="amd64";;
  "armv5l") GOARCH="armv5";;
  "armv6l") GOARCH="armv6";;
  "armv7l") GOARCH="armv7";;
  "armv8l" | "aarch64" | "arm64") GOARCH="arm64";;
  "mips") GOARCH="mips";;
  "mipsel") GOARCH="mipsle";;
  "mips64") GOARCH="mips64";;
  "mips64el") GOARCH="mips64le";;
  "ppc64") GOARCH="ppc64";;
  "ppc64le") "ppc64le";;
  "s390x") "s390x";;
  *)
    echo "Unsupported architecture, exiting..."
    exit 1;;
esac

do_install() {
  echo "node_exporter binary install script"

  echo "Create user prometheus"
  sudo useradd -ms /bin/bash prometheus

  echo "Download binary file"
  sudo su -c "curl -fsSL https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.$GOOS-$GOARCH.tar.gz | tar -xzO node_exporter-$VERSION.$GOOS-$GOARCH/node_exporter > /home/prometheus/node_exporter"
  sudo chmod +x /home/prometheus/node_exporter
  sudo chown prometheus /home/prometheus/node_exporter

  echo "Download systemd config file"
  sudo curl -fsSL https://exporter.accelf.net/node_exporter.service -o /etc/systemd/system/node_exporter.service
  sudo systemctl daemon-reload
  sudo systemctl enable node_exporter
  sudo systemctl start node_exporter

  echo "Install completed"
  curl -fsSL localhost:9100/metrics | grep -e '^node_exporter_build_info'
}

do_install
