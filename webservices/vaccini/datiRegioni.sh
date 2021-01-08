#!/bin/bash

### requisiti ###
# jq https://stedolan.github.io/jq/
# miller  https://github.com/johnkerl/miller
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing/datiRegioni

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
  ' then rename b,vaccino,d,punto,e,classeEta \
  then sort -f data,categoria,classeEta,punto -n somministrazioni "$folder"/processing/datiRegioni/"$i".csv
done

# fai il merge dei dati di dettaglio regionali
mlr --csv sort -f codice_regione,data,categoria,classeEta,punto -n somministrazioni "$folder"/processing/datiRegioni/*.csv >"$folder"/processing/datiRegioni.csv
