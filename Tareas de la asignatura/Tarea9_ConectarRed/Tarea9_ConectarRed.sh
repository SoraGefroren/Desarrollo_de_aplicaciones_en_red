#!/bin/bash
#........................................................
# Programa: ConectarRed.sh
# Fecha: 14/09/2018
# Autor: Jorge Luis Jácome Domínguez
# Descripción: Script para conectar una red
#........................................................
# Validar usuario
if [ "$(whoami)" != "root" ] ; then
	echo "* No cuentas con los permisos necesarios ejecutar este script"
	exit 1
fi
# Validar comando
if ! test -x "$( command -v ip )"; then
	echo "* No cuentas con los permisos necesarios"
	exit 1
fi
# Validar comando
if ! test -x "$( command -v dhclient )"; then
	echo "* No cuentas con los permisos necesarios"
	exit 1
fi
# Preguntar Suplica
if [ ! -n "$(which ifconfig)" ]; then
	echo "* No puedes ejecutar este script"
	exit 1
fi

#........................................................
# Limpiar pantalla
clear
# Presentación
echo "Conectar red"
echo "Por favor, siga las instrucciones"
echo "---------------------------------"
# Declaración de variables principales
puerto=""
tipoDeConexion=""

# Declaración de variables de apoyo
valOpc=""

#........................................................
# Seleccionar tipo conexión
while [ ! "$valOpc" ] || [ -z "$valOpc" ]; do
	read -r -p "Tipo de conexión (I:Inalámbrica/C:Cableada): " valOpc
	if [ ! "$valOpc" ] || [ -z "$valOpc" ]; then
		valOpc=""
		continue
	fi
	if [ "$valOpc" = "I" ] || [ "$valOpc" = "i" ]; then
    	break
	fi

	if [ "$valOpc" = "C" ] || [ "$valOpc" = "c" ]; then
    	break
	fi
	valOpc=""
done

# Definir tipo de conexión
if [ "$valOpc" = "I" ] || [ "$valOpc" = "i" ]; then
	tipoDeConexion="I"
else
	tipoDeConexion="C"
fi

#........................................................
# Declaración de variables de red
nomDeLaRed=""
passDeLaRed=""

# Por tipo de conexión
if [ "$tipoDeConexion" = "I" ]; then
	# Preguntar por nombre de la Red
	while [ ! "$nomDeLaRed" ] || [ -z "$nomDeLaRed" ]; do
		read -r -p "¿Cuál es el nombre de la red?: " nomDeLaRed
		if [ ! "$nomDeLaRed" ] || [ -z "$nomDeLaRed" ]; then
			nomDeLaRed=""
			continue
		fi
	done

	# Preguntar por contraseña de la Red
	read -r -sp "¿Cuál es la contraseña de la red?: " passDeLaRed
	echo ""
	if [ ! "$passDeLaRed" ] || [ -z "$passDeLaRed" ]; then
		nomDeLaRed=""
	fi
fi

#........................................................
# Declaración de variables de apoyo
rutaDePuerto=""

# Obtener puerto objetivo
while [ ! "$puerto" ] || [ -z "$puerto" ]; do
	read -r -p "Puerto de red: " puerto
	if [ ! "$puerto" ] || [ -z "$puerto" ]; then
		puerto=""
		continue
	fi
	if [[ ! "$puerto" =~ ^[[:alnum:]]+$ ]]; then
		echo "* El puerto ingresado es invalido"
		puerto=""
		continue
	fi
	rutaDePuerto="/sys/class/net/""$puerto"
	if [ ! -e "$rutaDePuerto" ]; then
		# El puerto no existe
		echo "* El puerto ingresado no existe"
		puerto=""
		continue
	fi
done

#........................................................
# Declaración de variables de red
ipEstatica=""
mascaraEstatica=""
puertaDeEnlace=""

# Usar ip estática?
valOpc=""
read -r -p "¿Desea usar una dirección IP estática? (S/N): " valOpc

# Si se usa IP estatica
if [ "$valOpc" = "S" ] || [ "$valOpc" = "s" ]; then
	# Obtener dirección ip
	while [ ! "$ipEstatica" ] || [ -z "$ipEstatica" ]; do
		read -r -p "Dirección IP estática: " ipEstatica
		if [ ! "$ipEstatica" ] || [ -z "$ipEstatica" ]; then
			ipEstatica=""
			continue
		fi
		if [[ ! "$ipEstatica" =~ ^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$ ]]; then
			echo "* La dirección IP no es valida"
			ipEstatica=""
			continue
		fi
	done
	# Obtener mascara para dirección ip
	while [ ! "$mascaraEstatica" ] || [ -z "$mascaraEstatica" ]; do
		read -r -p "Mascara de red: " mascaraEstatica
		if [ ! "$mascaraEstatica" ] || [ -z "$mascaraEstatica" ]; then
			mascaraEstatica=""
			continue
		fi
		if [[ ! "$mascaraEstatica" =~ ^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$ ]]; then
			echo "* La mascara no es valida"
			mascaraEstatica=""
			continue
		fi
	done
	# Obtener dirección ip
	while [ ! "$puertaDeEnlace" ] || [ -z "$puertaDeEnlace" ]; do
		read -r -p "Puerta de enlace: " puertaDeEnlace
		if [ ! "$puertaDeEnlace" ] || [ -z "$puertaDeEnlace" ]; then
			puertaDeEnlace=""
			continue
		fi
		if [[ ! "$puertaDeEnlace" =~ ^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$ ]]; then
			echo "* La puerta de enlace no es valida"
			puertaDeEnlace=""
			continue
		fi
	done
fi

#........................................................
# Notificación
# echo "Conectando..."
bienConStaticConf=""
# Por tipo de conexión
if [ "$tipoDeConexion" = "I" ]; then
	# Conexión inalambrica
	#........................................................
	# Preguntar Suplica
	if [ -n "$(which wpa_supplicant)" ] && [ -n "$(which wpa_passphrase)" ]; then
		# Desbloquear elementos
		if [ -n "$(which rfkill)" ]; then
			if test -x "$( command -v rfkill )"; then
				rfkill unblock all
			fi
		fi
		# Validar comando
		if ! test -x "$( command -v wpa_supplicant )"; then
			echo "* No cuentas con los permisos necesarios"
			exit 1
		fi
		# Validar comando
		if ! test -x "$( command -v wpa_passphrase )"; then
			echo "* No cuentas con los permisos necesarios"
			exit 1
		fi
		# Tirar puerto
		# ip link set dev "$puerto" down
		# Levantar puesto
		ip link set dev "$puerto" up
		# Comprobar
		if [ "$(ip a show $puerto up)" ]; then
			# Reiniciar archivo sulplica
			if [ -e "/etc/wpa_supplicant/wpa_supplicant_script.conf" ]; then
				rm -r /etc/wpa_supplicant/wpa_supplicant_script.conf
			fi
			# Construir archivo sulplica
			echo "" > /etc/wpa_supplicant/wpa_supplicant_script.conf
			echo $passDeLaRed | wpa_passphrase \""$nomDeLaRed"\" >> /etc/wpa_supplicant/wpa_supplicant_script.conf
			wpa_supplicant -B -i "$puerto" -c /etc/wpa_supplicant/wpa_supplicant_script.conf &>/dev/null
			# Mensaje
			echo "Conectando..."
			# Ajustes
			ip addr flush dev "$puerto" &>/dev/null
			# Si se tiene una IP estatica
			if [ ! "$ipEstatica" ] || [ -z "$ipEstatica" ]; then
				# Si esta activa
				dhclient -r "$puerto" &>/dev/null
				dhclient "$puerto"
			else
				# Asignar IP estatica
				ifconfig "$puerto" "$ipEstatica" netmask "$mascaraEstatica" &>/dev/null
				route add default gw "$puertaDeEnlace" "$puerto" &>/dev/null
				bienConStaticConf="S"
			fi
		else
			# No esta activa
			echo "* Error en la conexión"
			exit 1
		fi
	else
		echo "* Requieres de \"wpasupplicant\" para conectarte de forma inalambrica"
	fi
else
	# Conexión cableada
	#........................................................
	# Tirar puerto
	# ip link set dev "$puerto" down
	# Levantar puesto
	ip link set dev "$puerto" up
	# Comprobar
	if [ "$(ip a show $puerto up)" ]; then
		# Mensaje
		echo "Conectando..."
		# Ajustes
		ip addr flush dev "$puerto" &>/dev/null
		# Si se tiene una IP estatica
		if [ ! "$ipEstatica" ] || [ -z "$ipEstatica" ]; then
			# Si esta activa
			dhclient -r "$puerto" &>/dev/null
			dhclient "$puerto"
		else
			# Asignar IP estatica
			ifconfig "$puerto" "$ipEstatica" netmask "$mascaraEstatica" &>/dev/null
			route add default gw "$puertaDeEnlace" "$puerto" &>/dev/null
			bienConStaticConf="S"
		fi
	else
		# No esta activa
		echo "* Error al levantar conexión"
		exit 1
	fi
fi

#........................................................
# Conservar configuración
if [ "$bienConStaticConf" = "S" ] || [ "$bienConStaticConf" = "s" ]; then
	valOpc=""
	read -r -p "¿Conservar configuración? (S/N): " valOpc
	if [ "$valOpc" = "S" ] || [ "$valOpc" = "s" ]; then
		echo "" >> /etc/network/interfaces
		echo "auto ""$puerto" >> /etc/network/interfaces
		echo "iface ""$puerto"" inet static" >> /etc/network/interfaces
		echo "address ""$ipEstatica" >> /etc/network/interfaces
		echo "netmask ""$mascaraEstatica" >> /etc/network/interfaces
		echo "gateway ""$puertaDeEnlace" >> /etc/network/interfaces
		# /etc/init.d/networking restart
	fi
fi

# Terminar programa
exit 0