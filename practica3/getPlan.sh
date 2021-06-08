#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "getPlan - Un wrapper sencillo de ff"
    echo "----------------------------"
    echo "Este programa necesita de 1 parámetro."
    echo "Uso: ./getPlan <n>"
    echo "<n>   El nombre del ejercicio"
    echo "      El archivo de dominio debe llamarse 'dominio<n>.pddl' y el de problema 'problema<n>.pddl'"
    echo "      Estos archivos deben estar en un subdirectorio llamado ejer<n> relativo al directorio donde se llama getPlan"
    exit
fi

num=$1

domain="ejer"$1"/dominio"$1".pddl"
problem="ejer"$1"/problema"$1".pddl"


if [ -f "$domain" -a -f "$problem" ]; then

./ff -o $domain -f $problem -O -g 1 -h 1

else

    if [ ! -f "$domain" ]; then
        echo ">ERROR: El archivo '$domain' no existe"
    fi

    if [ ! -f "$problem" ]; then
        echo ">ERROR: El archivo  '$problem' no existe."
    fi

fi
