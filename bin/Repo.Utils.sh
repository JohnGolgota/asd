#!/bin/zsh

# Definir el archivo CSV
archivo_csv=".repos.csv"
touch $archivo_csv

# Crear un array asociativo en Zsh para almacenar los datos
declare -A datos

# Ejecutar awk y almacenar los datos en un archivo temporal
awk -F ',' '{
    clave=$1
    valor=$2
    gsub(/^ *| *$/,"",valor)
    datos[clave]=valor
} END {
    for (i in datos) {
        print i, datos[i]
    }
}' "$archivo_csv" > temp_file

# Leer los datos del archivo temporal y almacenarlos en el array asociativo
while read -r clave valor; do
    datos[$clave]=$valor
done < temp_file
# rm temp_file

echo '_bb() {
    claves=(' >> nuevo.sh
echo ${(@k)datos} >> nuevo.sh
echo ')
    compadd "$claves[@]"
}
bb() {
    echo "${datos[$1]}"
}' >> nuevo.sh

compdef _bb bb
