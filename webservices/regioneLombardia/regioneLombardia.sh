#!/bin/bash

### requisiti ###
# gdal/ogr https://gdal.org/index.html
# miller https://github.com/johnkerl/miller
### requisiti ###

set -x

debugMode="off"

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/processing/INCR_DATE_TAMP_RL_v2
mkdir -p "$folder"/processing/INCR_DATE_TAMP_RL

dos2unix "$folder"/risorse

while IFS=$'\t' read -r nome formato url attivo; do
    if [[ "$attivo" == "1" ]]; then
        curl -kL "$url" >"$folder"/rawdata/"$nome"."$formato"
    fi
done <"$folder"/risorse

# ogr2ogr -f CSV -lco GEOMETRY=AS_XY "$folder"/processing/ta_covid19_comuni_time.csv "$folder"/rawdata/ta_covid19_comuni_time.geojson

# ogr2ogr -f CSV "$folder"/processing/COMUNI_COVID19.csv "$folder"/rawdata/COMUNI_COVID19.geojson

ogr2ogr -f CSV "$folder"/processing/PROVINCE_COVID19.csv "$folder"/rawdata/PROVINCE_COVID19.geojson

rm "$folder"/rawdata/INCR_DATE_PRV_TAMP_RL_v2.json

ogr2ogr "$folder"/rawdata/INCR_DATE_PRV_TAMP_RL_v2.json  -f GEOJson "https://services1.arcgis.com/XannvQVnsM1hoZyv/ArcGIS/rest/services/INCR_DATE_PRV_TAMP_RL_v2/FeatureServer/0/query?where=objectid>0&outfields=*&f=geojson" OGRGeoJSON -oo FEATURE_SERVER_PAGING="YES"

jq <"$folder"/rawdata/INCR_DATE_PRV_TAMP_RL_v2.json '.features[].properties' | mlr --j2c unsparsify >"$folder"/processing/INCR_DATE_PRV_TAMP_RL_v2.csv

mkdir -p "$folder"/processing/INCR_DATE_PRV_TAMP_RL_v2

date=$(date '+%Y-%m-%d')

jq <"$folder"/rawdata/INCR_DATE_PRV_TAMP_RL_v2.json '.features[].attributes' | mlr --j2c cat >"$folder"/processing/INCR_DATE_PRV_TAMP_RL_v2/"$date"-INCR_DATE_PRV_TAMP_RL_v2.csv

#jq <"$folder"/rawdata/INCR_DATE_TAMP_RL_v2.json '.features[].attributes' | mlr --j2c cat >"$folder"/processing/INCR_DATE_TAMP_RL_v2/"$date"-INCR_DATE_TAMP_RL_v2.csv

jq <"$folder"/rawdata/INCR_DATE_TAMP_RL.json '.features[].attributes' | mlr --j2c cat >"$folder"/processing/INCR_DATE_TAMP_RL/"$date"-INCR_DATE_TAMP_RL.csv

host=$(hostname)
if [[ "$host" == "ex-machina.ondata.it" ]] && [[ "$debugMode" == "off" ]]; then
    # commit e push
    . ~/.keychain/$HOSTNAME-sh

    cd "$folder"
    git -C "$folder" pull
    git -C "$folder" add .
    git -C "$folder" commit -am "update"
    git -C "$folder" push origin master

fi
