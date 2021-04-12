#!/bin/bash

### requisiti ###
# sqlite3 https://www.sqlite.org/index.html
# miller https://github.com/johnkerl/miller
# moreutils https://joeyh.name/code/moreutils/
### requisiti ###

### output ###
# https://bl.ocks.org/aborruso/raw/28374f1d59a5d9880c4c76dc66865cd8/
### output ###

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/rawdata

URL="https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-province/dpc-covid19-ita-province-latest.csv"

# estrai codici di risposta HTTP
code=$(curl -s -L -o /dev/null -w "%{http_code}" "$URL")

# se il server risponde fai partire lo script
if [ $code -eq 200 ]; then

  curl -kL "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-province/dpc-covid19-ita-province-latest.csv" >"$folder"/rawdata/dpc-covid19-ita-province-latest.csv
  max=$(mlr --c2n stats1 -a max -f data "$folder"/rawdata/dpc-covid19-ita-province-latest.csv)

  mlr --csv filter -S '$data=="'"$max"'" && $codice_nuts_3=~".+"' "$folder"/rawdata/dpc-covid19-ita-province-latest.csv >"$folder"/processing/dpc-covid19-ita-province-latest.csv
fi
