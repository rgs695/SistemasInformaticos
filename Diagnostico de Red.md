# Protocolo de Diagnóstico de Problemas de Red en Linux

**Asignatura:** Administración de Sistemas
**Basado en:** Apuntes de clase – Introducción a Redes (TCP/IP)

---

## Objetivo

Proporcionar una guía práctica y sistemática para identificar y resolver problemas de red en sistemas Linux, siguiendo el enfoque por capas del modelo TCP/IP. Está diseñado para utilizarse durante prácticas o exámenes donde se detectan fallos de conectividad o configuración de red.

---

## 1. Verificar el estado de la interfaz de red

### Comandos para listar interfaces:

```bash
ip link show
ifconfig -a
```

### Para levantar una interfaz inactiva:

```bash
ip link set <interfaz> up
ifup <interfaz>
```

---

## 2. Revisar la configuración IP

### Comprobar IP, máscara y broadcast:

```bash
ip address show
ifconfig
```

### Revisar tabla de rutas:

```bash
ip route show
route -n
```

Debe haber una ruta por defecto, como:

```
default via 192.168.1.1 dev enp0s3
```

### Si la IP es estática, verificar configuración en:

```
/etc/network/interfaces
```

Y reiniciar la interfaz:

```bash
ifdown <interfaz>
ifup <interfaz>
```

---

## 3. Comprobar funcionamiento del DHCP

### Forzar obtención de IP mediante DHCP:

```bash
dhclient <interfaz>
```

Si no se obtiene IP, puede haber un fallo en el cliente DHCP o en el servidor.

---

## 4. Verificar resolución de nombres (DNS)

### Revisar contenido de `/etc/resolv.conf`:

```bash
cat /etc/resolv.conf
```

Debe contener líneas como:

```
nameserver 8.8.8.8
nameserver 1.1.1.1
```

### Probar resolución de nombres:

```bash
ping google.com
nslookup google.com
```

---

## 5. Comprobar conectividad IP

### Probar conectividad con gateway:

```bash
ping <puerta_de_enlace>
```

### Comprobar conexión a Internet por IP:

```bash
ping 8.8.8.8
```

### Analizar la ruta hasta un destino:

```bash
traceroute 8.8.8.8
```

Esto permite saber en qué punto se corta la conexión.

---

## 6. Verificar servicios locales y puertos

### Ver puertos en escucha:

```bash
netstat -tuln
ss -tuln
```

### Ver conexiones activas:

```bash
netstat -antp
```

---

## 7. Consultar la tabla ARP (resolución IP ↔ MAC)

### Ver la tabla ARP:

```bash
arp -a
ip neighbour
```

### Limpiar la tabla si es necesario:

```bash
ip neighbour flush all
```

---

## 8. Probar acceso a servicios externos

### Verificar si se puede acceder a servicios por red:

```bash
curl https://example.com
apt-get update
```

Si estos comandos fallan, puede deberse a problemas de DNS, rutas o cortafuegos.

---

## 9. Consultar logs del sistema

### Mensajes del kernel sobre red:

```bash
dmesg | grep -i eth
```

### Logs del servicio de red (si se usa systemd):

```bash
journalctl -u networking
```

---

## 10. Resumen del procedimiento

1. Ver interfaces de red y estado.
2. Comprobar dirección IP, máscara y puerta de enlace.
3. Revisar DHCP si la IP debe asignarse automáticamente.
4. Validar resolución de nombres (DNS).
5. Comprobar conectividad con gateway e Internet.
6. Consultar rutas y tabla ARP.
7. Verificar servicios y puertos abiertos.
8. Probar acceso a servicios externos.
9. Analizar logs del sistema para mensajes de error.

---
