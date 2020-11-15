#!/bin/bash

### requisiti ###
# visidata https://github.com/saulpw/visidata
# Miller https://github.com/johnkerl/miller
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

URL="https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab1"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
  curl -kL "https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab1" | vd -f html +:table_0:: -b -o "$folder"/rawdata/positivi-e-ricoverati.csv
  curl -kL "https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab2" | vd -f html +:table_0:: -b -o "$folder"/rawdata/postiletto-e-ricoverati-areaNonCritica.csv
fi

date=$(date '+%Y-%m-%d')

# rimuovi il separatore delle migliaia
mlr  -I --csv put -S '
  for (k in $*) {
    $[k] = gsub($[k], "\.([0-9])", "\1");
  }
' "$folder"/rawdata/positivi-e-ricoverati.csv

mlr -I --csv put -S '
  for (k in $*) {
    $[k] = gsub($[k], "\.([0-9])", "\1");
  }
' "$folder"/rawdata/postiletto-e-ricoverati-areaNonCritica.csv

mv "$folder"/rawdata/positivi-e-ricoverati.csv "$folder"/processing/"$date"_positivi-e-ricoverati.csv
mv "$folder"/rawdata/postiletto-e-ricoverati-areaNonCritica.csv "$folder"/processing/"$date"_postiletto-e-ricoverati-areaNonCritica.csv
