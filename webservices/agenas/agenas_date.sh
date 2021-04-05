#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

if [[ $(hostname) == "DESKTOP-7NVNDNF" ]]; then
  dconvname="dconv"
else
  dconvname="dateutils.dconv"
fi

if [ -f "$folder"/processing/positivi-e-ricoverati.csv ]; then
  mlr --csv put '$data=system("echo \"".regextract_or_else($fonte,"[0-9]{1,} .+[0-9]{4}","")."\" | '"$dconvname"' --from-locale it_IT  -i \"%d %B %Y\"")' "$folder"/processing/positivi-e-ricoverati.csv >"$folder"/processing/positivi-e-ricoverati_date.csv
fi

if [ -f "$folder"/processing/postiletto-e-ricoverati-areaNonCritica.csv ]; then
  mlr --csv put '$data=system("echo \"".regextract_or_else($fonte,"[0-9]{1,} .+[0-9]{4}","")."\" | '"$dconvname"' --from-locale it_IT  -i \"%d %B %Y\"")' "$folder"/processing/postiletto-e-ricoverati-areaNonCritica.csv >"$folder"/processing/postiletto-e-ricoverati-areaNonCritica_date.csv
  mlr --csv join -j Regioni -f "$folder"/processing/postiletto-e-ricoverati-areaNonCritica_date.csv then unsparsify then sort -f data,Regioni then put '$soglia30=${Ricoverati in Terapia intensiva}/${PL in Terapia Intensiva}*100;if($soglia30>=30){$sopraSoglia="◼"}else{$sopraSoglia=""}' "$folder"/risorse/nomiCodiciRegioni.csv >"$folder"/tmp.csv
  mv "$folder"/tmp.csv "$folder"/processing/postiletto-e-ricoverati-areaNonCritica_date.csv
fi

