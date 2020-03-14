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

<"$folder"/rawdata/TA_COVID19_RL.json jq '.features[].attributes' | mlr --j2c cat >"$folder"/processing/TA_COVID19_RL.csv
