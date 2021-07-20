#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/rawdata

dataset="iss_age_date"

# sintomatici operatori
find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[0]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/0-9_"$nome".csv
done

# sintomatici altri
find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[1]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/10-19_"$nome".csv
done

find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[2]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/20-29_"$nome".csv
done

find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[3]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/30-39_"$nome".csv
done

find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[4]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/40-49_"$nome".csv
done

find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[5]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/50-59_"$nome".csv
done

find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[6]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/60-69_"$nome".csv
done

find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[7]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/70-79_"$nome".csv
done

find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[8]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/80-89_"$nome".csv
done

find "$folder"/processing/"$dataset"/ -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[9]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,valore >"$folder"/processing/"$dataset"/over90_"$nome".csv
done

# cancella file csv vuoti
find "$folder"/processing/"$dataset"/ -name "*.csv" -size 0 -delete

# merge dei CSV

mlr --csv put '$r=FILENAME;$r=gsub($r,"(.+_age_date_|\.csv)","");$regione=regextract($r,"^(.+_giulia|.+_romagna|.+_daosta|.+_adige|.._[a-z]+|[a-z]+)_");$tipo=sub($r,$regione,"");$regione=sub($regione,"_","")' then cut -x -f r then sort -f regione,tipo,date "$folder"/processing/"$dataset"/ottantaPlus_*.csv >"$folder"/processing/iss_80plus.csv

mlr --csv put '$r=FILENAME;$r=gsub($r,"(.+_age_date_|\.csv)","");$regione=regextract($r,"^(.+_giulia|.+_romagna|.+_daosta|.+_adige|.._[a-z]+|[a-z]+)_");$tipo=sub($r,$regione,"");$regione=sub($regione,"_","")' then cut -x -f r then sort -f regione,tipo,date "$folder"/processing/"$dataset"/altri*.csv >"$folder"/processing/iss_80plus_altri.csv
