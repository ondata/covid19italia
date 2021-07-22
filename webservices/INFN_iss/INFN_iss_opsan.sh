#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/rawdata

dataset="iss_opsan_italia"

# sintomatici operatori
find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[0]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/operatori_"$nome".csv
done

# sintomatici altri
find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[1]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/altri_"$nome".csv
done

# cancella file csv vuoti
find "$folder"/processing/"$dataset"/ -name "*.csv" -size 0 -delete

# merge dei CSV

mlr --csv put '$r=FILENAME;$r=gsub($r,"(.+_opsan_|\.csv)","");$regione=regextract($r,"^(.+_giulia|.+_romagna|.+_daosta|.+_adige|.._[a-z]+|[a-z]+)_");$tipo=sub($r,$regione,"");$regione=sub($regione,"_","")' then cut -x -f r then sort -f regione,tipo,date "$folder"/processing/iss_opsan_italia/operatori*.csv >"$folder"/processing/iss_opsan.csv
# creazione versione wide
mlr --csv reshape -s tipo,valore then unsparsify then sort -f regione,date "$folder"/processing/iss_sintomatici_opsan.csv >"$folder"/processing/iss_opsan_wide.csv


mlr --csv put '$r=FILENAME;$r=gsub($r,"(.+_opsan_|\.csv)","");$regione=regextract($r,"^(.+_giulia|.+_romagna|.+_daosta|.+_adige|.._[a-z]+|[a-z]+)_");$tipo=sub($r,$regione,"");$regione=sub($regione,"_","")' then cut -x -f r then sort -f regione,tipo,date "$folder"/processing/iss_opsan_italia/altri*.csv >"$folder"/processing/iss_opsan_altri.csv
# creazione versione wide
mlr --csv reshape -s tipo,valore then unsparsify then sort -f regione,date "$folder"/processing/iss_sintomatici_altri.csv >"$folder"/processing/iss_opsan_altri_wide.csv

# cancella i file CSV singoli
find "$folder"/processing/iss_opsan_italia -name "*.csv" -delete
