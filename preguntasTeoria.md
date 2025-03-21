# Preguntas de exámenes anteriores

1. **Pregunta:** ¿En qué consiste el proceso de redirección disponible en la Shell de Linux?
   **Respuesta:** El proceso de redirección en la Shell de Linux consiste en redirigir la entrada, salida o errores de un comando hacia o desde un archivo, dispositivo o flujo de datos.

2. **Pregunta:** Entre los atributos de un fichero en el sistema de ficheros están los bits que gestionan sus permisos. Describe la estructura de dichos bits, cómo se modifican y si existen alternativas para la gestión de permisos en ficheros.
   **Respuesta:** Los bits que gestionan los permisos de un archivo en el sistema de ficheros tienen una estructura de 9 bits, divididos en tres conjuntos: los primeros tres bits representan los permisos del propietario, los siguientes tres bits representan los permisos del grupo y los últimos tres bits representan los permisos de otros usuarios. Se modifican mediante comandos como "chmod" en la línea de comandos. Alternativas para la gestión de permisos incluyen ACLs (Listas de Control de Acceso) que permiten definir permisos más granulares.

3. **Pregunta:** Describimos a continuación algunos parámetros de un sistema de ficheros basado en i-nodos: Cada i-nodo de la tabla de i-nodos contiene 5 punteros directos y 1 puntero indirecto de primer nivel. El tamaño de bloque del disco es de 1Kbyte y cada puntero ocupa 8 bytes. Con estos datos, ¿sabrías calcular el tamaño máximo de fichero que soporta nuestro sistema de ficheros?
   **Respuesta:**
- **5 punteros directos** (apuntan directamente a bloques de datos).
- **1 puntero indirecto de primer nivel** (apunta a un bloque de punteros, cada uno de los cuales apunta a un bloque de datos).
- **Tamaño de bloque del disco:** 1 KB (1024 bytes).
- **Tamaño de cada puntero:** 8 bytes.

 **Cálculo del tamaño máximo del fichero**

 **1. Bloques accesibles por los punteros directos**
Cada puntero directo apunta a un bloque de datos de 1 KB. Como hay **5 punteros directos**, la cantidad de datos accesibles es:
\[
5 \times 1\text{KB} = 5\text{KB}
\]

 **2. Bloques accesibles mediante el puntero indirecto**
El puntero indirecto apunta a un **bloque de punteros**. Cada puntero ocupa **8 bytes**, por lo que en un bloque de 1 KB caben:
\[
\frac{1024}{8} = 128 \text{ punteros}
\]
Cada uno de estos punteros apunta a un bloque de datos de 1 KB, lo que da un tamaño total accesible mediante el puntero indirecto de:
\[
128 \times 1\text{KB} = 128\text{KB}
\]

 **3. Tamaño total máximo del fichero**
Sumamos los bloques accesibles por los punteros directos y por el puntero indirecto:

\[
5\text{KB} + 128\text{KB} = 133\text{KB}
\]

 **Conclusión**
El tamaño máximo de fichero que soporta este sistema de ficheros es **133 KB**. 

4. **Pregunta:** En el proceso de arranque del sistema operativo conviven dos piezas con un nombre muy similar, el BootManager y el BootLoader. Describe la función de cada uno y en qué etapa del arranque están presentes.
   **Respuesta:** El BootManager es responsable de seleccionar qué sistema operativo o kernel se iniciará en el arranque, mientras que el BootLoader es el encargado de cargar el sistema operativo seleccionado en la memoria. El BootManager está presente en la etapa inicial del arranque, mientras que el BootLoader entra en acción después, en la etapa de carga del sistema operativo.

5. **Pregunta:** Describe qué ficheros y directorios forman parte del proceso de creación de un usuario, así como la utilidad de cada uno de ellos.
   **Respuesta:** Durante el proceso de creación de un usuario en Linux, los ficheros y directorios relevantes incluyen "/etc/passwd", que contiene información de usuario como el nombre de usuario y el identificador de usuario (UID); "/etc/shadow", que almacena las contraseñas encriptadas; y "/home/username", que es el directorio de inicio del usuario y donde se almacenan sus archivos personales.

6. **Pregunta:** ¿Es físicamente posible trabajar en un sistema en el que el tamaño de la memoria principal sea mayor que el tamaño del Disco duro que utiliza para almacenar el sistema de ficheros raíz?
   **Respuesta:** Sí, es físicamente posible trabajar en un sistema donde el tamaño de la memoria principal (RAM) sea mayor que el tamaño del disco duro que utiliza para almacenar el sistema de archivos raíz. Esto se conoce como un sistema con memoria virtual, donde parte del disco duro se utiliza como extensión de la memoria RAM cuando la memoria física se agota, permitiendo así ejecutar procesos aunque no quepan completamente en la memoria física.

7. **Pregunta:** ¿Qué es una expresión regular y algún ejemplo de uso?
    **Respuesta:** Una expresión regular es una secuencia de caracteres que define un patrón de búsqueda en texto. Por ejemplo, en el texto "Hola mundo", la expresión regular "mundo" buscaría la coincidencia de la palabra "mundo".

8. **Pregunta:** ¿Cuál es el tamaño máximo de fichero en tu sistema de ficheros basado en i-nodos?
   **Respuesta:** El tamaño máximo de fichero en el sistema de ficheros sería de 20 KB, calculado como 4 punteros directos * 4 KB (tamaño del bloque) + 1 puntero indirecto de primer nivel * 4 KB.

9. **Pregunta:** ¿Por qué Linux utiliza la interfaz de nombre Virtual File System (VFS) y qué acciones lleva a cabo cuando se monta un nuevo sistema de ficheros?
   **Respuesta:** Linux utiliza VFS para abstraer las diferencias entre sistemas de ficheros. Cuando se monta un nuevo sistema de ficheros, VFS establece la conexión entre el nuevo sistema y el sistema operativo, realizando acciones como la asignación de recursos y la gestión de operaciones de entrada/salida.

10. **Pregunta:** ¿Cuáles son algunas formas de obtener permisos de administración durante el proceso de arranque?
   **Respuesta:** Algunas formas incluyen acceder al modo de usuario único, iniciar desde un medio externo con privilegios de administrador, o modificar las opciones de arranque desde un gestor de arranque como GRUB.

11. **Pregunta:** ¿Para qué se utiliza la partición de swap y cómo se puede ampliar su tamaño?
   **Respuesta:** La partición de swap se utiliza para almacenar datos temporales cuando la memoria RAM está llena. Se puede ampliar su tamaño aumentando el tamaño de la partición existente o creando una nueva partición de swap adicional.

12. **Pregunta:** ¿En qué se diferencia el pseudo sistema de ficheros /proc de un sistema de ficheros convencional y qué tipo de información contiene?
   **Respuesta:** /proc es un sistema de archivos virtual que contiene información sobre el estado del sistema y los procesos en ejecución en tiempo real. Se diferencia de un sistema de archivos convencional en que no contiene archivos físicos en el disco, sino que genera información dinámica. Contiene información sobre procesos, dispositivos, módulos del kernel y otros recursos del sistema.

13. **Pregunta:** Describe el proceso de validación de paquetes basado en llave pública privada que utiliza apt.
   **Respuesta:** El proceso implica verificar la firma digital del paquete con la clave pública del repositorio. Si la firma coincide, el paquete se considera válido y seguro para instalar.

14. **Pregunta:** ¿Qué implicaciones tiene sobre el rendimiento un sistema con tres discos duros agrupados en un RAID 5 cuando un disco falla?
   **Respuesta:** Mientras no se reemplace el disco fallido, puede haber una degradación en el rendimiento debido al cálculo de los datos a partir de la paridad y a la reconstrucción de los datos en el disco de repuesto.

15. **Pregunta:** ¿Qué implica la gestión de la memoria física disponible por parte del kernel?
   **Respuesta:** Implica asignar y liberar espacio en la memoria RAM para los procesos en ejecución, garantizando un uso eficiente de los recursos y evitando conflictos de acceso a la memoria entre procesos.

16. **Pregunta:** ¿Cuáles son las dos formas de administrar la resolución de nombres en la capa de red?
    **Respuesta:** Las dos formas son el enrutamiento estático, donde se configuran manualmente las rutas de red en la tabla de enrutamiento, y el enrutamiento dinámico, donde los routers intercambian información de enrutamiento utilizando protocolos como RIP, OSPF o BGP para determinar las rutas óptimas automáticamente.

17. **Pregunta:** ¿Qué es el kernel y cuáles son sus funciones principales?
   **Respuesta:** El kernel es el núcleo del sistema operativo que actúa como intermediario entre el hardware y el software. Sus funciones principales incluyen la gestión de recursos del sistema, la ejecución de procesos, la administración de memoria y la comunicación entre software y hardware.

18. **Pregunta:** ¿Consideras razonable el funcionamiento del sistema basado en los resultados del comando vmstat? Justifica tu respuesta.
    ```
    [ (SI) root core ~] vmstat 5 3 
    procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu----- 
    r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st 
    0 17 1416076  53620   1416  15004 6790 10353  7039 10359  377  994 12 33 49  5  0 
    0 16 1904780  70024    776  12856 31582 128698 31591 128698 1507 4008  1 29  0 69  0 
    1 15 2075400  78816     96  11396 30692 65362 30696 65362 1425 3588  4 28  0 68  0 
    ```
   **Respuesta:** No parece razonable. Los altos valores de memoria virtual utilizada y actividad de intercambio sugieren que el sistema está experimentando una alta demanda de memoria física, lo que podría causar degradación en el rendimiento debido al uso excesivo de la memoria virtual y el intercambio de datos entre la memoria y el disco.

19. **Pregunta:** ¿Cuál es el tamaño máximo de fichero que soporta el sistema de ficheros basado en i-nodos descrito?
   **Respuesta:** El tamaño máximo de fichero sería de 41 KB, calculado como 5 punteros directos * 1 KB (tamaño del bloque) + 1 puntero indirecto de primer nivel * 1 KB (tamaño del bloque) * 1024 (número máximo de bloques indirectos de primer nivel).

20. **Pregunta:** Describe los componentes del disco en un dispositivo de almacenamiento que utiliza el estándar de particionado GPT y su ubicación en el disco.
   **Respuesta:** 
   - Primary GPT: Almacena la información de particionado del disco y se encuentra al principio del disco.
   - Legacy MBR: Contiene una copia de seguridad de la tabla de particiones GPT y está ubicada al final del disco.
   - Secondary GPT: Es una copia de la tabla de particiones GPT y se encuentra al final del disco.

21. **Pregunta:** ¿Cuáles son algunas formas de aprovechar el acceso físico durante las etapas de arranque para obtener permisos de administrador en la máquina?
   **Respuesta:** Algunas formas incluyen modificar las opciones de arranque desde el UEFI/BIOS, modificar la configuración de GRUB o iniciar desde un medio externo con privilegios de administrador.

22. **Pregunta:** Describe brevemente los tipos de relaciones de dependencia entre servicios en systemd.
   **Respuesta:** Los tipos de relaciones de dependencia incluyen requisitos, conflictos, habilitación y requisitos de deseo, que definen las relaciones entre diferentes servicios en el sistema.

23. **Pregunta:** ¿Por qué reservamos espacio en disco para el intercambio de páginas con memoria principal y es posible modificar el espacio de swap disponible en nuestro sistema?
   **Respuesta:** Reservamos espacio en disco para el intercambio de páginas con memoria principal para permitir que el sistema opere eficientemente cuando la memoria física se agota. Sí, es posible modificar el espacio de swap disponible agregando o eliminando particiones de intercambio o ajustando la configuración de swap en el sistema operativo.

24. **Pregunta:** ¿Qué ventajas proporciona la instalación de paquetes a través de APT sobre la instalación con el comando dpkg?
   **Respuesta:** APT proporciona ventajas como la resolución automática de dependencias, la gestión centralizada de repositorios y la facilidad de actualización y eliminación de paquetes junto con sus dependencias.

25. **Pregunta:** Completa la tabla indicando el número mínimo de discos, el almacenamiento disponible y el número máximo de fallos de disco tolerados para cada tipo de RAID.
   **Respuesta:** 
   ```
   RAID | Discos mínimos | Almacenamiento | Fallos tolerados
   ---- | -------------- | -------------- | ----------------
   0    | 2              | N              | 0
   1    | 2              | 1GB            | 1
   4    | 3              | (N-1)GB        | 1
   5    | 3              | (N-1)GB        | 1
   ```

26. **Pregunta:** ¿En qué consisten las técnicas utilizadas para reducir los riesgos de seguridad derivados de la mala elección de contraseñas por parte de los usuarios?
    **Respuesta:** Las técnicas incluyen el establecimiento de políticas de contraseñas que definen reglas de complejidad y longitud, y la implementación de autenticación multifactor que requiere más de una forma de autenticación para acceder a un sistema.

27. **Pregunta:** Cuando hacemos referencia a los directorios /proc o /sys como “pseudo sistemas de ficheros” ¿A qué nos referimos? Describe de forma breve qué tipo de datos contienen los directorios mencionados.
   **Respuesta:** Nos referimos a que son sistemas de archivos virtuales que no almacenan datos en disco, sino que proporcionan una interfaz para acceder a información del kernel y del hardware del sistema en tiempo real. El directorio /proc contiene información sobre procesos, dispositivos y recursos del sistema, mientras que /sys contiene información sobre dispositivos y controladores.

28. **Pregunta:** A la vista de los datos obtenidos en el comando vmstat, ¿crees que el funcionamiento del sistema es razonable? Justifica tu respuesta.
    ```
    [ (SI) root core ~] vmstat 5 3 
    procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu----- 
    r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st 
    0 17 1416076  53620   1416  15004 6790 10353  7039 10359  377  994 12 33 49  5  0 
    0 16 1904780  70024    776  12856 31582 128698 31591 128698 1507 4008  1 29  0 69  0 
    1 15 2075400  78816     96  11396 30692 65362 30696 65362 1425 3588  4 28  0 68  0 
    ```

   **Respuesta:** No parece razonable. Los altos valores de memoria virtual utilizada y actividad de intercambio sugieren que el sistema está experimentando una alta demanda de memoria física, lo que podría causar degradación en el rendimiento debido al uso excesivo de la memoria virtual y el intercambio de datos entre la memoria y el disco.

29. **Pregunta:** ¿En qué consiste el proceso de garantizar la autenticidad del software en los repositorios Debian a través de mecanismos de criptografía asimétrica (llave pública-privada) y por qué es relevante?
   **Respuesta:** El proceso implica firmar digitalmente los paquetes de software con una llave privada y permitir que los usuarios verifiquen la autenticidad de los paquetes utilizando la llave pública correspondiente. Es relevante porque garantiza que el software no ha sido alterado durante la transferencia y que proviene de una fuente confiable.

30. **Pregunta:** Indica qué información proporciona cada campo de la línea del fichero de configuración /etc/apt/sources.lst.
    ```
    deb-src http://ftp.es.debian.org/debian/  stretch  main contrib non-free 
    ```
   **Respuesta:** El campo "deb-src" indica que se trata de un repositorio para obtener paquetes fuente, seguido de la URL del repositorio, la versión de Debian (stretch), y las secciones del repositorio (main, contrib, non-free) que contienen los paquetes.

31. **Pregunta:** Si dispongo de 4 discos de 1GB cada uno, ¿cuál sería el tamaño máximo de sistema de ficheros que podría implementar sin usar LVM? ¿Y usando LVM? Si creo un dispositivo RAID de nivel 5 con los cuatro discos, ¿cambian los tamaños mencionados?
   **Respuesta:** Sin LVM, el tamaño máximo del sistema de archivos sería de 4GB. Con LVM, el tamaño máximo dependería de cómo se configuren los volúmenes lógicos. Si se crea un dispositivo RAID 5 con los cuatro discos, el tamaño máximo del sistema de archivos sería de 3GB debido a la paridad distribuida y la redundancia de datos.

32. **Pregunta:** ¿En qué consiste una implementación de kernel de tipo modular y qué tipo de ventajas puede tener esta aproximación sobre un kernel completamente monolítico?
   **Respuesta:** Una implementación de kernel modular permite cargar y descargar módulos de kernel en tiempo de ejecución según sea necesario, lo que permite una configuración más flexible del sistema y una mejor gestión de los recursos del sistema. Esto puede resultar en un menor consumo de memoria y una mayor facilidad para añadir o quitar características del kernel.

33. **Pregunta:** ¿Quién se encarga de cargar en el kernel el módulo con el driver apropiado y crear un device file adecuado en /dev al conectar un dispositivo de almacenamiento USB (sistema de ficheros tipo FAT)?
   **Respuesta:** Normalmente, el sistema operativo, a través del administrador de dispositivos, es quien se encarga de cargar el módulo del controlador adecuado para el dispositivo conectado y de crear el archivo de dispositivo adecuado en /dev para acceder a su contenido.

34. **Pregunta:** Describe en qué consiste la resolución de nombres de la capa de red y qué opciones proporciona Debian para llevarla a cabo.
   **Respuesta:** La resolución de nombres de la capa de red es el proceso de traducir nombres de dominio en direcciones IP. Debian proporciona opciones como el uso de un servidor DNS local, configuración manual de los archivos /etc/hosts y /etc/resolv.conf, y herramientas como dig, nslookup y host para realizar consultas DNS.

35. **Pregunta:** ¿Qué tipo de información proporcionan los 4 componentes básicos de un sistema de ficheros de tipo EXT: superbloque, bitmap de inodos, bitmap de bloques, tabla de inodos? ¿Cómo se implementa la jerarquía de directorios a través de dichos componentes?
   **Respuesta:** 
   - El superbloque contiene información sobre el sistema de ficheros, como su tamaño, estado y otros metadatos.
   - El bitmap de inodos y el bitmap de bloques indican qué inodos y bloques están ocupados o libres en el sistema de ficheros, respectivamente.
   - La tabla de inodos almacena metadatos de cada archivo, como permisos, tamaño y ubicación de bloques de datos.
   La jerarquía de directorios se implementa asignando a cada directorio un inodo especial que contiene entradas que apuntan a otros inodos correspondientes a archivos o subdirectorios.

36. **Pregunta:** ¿Cómo es posible que comandos como ls, cd, cp interactúen de manera transparente en un sistema de ficheros raíz con múltiples particiones y distintos sistemas de ficheros?
   **Respuesta:** Los comandos interactúan de manera transparente porque el sistema operativo maneja la traducción entre diferentes sistemas de archivos y particiones. Cuando se accede a un archivo en una partición diferente, el sistema operativo se encarga de gestionar la lectura y escritura en la partición correspondiente, permitiendo así que los comandos funcionen de manera uniforme independientemente del sistema de archivos subyacente.

37. **Pregunta:** En systemd se pueden establecer diferentes relaciones de dependencia entre Unit files. ¿Cuáles son y cómo nos ayudan a gestionar el proceso de arranque de servicios?
   **Respuesta:** Las relaciones de dependencia en systemd incluyen:
   - Requisitos: Define qué servicios deben estar activos para que otro servicio funcione correctamente.
   - Conflicto: Especifica servicios que no pueden estar activos simultáneamente.
   - Requisitos de deseo: Indica servicios que mejorarían si están activos, pero no son necesarios para que otro servicio funcione.
   Estas relaciones ayudan a gestionar el proceso de arranque asegurando que los servicios se inicien en el orden correcto y que las dependencias entre ellos se cumplan.

38. **Pregunta:** Uno de los elementos claves en la gestión de procesos es el sistema de ficheros /proc. Describe la jerarquía y contenido de dicho sistema de ficheros con respecto a los procesos activos.
   **Respuesta:** 
   - La jerarquía en /proc refleja la estructura de los procesos en el sistema, con un directorio para cada proceso identificado por su PID.
   - Dentro de cada directorio de proceso se encuentran archivos especiales que contienen información sobre el proceso, como su estado, uso de recursos, comandos asociados, entre otros.
   - /proc también proporciona información sobre otros aspectos del sistema, como la configuración del kernel y los dispositivos.

39. **Pregunta:** ¿Qué ventajas proporciona el sistema de gestión de paquetes APT sobre la instalación de paquetes mediante DPKG?
   **Respuesta:** APT ofrece ventajas como la resolución automática de dependencias, la gestión centralizada de repositorios y la facilidad de actualización y eliminación de paquetes junto con sus dependencias, lo que simplifica y agiliza el proceso de gestión de paquetes en comparación con el uso directo de DPKG.

40. **Pregunta:** ¿Qué mecanismos de seguridad se utilizan en los repositorios de software de Debian para garantizar la integridad de los paquetes?
   **Respuesta:** Los repositorios de software de Debian utilizan firmas digitales para garantizar la integridad de los paquetes. Cada paquete está firmado digitalmente con una clave de firma y el administrador de paquetes verifica la firma antes de instalar el paquete, asegurando que no haya sido alterado durante la transferencia.

41. **Pregunta:** Dado el esquema de disco de la figura inferior, indica qué tipo de información contiene cada una de las partes indicadas: Legacy MBR, Primary GPT, Boot Partition, Root Partition, Swap Partition, Secondary GPT.
    **Respuesta:** 
   - Legacy MBR: Contiene el registro de arranque maestro y la tabla de particiones del disco.
   - Primary GPT: Almacena la tabla de particiones GUID y otra información de particionado.
   - Boot Partition: Partición utilizada para almacenar los archivos necesarios para el arranque del sistema.
   - Root Partition: Partición que contiene el sistema operativo y los archivos del sistema.
   - Swap Partition: Partición utilizada como espacio de intercambio para la memoria virtual.
   - Secondary GPT: Es una copia de seguridad de la tabla de particiones GUID situada al final del disco.

42. **Pregunta:** Haciendo uso del esquema de la figura inferior, que representa los componentes de un sistema de ficheros de tipo EXT, indica las implicaciones que tiene incrementar el tamaño de un fichero hasta sobrepasar el tamaño de un bloque de datos. ¿Qué problemas de consistencia se derivan de esto si se interrumpe el proceso de manera abrupta?
   **Respuesta:** Si un fichero crece hasta sobrepasar el tamaño de un bloque de datos, se convertirá en un fichero fragmentado, lo que puede ralentizar el acceso a los datos. Si el proceso de escritura se interrumpe abruptamente, puede resultar en la corrupción del fichero o la pérdida de datos, ya que el sistema de ficheros no será capaz de completar la escritura de manera coherente.

43. **Pregunta:** Describe qué es un Ramdisk, así como su utilidad. ¿Por qué es necesaria la presencia de este tipo de componente en el proceso de arranque del sistema?
   **Respuesta:** Un Ramdisk es un dispositivo de bloque de memoria que se utiliza como un disco virtual en la memoria RAM. Su utilidad radica en su alta velocidad de lectura y escritura, lo que lo hace ideal para almacenar temporalmente datos que deben ser accedidos rápidamente. Es necesario en el proceso de arranque del sistema para cargar los archivos y componentes esenciales del sistema operativo antes de que el sistema de ficheros principal esté disponible.

44. **Pregunta:** El scheduler de nuestro sistema operativo gestiona de manera automática cómo se reparte el tiempo de CPU entre múltiples procesos. ¿Podemos, como administradores, influir de alguna forma en dicho reparto?
   **Respuesta:** Sí, los administradores pueden influir en el reparto del tiempo de CPU mediante la configuración de prioridades de proceso, la asignación de afinidades de CPU y el ajuste de parámetros del scheduler del kernel, como el quantum de tiempo, la política de scheduling y la afinidad de CPU.

45. **Pregunta:** Dado el siguiente fichero de configuración de repositorios software, indica qué tipo de información proporciona cada campo de una de las líneas.
   ```
   deb http://ftp.es.debian.org/debian/ stretch main contrib non-free 
   deb-src http://ftp.es.debian.org/debian/ stretch main contrib non-free 
   deb http://security.debian.org/debian-security stretch/updates main contrib non-free 
   deb-src http://security.debian.org/debian-security stretch/updates main contrib non-free 
   ```
   **Respuesta:** Cada línea especifica un repositorio de software de Debian y su contenido:
   - El primer campo ("deb" o "deb-src") indica si se trata de un repositorio binario o fuente.
   - El segundo campo especifica la URL del repositorio.
   - El tercer campo indica la versión de Debian (stretch).
   - Los campos restantes especifican las secciones del repositorio (main, contrib, non-free) que contienen los paquetes.

46. **Pregunta:** Para parte de los niveles RAID vistos en clase (0, 1 y 5), indica el número mínimo de discos necesarios para su implementación, y cuál es la capacidad efectiva (% de capacidad utilizable para almacenar datos) de almacenamiento en cada uno de ellos.
   **Respuesta:** 
   - RAID 0: Mínimo 2 discos. Capacidad efectiva: 100%.
   - RAID 1: Mínimo 2 discos. Capacidad efectiva: 50%.
   - RAID 5: Mínimo 3 discos. Capacidad efectiva: (N-1) * 100%, donde N es el número total de discos.

47. **Pregunta:** En teoría hemos visto que el kernel de Linux es de tipo modular. ¿Qué quiere decir esto?
   **Respuesta:** Significa que el kernel de Linux está compuesto por módulos que pueden ser cargados y descargados en tiempo de ejecución según sea necesario. Esto permite una mayor flexibilidad en la configuración del kernel y la gestión de recursos del sistema, ya que los módulos pueden añadir o quitar características

48. **Pregunta:** ¿Cuál es la utilidad de las variables de entorno $PATH y $PWD?
   **Respuesta:** 
   - La variable de entorno $PATH contiene una lista de directorios donde el sistema operativo busca los ejecutables de comandos cuando se ingresan en la línea de comandos.
   - La variable de entorno $PWD almacena la ruta del directorio actual en el que se encuentra el usuario.

49. **Pregunta:** Describe, de manera básica, el conjunto de acciones que ocurren en el proceso de arranque de un computador desde que se pulsa el botón de encendido hasta que el Sistema Operativo se encuentra cargado en Memoria y listo para iniciar su ejecución.
   **Respuesta:** 
    1. Se enciende el computador.
    2. Se realiza el POST (Power-On Self-Test), donde se verifica el hardware.
    3. Se carga el firmware de la BIOS/UEFI y se inicializan los dispositivos.
    4. Se busca el cargador de arranque (GRUB, por ejemplo) en el disco.
    5. Se carga el kernel del Sistema Operativo en memoria.
    6. Se monta el sistema de ficheros raíz.
    7. Se inician los procesos y servicios esenciales.
    8. Se presenta la pantalla de inicio de sesión o escritorio, dependiendo del Sistema Operativo.

50. **Pregunta:** Uno de los recursos hardware que el administrador puede gestionar es el uso de la CPU (Gestión de Procesos). Explica los diferentes mecanismos que conozcas para dicha tarea.
   **Respuesta:** 
   - Planificación de procesos: Asigna tiempo de CPU a los procesos de manera equitativa y eficiente.
   - Afinidad de CPU: Asigna procesos específicos a núcleos de CPU específicos.
   - Prioridades de procesos: Determina el orden de ejecución de los procesos en función de su importancia y necesidades.

51. **Pregunta:** ¿Qué ventajas ofrece la instalación de software a través de su código fuente en comparación con los mecanismos automatizados (dpkg, apt)? ¿Cómo se garantiza en Debian que un paquete software descargado desde un repositorio externo no ha sido manipulado?
   **Respuesta:** 
   - La instalación desde código fuente permite una mayor personalización y optimización del software para el sistema específico.
   - En Debian, la integridad de los paquetes se garantiza mediante firmas digitales y el uso de claves de autenticación. Cada paquete tiene una firma digital que el administrador puede verificar para asegurarse de que no ha sido manipulado.

52. **Pregunta:** En la administración de usuarios, ¿En qué consiste la delegación de privilegios por parte del administrador del sistema y con qué comando se gestiona?
   **Respuesta:** La delegación de privilegios consiste en otorgar a ciertos usuarios permisos específicos para realizar ciertas tareas administrativas sin necesidad de concederles permisos de administrador completos. Se gestiona utilizando el comando "sudo" en sistemas basados en Unix.

53. **Pregunta:** Explica en qué consiste y qué permite el mecanismo de gestión de discos RAID. Describe el funcionamiento de al menos 3 de los niveles RAID que conozcas.
   **Respuesta:** 
   - RAID (Redundant Array of Independent Disks) es un método para combinar múltiples discos duros en un solo sistema de almacenamiento para mejorar la redundancia, el rendimiento o ambos.
   - RAID 0: Striping sin paridad. Aumenta el rendimiento al dividir los datos entre varios discos, pero no ofrece redundancia.
   - RAID 1: Mirroring. Crea una copia exacta (espejo) de los datos en dos o más discos, ofreciendo redundancia completa.
   - RAID 5: Striping con paridad distribuida. Distribuye los datos y la paridad en múltiples discos, lo que proporciona redundancia y mejora el rendimiento de lectura. 

54. **Pregunta:** En un kernel modular, parte de la funcionalidad se incluye en módulos que se cargan de manera dinámica en tiempo de ejecución (LKM). Sin embargo, hay funcionalidad que debe ser incluida en el kernel, ¿Por qué razón?. Cada vez que un usuario monta una partición con un nuevo sistema de ficheros, ¿Por qué no es necesario que dicho usuario realice de forma previa la carga del módulo del kernel apropiado?
   **Respuesta:** 
   Algunas funcionalidades esenciales necesitan estar incluidas directamente en el kernel para garantizar un funcionamiento básico y estable del sistema. Cuando se monta una partición con un nuevo sistema de archivos, el kernel detecta automáticamente el tipo de sistema de archivos y carga el módulo correspondiente si es necesario, lo que simplifica el proceso para el usuario y garantiza la compatibilidad con una amplia gama de sistemas de archivos.



---
# Preguntas de la Ordinaria 2024

**Pregunta 1:**
Si renombro un script eliminando su extensión (Por ejemplo: mv script.sh script), ¿Se puede seguir ejecutando dicho script?

**Respuesta 1:**
Sí, el script puede seguir ejecutándose. En sistemas Unix y Linux, la extensión del archivo no afecta su ejecutabilidad. Lo importante es que el archivo tenga permisos de ejecución y el "shebang" (#!) correcto al principio del archivo que especifica el intérprete a utilizar. Por ejemplo, si tu script tiene `#!/bin/bash` en la primera línea y el archivo tiene permisos de ejecución (`chmod +x script`), se ejecutará sin importar su extensión.

---

**Pregunta 2:**
Los enlaces son un tipo de ficheros especial que "apuntan" a otra ubicación en el sistema de ficheros. Describe los dos tipos que existen y sus principales características.

**Respuesta 2:**
Existen dos tipos principales de enlaces en sistemas de archivos Unix y Linux:

1. **Enlaces duros (hard links)**:
   - Apuntan directamente al i-nodo de un archivo.
   - No crean un nuevo archivo, sino otra referencia al mismo i-nodo.
   - Todos los enlaces duros a un archivo son indistinguibles del archivo original.
   - Si se borra un enlace duro, los otros enlaces siguen funcionando y el archivo no se elimina hasta que el último enlace sea eliminado.
   - No pueden enlazar directorios y no pueden enlazar archivos en diferentes sistemas de archivos.

2. **Enlaces simbólicos (symlinks o enlaces blandos)**:
   - Son archivos que contienen una ruta al archivo original.
   - Funcionan como accesos directos.
   - Si se borra el archivo original, el enlace simbólico queda "roto" (apunta a una ruta inexistente).
   - Pueden enlazar directorios y archivos en diferentes sistemas de archivos.
   - Son más flexibles pero menos robustos que los enlaces duros.

---

**Pregunta 3:**
Dispongo de un sistema de ficheros en el que cada i-nodo cuenta con 10 punteros directos y 3 indirectos de primer nivel. La tabla de i-nodos cuenta con 500 entradas, y dispongo de 2000 bloques de datos de 1 Kbyte cada uno. ¿Cabe la información relativa a los bitmaps de datos e i-nodos en un solo bloque? Justifica tu respuesta.

**Respuesta 3:**
Para determinar si los bitmaps de datos e i-nodos caben en un solo bloque de 1 KB, necesitamos calcular el tamaño requerido para cada bitmap:

- **Bitmap de i-nodos**:
  - Cada bit del bitmap representa un i-nodo.
  - Con 500 i-nodos, se necesitan 500 bits.
  - 500 bits / 8 bits por byte = 62.5 bytes.

- **Bitmap de bloques de datos**:
  - Cada bit del bitmap representa un bloque de datos.
  - Con 2000 bloques de datos, se necesitan 2000 bits.
  - 2000 bits / 8 bits por byte = 250 bytes.

Sumando ambos:
- 62.5 bytes (bitmap de i-nodos) + 250 bytes (bitmap de bloques de datos) = 312.5 bytes.

Como 312.5 bytes es menor que 1024 bytes (1 KB), sí, la información relativa a los bitmaps de datos e i-nodos cabe en un solo bloque de 1 KB.

---

**Pregunta 4:**
Si nuestras contraseñas se encuentran encriptadas en el fichero shadow, ¿por qué se utilizan Aging y Cracklib como mecanismos de refuerzo de contraseñas? ¿Cuál es el objetivo de cada mecanismo?

**Respuesta 4:**
- **Aging**:
  - **Objetivo**: Asegurar que las contraseñas se cambien regularmente.
  - **Función**: Implementa políticas de expiración de contraseñas. Obliga a los usuarios a cambiar sus contraseñas después de un período específico de tiempo. También puede imponer un período mínimo entre cambios de contraseña para evitar cambios demasiado frecuentes que puedan comprometer la seguridad.

- **Cracklib**:
  - **Objetivo**: Evitar contraseñas débiles.
  - **Función**: Es una biblioteca que verifica la solidez de las contraseñas nuevas. Evalúa la complejidad de las contraseñas en función de varios criterios, como longitud, uso de caracteres especiales, números, y la no inclusión de palabras del diccionario. Esto ayuda a prevenir el uso de contraseñas fácilmente adivinables o comunes.

---

**Pregunta 5:**
El acceso físico a un computador supone un riesgo de seguridad. ¿Puedes describir las formas de obtener permisos de administración que se te ocurran durante el proceso de arranque?

**Respuesta 5:**
Durante el proceso de arranque, una persona con acceso físico a un computador puede obtener permisos de administración mediante varias técnicas, entre ellas:

1. **Acceso al menú de arranque (boot loader)**:
   - **Grub**: Si el menú de GRUB no está protegido con contraseña, se puede editar la configuración de arranque para iniciar en modo de rescate (single-user mode) o modificar los parámetros del kernel para obtener acceso de root.

2. **Modo de rescate (single-user mode)**:
   - Durante el arranque, se puede acceder al modo de rescate que proporciona acceso directo como usuario root sin necesidad de contraseña.

3. **Live CD/USB**:
   - Arrancar el sistema desde un medio externo (Live CD/USB) permite acceder al sistema de archivos del disco duro y modificar archivos de configuración, incluidas las contraseñas de los usuarios.

4. **Quitar el disco duro**:
   - Sacar el disco duro y conectarlo a otro sistema como secundario. Esto permite acceso completo a los datos del disco, incluyendo los archivos de configuración y contraseñas.

5. **Reset de la BIOS/UEFI**:
   - Acceder a la BIOS/UEFI para cambiar el orden de arranque o resetear configuraciones de seguridad que puedan impedir el acceso a los métodos anteriores.

---

**Pregunta 6:**
¿Dónde se encuentra el kernel cuando nuestra máquina está apagada? ¿Qué tipo de información se almacena en la memoria principal cuando nuestra máquina está apagada?

**Respuesta 6:**
- **Kernel**:
  - Cuando la máquina está apagada, el kernel se encuentra almacenado en el disco duro o en algún dispositivo de almacenamiento permanente. Generalmente, está en la partición del sistema (por ejemplo, en `/boot` en sistemas Linux).

- **Memoria principal (RAM)**:
  - Cuando la máquina está apagada, la memoria principal (RAM) no almacena ninguna información persistente, ya que es volátil y se borra al perder la alimentación eléctrica. Por lo tanto, no hay información en la RAM cuando la máquina está apagada.

---

**Pregunta 8:**
En un sistema con tres discos duros agrupados en un RAID de nivel 5, cuando un disco falla, ¿qué tipo y cantidad de operaciones tenemos que llevar a cabo para leer los datos que se encontraban en el disco dañado? ¿Afectará esto al rendimiento?

**Respuesta 8:**
- **Operaciones necesarias**:
  - RAID 5 utiliza paridad distribuida para tolerancia a fallos. Cuando un disco falla, los datos que estaban en el disco dañado se pueden reconstruir usando la información de los bloques de datos y de paridad en los discos restantes.
  - Para leer un bloque de datos perdido, el sistema debe leer los datos de los bloques correspondientes de los discos restantes y el bloque de paridad. Luego, usa una operación XOR para reconstruir el bloque perdido.

- **Impacto en el rendimiento**:
  - Leer datos de un disco fallido en RAID 5 implica operaciones adicionales de lectura y cálculos de paridad, lo que afecta negativamente al rendimiento.
  - El sistema debe realizar múltiples operaciones de E/S y procesamiento para cada solicitud de datos que involucra el disco fallido, lo que puede resultar en una disminución significativa del rendimiento hasta que el disco sea reemplazado y la matriz RAID se reconstruya completamente.

---

**Pregunta 9:**
En teoría hemos visto dos mecanismos, Affinity e Isolation, para "manipular" el trabajo del scheduler en la asignación de procesos. Describe en qué consiste cada uno.

**Respuesta 9:**
- **Affinity (afinidad)**:
  - **Objetivo**: Mejorar la eficiencia de la caché de la CPU.
  - **Función**: La afinidad se refiere a la vinculación de procesos o hilos a uno o varios núcleos específicos de la CPU. Esto ayuda a mejorar la eficiencia al mantener un proceso en el mismo núcleo donde ha sido ejecutado anteriormente, aprovechando la caché de la CPU y reduciendo la sobrecarga de mover procesos entre núcleos.

- **Isolation (aislamiento)**:
  - **Objetivo**: Asegurar que ciertos procesos no compartan recursos de la CPU con otros.
  - **Función**: El aislamiento asigna uno o más núcleos de CPU exclusivamente a ciertos procesos o grupos de procesos, evitando que otros procesos utilicen esos núcleos. Esto es útil para garantizar un rendimiento predecible y evitar la interferencia de otros procesos, especialmente en sistemas donde se ejecutan aplicaciones con requisitos de tiempo real o de alta prioridad.

---

**Pregunta 10:**
¿Qué son y cómo se relacionan los siguientes componentes del SO de Linux: system.journal, journalctl, systemd-journald, /etc/systemd/journald.conf, cron, ssh y

 kernel?

**Respuesta 10:**
- **system.journal**:
  - `system.journal` es uno de los archivos binarios donde `systemd-journald` almacena los logs del sistema. Estos archivos están ubicados en `/var/log/journal/` o `/run/log/journal/` y contienen registros de eventos del sistema, aplicaciones y servicios.

- **journalctl**:
  - `journalctl` es una herramienta de línea de comandos utilizada para ver y analizar los registros almacenados por `systemd-journald`. Permite a los usuarios buscar y filtrar logs de manera eficiente. Con `journalctl`, puedes acceder a los registros del sistema y los servicios, ver logs específicos de una unidad o servicio, y aplicar filtros basados en fechas, niveles de registro, etc.

- **systemd-journald**:
  - `systemd-journald` es el servicio responsable de recopilar, almacenar y gestionar los registros del sistema y de los servicios en un sistema Linux que utiliza `systemd`. Este demonio captura información de log desde diversas fuentes, incluyendo el kernel, servicios del sistema, y aplicaciones, y almacena esta información en formato binario en archivos de journal.

- **/etc/systemd/journald.conf**:
  - Este archivo de configuración controla el comportamiento de `systemd-journald`. Aquí se pueden establecer parámetros como el tamaño máximo del journal, la ubicación de los archivos de log, la compresión y la retención de logs, entre otros.

- **cron, ssh y kernel**:
  - **cron**: Es un servicio que ejecuta tareas programadas en intervalos regulares. Los registros de cron (ejecución de tareas, errores, etc.) son capturados por `systemd-journald` y se pueden visualizar con `journalctl`.
  - **ssh**: El servicio SSH (Secure Shell) permite acceder de manera segura a un sistema remoto. Los eventos y errores de SSH se registran y son gestionados por `systemd-journald`. Pueden incluir intentos de conexión, autenticaciones exitosas y fallidas, etc.
  - **kernel**: El kernel de Linux genera una variedad de mensajes de log relacionados con el sistema operativo y el hardware. Estos mensajes incluyen información sobre dispositivos, errores, advertencias y otros eventos del sistema. `systemd-journald` captura estos mensajes y los hace accesibles mediante `journalctl`.

- **Relación entre estos componentes**:
  1. **Generación de logs**: Servicios y componentes como cron, ssh y el kernel generan eventos y mensajes de log.
  2. **Captura y almacenamiento de logs**: `systemd-journald` recopila estos logs y los almacena en archivos binarios, como `system.journal`.
  3. **Configuración**: El comportamiento de `systemd-journald` se puede ajustar mediante el archivo de configuración `/etc/systemd/journald.conf`.
  4. **Visualización y análisis**: `journalctl` se utiliza para acceder, visualizar y analizar los registros almacenados por `systemd-journald`.

En resumen, estos componentes trabajan juntos para proporcionar un sistema robusto de logging y análisis en Linux, facilitando la administración y el diagnóstico del sistema y sus servicios.

---
