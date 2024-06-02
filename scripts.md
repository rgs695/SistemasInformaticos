SCRIPTS Y EXAMENES PASADOS

# Ordinaria 2023

## Ejercicio 1
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

## Ejercicio 2
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

## Ejercicio 3
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

## Ejercicio 4
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

## Ejercicio 5
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

## Ejercicio 1
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


## Ejercicio 3
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
