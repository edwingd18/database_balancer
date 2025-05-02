#!/bin/bash

echo "[INFO] Instalando MySQL Server en el esclavo..."

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y mysql-server

echo "[INFO] Configurando MySQL como esclavo..."
systemctl stop mysql
cp /vagrant/config/my.conf.slave /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl start mysql

if systemctl is-active --quiet mysql; then
    echo "[✅] MySQL está corriendo como esclavo."
else
    echo "[❌] MySQL no se pudo iniciar." >&2
    exit 1
fi

echo "[INFO] Obteniendo binlog y posición desde el maestro (192.168.70.10)..."

# Conexión remota al maestro para obtener el log bin y la posición
read -r MASTER_LOG_FILE MASTER_LOG_POS <<< $(mysql -uadmin -padmin -h 192.168.70.10 -e "SHOW MASTER STATUS\G" | awk '/File:/ {print $2} /Position:/ {print $2}' | tr '\n' ' ')

if [[ -z "$MASTER_LOG_FILE" || -z "$MASTER_LOG_POS" ]]; then
    echo "[❌] No se pudo obtener log binario y posición del maestro." >&2
    exit 1
fi

echo "[DEBUG] MASTER_LOG_FILE = $MASTER_LOG_FILE)"
echo "[DEBUG] MASTER_LOG_POS  = $MASTER_LOG_POS)"

echo "[INFO] Configurando esclavo para replicar desde el maestro..."
mysql -uroot -padmin <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'admin';
FLUSH PRIVILEGES;
EOF

mysql -uroot -padmin <<EOF
STOP SLAVE;
RESET SLAVE ALL;
CHANGE MASTER TO
    MASTER_HOST='192.168.70.10',
    MASTER_USER='admin',
    MASTER_PASSWORD='admin',
    MASTER_LOG_FILE='$MASTER_LOG_FILE',
    MASTER_LOG_POS=$MASTER_LOG_POS;
START SLAVE;
EOF

echo "[INFO] Verificando estado de la replicación ..."

SLAVE_IO_RUNNING=$(mysql -uroot -padmin -e "SHOW SLAVE STATUS\G" | grep "Slave_IO_Running:" | awk '{print $2}')
SLAVE_SQL_RUNNING=$(mysql -uroot -padmin -e "SHOW SLAVE STATUS\G" | grep "Slave_SQL_Running:" | awk '{print $2}')

if [[ "$SLAVE_IO_RUNNING" == "Yes" && "$SLAVE_SQL_RUNNING" == "Yes" ]]; then
    echo "[✅] La replicación está funcionando correctamente."
else
    echo "[❌] La replicación NO está funcionando. Verifica configuración y logs." >&2
    exit 1
fi


echo "[INFO] Configurando acceso remoto restringido para root (solo desde el balanceador)..."
mysql -uroot -padmin <<EOF

CREATE USER 'root'@'192.168.70.12' IDENTIFIED BY 'admin';  
GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.70.12' WITH GRANT OPTION;  
FLUSH PRIVILEGES;
EOF

echo "[INFO] Creando base de datos en el maestro para probar replicación..."

mysql -uroot -padmin -h 192.168.70.10 <<EOF
CREATE DATABASE test;
CREATE DATABASE sbtest;
USE test;
CREATE TABLE test (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100));
INSERT INTO test (name) VALUES ('dato1'), ('dato2');
EOF

echo "[✅] Base de datos creada en el maestro. Debería replicarse en el esclavo."
