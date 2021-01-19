#!/bin/bash

### requisiti ###
# jq https://stedolan.github.io/jq/
# miller  https://github.com/johnkerl/miller
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing/datiRegioni
mkdir -p "$folder"/rawdata

# url dashboard
URL="https://app.powerbi.com/view?r=eyJrIjoiMzg4YmI5NDQtZDM5ZC00ZTIyLTgxN2MtOTBkMWM4MTUyYTg0IiwidCI6ImFmZDBhNzVjLTg2NzEtNGNjZS05MDYxLTJjYTBkOTJlNDIyZiIsImMiOjh9"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URL")

if [ $code -eq 200 ]; then

  # scarica microdati su regioni
  scaricaR="sì"

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

  if [[ $scaricaR == "sì" ]]; then
    while IFS=$'\t' read -r nome codice; do
      echo "$nome"

      curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
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
{ "Condition": { "In": { "Expressions": [ { "Column": { "Expression": { "SourceRef": { "Source": "t1" } }, "Property": "REGIONE" } } ], "Values": [ [ { "Literal": { "Value":"'"\'$nome\'"'" } } ] ] } } } ], "GroupBy": [ { "SourceRef": { "Source": "t" }, "Name": "TAB_MASTER_PIVOT" } ] }, "Binding": { "Primary": { "Groupings": [ { "Projections": [ 0, 1, 2, 3, 4 ], "GroupBy": [ 0 ] } ] }, "DataReduction": { "Primary": { "Top": { "Count": 30000 } } }, "Version": 1 } } } ] }, "QueryId": "", "ApplicationContext": { "DatasetId": "5bff6260-1025-49e0-8e9b-169ade7c07f9", "Sources": [ { "ReportId": "b548a77c-ab0a-4d7c-a457-2e38c2914fc6" } ] } } ], "cancelQueries": [], "modelId": 4280811 }' \
        --compressed | jq -c '.results[0].result.data.dsr.DS' >"$folder"/processing/datiRegioni/"$codice".json

    done <"$folder"/risorse/listaRegioni.tsv

    curl 'https://wabi-europe-north-b-api.analysis.windows.net/public/reports/querydata?synchronous=true' \
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
      --compressed | jq -c '.results[0].result.data.dsr.DS' >"$folder"/processing/datiRegioni/02.json

  fi

  # estrai file con codici NUTS2
  mlr --csv cut -f siglaRegione,NUTS2 "$folder"/risorse/codiciTerritoriali.csv >"$folder"/processing/datiRegioni/tmp_nuts2.csv

  for i in {01..20}; do

    jq <"$folder"/processing/datiRegioni/"$i".json '.[0].PH[0].DM0' | mlr --j2c unsparsify >"$folder"/rawdata/tmp.csv

    mlr --c2t cut -x -r -f "S:" then label a,b,c,d,e,R then put -S '
  if($R=="23"){
  if($a=~"/"){$punto=$a}else{$punto=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D2[".$a."]\"")}
  }
  elif($R==""){
  $somm=$a;
  if($b=~"/"){$regione=$b}else{$regione=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D0[".$b."]\"")};
  if($c=~"/"){$cat=$c}else{$cat=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D1[".$c."]\"")};
  if($d=~"/"){$punto=$d}else{$punto=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D2[".$d."]\"")};
  if($e=~"/"){$tipo=$e}else{$tipo=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D3[".$e."]\"")};
  }
  elif($R=="2"){
  $somm=$a;
  if($b=~"/"){$cat=$b}else{$cat=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D1[".$b."]\"")};
  if($c=~"/"){$punto=$c}else{$punto=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D2[".$c."]\"")};
  if($d=~"/"){$tipo=$d}else{$tipo=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D3[".$d."]\"")};
  }
  elif($R=="3"){
  if($a=~"/"){$cat=$a}else{$cat=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D1[".$a."]\"")};
  if($b=~"/"){$punto=$b}else{$punto=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D2[".$b."]\"")};
  if($c=~"/"){$tipo=$c}else{$tipo=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D3[".$c."]\"")};
  }
  elif($R=="22"){
  $somm=$a;
  if($b=~"/"){$punto=$b}else{$punto=system("<'"$folder"'/processing/datiRegioni/'"$i"'.json jq -r \".[0].ValueDicts.D2[".$b."]\"")};
  }
  ' then unsparsify then fill-down -f somm,regione,cat,punto,tipo then cut -f somm,regione,cat,punto,tipo "$folder"/rawdata/tmp.csv >"$folder"/processing/datiRegioni/"$i".csv

    mlr -I --t2c --ors '\r\n' label somministrazioni,regione,siglaCategoria,identificativo,categoria then put -S '$identificativo=gsub($identificativo,"\n"," ")' then clean-whitespace "$folder"/processing/datiRegioni/"$i".csv

    # aggiungi codice regione ed estrai data, vaccino, punto di somministrazione e classe d'età
    mlr -I --csv put -S '
  $codice_regione=sub(FILENAME,"^(.+/)([0-9]+)(\..+)$","\2");
  $data=strftime(strptime(sub(sub($identificativo,"^([0-9]+/[0-9]+/[0-9]+)_(.+)_([A-Z]{3})_(.+)_([0-9]+(-|[+])*[0-9]*)$","\1"),"_.+",""), "%d/%m/%Y"),"%Y-%m-%d");
  $b=sub($identificativo,"^([0-9]+/[0-9]+/[0-9]+)_(.+)_([A-Z]{3})_(.+)_([0-9]+(-|[+])*[0-9]*)$","\2");
  $d=sub($identificativo,"^([0-9]+/[0-9]+/[0-9]+)_(.+)_([A-Z]{3})_(.+)_([0-9]+(-|[+])*[0-9]*)$","\4");
  $e=sub($identificativo,"^([0-9]+/[0-9]+/[0-9]+)_(.+)_([A-Z]{3})_(.+)_([0-9]+(-|[+])*[0-9]*)$","\5");
  $c=sub($identificativo,"^([0-9]+/[0-9]+/[0-9]+)_(.+)_([A-Z]{3})_(.+)_([0-9]+(-|[+])*[0-9]*)$","\3");
  ' then rename b,vaccino,d,punto,e,classeEta,c,siglaRegione \
      then sort -f data,categoria,classeEta,punto -n somministrazioni "$folder"/processing/datiRegioni/"$i".csv

    # aggiungi codice NUTS2
    mlr --csv join --ul -j siglaRegione -f "$folder"/processing/datiRegioni/"$i".csv then unsparsify then reorder -e -f siglaRegione,NUTS2 "$folder"/processing/datiRegioni/tmp_nuts2.csv >"$folder"/processing/datiRegioni/tmp.csv

    mv "$folder"/processing/datiRegioni/tmp.csv "$folder"/processing/datiRegioni/"$i".csv

  done

  # fai pulizia
  rm "$folder"/processing/datiRegioni/tmp_nuts2.csv

  # fai il merge dei dati di dettaglio regionali
  mlr --csv sort -f codice_regione,data,categoria,classeEta,punto -n somministrazioni "$folder"/processing/datiRegioni/*.csv >"$folder"/processing/datiRegioni.csv

fi
