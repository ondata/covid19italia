#!/bin/bash

### requisti ###
# camelot https://camelot-py.readthedocs.io/en/master/
# miller https://github.com/johnkerl/miller
### requisti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing

rm -r "$folder"/processing/*.csv
rm -r "$folder"/rawdata/*table-2*.csv

#cd "$folder"/processing

#camelot -p 9-85 -f csv -o e.csv stream  "$folder"/rawdata/_contributi.pdf
cp -r "$folder"/rawdata/*.csv "$folder"/processing/
mv "$folder"/processing/e-page-9-table-1.csv "$folder"/processing/00e-page-9-table-1.csv

# aggiungi numero pagina
mlr -I --csv -N put -S '$pagina=FILENAME' "$folder"/processing/*.csv

# rimuovi path file
sed -i -r 's|/mnt.+/0?0?||g' "$folder"/processing/*.csv

# rinomina campo
mlr -I --csv rename -r ".+page.+",pagina "$folder"/processing/00e-page-9-table-1.csv

# fai il merge dei CSV
mlr --csv -N unsparsify "$folder"/processing/*.csv >"$folder"/allegato_01.csv

# estrai popolazione presente per errore nel campo ente
mlr -I --csv -N put -S '$6=regextract_or_else($5,"[0-9]\.?[0-9]+",$6)' "$folder"/allegato_01.csv

# nei campi numerici rimuovi la , e imposta come decimale il .
# converti - in null
mlr -I --csv -N put -S '$6=gsub($6,"\.","");$6=gsub($6,",",".");$6=gsub($6,"-","")' "$folder"/allegato_01.csv
mlr -I --csv -N put -S '$7=gsub($7,"\.","");$7=gsub($7,",",".");$7=gsub($7,"-","")' "$folder"/allegato_01.csv
mlr -I --csv -N put -S '$8=gsub($8,"\.","");$8=gsub($8,",",".");$8=gsub($8,"-","")' "$folder"/allegato_01.csv
mlr -I --csv -N put -S '$9=gsub($9,"\.","");$9=gsub($9,",",".");$9=gsub($9,"-","")' then clean-whitespace "$folder"/allegato_01.csv

# rimuovi righe in cui il campo 3 è vuoto
mlr -I --csv -N filter -x '$3==""' "$folder"/allegato_01.csv

# rimuovi i valori di popolazione dal campo ente
mlr -I --csv -N put -S '$5=gsub($5,"[0-9]\.?[0-9]+","")' "$folder"/allegato_01.csv

# correggi le celle in cui codINT e codBDAP risultano uniti nella colonna 2
mlr -I --csv -N put -S 'if ($1==""){$1=$2;$1=regextract_or_else($1,"[0-9]+ ","");$2=regextract_or_else($2," [0-9]+","")};' then clean-whitespace "$folder"/allegato_01.csv

# rimuovi caratteri inutili dal campo pagina
mlr -I --csv put -S '$pagina=gsub($pagina,"^(e-page-)([0-9]+)(-.+)$","\2")' then sort -n pagina -f codINT "$folder"/allegato_01.csv
