#!/bin/bash

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -x

while IFS=$'\t' read -r url layer; do
    curl -sL "$url" >"$folder"/webMapServices/"$layer".geojson
    ogr2ogr -f CSV -lco GEOMETRY=AS_XY "$folder"/webMapServices/"$layer".csv "$folder"/webMapServices/"$layer".geojson
done <"$folder"/webMapServicesList.tsv
