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
    echo "[OK] MySQL está corriendo como maestro."
else
    echo "[ERROR] MySQL no se pudo iniciar." >&2
    exit 1
fi

echo "[INFO] Creando usuario de replicación..."

echo "[INFO] Creando usuario de replicación..."
mysql -uroot -padmin <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'admin';
FLUSH PRIVILEGES;

DROP USER IF EXISTS 'admin'@'192.168.70.%';
CREATE USER 'admin'@'192.168.70.%' IDENTIFIED WITH mysql_native_password BY 'admin';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'admin'@'192.168.70.%';
FLUSH PRIVILEGES;
EOF

echo "[INFO] Habilitando acceso remoto para root desde el esclavo..."
mysql -uroot -padmin <<EOF
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'admin';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

GRANT ALL PRIVILEGES ON sbtest.* TO 'admin'@'192.168.70.%';
FLUSH PRIVILEGES;
EOF
mysql -uroot -padmin <<EOF
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'admin';
FLUSH PRIVILEGES;

EOF



echo "[✅] Maestro configurado correctamente."


