#!/bin/bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null

echo "[INFO] Instalando sysbench..."

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y sysbench

echo "[INFO] Preparando los datos para la prueba en el cliente..."

sysbench /usr/share/sysbench/oltp_read_write.lua \
--mysql-host=192.168.70.12 \
--mysql-port=3308 \
--mysql-user=root \
--mysql-password=admin \
--mysql-db=sbtest \
--tables=4 \
--table-size=10000 \
prepare

echo "[✅] Todo listo para la prueba en el cliente."
