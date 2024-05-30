#!/bin/bash
# Borra los archivos filex.t si la x es la suma de los parametros

# Importante, no dejar espacios antes y despues del igual
cd trial
sum=0
for num in $@
do
    sum=$((sum + num))
done

for file in file*.t
do
    number=$(echo $file | grep -o -E '[0-9]+') # obtiene el numero de fileN.t

    # si fileN.t N==sum borralo
    # ${file:4:2} obtiene el numero de fileN.t 4 es el char donde empieza y 2 es la longitud de chars que examina
    # No usamos ${file:4:2} porque hay numeros de 1 y 2 digitos, es mejor extraer N antes con grep
    # -eq es igual a == en bash

    if [ $number -eq $sum ]
    then
        rm $file
        echo "Borrado $file"
    fi
done
