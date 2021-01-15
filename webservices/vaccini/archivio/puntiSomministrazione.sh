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

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/rawdata/puntiSomministrazione
mkdir -p "$folder"/processing
mkdir -p "$folder"/processing/puntiSomministrazione

# url dashboard
URL="https://app.powerbi.com/view?r=eyJrIjoiMzg4YmI5NDQtZDM5ZC00ZTIyLTgxN2MtOTBkMWM4MTUyYTg0IiwidCI6ImFmZDBhNzVjLTg2NzEtNGNjZS05MDYxLTJjYTBkOTJlNDIyZiIsImMiOjh9"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica e "lavora" i dati
if [ $code -eq 200 ]; then

  # scarica microdati su regioni. Al momento non si comprende la mappatura dei file JSON di output
  scaricaP="sì"

  if [[ $scaricaP == "sì" ]]; then
    while IFS=$'\t' read -r nome codice; do
      echo "$nome"

      curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
        -H 'Connection: keep-alive' \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'RequestId: 699c9622-fe70-f5c8-d562-c4a133bca84b' \
        -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' \
        -H 'Content-Type: application/json;charset=UTF-8' \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36' \
        -H 'ActivityId: 66610f38-9c48-46d5-8902-99b874fa73ba' \
        -H 'Origin: https://app.powerbi.com' \
        -H 'Sec-Fetch-Site: cross-site' \
        -H 'Sec-Fetch-Mode: cors' \
        -H 'Sec-Fetch-Dest: empty' \
        -H 'Referer: https://app.powerbi.com/' \
        -H 'Accept-Language: en-US,en;q=0.9,it;q=0.8' \
        --data-binary $'{"version":"1.0.0","queries":[{"Query":{"Commands":[{"SemanticQueryDataShapeCommand":{"Query":{"Version":2,"From":[{"Name":"c","Entity":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI","Type":0}],"Select":[{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"DEN_PRESIDIO_OSPEDALIERO"},"Name":"Count(cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.DEN_PRESIDIO_OSPEDALIERO)"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"REGIONI"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.REGIONI"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"ID_AREA"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.ID_AREA"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"AREA"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.AREA"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"PROVINCIA"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.PROVINCIA"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"COMUNE"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.COMUNE"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"INDIRIZZO"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.INDIRIZZO"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"CAP"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.CAP"}],"Where":[{"Condition":{"In":{"Expressions":[{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"REGIONI"}}],"Values":[[{"Literal":{"Value":"'"\'$nome\'"'"}}]]}}}],"GroupBy":[{"SourceRef":{"Source":"c"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI"}]},"Binding":{"Primary":{"Groupings":[{"Projections":[0,1,2,3,4,5,6,7],"GroupBy":[0]}]},"DataReduction":{"Primary":{"Top":{"Count":1000}}},"Version":1}}}]},"QueryId":"","ApplicationContext":{"DatasetId":"5bff6260-1025-49e0-8e9b-169ade7c07f9","Sources":[{"ReportId":"b548a77c-ab0a-4d7c-a457-2e38c2914fc6"}]}}],"cancelQueries":[],"modelId":4280811}' \
        --compressed | jq -c '.results[0].result.data.dsr.DS' >"$folder"/processing/puntiSomministrazione/"$codice".json

    done \
      <"$folder"/risorse/listaRegioni.tsv

    curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
      -H 'Connection: keep-alive' \
      -H 'Accept: application/json, text/plain, */*' \
      -H 'RequestId: 699c9622-fe70-f5c8-d562-c4a133bca84b' \
      -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' \
      -H 'Content-Type: application/json;charset=UTF-8' \
      -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36' \
      -H 'ActivityId: 66610f38-9c48-46d5-8902-99b874fa73ba' \
      -H 'Origin: https://app.powerbi.com' \
      -H 'Sec-Fetch-Site: cross-site' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Dest: empty' \
      -H 'Referer: https://app.powerbi.com/' \
      -H 'Accept-Language: en-US,en;q=0.9,it;q=0.8' \
      --data-binary $'{"version":"1.0.0","queries":[{"Query":{"Commands":[{"SemanticQueryDataShapeCommand":{"Query":{"Version":2,"From":[{"Name":"c","Entity":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI","Type":0}],"Select":[{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"DEN_PRESIDIO_OSPEDALIERO"},"Name":"Count(cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.DEN_PRESIDIO_OSPEDALIERO)"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"REGIONI"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.REGIONI"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"ID_AREA"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.ID_AREA"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"AREA"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.AREA"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"PROVINCIA"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.PROVINCIA"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"COMUNE"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.COMUNE"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"INDIRIZZO"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.INDIRIZZO"},{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"CAP"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI.CAP"}],"Where":[{"Condition":{"In":{"Expressions":[{"Column":{"Expression":{"SourceRef":{"Source":"c"}},"Property":"REGIONI"}}],"Values":[[{"Literal":{"Value":"\'Valle d\'\'Aosta\'"}}]]}}}],"GroupBy":[{"SourceRef":{"Source":"c"},"Name":"cfg VACCINI_PUNTI_SOMMINISTRAZIONE_DOSI_REGIONI"}]},"Binding":{"Primary":{"Groupings":[{"Projections":[0,1,2,3,4,5,6,7],"GroupBy":[0]}]},"DataReduction":{"Primary":{"Top":{"Count":1000}}},"Version":1}}}]},"QueryId":"","ApplicationContext":{"DatasetId":"5bff6260-1025-49e0-8e9b-169ade7c07f9","Sources":[{"ReportId":"b548a77c-ab0a-4d7c-a457-2e38c2914fc6"}]}}],"cancelQueries":[],"modelId":4280811}' \
      --compressed | jq -c '.results[0].result.data.dsr.DS' >"$folder"/processing/puntiSomministrazione/02.json

  fi
fi
