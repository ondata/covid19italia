#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/rawdata

# RT regioni
find "$folder"/processing/iss_bydate_italia/regioni -name "*.json" | while read line; do
  nome=$(basename "$line" ".json")
  <"$line" jq '.[1]|[.]|map([.x, .y]| transpose|.[]|{x:.[0],y:.[1]})'  | mlr --j2c label date,nuoviCasiGiornalieri >"$folder"/processing/iss_bydate_italia/regioni/"$nome".csv
done


