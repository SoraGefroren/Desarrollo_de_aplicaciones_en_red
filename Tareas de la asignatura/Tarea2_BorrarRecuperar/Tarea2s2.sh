#!/bin/bash
#........................................................
# Programa: Tarea2s2.sh
# Fecha: 25/08/2018
# Autor: Jorge Luis Jácome Domínguez
# Descripción: Eliminar archivo.
#........................................................

if [ $# -lt 1 ] || [ -z $1 ]; then
	echo "Se requiere el nombre del archivo a eliminar"
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

valOpc="S"

read -r -p "¿Estar seguro de eliminar el archivo indicado? (S/N): " valOpc
if [ $valOpc != "S" ] && [ $valOpc != "s" ]; then
	exit 0
fi

archObjetivo=$1

if [ ! -f $archObjetivo ]; then
	echo "El archivo que intentas eliminar no existe"
	exit 1
fi

mv $archObjetivo $rutaPapelera &>/dev/null
valError=$?

if [ $valError -gt 0 ]; then
	echo "No se puede completar la acción"
	exit 1
fi

exit 0