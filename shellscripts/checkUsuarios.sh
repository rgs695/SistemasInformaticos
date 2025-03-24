#!/bin/bash

# En el $HOME del usuario root el administrador deja un
# fichero de nombre usuarios.txt que tiene información de los usuarios que debe haber en el
# sistema con el siguiente formato por línea:
# GECOS;USER NAME;UID;GID;SHELL;PASSWORD
# 1. Asegúrate de que durante el proceso de arranque de la máquina, el sistema comprueba
# que los usuarios que se encuentran en ese documento existen en el sistema. Si no
# existen crear un fichero error.txt en el directorio $HOME del administrador, con el texto
# “<fecha y hora actual> <usuario> no existe”.
# 2. Adicionalmente, cuando un usuario no exista, debe crearse con los datos del fichero (los
# datos que no se indiquen se pueden usar valores por defecto).

# Asignamos valores
file="/root/usuarios.txt"  # Asegúrate de que no haya espacios antes o después del signo '='
date=$(date)

# Leer cada línea del archivo
while IFS= read -r line; do
  # Extraer el nombre de usuario (segunda columna, asumiendo que está separada por ';')
  name=$(echo "$line" | cut -d';' -f2)

  # Buscar el nombre en /etc/passwd
  var=$(grep "^$name:" /etc/passwd)  # Usar un patrón para que coincida con el nombre exacto de usuario

  # Verificar si la variable está vacía o no
  if [[ -z "$var" ]]; then
    echo "$date; $name no existe" >> /root/error.txt

    # extraer campos
    gecos=$(echo "$line" | cut -d';' -f1)
    uid=$(echo "$line" | cut -d';' -f3)
    gid=$(echo "$line" | cut -d';' -f4)
    shell=$(echo "$line" | cut -d';' -f5)
    passwd=$(echo "$line" | cut -d';' -f6)

    # Crear usuarios
    sudo useradd -m -u "$uid" -g "$gid" -s "$shell" -c "$gecos" -p "$passwd" "$name"
    # echo "$gecos $uid $gid $shell $passwd"

  else
    echo "Usuario $name encontrado"
  fi
done < "$file"
