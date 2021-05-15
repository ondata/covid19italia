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

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/risorse

# dati nazione
URLN="https://download.data.world/s/67bofmmi7jubq2d6cezbt7qxx4iwba"
# dati regioni
URLR="https://download.data.world/s/mj726nk3buk65abrmkvpgcs5mbxsul"
# dati regioni con soglia
URLRS="https://download.data.world/s/oherutj4dwgwrg6uofmr7i6psjburd"

curl -kL  "$URLN" >"$folder"/processing/terapiaIntensivaNaz.csv
curl -kL  "$URLR" >"$folder"/processing/terapiaIntensivaReg.csv
curl -kL  "$URLRS" >"$folder"/processing/terapiaIntensivaRegSoglia.csv

mlr -I --csv sort -f data,denominazione_regione "$folder"/processing/terapiaIntensivaReg.csv
mlr -I --csv sort -f data,denominazione_regione "$folder"/processing/terapiaIntensivaRegSoglia.csv

dos2unix "$folder"/processing/terapiaIntensivaNaz.csv
dos2unix "$folder"/processing/terapiaIntensivaReg.csv
dos2unix "$folder"/processing/terapiaIntensivaRegSoglia.csv
