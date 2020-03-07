#!/bin/bash

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -x

while IFS=$'\t' read -r url layer; do
    iso=$(date --iso-8601)
    curl -sL "$url" >"$folder"/webMapServices/"$iso"_"$layer".geojson
    ogr2ogr -f CSV -lco GEOMETRY=AS_XY "$folder"/webMapServices/"$iso"_"$layer".csv "$folder"/webMapServices/"$iso"_"$layer".geojson
done <"$folder"/webMapServicesList.tsv
