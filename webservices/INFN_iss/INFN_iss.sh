#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/rawdata

URL="https://covid19.infn.it/iss/"

#google-chrome-stable --headless --disable-gpu --dump-dom --virtual-time-budget=99999999 --run-all-compositor-stages-before-draw "$URL" >"$folder"/rawdata/INFN_iss.html

grep <"$folder"/rawdata/INFN_iss.html -Po '"filename": ".+?"' >"$folder"/rawdata/file

sed -i -r 's/^.+ //g;s/"//g' "$folder"/rawdata/file

cat "$folder"/rawdata/file | while read line; do
  echo "$line"
  curl -kL "https://covid19.infn.it/iss/plots/$line.div" >"$folder"/rawdata/"$line".html
  grep <"$folder"/rawdata/"$line".html -P '.+"hoverinfo".+' | grep -oP '\[.+\]' >"$folder"/processing/"$line".json
done
