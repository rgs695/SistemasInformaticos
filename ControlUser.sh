#!/bin/bash

# EXAMEN JUNIO https://chatgpt.com/share/bef08e86-64a7-4d61-ad66-a355b69208bb
# Script que comprueba cada 5 minutos si hay usuarios conectados al sistema

while true; do
    current_date=$(date "+%Y-%m-%d %H:%M:%S")
    users=$(who | awk '{print $1}' | sort | uniq)
    
    for user in $users; do
        echo "$current_date: $user activo!!"
    done
    
    sleep 300  # Esperar 5 minutos (300 segundos) antes de la próxima comprobación
done
