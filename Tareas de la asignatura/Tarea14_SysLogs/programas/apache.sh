#!/bin/bash
#........................................................
# Programa: Bitacora.sh
# Fecha: 26/10/2018
# Autor: Jorge Luis Jácome Domínguez
# Descripción: Script que leer y analizar un serv del sistema
#			   Muestra los intentos de acceso fallidos, con fecha
#			   y el origen del intento de acceso
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

# Obtener cadena información sobre errores en apache
strLogDat1=$(cat /var/log/apache2/error.log | grep "auth")
strLogDat2=$(cat /var/log/apache2/error.log.1 | grep "auth")

# Variables auxiliares
strValLines=""
strValSections=""
strValPalabras=""
strValPalabra=""
strValCads=""
strVal=""
strValAux=""
strValAuxs=""
strValApy=""
strValApys=""
# 0 = Fecha
# 1 = Tipo de error
# 2 = Proceso
# 3 = Cliente que accede y error
indice=0
indiceX=0
indiceY=0
indiceZ=0
# Resultados
vAryFechas=("");
vAryUsers=("");
vAryIPs=("");

# Se asigna separador de saldo de linea
IFS="
"
# Fecha // [Fri Oct 26 13:21:34.137424 2018] [client ::1:42062] AH01617: user sora: authentication failure for "/": Password Mismatch
for strValLines in $strLogDat1; do
IFS="]"
indice=0
	for strValSections in $strValLines; do
		# Fecha // [Fri Oct 26 13:21:34.137424 2018
		if [ $indice -eq 0 ]; then
			IFS="["
			indiceX=0
			for strValCads in $strValSections; do
					if [ $indiceX -eq 1 ]; then
						IFS=" "
						indiceY=0
						strValPalabras=""
						for strValPalabra in $strValCads; do
							if [ $indiceY -eq 3 ]; then
								IFS="."
								indiceZ=0
								strValAux=""
								for strValCads in $strValPalabra; do
									if [ $indiceZ -eq 0 ]; then
										strValAux=$strValCads
									fi
									let "indiceZ += 1"
									IFS="."
								done
								if [ ! "$strValPalabras" ] || [ -z "$strValPalabras" ]; then
									strValPalabras=$strValAux
								else
									strValPalabras=$strValPalabras"|"$strValAux
								fi
							else
								if [ ! "$strValPalabras" ] || [ -z "$strValPalabras" ]; then
									strValPalabras=$strValPalabra
								else
									strValPalabras=$strValPalabras"|"$strValPalabra
								fi
							fi
							let "indiceY += 1"
							IFS=" "
						done
						if [ ! "$strValPalabras" ] || [ -z "$strValPalabras" ]; then
							vAryFechas=("${vAryFechas[@]}" " ")
						else
							vAryFechas=("${vAryFechas[@]}" $strValPalabras)
						fi
					fi
				IFS="["
				let "indiceX += 1"
			done
			IFS="]"
		# Cliente
		# [client ::1:42062
		elif [ $indice -eq 3 ]; then
			IFS="["
			indiceX=0
			for strValCads in $strValSections; do
				if [ $indiceX -eq 1 ]; then
					IFS=" "
					strValPalabras=""
					for strValPalabra in $strValCads; do
						IFS="."
						strValAuxs=""
						strValAuxs=($strValPalabra)
						if [ ${#strValAuxs[@]} -gt 3 ]; then
							strValAuxs=""
							indiceY=0
							IFS="."
							for strValAux in $strValPalabra; do
								if [ $indiceY -lt 3 ]; then
									if [ ! "$strValAuxs" ] || [ -z "$strValAuxs" ]; then
										strValAuxs=$strValAux
									else
										strValAuxs=$strValAuxs"."$strValAux
									fi
								elif [ $indiceY -lt 4 ]; then
									IFS=":"
									indiceZ=0
									strValApys=""
									for strValApy in $strValAux; do
										if [ $indiceZ -eq 0 ]; then
											strValApys=$strValApy
										fi
										let "indiceZ += 1"
										IFS=":"
									done
									strValAuxs=$strValAuxs"."$strValApys
								fi
								let "indiceY += 1"
								IFS="."
							done
							strValPalabras=$strValAuxs
						else
							strValAuxs=""
							strValPalabras=$strValAuxs
						fi
						IFS=" "
					done
					if [ ! "$strValPalabras" ] || [ -z "$strValPalabras" ]; then
						vAryIPs=("${vAryIPs[@]}" " ")
					else
						vAryIPs=("${vAryIPs[@]}" $strValPalabras)
					fi
				fi
				IFS="["
				let "indiceX += 1"
			done
			IFS="]"
		# Cliente - Error
		# AH01617: user sora: authentication failure for "/": Password Mismatch
		elif [ $indice -eq 4 ]; then
			IFS=":"
			indiceX=0
			strValPalabras=""
			for strValCads in $strValSections; do
				if [ $indiceX -gt 0 ]; then
					if [ $indiceX -eq 1 ]; then
						IFS=" "
						indiceY=0
						strValAuxs=""
						for strValAux in $strValCads; do
							if [ $indiceY -eq 0 ]; then
								strValAuxs=$strValAux
							else
								strValAuxs=$strValAuxs" "$strValAux
							fi
							IFS=" "
							let "indiceY += 1"
						done
						strValPalabras=$strValAuxs;
					else
						strValPalabras=$strValPalabras"|"$strValCads;
					fi
				fi
				IFS=":"
				let "indiceX += 1"
			done
			if [ ! "$strValPalabras" ] || [ -z "$strValPalabras" ]; then
				vAryUsers=("${vAryUsers[@]}" " ")
			else
				vAryUsers=("${vAryUsers[@]}" $strValPalabras)
			fi
			IFS="]"
		fi
		let "indice += 1"
		IFS="]"
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
		IFS="|"
		strVal=""
		indiceX=0
		echo "Event"
		for strValCads in ${vAryUsers[$indice]}; do
			if [ $indiceX -eq 0 ]; then
				strVal=$strValCads
			else
				if [ ! "$strVal" ] || [ -z "$strVal" ]; then
					strVal=$strValCads
				else
					strVal=$strVal", "$strValCads
				fi
			fi
			IFS="|"
			let "indiceX += 1"
		done
		echo $strVal""
		echo "Date:	"${vAryFechas[$indice]}
		echo "From:	"${vAryIPs[$indice]}

		echo "-----------------------------------------"
	fi
	let "indice += 1"
done

# Terminar programa
exit 0