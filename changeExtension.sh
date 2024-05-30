#!/bin/bash
# cambia las terminaciones de los archivos en un directorio

cd trial
for file in *.txt
do
    mv $file ${file%.txt}.t
done