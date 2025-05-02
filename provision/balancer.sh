#!/bin/bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null

echo "[INFO] Instalando nginx..."

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx

echo "[INFO] Configurando nginx como balanceador de carga..."
systemctl stop nginx
cp /vagrant/config/conf.balancer /etc/nginx/nginx.conf
systemctl start nginx

if systemctl is-active --quiet nginx; then
    echo "[✅] nginx está corriendo como balanceador de carga."
else
    echo "[❌] nginx no se pudo iniciar." >&2
    exit 1
fi
