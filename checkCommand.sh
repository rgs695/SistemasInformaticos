#!/bin/bash
# Script que toma una palabra y dice si es un comando del usuario o no

# La expresión &> /dev/null en un script de shell redirige tanto la salida estándar (stdout) como la salida de error estándar (stderr) a /dev/null.
# /dev/null es un archivo especial en sistemas Unix y Linux que descarta toda la información escrita en él.
# Por lo tanto, cuando se usa &> /dev/null en un comando, tanto la salida normal del comando como cualquier error que produzca el comando se descartan, 
# es decir, no se muestran en la terminal.
# Por ejemplo, en el siguiente comando:
# ls non_existent_directory 
# normalmente produciría un error porque el directorio no existe. Pero como la salida de error se redirige a /dev/null, no se muestra ningún mensaje de 
# error en la terminal.

# &>: Este operador redirige tanto stdout (file descriptor 1) como stderr (file descriptor 2) al archivo especificado. Por ejemplo, command &> file redirige 
# tanto la salida estándar como la salida de error del comando a file.

# 2>&1: Este operador redirige stderr (file descriptor 2) a stdout (file descriptor 1). Es útil cuando quieres capturar tanto la salida estándar como la 
# salida de error en el mismo lugar. Por ejemplo, command > file 2>&1 redirige tanto la salida estándar como la salida de error del comando a file.

if type $1 &> /dev/null 2>&1; then
    echo "El comando $1 es un comando del usuario"
else
    echo "El comando $1 no es un comando del usuario"
fi
