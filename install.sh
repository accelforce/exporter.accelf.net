#!/bin/sh
set -e

# node_exporter install script
# curl -fsSL https://exporter.accelf.net/ | sh

VERSION="0.18.1"

do_install() {
  echo "node_exporter binary install script"
  echo "Create user prometheus"
  sudo useradd -ms /bin/bash prometheus
  echo "Download binary file"
  curl -fsSL "https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz" | sudo tar -xzO "node_exporter-$VERSION.linux-amd64/node_exporter" > /home/prometheus/node_exporter
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
