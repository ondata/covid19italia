#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/rawdata

dataset="iss_80plus"

# sintomatici operatori
find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[0]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/ottantaPlus_"$nome".csv
done

# sintomatici altri
find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[1]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/altri_"$nome".csv
done

# cancella file csv vuoti
find "$folder"/processing/"$dataset"/ -name "*.csv" -size 0 -delete

# merge dei CSV

mlr --csv put '$r=FILENAME;$r=gsub($r,"(.+_80plus_|\.csv)","");$regione=regextract($r,"^(.+_giulia|.+_romagna|.+_daosta|.+_adige|.._[a-z]+|[a-z]+)_");$tipo=sub($r,$regione,"");$regione=sub($regione,"_","")' then cut -x -f r then sort -f regione,tipo,date "$folder"/processing/"$dataset"/ottantaPlus_*.csv >"$folder"/processing/"$dataset".csv
# creazione versione wide
mlr --csv reshape -s tipo,valore then unsparsify then sort -f regione,date "$folder"/processing/"$dataset".csv >"$folder"/processing/"$dataset"_wide.csv

mlr --csv put '$r=FILENAME;$r=gsub($r,"(.+_80plus_|\.csv)","");$regione=regextract($r,"^(.+_giulia|.+_romagna|.+_daosta|.+_adige|.._[a-z]+|[a-z]+)_");$tipo=sub($r,$regione,"");$regione=sub($regione,"_","")' then cut -x -f r then sort -f regione,tipo,date "$folder"/processing/"$dataset"/altri*.csv >"$folder"/processing/"$dataset"_altri.csv
# creazione versione wide
mlr --csv reshape -s tipo,valore then unsparsify then sort -f regione,date "$folder"/processing/"$dataset"_altri.csv >"$folder"/processing/"$dataset"_altri_wide.csv

find "$folder"/processing/"$dataset" -name "*.csv" -delete
