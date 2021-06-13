#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

git pull

URL="https://www.epicentro.iss.it/coronavirus/open-data/covid_19-iss.xlsx"

# leggi la risposta HTTP del sito
code=$(curl --cipher 'DEFAULT:!DH' -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -kL --cipher 'DEFAULT:!DH' "https://www.epicentro.iss.it/coronavirus/open-data/covid_19-iss.xlsx" >"$folder"/rawdata/covid_19-iss.xlsx

  contaCSV=$(ls "$folder"/rawdata/*.csv | wc -l)
  if [ "$contaCSV" -gt 0 ]; then
    rm "$folder"/rawdata/*.csv
  fi

  # leggi lista dei fogli, rimuovendo Contenuto e foglio che contiene spazio nel nome
  in2csv -n "$folder"/rawdata/covid_19-iss.xlsx | grep -vP "( |Contenuto)" >"$folder"/rawdata/listafogli
  #in2csv -n "$folder"/tmp_bad_data.xlsx | grep -vP "( |Contenuto)" >"$folder"/rawdata/listafogli

  # crea un CSV per ogni foglio
  while read p; do
    #in2csv -I --sheet "$p" "$folder"/rawdata/covid_19-iss.xlsx >"$folder"/rawdata/"$p".csv
    csvtk xlsx2csv "$folder"/rawdata/covid_19-iss.xlsx -n "$p" >"$folder"/rawdata/"$p".csv
  done <"$folder"/rawdata/listafogli

  # se la cartella processing è vuota copia i CSV da rawdata a processing
  if [ -z "$(ls -A "$folder"/processing)" ]; then
    cp "$folder"/rawdata/*.csv "$folder"/processing
  else
    # aggiungi nuovi dati ai fogli archiviati
    while read p; do
      mlr --csv unsparsify then uniq -a then remove-empty-columns "$folder"/processing/"$p".csv "$folder"/rawdata/"$p".csv >"$folder"/processing/tmp.csv
      mv "$folder"/processing/tmp.csv "$folder"/processing/"$p".csv
      mlr -I --csv remove-empty-columns "$folder"/rawdata/"$p".csv
      cp "$folder"/rawdata/"$p".csv "$folder"/processing/"$p"-latest.csv
    done <"$folder"/rawdata/listafogli
  fi
fi
