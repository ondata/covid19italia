#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing

curl -k "https://www.dep.lazio.it/covid/covid_map.php" | scrape -be '//div[@id="nav-comuni"]//script' | xq -r '.html.body.script' | awk 'f{ if (/\]\]/){printf "%s", buf; f=0; buf=""} else buf = buf $0 ORS}; /\[\[/{f=1}' | sed '1s/^/[[/' | sed -e "\$a]]" | jq '[.[]|{ISTAT:.[0],comune:.[1],casi:.[2],tasso:.[3]}]' | mlr --j2c cat >"$folder"/processing/comuni.csv

curl -k "https://www.dep.lazio.it/covid/covid_map.php" | scrape -be '//div[@id="nav-distretti"]//script' | xq -r '.html.body.script' | awk 'f{ if (/\]\]/){printf "%s", buf; f=0; buf=""} else buf = buf $0 ORS}; /\[\[/{f=1}' | sed '1s/^/[[/' | sed -e "\$a]]" | jq '[.[]|{codice:.[0],distretto:.[1],casi:.[2],tasso:.[3]}]' | mlr --j2c cat >"$folder"/processing/distretti.csv

curl -k "https://www.dep.lazio.it/covid/covid_map.php" | scrape -be '//div[@id="nav-zurb"]//script' | xq -r '.html.body.script' | awk 'f{ if (/\]\]/){printf "%s", buf; f=0; buf=""} else buf = buf $0 ORS}; /\[\[/{f=1}' | sed '1s/^/[[/' | sed -e "\$a]]" | jq '[.[]|{cod:.[0],zona:.[1],casi:.[2],tasso:.[3]}]' | mlr --j2c cat >"$folder"/processing/zoneurbane.csv
