#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

git pull

nome="regioneLombardiaStatiClinici"

URL="https://hub.dati.lombardia.it/api/views/7jw9-ygfv/rows.csv?accessType=DOWNLOAD&bom=true&format=true&delimiter=%3B"
URLJSON="https://hub.dati.lombardia.it/resource/7jw9-ygfv.json"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -kL "$URL" >"$folder"/rawdata/"$nome".csv

  mlr --csv --ifs ";" put -S '$date = strftime(strptime($DATA_INIZIO_SINTOMI, "%d/%m/%Y"),"%Y-%m-%d")' then sort -f date "$folder"/rawdata/"$nome".csv >"$folder"/processing/"$nome".csv

  curl -kL "$URLJSON" | jq -c 'sort_by(.data_inizio_sintomi)|.[]' >"$folder"/processing/"$nome".jsonl

  dos2unix "$folder"/processing/"$nome".jsonl
  dos2unix "$folder"/processing/"$nome".csv
fi
