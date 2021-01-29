#!/bin/bash

### requisiti ###
# jq https://stedolan.github.io/jq/
# xq https://github.com/kislyuk/yq
# scrape https://github.com/aborruso/scrape-cli
# miller https://github.com/johnkerl/miller
### requisiti ###

set -x

debugMode="off"

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

date=$(date '+%Y-%m-%d')

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/risorse

# fai pulizia
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

### Incidenza di COVID-19 segnalati in Italia per Regione/Provincia Autonoma per data di prelievo o diagnosi ###

# ricava nome del file JSON che contiene questi dati
nomeCasi=$(grep -rnEli '\...-[0-9]{2}' "$folder"/rawdata/*.json | grep -Eo 'html.+json')

# estrai il numero di classi di dati
numeroClassi=$(expr $(jq <"$folder"/rawdata/"$nomeCasi" '.x.data| length') - 1)

# fai pulizia
rm "$folder"/rawdata/tmp_classe_*.csv

# crea CSV x, y, valore per ogni classe di dati
for i in $(seq 0 "$numeroClassi"); do
  jq <"$folder"/rawdata/"$nomeCasi" '.x.data['"$i"']' | mlr --j2c reshape -r "^[xy]:" -o item,value then cut -f item,value then nest --explode --values --across-fields --nested-fs ":" -f item then reshape -s item_1,value then put '$classe='"$i"'' then rename item_2,id >"$folder"/rawdata/tmp_classe_"$i".csv
  numerorighe=$(cat "$folder"/rawdata/tmp_classe_"$i".csv | tail -n +2 | wc -l)
  mlr --ocsv seqgen --step 6 --start 0 --stop "$numerorighe" -f id then put '$code=$id' >>"$folder"/rawdata/tmp_classe_"$i"_join.csv
  mlr --csv join --ul -j id -f "$folder"/rawdata/tmp_classe_"$i".csv then unsparsify then sort -n id then fill-down -f code then cat -n -g code "$folder"/rawdata/tmp_classe_"$i"_join.csv >"$folder"/rawdata/tmp_classe_"$i"_out.csv
done

# unisci i CSV delle classi di dati
mlr --csv cat "$folder"/rawdata/tmp_classe_*_out.csv >"$folder"/rawdata/incidenzaInizio.csv

### Numero di casi di COVID-19 segnalati in Italia per Regione/Provincia Autonoma per data di prelievo o diagnosi ###

# ricava nome del file JSON che contiene questi dati
nomeCasi=$(grep -rnEli '[0-9]{3}-[0-9]{3}' "$folder"/rawdata/*.json | grep -Eo 'html.+json')

# estrai il numero di classi di dati
numeroClassi=$(expr $(jq <"$folder"/rawdata/"$nomeCasi" '.x.data| length') - 1)

# crea CSV x, y, valore per ogni classe di dati
rm "$folder"/rawdata/tmp_classe_*.csv
for i in $(seq 0 "$numeroClassi"); do
  jq <"$folder"/rawdata/"$nomeCasi" '.x.data['"$i"']' | mlr --j2c reshape -r "^[xy]:" -o item,value then cut -f item,value then nest --explode --values --across-fields --nested-fs ":" -f item then reshape -s item_1,value then put '$classe='"$i"'' then rename item_2,id >"$folder"/rawdata/tmp_classe_nc_"$i".csv
  numerorighe=$(cat "$folder"/rawdata/tmp_classe_nc_"$i".csv | tail -n +2 | wc -l)
  mlr --ocsv seqgen --step 6 --start 0 --stop "$numerorighe" -f id then put '$code=$id' >>"$folder"/rawdata/tmp_classe_nc_"$i"_join.csv
  mlr --csv join --ul -j id -f "$folder"/rawdata/tmp_classe_nc_"$i".csv then unsparsify then sort -n id then fill-down -f code then cat -n -g code "$folder"/rawdata/tmp_classe_nc_"$i"_join.csv >"$folder"/rawdata/tmp_classe_nc_"$i"_out.csv
done

# unisci i CSV delle classi di dati
mlr --csv cat "$folder"/rawdata/tmp_classe_nc_*_out.csv >"$folder"/rawdata/numeroCasiInizio.csv

# fai pulizia
rm "$folder"/rawdata/tmp_classe_*.csv

cp "$folder"/rawdata/numeroCasiInizio.csv "$folder"/processing/raw_numeroCasiInizio.csv
cp "$folder"/rawdata/incidenzaInizio.csv "$folder"/processing/raw_incidenzaInizio.csv

python3 "$folder"/iss_epicentroInizio.py

host=$(hostname)
if [[ "$host" == "ex-machina.ondata.it" ]] && [[ "$debugMode" == "off" ]]; then
    # commit e push

    . ~/.keychain/$HOSTNAME-sh

    cd "$folder"
    git -C "$folder" pull
    git -C "$folder" add .
    git -C "$folder" commit -am "update"
    git -C "$folder" push origin master
fi
