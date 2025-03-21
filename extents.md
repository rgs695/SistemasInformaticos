# Esquema de Sistemas de Archivos EXT (Ext1, Ext2, Ext3, Ext4)

## 1. **Ext1** (Primera versión)
- **Descripción**: 
  - Fue la **primera versión** del sistema de archivos EXT.
  - Utiliza **bloques individuales** para la asignación de espacio de los archivos.
  - Cada bloque puede contener una parte del archivo, y se utilizan **punteros** para acceder a estos bloques.
- **Características**:
  - Sin soporte para **journaling** (sin recuperación en caso de fallo).
  - Estructura básica con **bloques directos** e indirectos.
  - A pesar de su simplicidad, **no es ampliamente utilizado hoy en día** debido a su falta de características avanzadas y optimizaciones.

---

## 2. **Ext2** (Segunda versión)
- **Descripción**: 
  - Basado en Ext1, **Ext2** resuelve varios problemas, como la **fragmentación**.
  - **Mejora la eficiencia** de la organización de los datos en disco, mejorando la **localidad** de los bloques de datos y metadatos, lo que reduce la fragmentación.
  - **Sin journaling** (como Ext1).
- **Características**:
  - Introducción de la **mejora de la localidad** de los i-nodos y sus datos asociados, lo que reduce la fragmentación interna.
  - El sistema de archivos sigue siendo eficiente, pero la falta de journaling limita su fiabilidad en caso de fallos.
  - Es utilizado en sistemas donde la fiabilidad no es crítica, como en **dispositivos de almacenamiento** o sistemas embebidos.

---

## 3. **Ext3** (Tercera versión)
- **Descripción**: 
  - Basado en Ext2, **Ext3** introduce el **journaling**, lo que mejora la **fiabilidad** y permite una **recuperación de datos más rápida** en caso de fallos.
  - El **journaling** consiste en registrar los cambios en el sistema de archivos antes de que se realicen en el disco, lo que previene la corrupción de datos.
- **Características**:
  - **Journaling**: Se agrega un "diario" de transacciones para asegurar que el sistema de archivos pueda ser recuperado rápidamente después de un apagón o fallo inesperado.
  - **Compatibilidad hacia atrás**: Ext3 es totalmente compatible con Ext2. Se puede convertir fácilmente de Ext2 a Ext3 sin necesidad de reformatear.
  - Menos eficiente que **Ext4** debido a la falta de mejoras adicionales como la asignación de bloques continuos.

---

## 4. **Ext4** (Cuarta versión)
- **Descripción**: 
  - **Ext4** es la versión más avanzada de los sistemas de archivos Ext.
  - Introduce los **extents**, que son rangos continuos de bloques para almacenar archivos. Esto mejora la **eficiencia** de la asignación de espacio y reduce la **fragmentación** externa.
  - **Mayor rendimiento** en comparación con Ext3, especialmente con archivos grandes.
- **Características**:
  - **Extents**: A diferencia de las versiones anteriores, **Ext4** utiliza los **extents**, lo que permite almacenar un archivo en **rangos continuos de bloques**. Esto mejora la **asignación de espacio** y reduce la fragmentación.
  - **Mayor capacidad**: Soporta volúmenes más grandes (hasta 1 exabyte) y archivos más grandes (hasta 16 terabytes).
  - **Journaling mejorado**: Ext4 mantiene el journaling de Ext3, pero con mejoras en el rendimiento y la gestión de archivos grandes.
  - **Delayed allocation**: Una técnica para mejorar el rendimiento de la asignación de bloques, retrasando la asignación hasta que sea necesario.
  - **Mejor manejo de la fragmentación**: El uso de los extents mejora el rendimiento en la **lectura y escritura** de archivos grandes al reducir la fragmentación.
  - Soporta **crípticos de disco** como la **compresión** y **cifrado** de archivos.

---

## Comparación rápida entre versiones:

| Característica              | **Ext1**                   | **Ext2**                    | **Ext3**                    | **Ext4**                    |
|-----------------------------|----------------------------|-----------------------------|-----------------------------|-----------------------------|
| **Bloques**                  | Bloques individuales       | Mejor localidad de bloques  | Bloques con journaling       | Uso de extents (rangos continuos de bloques) |
| **Journaling**               | No                         | No                          | Sí (Journaling básico)       | Sí (Journaling avanzado)    |
| **Recuperación tras fallo** | No                         | No                          | Sí                          | Sí                          |
| **Rendimiento**              | Bajo                       | Bueno, pero con fragmentación | Mejor con journaling         | Mejor rendimiento general, especialmente con archivos grandes |
| **Capacidad de archivo**     | Limitado                   | 2 TiB                       | 2 TiB                       | 16 TiB                      |
| **Capacidad de volumen**     | 2 TiB                      | 8 TiB                       | 8 TiB                       | 1 Exabyte                   |
| **Fragmentación**            | Alta                       | Menor que Ext1               | Menor que Ext2               | Mínima (debido a los extents) |

---

## Conclusión:
- **Ext1**: Primera versión, poco usada hoy debido a sus limitaciones.
- **Ext2**: Mejoró la fragmentación pero carece de **journaling**.
- **Ext3**: Introdujo el **journaling**, mejorando la fiabilidad.
- **Ext4**: La versión más moderna, con **extents**, **mejor rendimiento** y capacidad para manejar grandes volúmenes y archivos.


