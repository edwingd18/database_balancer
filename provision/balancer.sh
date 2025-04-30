#!/bin/bash

echo "[INFO] Instalando nginx..."

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx

echo "[INFO] Configurando nginx como balanceador de carga..."
systemctl stop nginx
cp /vagrant/config/conf.balancer /etc/nginx/nginx.conf
systemctl start nginx

if systemctl is-active --quiet nginx; then
    echo "[OK] nginx está corriendo como balanceador de carga."
else
    echo "[ERROR] nginx no se pudo iniciar." >&2
    exit 1
fi
