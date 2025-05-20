# 💾 Sistema de Balanceo MySQL con Nginx

## 🏗️ Arquitectura del Sistema

<p align="center">
  <img src="https://i.imgur.com/Ke4rUC8.png" alt="Imagen de la arquitectura">
</p>

El sistema está compuesto por:
- Un balanceador Nginx configurado para enrutar operaciones de lectura y escritura a diferentes puertos y servidores MySQL.
- Un clúster de MySQL con un nodo maestro (para escritura) y varios nodos esclavos (para lectura).
- Un cliente que ejecuta pruebas de rendimiento y monitorea el sistema.
- Todo el entorno se despliega automáticamente usando Vagrant y VirtualBox, facilitando la creación y destrucción de las máquinas virtuales necesarias para las pruebas.

---

## 📋 Descripción

**Este proyecto implementa un _balanceador de carga_ para bases de datos MySQL usando Nginx.** El objetivo es separar las operaciones de **lectura** y **escritura**: las *escrituras* se dirigen al nodo maestro y las *lecturas* se distribuyen entre los nodos esclavos. Todo el entorno se despliega de forma _automática_ con **Vagrant** y **VirtualBox**, permitiendo pruebas de rendimiento y análisis de arquitecturas distribuidas de manera sencilla y reproducible.

---

## 🚀 Instalación y Puesta en Marcha

### 1. Clonar el repositorio

```bash[
git clone https://github.com/edwingd18/database_balancer
cd database_balancer
```

### 2. Requisitos Previos
- [Vagrant](https://www.vagrantup.com/downloads) instalado
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) instalado

### 3. Iniciar el entorno
Ejecuta en la raíz del proyecto:

```bash
vagrant up
```

> ⏱️ *Por favor, espera a que todas las máquinas virtuales se inicien correctamente. Esto puede tomar varios minutos.*

---

## 🏗️ Monitoreo y Pruebas

### Monitoreo de logs del balanceador

1. Accede a la máquina del balanceador Nginx:

```bash
vagrant ssh nginx_balancer
```

2. Visualiza los logs en tiempo real:

```bash
tail -f /var/log/nginx/mysql_access.log
```

> 💡 *Mantén esta terminal abierta para observar las solicitudes mientras ejecutas las pruebas*

### Ejecutando pruebas de rendimiento

Abre una **nueva terminal** y accede a la máquina cliente:

```bash
vagrant ssh client
```

#### Pruebas de Escritura

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

#### Pruebas de Lectura

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

---

## 📈 Análisis de Resultados

Observa los siguientes aspectos en los resultados de las pruebas:
- Transacciones por segundo (TPS)
- Latencia (mínima, promedio, máxima)
- Tasas de error (si las hubiera)

En los logs del balanceador, podrás observar:
- Distribución de consultas entre servidores
- Tiempos de respuesta
- Posibles errores de conexión

---

## 🛑 Apagado y Limpieza del Sistema

Cuando hayas terminado las pruebas, puedes apagar las máquinas virtuales:

```bash
vagrant halt
```

O eliminarlas completamente:

```bash
vagrant destroy
```

---

## 📚 Información Adicional

- **Puerto 3307**: Configurado para operaciones de lectura (balanceado entre esclavos)
- **Puerto 3308**: Configurado para operaciones de escritura (dirigido al maestro)

---

*Desarrollado para pruebas de rendimiento de bases de datos MySQL❤️*
