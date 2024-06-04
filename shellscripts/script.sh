#!/bin/bash

# Esto es un comentario. Los comentarios en Bash comienzan con un '#'.

# Imprimir texto en la consola
echo "Hola, mundo!"

# Variables
NOMBRE="GitHub Copilot"
echo "Hola, $NOMBRE!"

# Leer entrada del usuario
echo "¿Cómo te llamas?"
read USUARIO
echo "Hola, $USUARIO!"

# Condicional if
if [ "$USUARIO" = "$NOMBRE" ]; then
    echo "¡Tienes el mismo nombre que yo!"
else
    echo "¡Es un placer conocerte, $USUARIO!"
fi

# Bucle for
echo "Contando hasta 5:"
for NUMERO in 1 2 3 4 5; do
    echo $NUMERO
done

# Bucle while
echo "Contando hasta 5 con un bucle while:"
NUMERO=1
while [ $NUMERO -le 5 ]; do
    echo $NUMERO
    NUMERO=$((NUMERO + 1))
done

# Funciones
saludo() {
    echo "¡Hola, $1!"
}

saludo "GitHub Copilot"
