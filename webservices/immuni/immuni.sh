#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing


URL="https://www.immuni.italia.it"

# leggi la risposta HTTP del sito
code=$(curl -A "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati e aggiorna feed
if [ $code -eq 200 ]; then

  oggi=$(date +%Y-%m-%d)

  # estrai nome file javascript
  jsPath=$(curl -kL "$URL/dashboard.html" | scrape -e '//script[contains(@src,"main")]/@src' | sed -r 's/^(.+js)(.+)$/\1/g')
  # scarica file
  curl -kL "$URL/$jsPath" >"$folder"/rawdata/tmp.html
  # estrai dati immuni
  grep <"$folder"/rawdata/tmp.html -oP '\{"nOfDownload":.+?\}' | mlr --ijson cat then put '$date="'"$oggi"'"' >>"$folder"/processing/immuni.dkvp
  # converti dati in CSV
  mlr --ocsv cat "$folder"/processing/immuni.dkvp >"$folder"/processing/immuni.csv

fi
