#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/risorse

# svuota cartella
#rm "$folder"/processing/*
#rm "$folder"/rawdata/*

### dashboard 30 giorni ###
urlinizio="https://www.epicentro.iss.it/coronavirus/dashboard/inizio.html"

# estrai id dei div html
#curl -kL "$urlinizio" >"$folder"/rawdata/Dashboard_finale_dallinizio.html
scrape <"$folder"/rawdata/Dashboard_finale_dallinizio.html -be '//div[contains(@id,"htmlwidget-")]' |
  xq -r '.html.body.div[]."@id"' >"$folder"/rawdata/listaDivIdDallInizio

# per ogni div estrai i dati JSON
while read p; do
  echo "$p"
  scrape <"$folder"/rawdata/Dashboard_finale_dallinizio.html -be '//div[@id="'"$p"'"]/following::script[1]' |
    xq -r '.html.body.script."#text"' | jq . >"$folder"/rawdata/"$p".json
done <"$folder"/rawdata/listaDivIdDallInizio

for i in {1..8}; do
  jq <rawdata/htmlwidget-0f53bc84789d52b2599d.json '.x.data['"$i"']' | mlr --j2c reshape -r "^[xy]:" -o item,value then cut -f item,value then nest --explode --values --across-fields --nested-fs ":" -f item then reshape -s item_1,value then put '$classe='"$i"'' >tmp_classe_"$i".csv
done
