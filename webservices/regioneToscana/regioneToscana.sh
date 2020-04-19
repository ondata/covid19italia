#!/bin/bash

### requisiti ###
# miller https://github.com/johnkerl/miller
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

curl -c "$folder"/cookie "https://www.ars.toscana.it/covid19/aggiornamento-covid-numero-di-morti-decessi-comune-toscana"

curl -b "$folder"/cookie 'https://www.ars.toscana.it/covid19/actions/loadAddressess_decessi.php?mappa=map4&flag_mappa=%5B%22%22%5D&tipo%5Bgenere%5D=t&tipo%5Bnome_indicatore%5D=grafico26&tipo%5Bmodalita%5D=reg_dec&tk=c48ea1419d34763b2dc13056ad61fc87' -H 'Connection: keep-alive' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Sec-Fetch-Dest: empty' -H 'X-Requested-With: XMLHttpRequest' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-Mode: cors' -H 'Referer: https://www.ars.toscana.it/covid19/aggiornamento-covid-numero-di-morti-decessi-comune-toscana' -H 'Accept-Language: it,en-US;q=0.9,en;q=0.8' --compressed '.indirizzi' >jq |
  mlr --j2c unsparsify then clean-whitespace >"$folder"/rawdata/dati.csv

mlr -I --csv put '$data_caricamento=int(systime())' "$folder"/rawdata/dati.csv

date=$(date '+%Y-%m-%d')

mv "$folder"/rawdata/dati.csv "$folder"/processing/"$date"-Toscana-comuni-casi.csv

# commit e push

. ~/.keychain/$HOSTNAME-sh

cd "$folder"
git -C "$folder" pull
git -C "$folder" add .
git -C "$folder" commit -am "update"
git -C "$folder" push origin master
