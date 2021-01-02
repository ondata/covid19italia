#!/bin/bash


set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

URL="https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab1"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  # scarica pagina tramite chrome headless
  google-chrome-stable --virtual-time-budget=30000 --run-all-compositor-stages-before-draw --headless --disable-gpu --dump-dom "https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab1" >"$folder"/rawdata/tab1.html
  # se la pagina scaricata non contiene nulla prova un nuovo download, non più di 5 volte
  n=0
  while [ "$n" -lt 5 ] && [ $(wc <"$folder"/rawdata/tab1.html -l) -eq 0 ]; do
    google-chrome-stable --virtual-time-budget=30000 --run-all-compositor-stages-before-draw --headless --disable-gpu --dump-dom "https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab1" >"$folder"/rawdata/tab1.html
    n=$(( n + 1 ))
  done
  #curl -kL "https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab1" >"$folder"/rawdata/tab1.html
  fonte1=$(scrape <"$folder"/rawdata/tab1.html -be ".text-decoration-none" | xq -r '.html.body.p."#text"')
  scrape <"$folder"/rawdata/tab1.html -be ".text-decoration-none" | xq -r '.html.body.p."#text"'
  vd <"$folder"/rawdata/tab1.html -f html +:table_0:: -b -o "$folder"/rawdata/positivi-e-ricoverati.csv

  # scarica pagina tramite chrome headless
  google-chrome-stable --virtual-time-budget=30000 --run-all-compositor-stages-before-draw --headless --disable-gpu --dump-dom "https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab2" >"$folder"/rawdata/tab2.html
  # se la pagina scaricata non contiene nulla prova un nuovo download, non più di 5 volte
  n=0
  while [ "$n" -lt 5 ] && [ $(wc <"$folder"/rawdata/tab2.html -l) -eq 0 ]; do
    google-chrome-stable --virtual-time-budget=30000 --run-all-compositor-stages-before-draw --headless --disable-gpu --dump-dom "https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab2" >"$folder"/rawdata/tab2.html
    n=$(( n + 1 ))
  done
  #curl -kL "https://www.agenas.gov.it/covid19/web/index.php?r=site%2Ftab2" >"$folder"/rawdata/tab2.html
  fonte2=$(scrape <"$folder"/rawdata/tab2.html -be ".text-decoration-none" | xq -r '.html.body.p."#text"')
  scrape <"$folder"/rawdata/tab2.html -be ".text-decoration-none" | xq -r '.html.body.p."#text"'
  vd <"$folder"/rawdata/tab2.html -f html +:table_0:: -b -o "$folder"/rawdata/postiletto-e-ricoverati-areaNonCritica.csv
fi

date=$(date '+%Y-%m-%d')

# rimuovi il separatore delle migliaia e aggiungi metadati fonte
mlr -I --csv put -S '
  for (k in $*) {
    $[k] = gsub($[k], ",([0-9])", "\1");
  }
' then put '$fonte="'"$fonte1"'"' "$folder"/rawdata/positivi-e-ricoverati.csv

mlr -I --csv put -S '
  for (k in $*) {
    $[k] = gsub($[k], ",([0-9])", "\1");
  }
' then put '$fonte="'"$fonte2"'"' "$folder"/rawdata/postiletto-e-ricoverati-areaNonCritica.csv

# copia i file nelle cartella di output
mv "$folder"/rawdata/positivi-e-ricoverati.csv "$folder"/processing/"$date"_positivi-e-ricoverati.csv
mv "$folder"/rawdata/postiletto-e-ricoverati-areaNonCritica.csv "$folder"/processing/"$date"_postiletto-e-ricoverati-areaNonCritica.csv

# converti il carriage return dei file
dos2unix "$folder"/processing/"$date"_positivi-e-ricoverati.csv
dos2unix "$folder"/processing/"$date"_postiletto-e-ricoverati-areaNonCritica.csv

# merge dei dati
mlr --csv unsparsify then uniq -a then clean-whitespace then filter -x -S '${Regioni}=="Italia"' "$folder"/processing/20*_postiletto-e-ricoverati-areaNonCritica.csv >"$folder"/processing/postiletto-e-ricoverati-areaNonCritica.csv
mlr --csv unsparsify then uniq -a then clean-whitespace then filter -x -S '${Regione/PA}=="Italia"' "$folder"/processing/20*_positivi-e-ricoverati.csv >"$folder"/processing/positivi-e-ricoverati.csv
