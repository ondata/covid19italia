#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

git pull

nome="regioneLombardiaVaccini"

URL="https://hub.dati.lombardia.it/api/views/xdg8-8qek/rows.csv?accessType=DOWNLOAD&bom=true&format=true&delimiter=%3B"
URLMeta="https://hub.dati.lombardia.it/api/views/metadata/v1/xdg8-8qek"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -kL "$URL" >"$folder"/rawdata/"$nome".csv
  curl -kL "$URLMeta" >"$folder"/rawdata/"$nome"_meta.json

  data=$(<"$folder"/rawdata/"$nome"_meta.json jq -r '.dataUpdatedAt')

  nomeD=$(echo "$data" | sed -r 's/T.+$//g')

  mlr --csv --ifs ";" put -S '$date = "'"$data"'"' then sort -f date,CODISTAT_COMUNE_DOM "$folder"/rawdata/"$nome".csv >"$folder"/processing/"$nome"_latest.csv
  cp "$folder"/processing/"$nome"_latest.csv "$folder"/processing/"$nome"_"$nomeD".csv

  dos2unix "$folder"/processing/"$nome"_"$nomeD".csv
  dos2unix "$folder"/processing/"$nome"_latest.csv
fi
