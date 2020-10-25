#!/bin/bash
#........................................................
# Programa: Tarea2s3.sh
# Fecha: 25/08/2018
# Autor: Jorge Luis Jácome Domínguez
# Descripción: Recuperar archivo.
#........................................................

if [ $# -lt 1 ] || [ -z $1 ]; then
	echo "Se requiere el nombre del archivo a recuperar"
	exit 1
fi

rutaPapelera='/home/.experimental/basura'
rutaPBase='/home/.experimental'

valError=0
if [ ! -d $rutaPBase ]; then
	mkdir $rutaPBase &>/dev/null
	valError=$?
fi

if [ $valError -gt 0 ]; then
	echo "No tienes los permisos necesarios"
	exit 1
fi

if [ ! -d $rutaPapelera ]; then
	mkdir $rutaPapelera &>/dev/null
	valError=$?
fi

if [ $valError -gt 0 ]; then
	echo "No tienes los permisos necesarios"
	exit 1
fi

archObjetivo=$rutaPapelera"/"$1

if [ ! -f $archObjetivo ]; then
	echo "El archivo que intentas recuperar no existe"
	exit 1
fi

mv $archObjetivo . &>/dev/null
valError=$?

if [ $valError -gt 0 ]; then
	echo "No se puede completar la acción"
	exit 1
fi

exit 0