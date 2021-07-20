#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/rawdata

# RT regioni
find "$folder"/processing/iss_rt/regioni -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[0]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,rt >"$folder"/processing/iss_rt/regioni/"$nome".csv
done


# RT province
find "$folder"/processing/iss_rt/province -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[0]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,rt >"$folder"/processing/iss_rt/province/"$nome".csv
done

# merge regioni
mlr --csv put '$regione=FILENAME;$regione=gsub($regione,"(.+_rt_|\.csv)","")' then sort -f regione,date "$folder"/processing/iss_rt/regioni/*.csv >"$folder"/processing/iss_rt/regioni.csv

# merge province
mlr --csv put '$provincia=FILENAME;$provincia=gsub($provincia,"(.+_rt_|\.csv)","")' then sort -f regione,date "$folder"/processing/iss_rt/province/*.csv >"$folder"/processing/iss_rt/province.csv
