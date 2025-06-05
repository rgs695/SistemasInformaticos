# PRACTICA 8 Sistemas Informaticos

## Practica 8 Parte 1


**<span style="color:red">Ejercicio 1</span>**
Haciendo uso de los comandos de monitorización apropiados, obtén la siguiente información de tu sistema:

a. Número total de procesos en ejecución en el sistema y cuántos de ellos pertenecen al usuario root. Utiliza tuberías para obtener la información requerida en una sola línea de comandos.

`ps -eo user= | wc -l && ps -eo user= | grep -c "^root$"` 


* `ps -eo user=`: lista todos los procesos mostrando solo el usuario propietario.
* `wc -l`: cuenta cuántas líneas hay (es decir, cuántos procesos en total).
* `grep -c "^root$"`: cuenta cuántos procesos son del usuario `root`.

También puedes usarlo así en una sola línea con un mensaje más claro:

```bash
echo "Total: $(ps -eo user= | wc -l), root: $(ps -eo user= | grep -c '^root$')"
```


b. Fracción de la partición del disco ocupada por el sistema de archivos raíz.

```bash
df -h / | awk 'NR==2 {print $5}'
```

* `df -h /`: muestra el uso de disco del sistema de archivos raíz `/` en formato legible.
* `awk 'NR==2 {print $5}'`: extrae solo el porcentaje de uso.

c. Tamaño del área de intercambio (swap) y cantidad de memoria libre y ocupada.

```bash
free -h
```

Esto muestra:

* Total de memoria (RAM)
* Usada y libre
* Total de swap
* Swap usada y libre

Si quieres solo los datos numéricos, puedes hacer algo como:

```bash
free -h | awk '/Swap:/ {print "Swap total:", $2, "Usada:", $3, "Libre:", $4}'
```

Y para la RAM:

```bash
free -h | awk '/Mem:/ {print "RAM total:", $2, "Usada:", $3, "Libre:", $4}'
```

---

**<span style="color:red">Ejercicio 2</span>**
Lee el manual del comando systemd-cat. A través de la línea de comandos, envía el mensaje “hello syslog, my name is…” con un nivel de severidad de advertencia (warning) y utilizando la facilidad local0. Verifica que lo hiciste correctamente.

1. **Lee el manual de `systemd-cat`**:

```bash
man systemd-cat
```

2. **Envía el mensaje con severidad *warning* y facilidad *local0***:

```bash
echo "hello syslog, my name is..." | systemd-cat --priority=warn --identifier=local0
```

* `--priority=warn`: nivel de severidad "warning".
* `--identifier=local0`: etiqueta el mensaje como proveniente de `local0`.

**Nota importante:** `systemd-cat` no permite especificar directamente la *facility* (como `local0`), ya que esto lo gestiona `rsyslog` o el demonio de logging, no el propio `systemd-cat`. Sin embargo, puedes redirigir a `local0` usando `logger`, que sí lo permite.

**Alternativa más precisa con `logger` (recomendado si necesitas usar `local0` realmente):**

```bash
logger -p local0.warning "hello syslog, my name is..."
```

* `-p local0.warning`: especifica la facilidad `local0` y el nivel de severidad `warning`.


**Verificación**

Para comprobar que se ha registrado el mensaje, puedes mirar el log con:

```bash
journalctl -t local0
```

O, si usaste `logger`, también puedes buscar en los archivos tradicionales de syslog (si están habilitados):

```bash
grep "hello syslog" /var/log/syslog
```

**<span style="color:red">Ejercicio 3</span>**
Modifica el nivel de severidad de los mensajes que se reenvían a la consola de cada usuario a INFO. Verifica que tus cambios funcionan correctamente.


**1. Editar configuración de rsyslog**

Crea o edita un archivo en `/etc/rsyslog.d/`, por ejemplo:

```bash
sudo nano /etc/rsyslog.d/50-console.conf
```

Añade la línea:

```bash
*.info    /dev/console
```

Esto hace que todos los mensajes con severidad **INFO o superior** se envíen a la consola del sistema.

**2. Reiniciar rsyslog**

```bash
sudo systemctl restart rsyslog
```

**3. Comprobar que funciona**

Envía un mensaje de prueba:

```bash
logger -p user.info "Mensaje de prueba para consola"
```

**NOTA:** Estos mensajes solo aparecen en la terminal de la maquina, es decir, en VirtualBox, no en la PowerShell conectada por ssh.

**<span style="color:red">Ejercicio 4</span>**
Lista todos los registros del journal correspondientes a los servicios cron y networking generados durante la última semana.

journalctl sirve para ver los registros del sistema (logs) que guarda el journal de systemd. Muestra mensajes generados por el sistema operativo, servicios, demonios, aplicaciones, etc.

1. Lista todos los registros del journal correspondientes a los servicios **cron** y **networking** generados durante la **última semana**.

```bash
journalctl -u cron -u networking --since "1 week ago"
```

* `-u cron`: filtra los logs del servicio `cron`.
* `-u networking`: también incluye los logs del servicio de red (si existe como tal en tu sistema).
* `--since "1 week ago"`: restringe los resultados a los generados en la última semana.

**Nota:** en algunos sistemas, `networking` puede no ser una unidad activa. En ese caso, podrías intentar con `NetworkManager` o `systemd-networkd` si no obtienes resultados:

```bash
journalctl -u NetworkManager --since "1 week ago"
```

**<span style="color:red">Ejercicio 5</span>**
Listar todos los registros del **kernel** generados en la última hora.

```bash
journalctl -k --since "1 hour ago"
```

* `-k`: filtra los registros solo del **kernel** (es decir, solo los mensajes del núcleo del sistema operativo).
* `--since "1 hour ago"`: limita los resultados a los registros generados **en la última hora**.


**<span style="color:red">Ejercicio 6</span>**
Modifica los atributos de registro del demonio sshd (/etc/ssh/sshd_config), estableciendo el nivel de severidad a debug. Reinicia el demonio (a través de su servicio) y verifica la cantidad de mensajes generados por el demonio durante el último minuto.


1. **Abre el archivo de configuración** de `sshd`:

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```

2. **Busca la línea que configura el nivel de logging**, si no existe, añádela. Debes establecer el nivel de severidad a `DEBUG`:

   ```bash
   LogLevel DEBUG
   ```

3. **Guarda y cierra el archivo** 

4. Reiniciar el demonio SSH**

Para que los cambios surtan efecto, necesitas reiniciar el servicio `sshd`:

```bash
sudo systemctl restart sshd
```

**5. Verificar la cantidad de mensajes generados durante el último minuto**

Usa `journalctl` para verificar los mensajes generados por `sshd` durante el último minuto:

```bash
journalctl -u sshd --since "1 minute ago"
```

* `-u sshd`: muestra los logs solo para el servicio `sshd`.
* `--since "1 minute ago"`: muestra los logs generados en los últimos 60 segundos.

Este comando te mostrará todos los registros de `sshd` generados durante el último minuto, con el nivel de severidad `DEBUG`.

**6**. Comprobar los mensajes**

Dado que has configurado el logging a `DEBUG`, deberías ver una gran cantidad de información detallada sobre la actividad del servicio SSH, como las conexiones, autenticaciones y más. De nuevo todos estos mensajes salen solo en la terminal tty de la maquina virtual (en vez de en PowerShell).




**<span style="color:red">Ejercicio 7</span>**
Crea un script en bash que reciba 2 parámetros:

**tiempo total de monitorización (X)** y **intervalo de tiempo (Y)** en segundos.

Durante el tiempo X, el script comprobará los **3 recursos más importantes del sistema** (**CPU, MEMORIA y DISCO**) y mostrará un pequeño resumen de ellos en la consola. Este resumen se actualizará cada Y segundos.

**La información que debe mostrarse es:**

* **CPU**: porcentaje de carga media del sistema durante el último minuto.
* **DISCO**: porcentaje de uso del sistema de archivos raíz (`/`).
* **MEMORIA**: porcentaje de RAM usada.

El script debe generar una tabla con tres columnas mostrando los porcentajes de uso de estos recursos, con una línea por cada intervalo.

**Ejemplo de ejecución:**

```bash
./stats.sh 120 5
```

### **Salida esperada:**

```
Memory  Disk  CPU
9.34%   7%    0.00%
9.34%   7%    0.00%
9.34%   7%    0.00%
9.34%   7%    0.00%
```

**SCRPT**

```bash

#!/bin/bash

# Comprobación de argumentos
if [ $# -ne 2 ]; then
  echo "Uso: $0 <tiempo_total_en_segundos> <intervalo_en_segundos>"
  exit 1
fi

TIEMPO_TOTAL=$1
INTERVALO=$2
VECES=$(( TIEMPO_TOTAL / INTERVALO ))

# Encabezado de la tabla
echo "Memory  Disk  CPU"

# Bucle principal
for ((i = 0; i < VECES; i++)); do
  # Porcentaje de uso de memoria RAM
  MEM_USAGE=$(free | awk '/Mem:/ {printf "%.2f%%", ($3/$2)*100}')

  # Porcentaje de uso del sistema de archivos raíz
  DISK_USAGE=$(df / | awk 'NR==2 {print $5}')

  # Carga media del sistema (último minuto)
  CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
  CPU_LOAD=$(printf "%.2f%%" "$CPU_LOAD")

  # Imprimir una línea de la tabla
  echo "$MEM_USAGE  $DISK_USAGE  $CPU_LOAD"

  sleep "$INTERVALO"
done

```

### 📄 **Script completo para referencia**

```bash
#!/bin/bash

# Comprobación de argumentos
if [ $# -ne 2 ]; then
  echo "Uso: $0 <tiempo_total_en_segundos> <intervalo_en_segundos>"
  exit 1
fi

TIEMPO_TOTAL=$1
INTERVALO=$2
VECES=$(( TIEMPO_TOTAL / INTERVALO ))

# Encabezado de la tabla
echo "Memory  Disk  CPU"

# Bucle principal
for ((i = 0; i < VECES; i++)); do
  # Porcentaje de uso de memoria RAM
  MEM_USAGE=$(free | awk '/Mem:/ {printf "%.2f%%", ($3/$2)*100}')

  # Porcentaje de uso del sistema de archivos raíz
  DISK_USAGE=$(df / | awk 'NR==2 {print $5}')

  # Carga media del sistema (último minuto)
  CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
  CPU_LOAD=$(printf "%.2f%%" "$CPU_LOAD")

  # Imprimir una línea de la tabla
  echo "$MEM_USAGE  $DISK_USAGE  $CPU_LOAD"

  sleep "$INTERVALO"
done
```

**Explicación detallada línea por línea**

```bash
#!/bin/bash
```

* **Shebang**: indica que el script debe ejecutarse con el intérprete `bash`.

```bash
if [ $# -ne 2 ]; then
```

* Comprueba si se han pasado exactamente **2 argumentos** al script (`$#` es el número de argumentos).
* Si no, entra en el bloque `then`.

```bash
  echo "Uso: $0 <tiempo_total_en_segundos> <intervalo_en_segundos>"
```

* Muestra un mensaje de uso correcto del script.
* `$0` es el nombre del script (por ejemplo, `./stats.sh`).

```bash
  exit 1
```

* Sale del script con código de error `1`.

```bash
TIEMPO_TOTAL=$1
INTERVALO=$2
```

* Guarda los argumentos en variables:

  * `$1`: primer parámetro → tiempo total de monitorización.
  * `$2`: segundo parámetro → intervalo entre mediciones.

```bash
VECES=$(( TIEMPO_TOTAL / INTERVALO ))
```

* Calcula cuántas veces debe repetirse el bucle: total dividido entre el intervalo.


```bash
echo "Memory  Disk  CPU"
```

* Imprime el **encabezado de la tabla**.


```bash
for ((i = 0; i < VECES; i++)); do
```

* Inicia un bucle `for` que se repite `VECES` veces (una por cada intervalo).

```bash
  MEM_USAGE=$(free | awk '/Mem:/ {printf "%.2f%%", ($3/$2)*100}')
```

* Usa el comando `free` para obtener datos de RAM.
* Con `awk`, calcula `(usado / total) * 100` y lo imprime con 2 decimales y símbolo `%`.

  * `$3`: memoria usada.
  * `$2`: memoria total.


```bash
  DISK_USAGE=$(df / | awk 'NR==2 {print $5}')
```

* Usa `df /` para ver el uso del disco raíz (`/`).
* La segunda línea (`NR==2`) contiene el porcentaje de uso de disco → se extrae la columna `%`.


```bash
  CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
```

* Usa `uptime` para obtener la **carga media** del sistema.
* Corta la parte después de "load average:", extrae el primer valor (último minuto), y lo limpia con `xargs`.

```bash
  CPU_LOAD=$(printf "%.2f%%" "$CPU_LOAD")
```

* Convierte la carga media (que es un número como `0.00`) en un porcentaje con 2 decimales.


```bash
  echo "$MEM_USAGE  $DISK_USAGE  $CPU_LOAD"
```

* Muestra una línea con los tres valores (memoria, disco, CPU) separados por espacios.


```bash
  sleep "$INTERVALO"
```

* Espera `INTERVALO` segundos antes de la siguiente iteración.


```bash
done
```

* Fin del bucle.

---

## Practica 8 Parte 2

**<span style="color:red">Ejercicio 8</span>**
Primero, aísla la CPU 0, de modo que el kernel no pueda planificar (programar) ningún proceso en esa CPU. Verifica si el proceso funciona correctamente.

- Paso 1: Comprobar el número de CPUs disponibles

Primero asegurémonos de cuántos cores tiene el sistema y su numeración.

```bash
lscpu | grep "^CPU(s):"
nproc
```

Deberías ver que tienes 2 CPUs (CPU 0 y CPU 1).

- Paso 2: Aislar la CPU 0 al arrancar el sistema

Esto se hace modificando los parámetros del kernel en GRUB.

1. Edita el archivo de configuración de GRUB:

```bash
sudo nano /etc/default/grub
```

2. Busca la línea que empieza por:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

Y modifícala para añadir `isolcpus=0`, quedando por ejemplo así:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash isolcpus=0"
```

`isolcpus=0` le dice al kernel que **no asigne tareas automáticas** en la CPU 0.

3. Guarda el archivo (`Ctrl + O`, luego `Enter`, y `Ctrl + X` para salir).

4. Actualiza GRUB: `sudo update-grub`

5. Reinicia la máquina virtual (`sudo reboot`)

- Paso 3: Verificar si la CPU 0 está aislada

Después de reiniciar, puedes verificar si la CPU 0 está aislada con este comando: `cat /proc/cmdline`

Debes ver algo como: BOOT_IMAGE=... quiet splash isolcpus=0`

Y para ver en qué CPUs se ejecutan los procesos `ps -eo pid,psr,comm | grep -v "\["`


Esto mostrará en qué CPU se están ejecutando los procesos (`psr` = processor). Si todo está bien, deberías ver que la mayoría de procesos **no** se están ejecutando en la CPU 0.

También puedes monitorizarlo en tiempo real con `htop`.

- Paso 4: Verifica que el sistema sigue funcionando correctamente

Puedes ejecutar comandos normales, iniciar procesos simples, o usar `stress` (si se puede instalar) para ver cómo se comporta el sistema solo con CPU 1 activa. `stress --cpu 2 --timeout 15`

**<span style="color:red">Ejercicio 9</span>**
Usando tmux, implementa una configuración de paneles como la que se describe en la figura a continuación. El panel superior ejecuta el comando htop, el panel inferior izquierdo corresponde al usuario alumno (ejecuta “su - alumno” para cambiar de root a alumno), y el panel inferior derecho es la shell de root.

### Configuración correcta de los paneles en tmux

1. **Iniciar tmux**:
   Abre una terminal y comienza una nueva sesión de tmux con el siguiente comando:

   ```bash
   tmux
   ```

2. **Dividir la pantalla en dos paneles horizontales (uno arriba y otro abajo)**:
   Para dividir la pantalla en dos paneles horizontales, utiliza el siguiente atajo:

   ```bash
   Ctrl + b, "  
   ```

   Esto dividirá la pantalla en dos paneles, uno encima del otro.

3. **Dividir el panel inferior en dos paneles verticales**:
   Ahora, selecciona el panel inferior (usando `Ctrl + b` y la flecha hacia abajo) y divídelos en dos paneles verticales con el siguiente atajo:

   ```bash
   Ctrl + b, %  
   ```

   Esto dividirá el panel inferior en dos, creando un panel izquierdo y un panel derecho.

4. **Asignar los comandos a cada panel**:
   Ahora que tienes tres paneles, asigna los comandos correspondientes a cada uno:

   * **Panel superior (htop)**:
     Selecciona el panel superior y ejecuta el comando `htop`:

     ```bash
     htop
     ```

   * **Panel inferior izquierdo (cambiar a alumno)**:
     En el panel inferior izquierdo, cambia al usuario `alumno` con el comando:

     ```bash
     su - alumno
     ```

   * **Panel inferior derecho (root shell)**:
     En el panel inferior derecho, asegúrate de estar en el shell de root o usa:

     ```bash
     sudo -i
     ```

5. **Ajustar el tamaño de los paneles (opcional)**:
   Si deseas ajustar el tamaño de los paneles, puedes hacerlo con los siguientes atajos:

   * **Para ajustar el tamaño de un panel**: Mantén presionado `Ctrl + b` y luego presiona las flechas de dirección (`↑`, `↓`, `←`, `→`) para ajustar el tamaño de los paneles.

6. **Guardar la configuración (opcional)**:
   Si prefieres guardar la configuración de paneles para futuras sesiones, puedes hacerlo creando un archivo de configuración de tmux o un script que ejecute los comandos mencionados.

### Resumen de los atajos:

* **Dividir pantalla horizontalmente**: `Ctrl + b, "`
* **Dividir pantalla verticalmente**: `Ctrl + b, %`
* **Mover entre paneles**: `Ctrl + b` seguido de la flecha de dirección correspondiente (`←`, `→`, `↑`, `↓`).


**<span style="color:red">Ejercicio 10</span>**
En el terminal de alumno, ejecuta dos instancias del comando stress en el mismo núcleo (CPU 0), con las opciones adecuadas para estresar solo la CPU. Luego, en el panel de root, realiza las siguientes tareas:

a. Detén el proceso de "stress" con el PID más bajo y revisa su estado. Reanúdalo.
b. Disminuye progresivamente la prioridad del otro proceso de "stress" (0-5-10-15-19) y observa cómo evoluciona la utilización de la CPU para ambos procesos de "stress".
c. Repite las acciones anteriores trabajando directamente con las opciones del menú de htop en el panel superior.


### **Situación inicial:**

Estás en el terminal del usuario `alumno`, y desde ahí lanzarás **dos procesos** de `stress` que consumirán CPU en el **núcleo 0**.

```bash
taskset -c 0 stress --cpu 1 &
taskset -c 0 stress --cpu 1 &
```

Esto lanza dos procesos en segundo plano que estresan el mismo núcleo.


### Ahora desde la **ventana root** (la inferior derecha):

#### a. **Detener el proceso `stress` con menor PID y comprobar su estado. Luego reanudarlo.**

1. **Localiza los PIDs** de los dos procesos de `stress`:

   ```bash
   ps -eLo pid,comm,psr,user | grep stress
   ```

   * `psr` muestra el número de núcleo donde se está ejecutando.
   * El PID más bajo es el más antiguo, o sea, el primero que lanzaste.

NOTA:  Arriba en htop, podemos ver el PID de ambos stress. El menor en este caso es el 735.

1. **Detén el proceso con menor PID** usando `kill -STOP <PID>`:

   ```bash
   kill -STOP 735
   ```

2. **Verifica su estado**:

   ```bash
   ps -p 735 -o pid,state,comm
   ```

   * El estado debería ser `T` (stopped / detenido).

3. **Reanuda el proceso**:

   ```bash
   kill -CONT 735
   ```

4. (Opcional) Verifica que está activo de nuevo:

   ```bash
   ps -p 735 -o pid,state,comm
   ```


#### b. **Reducir progresivamente la prioridad**

Reducir progresivamente la prioridad de **uno** de los dos procesos `stress`, usando valores: `0`, `5`, `10`, `15`, `19`.

Así verás en `htop` cómo cambia el uso de CPU entre ambos procesos, ya que el otro mantiene `nice = 0` todo el rato.

**Pasos desde el terminal root (pane inferior derecho):**

1. **Comprueba los dos procesos `stress` y elige uno para modificar su `nice`:**

   ```bash
   ps -eLo pid,ni,comm,psr,user | grep stress
   ```

   * Anota los PIDs.
   * Decide cuál modificarás.

2. **Cambia el valor `nice` progresivamente**:

   * A `5`:

     ```bash
     renice 5 -p <PID>
     ```

   * Luego a `10`:

     ```bash
     renice 10 -p <PID>
     ```

   * A `15`:

     ```bash
     renice 15 -p <PID>
     ```

   * Finalmente a `19`:

     ```bash
     renice 19 -p <PID>
     ```

   Puedes ir observando los efectos en tiempo real en el **pane superior con `htop`**.

3. **Verifica el cambio de prioridad** (opcional):

   ```bash
   ps -o pid,ni,comm -p <PID>
   ```

Lo que se observa cada vez que aplicamos uno de estos comandos de cambio de prioridad es como el proceso al que se lo aplicamos reduce su porcentaje de CPU mientras el otro lo aumenta de modo que juntos lleguen al 100%.


#### c. **Ajustar prioridades con tmux**

1. **Asegúrate de estar en el panel superior** (usa `Ctrl+b`, luego ↑ si hace falta).

2. **Busca los procesos `stress`** en la lista. Puedes usar `F3` para buscarlos por nombre:

   * Pulsa `F3`
   * Escribe `stress`
   * Usa flechas ↑↓ para seleccionarlos

3. **Selecciona uno de los procesos `stress`** (elige el que *no* tocaste antes si quieres comparar) y modifica su `nice`:

   * Pulsa `F7` para **reducir** el valor de nice (más prioridad)
   * Pulsa `F8` para **aumentar** el valor de nice (menos prioridad)

   Ve pulsando `F8` para subir el valor a 5, luego 10, 15 y 19 (como antes), observando cómo cambia el uso de CPU.

4. **Observa la diferencia en uso de CPU** entre ambos procesos a medida que el valor de nice aumenta.

---

### Tips:

* En `htop`, la columna **NI** muestra el valor `nice`, y la columna **%CPU** el uso de CPU.
* Puedes ordenar por CPU (tecla `F6`, luego elige `%CPU`) para ver mejor los cambios.
* Para ejecutar F3, F7, F8 hay que hacer `Fn + Fx` en el teclado.

---
**<span style="color:red">Ejercicio 11</span>**
Recuerda el servicio creado en la Práctica 4 con el script check-disk-space.sh.
¡Vamos a usarlo de nuevo! Elimina el bucle while y crea una unidad de temporizador (timer) asociada al servicio para reemplazar el comportamiento de "bucle".

### Objetivo

Reemplazar el bucle `while` del script con un **timer de systemd**, de modo que el script se ejecute cada 5 minutos automáticamente mediante el sistema de servicios, no dentro de sí mismo.

---

### 1. **Modificar el script `check-disk-space.sh`**

Elimina el `while true` y el `sleep`, ya que el temporizador se encargará de ejecutar el script periódicamente:

```bash
#!/bin/bash
# check-disk-space.sh
# Script to monitor disk usage on the system partition

# Set the threshold to 80%
THRESHOLD=80

# Get disk usage
DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

# Check if disk usage is above threshold
if [ $DISK_USAGE -gt $THRESHOLD ]; then
    echo "Disk usage is over $THRESHOLD%! Current usage: $DISK_USAGE%" | mail -s "Disk Usage Warning" your-email@example.com
fi
```

Guárdalo como `/usr/local/bin/check-disk-space.sh` y asegúrate de que tenga permisos de ejecución:

```bash
chmod +x /usr/local/bin/check-disk-space.sh
```

---

### 2. **Modificar el archivo del servicio `check-disk.service`**

También hay que quitar el reinicio automático, ya que ahora **solo se ejecutará cuando lo invoque el temporizador**:

```ini
[Unit]
Description=Check Disk Space Service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check-disk-space.sh
```

Guárdalo en `/etc/systemd/system/check-disk.service`.

---

### 3. **Crear el archivo del temporizador `check-disk.timer`**

Nuevo archivo: `/etc/systemd/system/check-disk.timer`

```ini
[Unit]
Description=Run check-disk.service every 5 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
Unit=check-disk.service

[Install]
WantedBy=timers.target
```

---

### 4. **Habilitar y arrancar**

Recarga los servicios de `systemd`, habilita y arranca el timer:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

sudo systemctl enable --now check-disk.timer
```

Comprueba que está activo:

```bash
systemctl list-timers --all | grep check-disk
```

Y puedes probarlo directamente con:

```bash
sudo systemctl start check-disk.service
```

---

**<span style="color:red">Ejercicio 12</span>**
Escribe un archivo `crontab` (y comprueba que funciona correctamente) para el usuario “root” que realice la siguiente tarea:

Limpiar el directorio `/tmp` **los últimos 15 días de cada mes** a las **17:00 horas**.

*La hora 17:00 es solo una guía. Copia el contenido de `/home` a `/tmp` y, durante la sesión de laboratorio, después de las 17:00 (o la hora que se ajuste a tu horario), comprueba si el trabajo se ha realizado correctamente.*

Claro, aquí tienes todos los comandos para realizar todo el proceso, incluyendo la edición del crontab y la verificación del funcionamiento.

### 1. Editar el crontab del usuario `root`:

Abre el crontab de `root` con el siguiente comando:

```bash
sudo crontab -e
```

Esto abrirá el archivo crontab en el editor por defecto. Luego, añade la siguiente línea al final del archivo para que se ejecute el script a las **13:40** el **día 14 de cada mes**:

```bash
40 13 14 * * rm -rf /tmp/* && cp -r /home/* /tmp/
```

Guarda y cierra el archivo.

### 2. Verificar que la tarea está programada:

Para asegurarte de que la tarea se ha añadido correctamente al crontab, puedes listar las tareas programadas con:

```bash
sudo crontab -l
```

Deberías ver la línea que has añadido:

```bash
40 13 14 * * rm -rf /tmp/* && cp -r /home/* /tmp/
```

### 3. Comprobar que la tarea se ejecuta correctamente:

En este caso, si es **el día 14 del mes**, la tarea debería ejecutarse automáticamente a las **13:40**.

Para comprobar que la tarea se ejecutó correctamente, puedes revisar los archivos en `/tmp` y `/home` usando los siguientes comandos después de la hora programada:

```bash
ls /tmp
ls /home
```

Al revisar `/tmp`, deberías ver el contenido de `/home` copiado allí, y `/tmp` debería haber sido limpiado.

### Resumen de los comandos:

1. Editar el crontab del usuario `root`:

   ```bash
   sudo crontab -e
   ```

2. Añadir la siguiente línea en el crontab:

   ```bash
   40 13 14 * * rm -rf /tmp/* && cp -r /home/* /tmp/
   ```

3. Verificar que la tarea está programada:

   ```bash
   sudo crontab -l
   ```

4. Comprobar el contenido de los directorios:

   ```bash
   ls /tmp
   ls /home
   ```

Con estos pasos, podrás programar y verificar que el proceso se ejecute correctamente.

---

**<span style="color:red">Ejercicio 13</span>**
Apaga tu máquina virtual. Descarga el disco proporcionado para esta sesión. Es un disco de 2 GB con dos particiones (1 GB cada una), una etiquetada como swap y la otra como ext4 (solo con la definición de tipo, las particiones no están formateadas). Agrégalo a tu máquina virtual y vuelve a encenderla. Realiza las siguientes tareas:

a. Extiende el swap disponible utilizando la partición swap en ese disco. Haz que esta extensión sea permanente.

b. Ahora, en el directorio /swapfiles, crea un archivo swap de 1 GB (llámalo swfile1) y realiza las tareas necesarias para comenzar a utilizarlo.

c. Copia el contenido de /home a la partición ext4 del nuevo disco y configura el sistema para montarlo en el directorio /home de forma permanente.

d. Habilita cuotas para el sistema de archivos montado en /home, limitando la cuota del usuario de prueba a 100 MB (límite duro). Verifica si el límite funciona correctamente.


* Has añadido un nuevo disco de 2 GB (`/dev/sda`) con:

  * `/dev/sda1`: partición de 1 GB para usar como **swap**.
  * `/dev/sda2`: partición de 1 GB para montar como **/home**, con sistema de archivos **ext4** (aunque aún no formateado).
* El disco principal del sistema es `/dev/sdb`, con:

  * `/`: montado en `/dev/sdb2`
  * `/boot/efi`: `/dev/sdb1`
  * Área swap ya en uso: `/dev/sdb3`

---

### Vamos a resolver el ejercicio paso a paso correctamente desde aquí.

#### **a. Ampliar el swap con `/dev/sda1` y hacerlo permanente**

1. **Formatear la partición `/dev/sda1` como swap (si no está ya)**:

   ```bash
   mkswap /dev/sda1
   ```

2. **Activar el swap temporalmente**:

   ```bash
   swapon /dev/sda1
   ```

3. **Verificar que está en uso**:

   ```bash
   swapon --show
   free -h
   ```

4. **Hacerlo permanente (añadir a `/etc/fstab`)**:
   Abre el archivo con un editor como `nano`:

   ```bash
   nano /etc/fstab
   ```

   Añade esta línea al final:

   ```
   /dev/sda1 none swap sw 0 0
   ```

---

### **b. Crear un archivo de swap de 1GB llamado `swfile1` en `/swapfiles` y activarlo**

#### 1. **Crear el directorio `/swapfiles` si no existe**:

```bash
mkdir -p /swapfiles
```

#### 2. **Crear el archivo de 1GB (usando `dd`)**:

```bash
dd if=/dev/zero of=/swapfiles/swfile1 bs=1M count=1024
```

#### 3. **Asignar los permisos correctos** (muy importante para swap files):

```bash
chmod 600 /swapfiles/swfile1
```

#### 4. **Formatear el archivo como swap**:

```bash
mkswap /swapfiles/swfile1
```

#### 5. **Activar el swap file temporalmente**:

```bash
swapon /swapfiles/swfile1
```

#### 6. **Verificar que está en uso junto al resto**:

```bash
swapon --show
```

Deberías ver tanto `/dev/sdb3`, `/dev/sda1`, como `/swapfiles/swfile1` activos como swap.

#### 7. **Hacerlo permanente (añadir a `/etc/fstab`)**:

```bash
nano /etc/fstab
```

Añade esta línea:

```
/swapfiles/swfile1 none swap sw 0 0
```

---

### **c. Copiar el contenido de `/home` a la partición ext4 (`/dev/sda2`) y montarla como `/home` de forma permanente**


#### **1. Formatear la partición `/dev/sda2` como ext4**

Asegúrate de que **no tiene nada importante**, ya que esto borra todo su contenido:

```bash
mkfs.ext4 /dev/sda2
```

#### **2. Crear un punto de montaje temporal**

Esto lo usamos para copiar el contenido actual de `/home`:

```bash
mkdir /mnt/newhome
```

#### **3. Montar `/dev/sda2` en ese punto temporal**

```bash
mount /dev/sda2 /mnt/newhome
```

#### **4. Copiar el contenido de `/home` actual al nuevo `/mnt/newhome`**

```bash
cp -a /home/. /mnt/newhome/
```

#### **5. Hacer copia de seguridad del antiguo `/home` por si acaso**

```bash
mv /home /home.bak
```

#### **6. Crear un nuevo `/home` vacío y montar la nueva partición**

```bash
mkdir /home
mount /dev/sda2 /home
```


#### **7. Verifica que todo esté correcto**

```bash
ls /home
```

Deberías ver todo el contenido anterior de tu home ahí.

#### **8. Añadir entrada a `/etc/fstab` para montar `/dev/sda2` en `/home` automáticamente al arrancar**

Edita el archivo:

```bash
nano /etc/fstab
```

Y añade esta línea:

```
/dev/sda2   /home   ext4   defaults   0 2
```


#### **9. Prueba que funciona**

Reinicia el sistema:

```bash
reboot
```

Después, ejecuta:

```bash
mount | grep /home
```

Y asegúrate de que `/dev/sda2` aparece como montado en `/home`.

---


Perfecto, pasamos al **apartado d**: habilitar **cuotas** en `/home` y limitar el uso de disco del usuario de prueba a **100MB (límite duro)**.

---

## 🟦 d. Habilitar cuotas en `/home` y limitar el uso del usuario

---

### ✅ 1. Instalar herramientas de cuotas (si no están instaladas)

```bash
apt update
apt install quota
```

---

### ✅ 2. Activar cuotas en `/etc/fstab`

Edita `/etc/fstab`:

```bash
nano /etc/fstab
```

Busca la línea que montaba `/dev/sda2` en `/home`, y **añade las opciones `usrquota` y/o `grpquota`**:

```
/dev/sda2   /home   ext4   defaults,usrquota   0 2
```

Guarda y cierra.

---

### ✅ 3. Remontar `/home` para aplicar los cambios

```bash
mount -o remount /home
```

---

### ✅ 4. Crear los archivos necesarios para las cuotas

```bash
quotacheck -cum /home
```

Esto creará los archivos `aquota.user` y `aquota.group` en `/home`.

---

### ✅ 5. Activar cuotas

```bash
quotaon /home
```

---

### ✅ 6. Crear un usuario de prueba (si no existe)

```bash
useradd prueba
```

Asegúrate de que su home está en `/home/prueba` (puedes verlo con `getent passwd prueba`).

---

### ✅ 7. Asignar límite de 100MB a ese usuario

```bash
edquota -u prueba
```

Se abrirá un editor de texto con algo parecido a esto:

```
Disk quotas for user prueba (uid 1001):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/sda2                        0          0      102400          0        0        0
```

> ⚠️ Los valores están en **KB**, así que 100MB = **102400 KB**.

Puedes poner también un límite **blando** (soft) si lo deseas.

Guarda y cierra.

---

### ✅ 8. Verifica los límites aplicados

```bash
quota -u prueba
```

---

### ✅ 9. Probar el límite

Cambia al usuario `prueba` y crea archivos grandes hasta sobrepasar los 100MB:

```bash
su - prueba
fallocate -l 110M archivo_grande
```

Debería bloquearse con un error de espacio.

---

NOTA: DEBES CREAR EL /home del usuario

### ✅ 1. Crear el directorio `/home/prueba` y asignarle permisos

```bash
mkdir /home/prueba
chown prueba:prueba /home/prueba
chmod 700 /home/prueba
```

---

### ✅ 2. Verifica que el usuario ahora puede entrar

```bash
su - prueba
```

Ya deberías tener acceso sin errores. Luego, prueba crear archivos:

```bash
fallocate -l 110M archivo_grande
```

---

Si falla por cuota, eso es buena señal (límite bien aplicado). Si se crea sin problema, revisamos si `edquota` está apuntando al sistema de archivos correcto (`/dev/sda2`) y si `quotaon` está activado.


# Practica 9 Sistemas Informaticos


**<span style="color:red">Ejercicio 1</span>**
Restaura la instantánea inicial. Inicia tu sistema con la versión del kernel **5.10.0-20** (a través de **GRUB > Opciones avanzadas**).

### Pasos para arrancar con el kernel 5.10.0-20 desde GRUB

1. **Reinicia la máquina virtual o el sistema.**

2. En cuanto aparezca el menú de GRUB, selecciona:

   ```
   Opciones avanzadas para Debian/GNU Linux (o tu distro)
   ```

3. Dentro del submenú, selecciona la entrada que diga algo como:

   ```
   Debian GNU/Linux, con Linux 5.10.0-20-amd64
   ```

4. Pulsa **Enter** para arrancar con ese kernel.

5. Una vez iniciado el sistema, puedes comprobar que estás usando el kernel correcto con el siguiente comando:

   ```bash
   uname -r
   ```

   Deberías ver:

   ```
   5.10.0-20-amd64
   ```

---

**<span style="color:red">Ejercicio 2</span>**
Descarga el código fuente del kernel versión **5.13.01** desde el repositorio oficial.
Crea el archivo de configuración **desde cero** (usando las opciones por defecto) y **compila el kernel**.
*(Este proceso puede tardar varios minutos; puedes continuar con el resto de la práctica mientras se compila).*
Completa la instalación y comprueba que eres capaz de **arrancar el sistema con el kernel compilado**.

### Paso 1: Descargar el código fuente del kernel 5.13.1

1. Abre una terminal.

2. Ve a `/usr/src` (directorio estándar para fuentes del kernel):

   ```bash
   cd /usr/src
   ```

3. Descarga el kernel 5.13.1 desde el repositorio oficial:

   ```bash
   sudo wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.13.1.tar.xz
   ```

4. Descomprime el archivo:

   ```bash
   sudo tar -xf linux-5.13.1.tar.xz
   cd linux-5.13.1
   ```

###  Paso 2: Crear archivo de configuración desde cero

Vamos a usar la configuración por defecto para la arquitectura actual:

```bash
make defconfig
```

**NOTA** si te da errores instala estas cosas:

```
sudo apt update
sudo apt install bc
sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev libudev-dev libpci-dev libiberty-dev
```

Esto generará el archivo `.config` con ajustes estándar.
🔧 (Opcional: puedes usar `make menuconfig` más adelante si quieres personalizarlo visualmente).

###  Paso 3: Compilar el kernel

>  Esto puede tardar varios minutos.

Para aprovechar varios núcleos del procesador y acelerar el proceso, usa el flag `-j` seguido del número de núcleos (por ejemplo, 4):

```bash
make -j$(nproc)
```

Cuando termine:

```bash
sudo make modules_install
sudo make install
```

Esto:

* Instala los módulos en `/lib/modules/5.13.1`
* Copia el kernel (`vmlinuz-5.13.1`), el archivo `System.map` y el `initrd` a `/boot`
* Actualiza GRUB automáticamente


###  Paso 4: Actualizar GRUB y reiniciar

Solo por si acaso, actualiza GRUB manualmente:

```bash
sudo update-grub
```

Reinicia:

```bash
sudo reboot
```

En el menú de GRUB:

1. Selecciona **Opciones avanzadas**.
2. Escoge la entrada para **Linux 5.13.1**.
3. Comprueba tras arrancar:

   ```bash
   uname -r
   ```

   Salida esperada:

   ```
   5.13.1
   ```

---

Claro, aquí tienes el **<span style="color:red">Ejercicio 3</span>** completo, con la **Parte c)** integrada según lo que ya hicimos y la guía que te proporcioné:

---

**<span style="color:red">Ejercicio 3</span>**
(*Usando el kernel 5.10.0-20*)
Ahora vamos a compilar dos nuevos módulos personalizados del kernel.

a. Asegúrate de que los **headers del kernel** correspondientes a tu versión del kernel (`uname -a`) estén instalados.
Si no lo están, busca el paquete adecuado e instálalo.

b. Descarga el código fuente de los módulos del kernel desde la siguiente URL:
[http://www.ce.unican.es/SI/Kernel/my\_modules.tar.gz](http://www.ce.unican.es/SI/Kernel/my_modules.tar.gz) y compílalos.

c. Instala ambos módulos en el directorio correspondiente e intenta insertar el nuevo módulo **mymodule2.ko** usando `insmod`.
Comprueba si funciona correctamente (usa herramientas de registro para revisar los mensajes del kernel) y si tu nuevo módulo (**mymodule2**) tiene dependencias con otros módulos del kernel.
Soluciona cualquier error hasta que tu módulo se inserte correctamente (prueba también a insertarlo usando `modprobe`).

### Parte a) Verificar los headers del kernel

1. Comprueba tu versión actual del kernel:

   ```bash
   uname -r
   ```

   Deberías ver algo como:

   ```
   5.10.0-20-amd64
   ```

2. Verifica si los headers están instalados:

   ```bash
   ls /lib/modules/$(uname -r)/build
   ```

   Si no existe ese directorio o da error, instálalos:

   ```bash
   sudo apt-get update
   sudo apt-get install linux-headers-$(uname -r)
   ```

### Parte b) Descargar y compilar los módulos

1. Ve a un directorio de trabajo (por ejemplo tu `$HOME`):

   ```bash
   cd ~
   ```

2. Descarga el archivo con los módulos:

   ```bash
   wget http://www.ce.unican.es/SI/Kernel/my_modules.tar.gz
   ```

3. Extrae el contenido:

   ```bash
   tar -xvzf my_modules.tar.gz

   mkdir my_modules
   mv mymodule*.c Makefile my_modules/
   cd my_modules
   ```

4. Compílalos:

   ```bash
   make
   ```

   Esto debería generar los archivos `.ko`, como `mymodule1.ko` y `mymodule2.ko`.

###  Parte c) Instalar e insertar el módulo `mymodule2.ko`

1.  **Copia ambos módulos al directorio estándar de módulos del kernel:**

   ```bash
   sudo cp mymodule1.ko mymodule2.ko /lib/modules/$(uname -r)/kernel/
   ```

2.  **Regenera la base de datos de dependencias de módulos:**

   ```bash
   sudo depmod
   ```

   > *Este paso es necesario para que `modprobe` y `modinfo` funcionen correctamente con los módulos nuevos.*

3.  **Inserta el módulo `mymodule2.ko` usando `insmod`:**

   ```bash
   sudo insmod /lib/modules/$(uname -r)/kernel/mymodule2.ko
   ```

    **ERROR ESPERADO si aún no cargaste `mymodule1`:**

   ```
   insmod: ERROR: could not insert module mymodule2.ko: Unknown symbol in module
   ```

    **SOLUCIÓN:** Carga primero el módulo del que depende:

   ```bash
   sudo insmod /lib/modules/$(uname -r)/kernel/mymodule1.ko
   sudo insmod /lib/modules/$(uname -r)/kernel/mymodule2.ko
   ```

4. **Verifica que ambos módulos están insertados:**

   ```bash
   lsmod | grep mymodule
   ```

   **Salida esperada:**

   ```
   mymodule2              16384  0
   mymodule1              16384  1 mymodule2
   ```

   > Esto indica que `mymodule2` está cargado y utiliza `mymodule1`, que a su vez está en uso.

5.  **Consulta los mensajes generados por el kernel:**

   ```bash
   dmesg | tail -n 20
   ```

   **Salida esperada (resumen):**

   ```
   Hello from Hello Module
   Hello Friend!!!
   Hello Friend!!!
   ...
   Sum of the numbers 11
   ```

   > Estos mensajes muestran que `mymodule2` está usando correctamente funciones y variables exportadas por `mymodule1`.

6.  **Consulta la información del módulo y sus dependencias:**

   ```bash
   modinfo mymodule2
   ```

   **Salida esperada (resumen):**

   ```
   filename:       /lib/modules/5.10.0-20-amd64/kernel/mymodule2.ko
   license:        GPL
   description:    Example module 2
   depends:        mymodule1
   vermagic:       5.10.0-20-amd64 SMP mod_unload modversions
   ```

   > Si `depends: mymodule1` aparece, se confirma que `mymodule2` requiere a `mymodule1`.

7.  **Alternativamente, puedes insertar el módulo con `modprobe`**, que resuelve automáticamente las dependencias:

   ```bash
   sudo modprobe mymodule2
   ```

   > Siempre que hayas ejecutado `depmod` y los módulos estén en la ruta adecuada, esta opción es la más cómoda.


---

**<span style="color:red">Ejercicio 4</span>**
(*Usando el kernel 5.10.0-20*)
Haciendo uso de la **reconfiguración dinámica**, configura el sistema para que **se reinicie automáticamente 10 segundos después de un "kernel panic"**.
Encuentra una forma de generar este tipo de evento para verificar que la reconfiguración funciona correctamente.
⚠️ **No realices esta operación mientras se esté compilando el kernel.**
Haz que esta configuración sea **permanente**.

Perfecto, aquí tienes el **<span style="color:red">Ejercicio 4</span>** completamente traducido, desarrollado y explicado con el mismo estilo claro y estructurado:

---

**<span style="color:red">Ejercicio 4</span>**
(*Usando el kernel 5.10.0-20*)
Haciendo uso de la **reconfiguración dinámica**, configura el sistema para que **se reinicie automáticamente 10 segundos después de un "kernel panic"**.
Encuentra una forma de generar este tipo de evento para verificar que la reconfiguración funciona correctamente.
⚠️ **No realices esta operación mientras se esté compilando el kernel.**
Haz que esta configuración sea **permanente**.

### Paso 1: Activar el reinicio automático tras un *kernel panic*

El parámetro del kernel responsable es:

```bash
kernel.panic
```

Este parámetro indica cuántos segundos esperar antes de reiniciar tras un *kernel panic*. Si está a `0`, no se reinicia automáticamente.

####  Establecer el reinicio a 10 segundos:

```bash
sudo sysctl -w kernel.panic=10
```

**Salida esperada:**

```
kernel.panic = 10
```

### Paso 2: Hacer el cambio permanente

Edita el archivo `/etc/sysctl.conf` para que el valor persista tras reiniciar:

```bash
sudo nano /etc/sysctl.conf
```

Añade (o edita si ya existe) la siguiente línea al final del archivo:

```ini
kernel.panic = 10
```

Guarda y sal con `Ctrl+O`, `Enter` y luego `Ctrl+X`.

Aplica los cambios sin reiniciar:

```bash
sudo sysctl -p
```

### Paso 3: Generar un *kernel panic* (solo para pruebas controladas)

¡Advertencia! Esto apagará o reiniciará la máquina virtual. **Guarda tu trabajo antes.**

Puedes forzar un *kernel panic* usando el comando especial:

```bash
echo c > /proc/sysrq-trigger
```

Pero primero debes habilitar esa función:

```bash
echo 1 > /proc/sys/kernel/sysrq
```

Y luego lanzar el *panic*:

```bash
echo c > /proc/sysrq-trigger
```

**Resultado esperado:** El sistema **se reiniciará automáticamente tras 10 segundos** del *kernel panic*.


---

**<span style="color:red">Ejercicio 5</span>**
(*Usando los kernels 5.10.0-20 y 5.13.0*)
Lista los **módulos que se han cargado durante el proceso de arranque** del sistema en ambos kernels.
Explica la diferencia según el tamaño de los ejecutables del kernel.

###  Objetivo

Comparar:

* Qué módulos se cargan automáticamente al arrancar con cada versión del kernel.
* Cómo esto se relaciona con el **tamaño del ejecutable del kernel** (`vmlinuz`), que refleja cuánto código está compilado directamente (monolítico) y cuánto se carga dinámicamente (modular).

### Paso 1: Ver módulos cargados tras el arranque

Después de arrancar cada kernel (5.10.0-20 y 5.13.0), ejecuta:

```bash
lsmod
```

**Salida esperada:**
Una lista como esta (ejemplo para 5.10):

```
Module                  Size  Used by
mymodule2              16384  0
mymodule1              16384  1 mymodule2
e1000                  98304  0
...
```

**Repite el mismo comando tras iniciar con el otro kernel (5.13.0)**.

>  Puedes guardar cada salida en un archivo para comparar más fácilmente:

```bash
lsmod > modules-5.10.txt
# Cambia de kernel y luego:
lsmod > modules-5.13.txt
```

###  Paso 2: Ver el tamaño del ejecutable del kernel

Lista los archivos en `/boot`:

```bash
ls -lh /boot/vmlinuz-5.10.0-20-amd64
ls -lh /boot/vmlinuz-5.13.1
```
**Salida esperada:**

```
[ (SI) root@core ~ ] ls -lh /boot/vmlinuz-5.10.0-20-amd64
-rw-r--r-- 1 root root 6,7M dic 13  2022 /boot/vmlinuz-5.10.0-20-amd64
[ (SI) root@core ~ ] ls -lh /boot/vmlinuz-5.13.1
-rw-r--r-- 1 root root 9,2M jun  4 20:44 /boot/vmlinuz-5.13.1
```


### Interpretación 

* Si **el ejecutable de 5.13.1 es más grande**, probablemente **incluye más funciones integradas directamente en el kernel**, lo cual hace que **se carguen menos módulos externos automáticamente** (o incluso ninguno).
* En cambio, si el kernel 5.10.0-20 es más pequeño y hay **más módulos en `lsmod`**, significa que usa más un enfoque **modular**.

### Conclusión esperada (ejemplo)

> El kernel 5.10.0-20 tiene un ejecutable más pequeño (\~5.6 MB) y carga más módulos automáticamente (visible con `lsmod`).
> El kernel 5.13.1, compilado manualmente, tiene un ejecutable más grande (\~7.2 MB), lo que indica que más funcionalidades están integradas directamente en el núcleo y no se cargan como módulos separados.
> Esto refleja la diferencia entre un enfoque modular (como el kernel de la distribución) y un enfoque monolítico más cerrado (como un kernel personalizado con `make defconfig`).

---

**<span style="color:red">Ejercicio 6</span>**
(*Usando el kernel 5.10*)
Inicia sesión en una **segunda terminal**.
Haciendo uso de los **archivos de dispositivo**, envía un mensaje desde la primera consola hacia la segunda usando el comando `echo`.

### Paso 1: Abre dos paneles en `tmux`

Desde dentro de una sesión de `tmux`, crea dos paneles con:

* `Ctrl + b`, luego `%` para dividir verticalmente
* `Ctrl + b`, luego `"` para dividir horizontalmente


### Paso 2: Identifica el nombre de cada terminal

En **cada panel**, ejecuta:

```bash
tty
```

Ejemplo de salida:

* Panel 1: `/dev/pts/1`
* Panel 2: `/dev/pts/2`

### Paso 3: Enviar un mensaje entre paneles

> Recomendado: en el **panel receptor**, deja ejecutándose `cat` para que los mensajes se vean.

```bash
cat
```

Ahora, en el **otro panel**, ejecuta:

```bash
echo "Hola desde el otro panel de tmux" > /dev/pts/2
```

### Explicación

* `tmux` gestiona terminales virtuales a través de **pseudo-terminales**, que aparecen como `/dev/pts/X`.
* El comando `echo` envía texto directamente a esos archivos de dispositivo.
* `cat` actúa como un lector del flujo de entrada, lo cual permite **ver el texto en tiempo real**.

---

**<span style="color:red">Ejercicio 7</span>**
(*Usando el kernel 5.10*)
Inserta la imagen del **CD de rescate** en el controlador de CDROM
(**Ventana de la terminal de VirtualBox → Dispositivos → Unidad óptica**).
Luego, crea **manualmente**, en el directorio `$HOME` del usuario root, un **archivo de dispositivo** asociado a la unidad de CDROM.
Verifica que funciona correctamente (para ello, basta con comprobar que puedes montar el contenido del dispositivo usando el archivo de dispositivo creado).

### Paso 1: Insertar la imagen del CD

1. En la interfaz de VirtualBox, con la VM encendida:

   * Ve a **Dispositivos → Unidad óptica → Elegir una imagen de disco**.
   * Selecciona la ISO del **Rescue CD** proporcionada.
   * Asegúrate de que aparece como insertada.

2. En la máquina virtual, verifica que el sistema detecta la unidad óptica:

   ```bash
   dmesg | grep -i cdrom
   ```

   o

   ```bash
   lsblk
   ```

   Buscas un dispositivo como `/dev/sr0` o `/dev/cdrom`.

### Paso 2: Crear manualmente el archivo de dispositivo

Si no existe `/dev/cdrom` o si quieres crear uno nuevo en tu `$HOME`:

1. Comprueba el **major y minor number** del dispositivo real (por ejemplo, `/dev/sr0`):

   ```bash
   ls -l /dev/sr0
   ```

   Salida esperada (ejemplo):

   ```
   brw-rw---- 1 root cdrom 11, 0 jun  4 20:00 /dev/sr0
   ```

   Aquí:

   * **`11`** → número mayor (major)
   * **`0`** → número menor (minor)

2. Crea el archivo de dispositivo en el directorio `$HOME` de root:

   ```bash
   cd ~
   sudo mknod cdrom_dev b 11 0
   sudo chmod 660 cdrom_dev
   ```

   * `b` indica que es un dispositivo de bloque (block device)
   * `cdrom_dev` es el nombre que le das (puede ser otro)


### Paso 3: Montar el contenido del CD usando el archivo creado

1. Crea un punto de montaje:

   ```bash
   mkdir ~/cdrom_mount
   ```

2. Monta el dispositivo:

   ```bash
   sudo mount ~/cdrom_dev ~/cdrom_mount
   ```

3. Verifica que puedes ver el contenido:

   ```bash
   ls ~/cdrom_mount
   ```

   Si ves archivos y carpetas, ¡funciona correctamente!

Los ejercicios 6 y 7, aunque puedan parecer secundarios, tienen un papel clave en el estudio del kernel de Linux, ya que permiten interactuar directamente con los dispositivos gestionados por el kernel a través de archivos especiales en el sistema. En el ejercicio 6, al enviar mensajes entre terminales mediante archivos de dispositivo (`/dev/pts/X`), se pone en práctica el modelo de Unix/Linux en el que “todo es un archivo” y se observa cómo el kernel abstrae dispositivos de carácter como las terminales. En el ejercicio 7, al crear manualmente un archivo de dispositivo con `mknod`, se refuerza el vínculo entre kernel, driver y dispositivo, aprendiendo cómo el kernel asocia un archivo en `/dev` a un controlador mediante los números mayor y menor. Ambos ejercicios ayudan a comprender cómo el kernel expone el hardware al usuario y a practicar la gestión de dispositivos desde el espacio de usuario, destacando el rol del kernel como puente entre software y hardware.


---

