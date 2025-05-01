# 💾 Sistema de Balanceo MySQL con Nginx

## 📋 Descripción
Este proyecto implementa un sistema de balanceo de carga para MySQL utilizando Nginx, configurado con máquinas virtuales a través de Vagrant.

## 🛠️ Requisitos Previos
- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado

## 🔧 Configuración inicial

### Paso 1: Iniciar el entorno
Ejecuta en la raíz del proyecto:

```bash
vagrant up
```

> ⏱️ *Por favor, espera a que todas las máquinas virtuales se inicien correctamente. Esto puede tomar varios minutos.*

## 📊 Monitoreo y Pruebas

### 📝 Monitoreo de logs del balanceador

1. Accede a la máquina del balanceador Nginx:

```bash
vagrant ssh nginx_balancer
```

2. Visualiza los logs en tiempo real:

```bash
tail -f /var/log/nginx/mysql_access.log
```

> 💡 *Mantén esta terminal abierta para observar las solicitudes mientras ejecutas las pruebas*

### 🔍 Ejecutando pruebas de rendimiento

Abre una **nueva terminal** y accede a la máquina cliente:

```bash
vagrant ssh client
```

#### 📥 Pruebas de Escritura

Ejecuta el siguiente comando para realizar pruebas de escritura:

```bash
sysbench /usr/share/sysbench/oltp_write_only.lua \
--mysql-host=192.168.70.12 \
--mysql-port=3308 \
--mysql-user=root \
--mysql-password=admin \
--mysql-db=sbtest \
--tables=4 \
--table-size=10000 \
--threads=8 \
--time=30 \
--report-interval=5 \
run
```

#### 📤 Pruebas de Lectura

Ejecuta el siguiente comando para realizar pruebas de lectura:

```bash
sysbench /usr/share/sysbench/oltp_read_only.lua \
--mysql-host=192.168.70.12 \
--mysql-port=3307 \
--mysql-user=root \
--mysql-password=admin \
--mysql-db=sbtest \
--tables=4 \
--table-size=10000 \
--threads=8 \
--time=30 \
--report-interval=5 \
run
```

## 📈 Análisis de Resultados

Observa los siguientes aspectos en los resultados de las pruebas:
- Transacciones por segundo (TPS)
- Latencia (mínima, promedio, máxima)
- Tasas de error (si las hubiera)

En los logs del balanceador, podrás observar:
- Distribución de consultas entre servidores
- Tiempos de respuesta
- Posibles errores de conexión

## 🛑 Apagado del Sistema

Cuando hayas terminado las pruebas, puedes apagar las máquinas virtuales:

```bash
vagrant halt
```

O eliminarlas completamente:

```bash
vagrant destroy
```

## 🔄 Arquitectura del Sistema

<p align="center">
  <img src="https://i.ibb.co/h1H7rfnM/Screenshot-2025-05-01-134834.png" alt="Imagen de la arquitectura">
</p>

---


## 📚 Información Adicional

- Puerto 3307: Configurado para operaciones de lectura (balanceado entre esclavos)
- Puerto 3308: Configurado para operaciones de escritura (dirigido al maestro)

---

*Desarrollado con ❤️ para pruebas de rendimiento de bases de datos MySQL*
