#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/rawdata

# RT regioni
find "$folder"/processing/iss_bydate_italia/regioni -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[1]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,nuoviCasiGiornalieri >"$folder"/processing/iss_bydate_italia/regioni/"$nome".csv
done

# file di insieme long
mlr --csv put '$fn=FILENAME;$fn=sub($fn,".+/","");$fn=sub($fn,"iss_bydate_","");$fn=sub($fn,".csv$","");$regione=regextract($fn,"^(.+_giulia|.+_romagna|.+_daosta|.+_adige|.._[a-z]+|[a-z]+)_");$tipo=sub($fn,$regione,"");$regione=sub($regione,"_","")' then cut -x -f fn then sort -f regione,tipo,date "$folder"/processing/iss_bydate_italia/regioni/*.csv >"$folder"/processing/iss_bydate_italia/regioni.csv

# file di insieme wide
mlr --csv  reshape -s tipo,nuoviCasiGiornalieri then unsparsify then sort -f regione,date "$folder"/processing/iss_bydate_italia/regioni.csv >"$folder"/processing/iss_bydate_italia/regioni_wide.csv
