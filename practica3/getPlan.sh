#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "getPlan - A quick ff wrapper"
    echo "----------------------------"
    echo "This program needs 1 parameter."
    echo "Usage: ./getPlan <number>"
    echo "<number>      The exercise number"
    echo "              The problem and domains name must 'dominio<number>.pddl' and 'promblema<number>.pddl'"
    exit
fi

num=$1

domain="ejer"$1"/dominio"$1".pddl"
problem="ejer"$1"/problema"$1".pddl"


if [ -f "$domain" -a -f "$problem" ]; then

./ff -o $domain -f $problem -O -g 1 -h 1

else

    if [ ! -f "$domain" ]; then
        echo ">ERROR: File '$domain' does not exist."
    fi

    if [ ! -f "$problem" ]; then
        echo ">ERROR: File '$problem' does not exist."
    fi

fi
