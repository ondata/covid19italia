#!/bin/bash

### requisiti ###
# gdal/ogr https://gdal.org/index.html
# miller https://github.com/johnkerl/miller
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

while IFS=$'\t' read -r nome formato url; do
    curl -kL "$url" >"$folder"/rawdata/"$nome"."$formato"
done <"$folder"/risorse

ogr2ogr -f CSV -lco GEOMETRY=AS_XY "$folder"/processing/ta_covid19_comuni_time.csv "$folder"/rawdata/ta_covid19_comuni_time.geojson

ogr2ogr -f CSV "$folder"/processing/COMUNI_COVID19.csv "$folder"/rawdata/COMUNI_COVID19.geojson

ogr2ogr -f CSV "$folder"/processing/PROVINCE_COVID19.csv "$folder"/rawdata/PROVINCE_COVID19.geojson

### TA_COVID19_RL ###

# crea cartella contenitore dati
mkdir -p "$folder"/TA_COVID19_RL
rm "$folder"/TA_COVID19_RL/*

URLTA_COVID19_RL="https://services1.arcgis.com/XannvQVnsM1hoZyv/ArcGIS/rest/services/TA_COVID19_RL/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=none&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=true&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token="

# conteggia il totale delle risorse
conteggioRisorse=$(curl "$URLTA_COVID19_RL" | jq -r '.count + 2000')

# scarica dati in loop
DA=0
A=2001
while [  $DA -lt "$conteggioRisorse" ]; do
	curl -kL "https://services1.arcgis.com/XannvQVnsM1hoZyv/ArcGIS/rest/services/TA_COVID19_RL/FeatureServer/0/query?where=objectid>$DA+AND+objectid<$A&objectIds=&time=&resultType=none&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token=" >"$folder"/TA_COVID19_RL/"$DA".json
  <"$folder"/TA_COVID19_RL/"$DA".json jq  '.features[].attributes' | mlr --j2c unsparsify >"$folder"/TA_COVID19_RL/"$DA".csv
	let DA=DA+2000
	let A=A+2000
done

# fai il merge
mlr --csv clean-whitespace "$folder"/TA_COVID19_RL/*.csv >"$folder"/processing/TA_COVID19_RL.csv

### TA_COVID19_RL ###

<"$folder"/rawdata/INCR_DATE_PRV_TAMP_RL_v2.json jq '.features[].attributes' | mlr --j2c cat >"$folder"/processing/INCR_DATE_PRV_TAMP_RL_v2.csv

mkdir -p "$folder"/processing/INCR_DATE_PRV_TAMP_RL_v2

date=$(date '+%Y-%m-%d')

<"$folder"/rawdata/INCR_DATE_PRV_TAMP_RL_v2.json jq '.features[].attributes' | mlr --j2c cat >"$folder"/processing/INCR_DATE_PRV_TAMP_RL_v2/"$date"-INCR_DATE_PRV_TAMP_RL_v2.csv

# commit e push

. ~/.keychain/$HOSTNAME-sh

cd "$folder"
git -C "$folder" pull
git -C "$folder" add .
git -C "$folder" commit -am "update"
git -C "$folder" push origin master
