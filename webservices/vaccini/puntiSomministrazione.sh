#!/bin/bash

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

  rispostaAPI=$(curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
    -H 'Connection: keep-alive' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' \
    -H 'Content-Type: application/json;charset=UTF-8' \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36' \
    -H 'Origin: https://app.powerbi.com' \
    -H 'Sec-Fetch-Site: cross-site' \
    -H 'Sec-Fetch-Mode: cors' \
    -H 'Sec-Fetch-Dest: empty' \
    -H 'Referer: https://app.powerbi.com/' \
    -H 'Accept-Language: en-US,en;q=0.9,it;q=0.8' \
    --data-binary $'{ "version": "1.0.0", "queries": [ { "Query": { "Commands": [ { "SemanticQueryDataShapeCommand": { "Query": { "Version": 2, "From": [ { "Name": "t", "Entity": "TAB_MASTER_PIVOT", "Type": 0 }, { "Name": "t1", "Entity": "TAB_REGIONI", "Type": 0 } ], "Select": [ { "Column": { "Expression": { "SourceRef": { "Source": "t" } }, "Property": "Valore" }, "Name": "Sum(TAB_MASTER_PIVOT.Valore)" }, { "Column": { "Expression": { "SourceRef": { "Source": "t1" } }, "Property": "REGIONE" }, "Name": "TAB_REGIONI.REGIONE" }, { "Column": { "Expression": { "SourceRef": { "Source": "t" } }, "Property": "Attributo" }, "Name": "TAB_MASTER_PIVOT.Attributo" }, { "Column": { "Expression": { "SourceRef": { "Source": "t" } }, "Property": "KEY" }, "Name": "TAB_MASTER_PIVOT.KEY" }, { "Column": { "Expression": { "SourceRef": { "Source": "t" } }, "Property": "Categoria Attributo" }, "Name": "TAB_MASTER_PIVOT.Categoria Attributo" } ], "Where": [
{ "Condition": { "Comparison": { "ComparisonKind": 1, "Left": { "Column": { "Expression": { "SourceRef": { "Source": "t" } }, "Property": "Valore" } }, "Right": { "Literal": { "Value": "0L" } } } } },
{ "Condition": { "In": { "Expressions": [ { "Column": { "Expression": { "SourceRef": { "Source": "t1" } }, "Property": "REGIONE" } } ], "Values": [ [ { "Literal": { "Value":"\'Valle d\'\'Aosta\'" } } ] ] } } } ], "GroupBy": [ { "SourceRef": { "Source": "t" }, "Name": "TAB_MASTER_PIVOT" } ] }, "Binding": { "Primary": { "Groupings": [ { "Projections": [ 0, 1, 2, 3, 4 ], "GroupBy": [ 0 ] } ] }, "DataReduction": { "Primary": { "Top": { "Count": 30000 } } }, "Version": 1 } } } ] }, "QueryId": "", "ApplicationContext": { "DatasetId": "5bff6260-1025-49e0-8e9b-169ade7c07f9", "Sources": [ { "ReportId": "b548a77c-ab0a-4d7c-a457-2e38c2914fc6" } ] } } ], "cancelQueries": [], "modelId": 4280811 }' \
    --compressed | jq -r '.error.code')

  if [[ $rispostaAPI == "KeyFoundInDeletedResourceKeyCacheException" ]]; then
    exit
  fi

  # scarica dati in formato JSON
  curl -s 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' --compressed -H 'Content-Type: application/json;charset=UTF-8' -H 'X-PowerBI-ResourceKey: 388bb944-d39d-4e22-817c-90d1c8152a84' --data @"$folder"/risorse/query_punti-di-somministrazione.json | jq . >"$folder"/processing/puntiSomministrazione/tmp_puntiSomministrazione.json

  # converti JSON in CSV
  python3 "$folder"/puntiSomministrazione.py "$folder"/processing/puntiSomministrazione/tmp_puntiSomministrazione.json "$folder"/processing/puntiSomministrazione/puntiSomministrazione.csv

  mlr -I --csv clean-whitespace then rename ID_AREA,siglaRegione "$folder"/processing/puntiSomministrazione/puntiSomministrazione.csv

  # aggiungi codice geografici standard
  mlr --csv join --ul -j siglaRegione -f "$folder"/processing/puntiSomministrazione/puntiSomministrazione.csv then unsparsify then cut -x -f Name,ITTER107 then clean-whitespace then uniq -a "$folder"/risorse/codiciTerritoriali.csv >"$folder"/processing/puntiSomministrazione/tmp.csv

  mv "$folder"/processing/puntiSomministrazione/tmp.csv "$folder"/processing/puntiSomministrazione/puntiSomministrazione.csv

fi

# scarica dettagli su dosi, sesso e categorie per punti di somministrazione

URLdati="https://github.com/slarosa/vax/raw/main/data/vax_total.csv"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URLdati")

# se il sito è raggiungibile scarica e "lavora" i dati
if [ $code -eq 200 ]; then

  # scarica dati in formato JSON
  curl -kL "$URLdati" >"$folder"/processing/puntiSomministrazione/puntiSomministrazioneDatiVax.csv

  mlr -I --csv sort -f TML_DTA_SOMM,TML_REGIONE,TML_DES_STRUTTURA,TML_VAX_FORNITORE \
    then rename TML_DTA_SOMM,data,TML_VAX_FORNITORE,vaccino,TML_AREA,siglaRegione,TML_REGIONE,regione,TML_NUTS,NUTS2 \
    then clean-whitespace "$folder"/processing/puntiSomministrazione/puntiSomministrazioneDatiVax.csv

fi
