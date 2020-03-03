#!/bin/bash

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -x

<<commento
commento

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/publication

# estrai tabelle da PDF province
camelot -p 1-end -f csv -o "$folder"/processing/province.csv lattice -scale 40 "$folder"/rawdata/*rovince*.pdf

# estrai tabelle da PDF riepilogo
camelot -p 1-end -f csv -o "$folder"/processing/riepilogo.csv -split lattice -scale 40 -shift b "$folder"/rawdata/*iepilogo*.pdf

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

# crea CSV regioni di riepilogo
mlr --csv unsparsify then clean-whitespace "$folder"/processing/tmp_province*.csv >"$folder"/publication/province.csv

# crea CSV di riepilogo pulito
mlr --csv -N filter -x '$1=="" || $1=~"(otal|OTAL)"' processing/riepilogo-page-1*1.csv | mlr --csv -N put -S 'if (NR == 1) {for (k in $*) {$[k] = clean_whitespace(gsub($[k], "\n", " "))}}' then clean-whitespace >"$folder"/publication/riepilogo.csv

# fai pulizia
rm "$folder"/processing/tmp_province*.csv
