#!/bin/bash
#........................................................
# Programa: CrearBaseScript.sh
# Fecha: 25/08/2018
# Autor: Jorge Luis Jácome Domínguez
# Descripción: Script que genera la base de otros scripts.
#........................................................
if [ $# -lt 1 ] || [ -z $1 ]; then
	echo "Nombre de archivo requerido"
	exit 1
fi

nombreArch=$1".sh"
valOpc="S"
clear;

if [ -f $nombreArch ]; then
	read -r -p "El archivo ya existe, ¿Desea reemplazarlo? (S/N): " valOpc
fi

if [ $valOpc != "S" ] && [ $valOpc != "s" ]; then
	exit 0
fi

cat > $nombreArch <<- EOM
#!/bin/bash
#........................................................
# Programa: $nombreArch
# Fecha: $(date +"%d/%m/%Y")
# Autor: Jorge Luis Jácome Domínguez
# Descripción: Tarea.
#........................................................
EOM

chmod a+x $nombreArch;
sed -i -e 's/\r$//' $nombreArch;

exit 0