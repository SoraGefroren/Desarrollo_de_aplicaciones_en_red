#!/bin/bash
#........................................................
# Programa: Bitacora.sh
# Fecha: 26/10/2018
# Autor: Jorge Luis Jácome Domínguez
# Descripción: Script que leer y analizar una bitacora del sistema
#			   Muestra que usuario ejecuto que comando como root
#			   y en que fecha llevo acabo dicha acción
#........................................................

# Limpiar pantalla
# clear;

# Validar usuario
if [ "$(whoami)" != "root" ] ; then
	echo "* No cuentas con los permisos necesarios ejecutar este script"
	exit 1
fi

# Parametros
if [ $# -lt 1 ] || [ -z $1 ]; then
	numRegs=0
else
	numRegs=$1
fi

# ==================================================
# ==================================================
# ==================================================
# Obtener cadena información sobre la autentificación
strLogBita1=$( cat /var/log/auth.log | grep "COMMAND=" | grep "USER=root" | grep "TTY=pts/" )
strLogBita2=$( cat /var/log/auth.log.1 | grep "COMMAND=" | grep "USER=root" | grep "TTY=pts/" )

# Variables auxiliares
strValLines=""
strValSections=""
strValPalabras=""
strValPalabra=""
strVal=""
#
indice=0
indiceX=0
indiceY=0
# Resultados
vAryFechas=("");
vAryUsers=("");
vAryCmds=("");

# Se asigna separador de saldo de linea
IFS="
"
# Oct 26 00:34:36 VPCEA37FL sudo:     sora : TTY=pts/0 ; PWD=/home/sora ; USER=root ; COMMAND=/usr/bin/subl /etc/rsyslog.conf
for strValLines in $strLogBita1; do
IFS=":"
indice=0
	for strValSections in $strValLines; do
		# Oct 26 00:34:36 VPCEA37FL sudo: 
		if [ $indice -eq 0 ] || [ $indice -eq 1 ] || [ $indice -eq 2 ]; then
			# Oct 26 00
			if [ $indice -eq 0 ]; then
				IFS=":"
				strVal=$strValSections
			# 34
			elif [ $indice -eq 1 ]; then
				IFS=":"
				if [ ! "$strVal" ] || [ -z "$strVal" ]; then
					strVal=$strValSections
				else
					strVal=$strVal":"$strValSections
				fi
			# 36 VPCEA37FL sudo:
			elif [ $indice -eq 2 ]; then
				IFS=" "
				indiceX=0;
				for strValPalabras in $strValSections; do
					if [ $indiceX -eq 0 ]; then
						if [ ! "$strVal" ] || [ -z "$strVal" ]; then
							strVal=$strValPalabras
						else
							strVal=$strVal":"$strValPalabras
						fi
					fi
					let "indiceX += 1"
					IFS=" "
				done
				if [ ! "$strVal" ] || [ -z "$strVal" ]; then
					vAryFechas=("${vAryFechas[@]}" " ")
				else
					vAryFechas=("${vAryFechas[@]}" "$strVal")
				fi
			fi
		#      sora 
		elif [ $indice -eq 3 ]; then
			IFS=" "
			strVal=""
			indiceX=0;
			for strValPalabras in $strValSections; do
				if [ ! "$strVal" ] || [ -z "$strVal" ]; then
					strVal=$strValPalabras
				else
					strVal=$strVal" "$strValPalabras
				fi
				let "indiceX += 1"
				IFS=" "
			done
			if [ ! "$strVal" ] || [ -z "$strVal" ]; then
				vAryUsers=("${vAryUsers[@]}" " ")
			else
				vAryUsers=("${vAryUsers[@]}" "$strVal")
			fi
		#  TTY=pts/0 ; PWD=/home/sora ; USER=root ; COMMAND=/usr/bin/subl /etc/rsyslog.conf
		elif [ $indice -eq 4 ]; then
			IFS=";"
			strVal=""
			indiceX=0;
			for strValPalabras in $strValSections; do
				if [ $indiceX -eq 3 ]; then
					IFS="="
					indiceY=0;
					for strValPalabra in $strValPalabras; do
						if [ $indiceY -eq 1 ]; then
							strVal=$strValPalabra
						fi
						IFS="="
						let "indiceY += 1"
					done
				fi
				IFS=";"
				let "indiceX += 1"
			done
			if [ ! "$strVal" ] || [ -z "$strVal" ]; then
				vAryCmds=("${vAryCmds[@]}" " ")
			else
				vAryCmds=("${vAryCmds[@]}" "$strVal")
			fi
		fi
		IFS=":"
		let "indice += 1"
	done
IFS="
"
done

# Exponer resultados
echo "-----------------------------------------"
echo "Results"
echo "-----------------------------------------"
IFS=""
indice=0
numTotalReg=${#vAryUsers[@]}
if [ "$numRegs" ]; then
	if [ $numRegs -gt 0 ] && [ $numRegs -lt ${#vAryUsers[@]} ]; then
		let "indice = numTotalReg - numRegs"
	fi
fi
for strValLines in "${vAryUsers[@]}"; do
	if [ $indice -gt 0 ] && [ $indice -lt ${#vAryUsers[@]} ]; then
		echo "User:	"${vAryUsers[$indice]}
		echo "Date:	"${vAryFechas[$indice]}
		echo "From:	"${vAryCmds[$indice]}
		echo "-----------------------------------------"
	fi
	let "indice += 1"
done

# Terminar programa
exit 0