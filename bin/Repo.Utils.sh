#!/bin/zsh

# Definir el archivo CSV
archivo_csv=".repos.csv"
touch $archivo_csv

# Crear un array asociativo en Zsh para almacenar los datos
declare -A datos

# Leer los datos del archivo temporal y almacenarlos en el array asociativo
while read -r linea; do
    parts=(${(@s:,:)linea})
    datos[$parts[1]]=${parts[2]}
done < $archivo_csv

_bb() {
    claves=(${(@k)datos})
    compadd "$claves[@]"
}
bb() {
    echo "${datos[$1]}"
}

compdef _bb bb