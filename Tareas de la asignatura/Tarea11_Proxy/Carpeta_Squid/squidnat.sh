#!/bin/bash

# IP de Red / Mascara de red
IP_RED_AND_MASK="192.168.1.0/24"

# IP Server
SQUID_SERVER="192.168.1.104"
# Interface con acceso a internet
INTERNET="wlp2s0"
# Interface de red local
LAN_IN="enp4s0"
# Puerto de Proxy
SQUID_PORT=3128

# Se limpian filtro de tablas NAT y MANGLE
iptables -F
iptables -X

iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Cargar modulos necesarios
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp

# Se activa el reenvio de peticiones IP en el KERNEL
echo 1 > /proc/sys/net/ipv4/ip_forward

# Se ajustan las politicas del Proxy

# Trafico de entrada con destino al servidor ---> Es cortado
# Trafico de salida procedente de servidor ---> Es aceptado
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT

# Se ilimita el acceso de entrada/salida para el Loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Se permite UDP, DNS y FTP pasivo procedente de Internet
iptables -A INPUT -i $INTERNET -m state --state ESTABLISHED,RELATED -j ACCEPT

# Hace al sistema un ROUTER para el resto de la red
iptables --table nat --append POSTROUTING --out-interface $INTERNET -j MASQUERADE
iptables --append FORWARD --in-interface $LAN_IN -j ACCEPT

# Permite acceso ilimitado para la LAN

iptables -A INPUT -i $LAN_IN -j ACCEPT
iptables -A OUTPUT -o $LAN_IN -j ACCEPT

# Entrada que efectua el DNAT a todas las perticiones recibidas por la interface de red interna
# cuando el destino sea el puerto 80 y se efectua DNAT haciendo que vayan siempre al puerto 3128
# de la IP del Servidor Proxy Squid. 
iptables -t nat -A PREROUTING -i $LAN_IN -p tcp -s $IP_RED_AND_MASK --dport 80 -j DNAT --to $SQUID_SERVER:$SQUID_PORT

# Abrimos algunos puertos para que sean accesibles desde internet
iptables -A INPUT -i $INTERNET -p tcp --dport 10000 -j ACCEPT
iptables -A INPUT -i $INTERNET -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -i $INTERNET -p tcp --dport 80 -j ACCEPT

# LOG de todo lo que sucede en /var/log/messages
iptables -A INPUT -j LOG


