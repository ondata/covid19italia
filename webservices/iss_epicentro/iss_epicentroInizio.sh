#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

date=$(date '+%Y-%m-%d')

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/risorse

# svuota cartella
#rm "$folder"/processing/*
rm "$folder"/rawdata/*

### dashboard inizio ###
urlinizio="https://www.epicentro.iss.it/coronavirus/dashboard/inizio.html"

# estrai id dei div html
curl -kL "$urlinizio" >"$folder"/rawdata/Dashboard_finale_dallinizio.html
scrape <"$folder"/rawdata/Dashboard_finale_dallinizio.html -be '//div[contains(@id,"htmlwidget-")]' |
  xq -r '.html.body.div[]."@id"' >"$folder"/rawdata/listaDivIdDallInizio

# per ogni div estrai i dati JSON
while read p; do
  echo "$p"
  scrape <"$folder"/rawdata/Dashboard_finale_dallinizio.html -be '//div[@id="'"$p"'"]/following::script[1]' |
    xq -r '.html.body.script."#text"' | jq . >"$folder"/rawdata/"$p".json
done <"$folder"/rawdata/listaDivIdDallInizio

# Incidenza di COVID-19 segnalati in Italia per Regione/Provincia Autonoma per data di prelievo o diagnosi

numeroClassi=$(expr $(jq <"$folder"/rawdata/htmlwidget-0971c37dd630e105e8c2.json '.x.data| length') - 1)

rm "$folder"/rawdata/tmp_classe_*.csv
for i in $(seq 0 "$numeroClassi"); do
  jq <"$folder"/rawdata/htmlwidget-0971c37dd630e105e8c2.json '.x.data['"$i"']' | mlr --j2c reshape -r "^[xy]:" -o item,value then cut -f item,value then nest --explode --values --across-fields --nested-fs ":" -f item then reshape -s item_1,value then put '$classe='"$i"'' then rename item_2,id >"$folder"/rawdata/tmp_classe_"$i".csv
  numerorighe=$(cat "$folder"/rawdata/tmp_classe_"$i".csv | tail -n +2 | wc -l)
  mlr --ocsv seqgen --step 6 --start 0 --stop "$numerorighe" -f id then put '$code=$id' >>"$folder"/rawdata/tmp_classe_"$i"_join.csv
  mlr --csv join --ul -j id -f "$folder"/rawdata/tmp_classe_"$i".csv then unsparsify then sort -n id then fill-down -f code then cat -n -g code "$folder"/rawdata/tmp_classe_"$i"_join.csv >"$folder"/rawdata/tmp_classe_"$i"_out.csv
done

mlr --csv cat "$folder"/rawdata/tmp_classe_*_out.csv >"$folder"/rawdata/incidenzaInizio.csv

# Numero di casi di COVID-19 segnalati in Italia per Regione/Provincia Autonoma per data di prelievo o diagnosi

numeroClassi=$(expr $(jq <"$folder"/rawdata/htmlwidget-0f53bc84789d52b2599d.json '.x.data| length') - 1)

rm "$folder"/rawdata/tmp_classe_*.csv
for i in $(seq 0 "$numeroClassi"); do
  jq <"$folder"/rawdata/htmlwidget-0f53bc84789d52b2599d.json '.x.data['"$i"']' | mlr --j2c reshape -r "^[xy]:" -o item,value then cut -f item,value then nest --explode --values --across-fields --nested-fs ":" -f item then reshape -s item_1,value then put '$classe='"$i"'' then rename item_2,id >"$folder"/rawdata/tmp_classe_nc_"$i".csv
  numerorighe=$(cat "$folder"/rawdata/tmp_classe_nc_"$i".csv | tail -n +2 | wc -l)
  mlr --ocsv seqgen --step 6 --start 0 --stop "$numerorighe" -f id then put '$code=$id' >>"$folder"/rawdata/tmp_classe_nc_"$i"_join.csv
  mlr --csv join --ul -j id -f "$folder"/rawdata/tmp_classe_nc_"$i".csv then unsparsify then sort -n id then fill-down -f code then cat -n -g code "$folder"/rawdata/tmp_classe_nc_"$i"_join.csv >"$folder"/rawdata/tmp_classe_nc_"$i"_out.csv
done

mlr --csv cat "$folder"/rawdata/tmp_classe_nc_*_out.csv >"$folder"/rawdata/numeroCasiInizio.csv

cp "$folder"/rawdata/numeroCasiInizio.csv "$folder"/processing/raw_numeroCasiInizio.csv
cp "$folder"/rawdata/incidenzaInizio.csv "$folder"/processing/raw_incidenzaInizio.csv

python3 "$folder"/iss_epicentroInizio.py

host=$(hostname)
if [ $host = "ex-machina.ondata.it" ]; then
    # commit e push

    . ~/.keychain/$HOSTNAME-sh

    cd "$folder"
    git -C "$folder" pull
    git -C "$folder" add .
    git -C "$folder" commit -am "update"
    git -C "$folder" push origin master
fi
