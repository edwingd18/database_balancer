#!/bin/bash

echo "[INFO] Instalando MySQL Server en el maestro..."

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y mysql-server

echo "[INFO] Configurando MySQL como maestro..."
systemctl stop mysql
cp /vagrant/config/my.conf.master /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl start mysql

if systemctl is-active --quiet mysql; then
    echo "[✅] MySQL está corriendo como maestro."
else
    echo "[❌] MySQL no se pudo iniciar." >&2
    exit 1
fi

echo "[INFO] Creando usuario de replicación..."
mysql -uroot -padmin <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'admin';
FLUSH PRIVILEGES;

CREATE USER 'admin'@'192.168.70.11' IDENTIFIED WITH mysql_native_password BY 'admin';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'admin'@'192.168.70.11';
FLUSH PRIVILEGES;
EOF

# Configuración de acceso remoto para root desde el balanceador y el esclavo
echo "[INFO] Configurando acceso remoto restringido para root (solo desde el balanceador y el esclavo)..."
mysql -uroot -padmin <<EOF

CREATE USER 'root'@'192.168.70.11' IDENTIFIED BY 'admin';
CREATE USER 'root'@'192.168.70.12' IDENTIFIED BY 'admin';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.70.12' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.70.11' WITH GRANT OPTION;  


FLUSH PRIVILEGES;

EOF

echo "[✅] Maestro configurado correctamente."
