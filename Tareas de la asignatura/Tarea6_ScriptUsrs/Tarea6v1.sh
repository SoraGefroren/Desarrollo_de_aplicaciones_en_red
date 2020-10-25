#!/bin/bash
#........................................................
# Programa: CreaUsuario_v1.sh
# Fecha: 08/09/2018
# Autor: Jorge Luis Jácome Domínguez
# Descripción: Script para registrar un usuario.
#........................................................
# Validar usuario
if [ "$(whoami)" != "root" ] ; then
	echo "* No cuentas con los permisos necesarios ejecutar este script"
	exit 1
fi
# Validar comando
if ! test -x "$( command -v useradd )"; then
	echo "* No cuentas con los permisos necesarios para agregar usuarios"
	exit 1
fi
# Validar comando
if ! test -x "$( command -v passwd )"; then
	echo "* No cuentas con los permisos necesarios para crear usuarios"
	exit 1
fi
# Limpiar pantalla
clear
# Presentación
echo "Creador de usuarios"
echo "Por favor, siga las instrucciones"
echo "---------------------------------"
# Declaración de variables principales
nombrePerfil=""
nombreUsr=""
passUsr=""
pComfirm=""
grupoUsr=""
rutaDirUsr=""
strEval=""
ssEvals=""
nSSEvls=0
# Declaración de variables de apoyo
valOpc=""
# Obtener nombre del usuario
IFS=' '
while [ "$valOpc" != "S" ]; do
	read -r -p "Nombre del usuario: " nombrePerfil
	if [ ! "$nombrePerfil" ] || [ -z "$nombrePerfil" ]; then
		nombrePerfil=""
		continue
	fi
	ssEvals=($nombrePerfil)
	nSSEvls=${#ssEvals[@]}
	if [ $nSSEvls -gt 0 ]; then
		for strEval in $nombrePerfil; do
	      	if [[ ! "$strEval" =~ ^[[:alnum:]]+$ ]]; then
				echo "* El nombre de usuario tiene caracteres ilegales"
				valOpc="X"
				break
			fi
	    done
	    if [ "$valOpc" = "X" ]; then
	    	nombrePerfil=""
	    	valOpc=""
	    	continue
		fi
	else
		if [[ ! "$nombrePerfil" =~ ^[[:alnum:]]+$ ]]; then
			echo "* El nombre de usuario tiene caracteres ilegales"
			nombrePerfil=""
			continue
		fi
	fi
	valOpc="S"
done
# Obtener usuario
while [ ! "$nombreUsr" ] || [ -z "$nombreUsr" ]; do
	read -r -p "Ingrese el usuario: " nombreUsr
	if [ ! "$nombreUsr" ] || [ -z "$nombreUsr" ]; then
		nombreUsr=""
		continue
	fi
	if [[ ! "$nombreUsr" =~ ^[[:alnum:]]+$ ]]; then		
		echo "* El usuario contiene caracteres ilegales"
		nombreUsr=""
		continue
	fi
	if [[ ! "$nombreUsr" =~ ^[a-z]+ ]]; then		
		echo "* El usuario debe empezar con una letra"
		nombreUsr=""
		continue
	fi
	if [[ "$nombreUsr" =~ [A-Z]+ ]]; then		
		echo "* El usuario no puede tener letras mayusculas"
		nombreUsr=""
		continue
	fi
	if id -u "$nombreUsr" >/dev/null 2>&1; then
		echo "Este usuario ya existe"
		nombreUsr=""
		continue
	fi
done
# nombreUsr="${nombreUsr,,}"
# Obtener contraseña
while [ ! "$passUsr" ] || [ -z "$passUsr" ]; do
	read -r -sp "Ingrese una contraseña: " passUsr
	if [ "$passUsr" ] && [ -n "$passUsr" ]; then
		if [ ${#passUsr} -lt 8 ]; then
			echo ""
			echo "* La contraseña debe tener al menos 8 caracteres"
			passUsr=""
			continue
		fi
		if [[ ! "$passUsr" =~ [a-z]+ ]]; then
			echo ""
			echo "* La contraseña debe tener al menos una letra minuscula"
			passUsr=""
			continue
		fi
		if [[ ! "$passUsr" =~ [A-Z]+ ]]; then
			echo ""
			echo "* La contraseña debe tener al menos una letra mayuscula"
			passUsr=""
			continue
		fi
		if [[ ! "$passUsr" =~ [0-9]+ ]]; then
			echo ""
			echo "* La contraseña debe tener al menos un número"
			passUsr=""
			continue
		fi
		echo ""
		pComfirm=""
		read -r -sp "Confirmar contraseña: " pComfirm

		if [ "$passUsr" != "$pComfirm" ]; then
			echo ""
			echo "* Las contraseñas no coinciden"
			passUsr=""
			continue
		fi
	fi
done
# Obtener grupo de pertenencia del usuario
echo ""
valOpc=""
while [ "$valOpc" != "S" ]; do
	read -r -p "Grupo de donde sera el usuario: " grupoUsr
	if [ ! "$grupoUsr" ] || [ -z "$grupoUsr" ]; then
		grupoUsr=""
		continue
	fi
	if [[ ! "$grupoUsr" =~ ^[[:alnum:]]+$ ]]; then		
		echo "* El grupo contiene caracteres ilegales"
		grupoUsr=""
		continue
	fi
	valOpc="S"
done
# Validar grupo de usuario
if ! grep -q "$grupoUsr" "/etc/group"; then
	if test -x "$( command -v groupadd )"; then
	 	groupadd "$grupoUsr"
 	else
 		echo "* No cuentas con los permisos necesarios para crear grupos de usuarios"
 		exit 1
 	fi
fi
# Obtener ruta del directorio HOME del usuario
IFS=/
while [ ! "$rutaDirUsr" ] || [ -z "$rutaDirUsr" ]; do
	read -r -p "Directorio del usuario (ruta absoluta): " rutaDirUsr
	if [ ! "$rutaDirUsr" ] || [ -z "$rutaDirUsr" ]; then
		rutaDirUsr=""
		continue
	fi
	if [[ ! "$rutaDirUsr" =~ ^/ ]] || [[ "$rutaDirUsr" =~ /$ ]]; then
		echo "* Ruta invalida"
		rutaDirUsr=""
		continue
	fi
	nSSEvls=0
	valOpc=""
	for strEval in $rutaDirUsr; do
		nSSEvls+=1
		if [ $nSSEvls -gt 1 ]; then
			if [ ! "$strEval" ] || [ -z "$strEval" ]; then
				echo "* Ruta no valida"
				valOpc="X"
				break
			fi
			if [[ ! "$strEval" =~ ^[[:alnum:]]+$ ]]; then
				echo "* La ruta tiene caracteres ilegales"
				valOpc="X"
				break
			fi
		else
			if [ ! "$strEval" ] || [ -z "$strEval" ]; then
				continue
			else
				echo "* Ruta no valida"
				valOpc="X"
				break
			fi
		fi
    done
    if [ "$valOpc" = "X" ]; then
    	rutaDirUsr=""
    	valOpc=""
    	continue
	fi
done
# Validar directorio HOME del usuario
if [ ! -d "$rutaDirUsr" ]; then
	if test -x "$( command -v mkdir )"; then
	 	nSSEvls=0
	 	ssEvals=""
		for strEval in $rutaDirUsr; do
			nSSEvls+=1
			if [ $nSSEvls -gt 1 ]; then
				ssEvals=$ssEvals"/"$strEval
				if [ ! -d "$ssEvals" ]; then
					mkdir "$ssEvals"
				fi
			else
				ssEvals="/"
			fi
	    done
 	else
 		echo "* No cuentas con los permisos necesarios para crear directorios"
 		exit 1
 	fi
fi
# Crear usuario
useradd -d "$rutaDirUsr" -m -k "/etc/skel" -s "/bin/bash" -c \'"$nombrePerfil"\' -g "$grupoUsr" "$nombreUsr" &>/dev/null
# Validar usuario creado
if id -u "$nombreUsr" >/dev/null 2>&1; then	
	# Asignar contraseña
	echo -e $passUsr"\n"$passUsr | passwd "$nombreUsr" &>/dev/null
	echo "Usuario creado"
else
	echo "No fue posible crear al usuario "\""$nombreUsr"\"
	exit 1
fi
# Terminar programa
exit 0