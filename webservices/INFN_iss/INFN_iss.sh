#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/rawdata

URL="https://covid19.infn.it/iss/"

# scarica pagina
google-chrome-stable --headless --disable-gpu --dump-dom --virtual-time-budget=99999999 --run-all-compositor-stages-before-draw "$URL" >"$folder"/rawdata/INFN_iss.html

# estrai elenco file
grep <"$folder"/rawdata/INFN_iss.html -Po '"filename": ".+?"' >"$folder"/rawdata/file
sed -i -r 's/^.+ //g;s/"//g' "$folder"/rawdata/file

# scarica file
cat "$folder"/rawdata/file | while read line; do
  echo "$line"
  curl -kL "https://covid19.infn.it/iss/plots/$line.div" >"$folder"/rawdata/"$line".html
  grep <"$folder"/rawdata/"$line".html -P '.+"hoverinfo".+' | grep -oP '\[.+\]' >"$folder"/processing/"$line".json
done

### iss_bydate_italia_positivi ###

dataset="iss_bydate_italia"
mkdir -p "$folder"/processing/"$dataset"

scrape <"$folder"/rawdata/INFN_iss.html -be '//select[@id="provincia_giornalieri"]' | xq -r '.html.body.select.option[]."@value"' | grep -P '.+' >"$folder"/rawdata/iss_bydate_italia_provincia

scrape <"$folder"/rawdata/INFN_iss.html -be '//select[@id="dati_giornalieri"]' | xq -r '.html.body.select.option[]."@value"' | grep -P '.+' >"$folder"/rawdata/iss_bydate_italia_dati

scrape <"$folder"/rawdata/INFN_iss.html -be '//select[@id="regione_giornalieri"]' | xq -r '.html.body.select.option[]."@value"' | grep -P '.+' | grep -Pv 'talia' >"$folder"/rawdata/iss_bydate_italia_regione

scarica_iss_bydate_italia="no"

# dati provinciali
if [ "$scarica_iss_bydate_italia" = "sì" ]; then
  cat "$folder"/rawdata/iss_bydate_italia_provincia | while read provincia; do
    cat "$folder"/rawdata/iss_bydate_italia_dati | while read dati; do
      curl -kL "https://covid19.infn.it/iss/plots/iss_bydate_{$provincia}_{$dati}.div" | grep -P '.+"hoverinfo".+' | grep -oP '\[.+\]' >"$folder"/processing/"$dataset"/iss_bydate_"$provincia"_"$dati".json
    done
  done
fi

# dati regionali
if [ "$scarica_iss_bydate_italia" = "sì" ]; then
  cat "$folder"/rawdata/iss_bydate_italia_regione | while read regione; do
    cat "$folder"/rawdata/iss_bydate_italia_dati | while read dati; do
      curl -kL "https://covid19.infn.it/iss/plots/iss_bydate_{$regione}_{$dati}.div" | grep -P '.+"hoverinfo".+' | grep -oP '\[.+\]' >"$folder"/processing/"$dataset"/r_iss_bydate_"$regione"_"$dati".json
    done
  done
fi

### iss_opsan_italia_sintomatici ###

dataset="iss_opsan_italia"
mkdir -p "$folder"/processing/"$dataset"

scrape <"$folder"/rawdata/INFN_iss.html -be '//select[@id="regione_opsan"]' | xq -r '.html.body.select.option[]."@value"' | grep -P '.+' | grep -Pv 'talia' >"$folder"/rawdata/"$dataset"_regione

scrape <"$folder"/rawdata/INFN_iss.html -be '//select[@id="dati_opsan"]' | xq -r '.html.body.select.option[]."@value"' | grep -P '.+' >"$folder"/rawdata/"$dataset"_dati

scarica_iss_opsan_italia="no"

if [ "$scarica_iss_opsan_italia" = "sì" ]; then
  cat "$folder"/rawdata/"$dataset"_regione | while read regione; do
    cat "$folder"/rawdata/"$dataset"_dati | while read dati; do
      curl -kL "https://covid19.infn.it/iss/plots/iss_opsan_{$regione}_{$dati}.div" | grep -P '.+"hoverinfo".+' | grep -oP '\[.+\]' >"$folder"/processing/"$dataset"/iss_opsan_"$regione"_"$dati".json
    done
  done
fi
