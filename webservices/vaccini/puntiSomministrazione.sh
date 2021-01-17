#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/rawdata/puntiSomministrazione
mkdir -p "$folder"/processing
mkdir -p "$folder"/processing/puntiSomministrazione

# url dashboard
URL="https://app.powerbi.com/view?r=eyJrIjoiMzg4YmI5NDQtZDM5ZC00ZTIyLTgxN2MtOTBkMWM4MTUyYTg0IiwidCI6ImFmZDBhNzVjLTg2NzEtNGNjZS05MDYxLTJjYTBkOTJlNDIyZiIsImMiOjh9"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica e "lavora" i dati
if [ $code -eq 200 ]; then

  # scarica dati in formato JSON
  curl -s 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' --compressed -H 'Content-Type: application/json;charset=UTF-8' -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' --data @"$folder"/risorse/query_punti-di-somministrazione.json | jq . >"$folder"/processing/puntiSomministrazione/tmp_puntiSomministrazione.json

  # converti JSON in CSV
  python3 "$folder"/puntiSomministrazione.py "$folder"/processing/puntiSomministrazione/tmp_puntiSomministrazione.json "$folder"/processing/puntiSomministrazione/puntiSomministrazione.csv

  mlr -I --csv clean-whitespace then rename ID_AREA,siglaRegione "$folder"/processing/puntiSomministrazione/puntiSomministrazione.csv

  # aggiungi codice geografici standard
  mlr --csv join --ul -j siglaRegione -f "$folder"/processing/puntiSomministrazione/puntiSomministrazione.csv then unsparsify then cut -x -f Name,ITTER107 then clean-whitespace then uniq -a "$folder"/risorse/codiciTerritoriali.csv >"$folder"/processing/puntiSomministrazione/tmp.csv

  mv "$folder"/processing/puntiSomministrazione/tmp.csv "$folder"/processing/puntiSomministrazione/puntiSomministrazione.csv

fi

# scarica dettagli su dosi, sesso e categorie per punti di somministrazione

URLdati="https://github.com/slarosa/vax/raw/main/data/vax_total.csv"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URLdati")

# se il sito è raggiungibile scarica e "lavora" i dati
if [ $code -eq 200 ]; then

  # scarica dati in formato JSON
  curl -kL "$URLdati" >"$folder"/processing/puntiSomministrazione/puntiSomministrazioneDatiVax.csv

  mlr -I --csv sort -f TML_DTA_SOMM,TML_REGIONE,TML_DES_STRUTTURA,TML_VAX_FORNITORE \
    then rename TML_DTA_SOMM,data,TML_VAX_FORNITORE,vaccino,TML_AREA,siglaRegione,TML_REGIONE,regione,TML_NUTS,NUTS2 "$folder"/processing/puntiSomministrazione/puntiSomministrazioneDatiVax.csv

fi
