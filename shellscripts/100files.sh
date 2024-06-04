#!/bin/bash
# crea 100 archivos en un directorio llamado trial
# Crear un directorio y movernos a el
if [ -d trial ]; then
    rm -r trial
fi

mkdir trial
cd trial

for i in {1..100}
do
    touch file$i.txt
    #escribir una linea de man ls en cada archivo
    man ls | col -b | sed -n "${i}p" > file$i.txt
done