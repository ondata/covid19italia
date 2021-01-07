#!/bin/bash

### requisiti ###
# google-chrome headless http://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# jq https://stedolan.github.io/jq/
# miller  https://github.com/johnkerl/miller
# scrape-cli https://github.com/aborruso/scrape-cli
# yq https://kislyuk.github.io/yq/
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/risorse

dataFlowID="22_289"

# estrai dati popolazione delle regioni
curl -kL -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "http://sdmx.istat.it/SDMXWS/rest/data/$dataFlowID/A.TOTAL..9.99.?startPeriod=2020" >"$folder"/risorse/popolazione.csv

mlr <"$folder"/risorse/popolazione.csv --csv filter -S '$ITTER107=~"^IT[A-Z][0-9]$"' >"$folder"/risorse/popolazioneRegioni.csv

# estrai id e nomi regioni
curl "http://sdmx.istat.it/SDMXWS/rest/codelist/IT1/CL_ITTER107" | xq '.["message:Structure"]["message:Structures"]["structure:Codelists"]["structure:Codelist"]["structure:Code"][]' | mlr --j2c unsparsify then rename -r '@,' then rename -r '.+Name:0.+,Name' then filter -S '$id=~"^IT[A-Z][0-9]$"' then cut -f id,Name >"$folder"/risorse/anagraficaRegioni.csv

# fai il join di popolazione e anagrafica
mlr --csv join --ul -j ITTER107 -l ITTER107 -r id -f "$folder"/risorse/popolazioneRegioni.csv then cut -f ITTER107,TIME_PERIOD,OBS_VALUE,Name "$folder"/risorse/anagraficaRegioni.csv >"$folder"/risorse/tmp.csv

mv "$folder"/risorse/tmp.csv "$folder"/risorse/popolazioneRegioni.csv
