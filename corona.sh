#!/bin/bash

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -x

<<commento
curl -sL "http://www.protezionecivile.gov.it/attivita-rischi/rischio-sanitario/emergenze/coronavirus/" | scrape -be "//div/a[contains(text(),'provincia (pdf)') or contains(text(),'nazionale (pdf)')]" | xq -r '("http://www.protezionecivile.gov.it" + .html.body.a[]."@href")' | sed -r 's/(.+)(\/.+)$/\1/g'
commento

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/publication
mkdir -p "$folder"/pdfArchive

rm -r "$folder"/processing/*

# estrai URL dei PDF dalla pagina protCiv
curl -sL "http://www.protezionecivile.gov.it/attivita-rischi/rischio-sanitario/emergenze/coronavirus/" | scrape -be "//div/a[contains(text(),'provincia (pdf)') or contains(text(),'nazionale (pdf)')]" | xq -r '("http://www.protezionecivile.gov.it" + .html.body.a[]."@href")' | sed -r 's/(.+)(\/.+)$/\1/g' >"$folder"/rawdata/downloadList

# crea un file anagrafico dei PDF
mlr --tsv -N cat then put 'if (tolower($1)=~"province") {$nome="province.pdf"} elif (tolower($1)=~"nazionale") {$nome="riepilogo.pdf"};$rawname=gsub($1,".+/","")' \
  then unsparsify "$folder"/rawdata/downloadList >"$folder"/processing/downloadList.tsv

<<esempioOutput
+------------------------------------------------------------------------------------------------+---------------+-------------------------------------+
| http://www.protezionecivile.gov.it/documents/20182/1221364/Dati+Riepilogo+Nazionale+3marzo2020 | riepilogo.pdf | Dati+Riepilogo+Nazionale+3marzo2020 |
| http://www.protezionecivile.gov.it/documents/20182/1221364/Dati+Province+3marzo2020            | province.pdf  | Dati+Province+3marzo2020            |
+------------------------------------------------------------------------------------------------+---------------+-------------------------------------+
esempioOutput

# scarica i PDF
while IFS=$'\t' read -r URL nome rawname; do
  curl -L -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36' "$URL" >"$folder"/rawdata/"$nome"
  cp "$folder"/rawdata/"$nome" "$folder"/pdfArchive/"$rawname".pdf
done <"$folder"/processing/downloadList.tsv

# estrai tabelle da PDF province
camelot -p 1-end -f csv -o "$folder"/processing/province.csv lattice -scale 40 "$folder"/rawdata/province.pdf

# estrai tabelle da PDF riepilogo
camelot -p 1-end -f csv -o "$folder"/processing/riepilogo.csv -split lattice -scale 40 -shift b "$folder"/rawdata/riepilogo.pdf

# normalizza le tabelle province, rimuovendo totali e aggiungendo colonna regione
for i in "$folder"/processing/province*csv; do
  numerorighe=$(wc <"$i" -l)
  #crea una variabile da usare per estrarre nome e estensione
  filename=$(basename "$i")
  #estrai estensione
  extension="${filename##*.}"
  #estrai nome file
  filename="${filename%.*}"
  if [[ $numerorighe -lt 2 ]]; then
    rm "$i"
  else
    mlr --csv -N cat then filter -x '$1=~"otale"' then put 'if (NR == 1) {$2="valore";$regione=$1;$1="a"}' then unsparsify then fill-down -f regione "$i" | mlr --csv label provincia,numero,regione >"$folder"/processing/tmp_province_"$filename".csv
  fi
done

# crea copia archivio province
cat "$folder"/publication/provinceArchivio.csv >"$folder"/publication/tmp2_province.csv

# crea CSV province di riepilogo
mlr --csv unsparsify then clean-whitespace then put '$datetime=system("date --iso-8601")' "$folder"/processing/tmp_province*.csv >"$folder"/publication/tmp1_province.csv

# province: fai il merge dell'ultimo dato con i dati di archivio
mlr --csv uniq -a "$folder"/publication/tmp1_province.csv "$folder"/publication/tmp2_province.csv >"$folder"/publication/provinceArchivio.csv

# crea copia archivio riepilogo
cat "$folder"/publication/riepilogoArchivio.csv >"$folder"/publication/tmp2_riepilogo.csv

# crea CSV di riepilogo pulito, rimuovi riga con i totali
mlr --csv -N filter -x '$1=="" || $1=~"(otal|OTAL)"' processing/riepilogo-page-1*1.csv | \
mlr --csv -N put -S 'if (NR == 1) {for (k in $*) {$[k] = clean_whitespace(gsub($[k], "\n", " "))}}' \
then clean-whitespace | \
mlr --csv put '$datetime=system("date --iso-8601")' >"$folder"/publication/tmp1_riepilogo.csv

# rimuovi eventuali inutili "a capo"
mlr -I --csv put -S '
  for (k in $*) {
    $[k] = gsub($[k], "\n", "");
  }
' "$folder"/publication/tmp1_riepilogo.csv

# riepilogo: fai il merge dell'ultimo dato con i dati di archivio
mlr --csv uniq -a "$folder"/publication/tmp1_riepilogo.csv "$folder"/publication/tmp2_riepilogo.csv >"$folder"/publication/riepilogoArchivio.csv

# rimuovi eventuali inutili "a capo"
mlr -I --csv put -S '
  for (k in $*) {
    $[k] = gsub($[k], "\n", "");
  }
' "$folder"/publication/riepilogoArchivio.csv

# fai pulizia
rm "$folder"/processing/tmp_province*.csv
rm "$folder"/publication/tmp*.csv

