#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

git pull

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

# url dato geografico
URL="https://github.com/pcm-dpc/COVID-19/raw/master/aree/geojson/dpc-covid-19-aree-nuove-g-json.zip"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica e "lavora" i dati
if [ $code -eq 200 ]; then

  # svuota cartella rawdata se non è vuota

  if [ "$(ls -A "$folder"/rawdata)" ]; then
    rm "$folder"/rawdata/*
  else
    echo "è vuota"
  fi

  # scarica dati
  curl -kL "$URL" >"$folder"/rawdata/aree.zip

  # decomprimi i dati
  unzip -j "$folder"/rawdata/aree.zip -d "$folder"/rawdata

  # estrai ID dei poligoni regionali più aggiornati
  fidMax=$(ogr2ogr -f CSV "/vsistdout/" "$folder"/rawdata/dpc-covid-19-aree-nuove-g.json -dialect sqlite -sql 'SELECT FID from (select FID,nometesto,max(versionid) versionid from "dpc-covid-19-aree-nuove-g" where nomeTesto not LIKE '\''%nazio%'\'' group by nomeTesto)' | sed 's/"//g' | tr '\n' ',' | sed -r 's/FID,,//g;s/,$//g;s/[^0-9]$//g')

  # estrai soltanto le geometrie con gli ID di sopra
  ogr2ogr -f geojson "$folder"/rawdata/aree_raw.geojson "$folder"/rawdata/dpc-covid-19-aree-nuove-g.json -dialect sqlite -sql 'select * from "dpc-covid-19-aree-nuove-g" where FID IN ('"$fidMax"')' -lco RFC7946=YES

  # crea CSV di questo file
  ogr2ogr -f CSV "$folder"/rawdata/aree_raw.csv "$folder"/rawdata/aree_raw.geojson

  # crea CSV con informazioni di base e assegnazione zone
  mlr --csv cut -f nomeTesto,designIniz,designFine,nomeAutCom,legNomeBre,legData,legLink,legSpecRif,legLivello,legGU_Link \
    then clean-whitespace \
    then put -S '
      if($legSpecRif=="art.1")
        {$zona="gialla"}
      elif ($legSpecRif=="art.2")
        {$zona="arancione"}
      elif ($legSpecRif=="art.3")
        {$zona="rossa"}
      elif ($legSpecRif=="art.1 comma 11")
        {$zona="bianca"}
      else
        {$zona="NA"}' "$folder"/rawdata/aree_raw.csv >"$folder"/processing/tmp_aree.csv

  # aggiungi al CSV codici NUTS
  mlr --csv join --ul -j nomeTesto -f "$folder"/processing/tmp_aree.csv \
    then unsparsify \
    then reorder -f nomeTesto,zona,NUTS_code,NUTS_level "$folder"/risorse/codici.csv >"$folder"/processing/aree.csv

  # semplifica il file geojson
  mapshaper "$folder"/rawdata/aree_raw.geojson -simplify dp 20% -o format=geojson "$folder"/processing/aree.geojson

  # aggiungi al geojson i codici NUTS
  mapshaper "$folder"/processing/aree.geojson -join "$folder"/risorse/codici.csv keys=nomeTesto,nomeTesto -o "$folder"/processing/tmp.geojson

  # aggiungi al geojson l'assegnazione delle zone
  ogr2ogr -f GeoJSON "$folder"/processing/aree.geojson "$folder"/processing/tmp.geojson -dialect sqlite -sql "
SELECT *,
CASE
WHEN legSpecRif = 'art.3' Then 'rossa'
WHEN legSpecRif = 'art.2' Then 'arancione'
WHEN legSpecRif = 'art.1' Then 'gialla'
WHEN legSpecRif = 'art.1 comma 11' Then 'bianca'
ELSE 'NA' END as zona
from tmp"

  rm "$folder"/processing/tmp_aree.csv
  rm "$folder"/processing/tmp.geojson

  # genera SVG
  mapshaper "$folder"/processing/aree.geojson -colorizer name=calcFill colors='red,orange,yellow,white' categories='rossa,arancione,gialla,bianca' -style fill='calcFill(zona)' stroke-width=1 stroke=gray -o id-field=NUTS_code "$folder"/processing/aree.svg

  # genera png
  rsvg-convert "$folder"/processing/aree.svg -o "$folder"/processing/aree.png

  ## test ##

  # estrai file di insieme
  ogr2ogr -f CSV "/vsistdout/" "$folder"/rawdata/dpc-covid-19-aree-nuove-g.json -dialect sqlite -sql 'SELECT FID,nomeTesto,datasetIni,datasetFin,designIniz,designFine,nomeAutCom,legNomeBre,legData,legLink,legSpecRif,legLivello,legGU_Link,versionID,legDataAbr from "dpc-covid-19-aree-nuove-g"' >"$folder"/processing/areeStorico.csv

  # correggi errore associazione zona lazio https://github.com/pcm-dpc/COVID-19/issues/1045#issuecomment-841725392
  mlr -I --csv put -S 'if($datasetIni=="15/03/2021" && $nomeTesto=="Lazio" && $legSpecRif=="art.2"){$legSpecRif="art.3"}else{$legSpecRif=$legSpecRif}' then filter -x -S '$legDataAbr=~"[/]"' then cut -x -f legDataAbr "$folder"/processing/areeStorico.csv

  # estrai CSV e JSON grezzi
  mapshaper "$folder"/rawdata/dpc-covid-19-aree-nuove-g.json -o format=json "$folder"/processing/areeStorico.json
  ogr2ogr -f CSV "/vsistdout/" "$folder"/rawdata/dpc-covid-19-aree-nuove-g.json -dialect sqlite -sql 'SELECT * from "dpc-covid-19-aree-nuove-g"' | mlr --csv reorder -f FID,nomeTesto,versionID,datasetIni,datasetFin,legDataAbr,legSpecRif,legLink,legGU_Link >"$folder"/processing/areeStorico_raw.csv

  # classifica le zone
  mlr -I --csv clean-whitespace \
    then put -S '
      if($legSpecRif=="art.1")
        {$zona="gialla"}
      elif ($legSpecRif=="art.2")
        {$zona="arancione"}
      elif ($legSpecRif=="art.3")
        {$zona="rossa"}
      elif ($legSpecRif=="art.1 comma 11")
        {$zona="bianca"}
      else
        {$zona="NA"}' then \
    put -S '$datasetIniISO = strftime(strptime($datasetIni, "%d/%m/%Y"),"%Y-%m-%d");$datasetFinISO = strftime(strptime($datasetFin, "%d/%m/%Y"),"%Y-%m-%d")' then \
    sort -f datasetIniISO,nomeTesto then put -S '$versionID=sub($versionID,"^0+","")' "$folder"/processing/areeStorico.csv

  # aggiungi codici NUTS
  mlr --csv join --ul -j nomeTesto -f "$folder"/processing/areeStorico.csv \
    then unsparsify then sort -f datasetIniISO,nomeTesto "$folder"/risorse/codici.csv >"$folder"/processing/tmp_areeStorico.csv
  # rinomina
  mv "$folder"/processing/tmp_areeStorico.csv "$folder"/processing/areeStorico.csv

  # estrai valori di versionID per coppia NUTS_code,datasetIniISO
  mlr --csv stats1 -a max -f versionID -g NUTS_code,datasetIniISO then rename versionID_max,versionID "$folder"/processing/areeStorico.csv >"$folder"/rawdata/tmp_max.csv

  # filtra per ogni regione, tramite JOIN, soltanto l'ultima versione di assegnazione zona per giorno
  mlr --csv join -j NUTS_code,datasetIniISO,versionID -f "$folder"/processing/areeStorico.csv then unsparsify then sort -f datasetIniISO,nomeTesto "$folder"/rawdata/tmp_max.csv >"$folder"/rawdata/tmp.csv
  # rinomina file
  mv "$folder"/rawdata/tmp.csv "$folder"/processing/areeStorico.csv

  # crea la versione wide: una colonna con la data e una nuova colonna per ogni codice NUTS
  # laddove c'è un decreto che si applica a tutta la nazione applicalo a tutti i codici NUTS
  mlr --csv cut -f NUTS_code,datasetIniISO,zona then \
    reshape -s NUTS_code,zona then \
    unsparsify then \
    sort -f datasetIniISO then \
    put '
      for (key, value in $*) {
          if(key=~"^.{4}$" && $IT=~".+"){$[key]=$IT}else{$[key]=value};
        }
    ' "$folder"/processing/areeStorico.csv >"$folder"/processing/areeStorico_wide.csv

  # crea la versione long, con una sola colonna per i codici NUTS
  mlr --csv cut -x -f IT then \
    reshape -r "^IT.+" -o item,value then \
    filter -S '$value=~".+"' then \
    sort -f datasetIniISO then \
    label datasetIniISO,NUTS_code,zona "$folder"/processing/areeStorico_wide.csv >"$folder"/processing/areeStorico_long.csv

  # crea copia file wide
  cp "$folder"/processing/areeStorico_wide.csv "$folder"/processing/areeStorico_wide_fill_down.csv

  # per ogni colonna che contiene codici NUTS di livello 2 (regioni e province), applica il fill-down
  mlr --csv put -q 'NR == 1 {for (key in $*) {if (key=~"^.{4}$") {print key}}}' "$folder"/processing/areeStorico_wide.csv |
    while read line; do
      mlr -I --csv fill-down -f "$line" "$folder"/processing/areeStorico_wide_fill_down.csv
    done

  # rimuovi colonna con i valori di NUTS per l'intero paese
  mlr -I --csv cut -x -f IT "$folder"/processing/areeStorico_wide_fill_down.csv

  # rimuovi file temporanei
  rm "$folder"/rawdata/tmp*.csv

fi

# URL fonte dati
URL="http://www.governo.it/it/articolo/domande-frequenti-sulle-misure-adottate-dal-governo/15638"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica e "lavora" i dati
if [ $code -eq 200 ]; then

  # estrai da SVG governativa
  curl -kL "http://www.governo.it/it/articolo/domande-frequenti-sulle-misure-adottate-dal-governo/15638" | scrape -be '//svg' | xq '[.html.body.svg.g[].path[]|{id:.["@id"]?,colore:.["@onclick"]?}]' | mlr --j2c skip-trivial-records then put -S '$colore=sub($colore,"^.+[(].","");$colore=sub($colore,".[)]$","")' >"$folder"/rawdata/areeGov.csv

  mlr --csv join --ul -j id -f "$folder"/rawdata/areeGov.csv then unsparsify "$folder"/risorse/codiciSVGGoverno.csv >"$folder"/rawdata/tmp.csv

  mlr -I --csv put -S 'if ($colore==""){$colore="bianco"}else{$colore=$colore}' "$folder"/rawdata/tmp.csv

  # crea file di output soltanto se composto da 21 regioni NUTS2, più intestazione
  conteggio=$(wc <"$folder"/rawdata/tmp.csv -l)

  if [[ $conteggio == 22 ]]; then

    mv "$folder"/rawdata/tmp.csv "$folder"/processing/areeGov.csv
    dos2unix "$folder"/processing/areeGov.csv

  fi

  # dati di insieme numero giorni regioni in zone
  # nota bene: si fa partire dal 15 novembre per avere un range confrontabile tra tutte le regioni

  oggi=$(date '+%Y-%m-%d')
  datamax=$(mlr --c2n stats1 -a max -f datasetIniISO "$folder"/processing/areeStorico_wide_fill_down.csv)

  if [ $(date -d "$oggi" +%s) -gt $(date -d "$datamax" +%s) ]; then
    echo "è maggiore"
    echo 'datasetIniISO='"$oggi"'' | mlr --ocsv cat >"$folder"/processing/tmp_a.csv

    mlr --csv unsparsify "$folder"/processing/areeStorico_wide_fill_down.csv "$folder"/processing/tmp_a.csv | sponge processing/tmp_a.csv

    mlr --csv put -q 'NR == 1 {for (key in $*) {if (key=~"[0-9]") {print key}}}' "$folder"/processing/tmp_a.csv |
      while read line; do
        mlr -I --csv fill-down -f "$line" "$folder"/processing/tmp_a.csv
      done
    mv "$folder"/processing/tmp_a.csv "$folder"/processing/areeStorico_wide_fill_down.csv
  else
    echo "è minore"
  fi

  mlr --csv reshape -r "[0-9]" -o item,value then sort -f item,datasetIniISO then filter -S '$datasetIniISO>"2020-11-14"' then rename item,NUTS_code,value,zona "$folder"/processing/areeStorico_wide_fill_down.csv | mlr --csv put -S '$c=strptime($datasetIniISO,"%Y-%m-%d")' then step -a delta -f c -g NUTS_code then step -a shift -f zona -g NUTS_code then stats1 -a sum -f c_delta -g NUTS_code,zona_shift then put '$c_delta_sum=int($c_delta_sum/60/60/24)' then rename zona_shift,zona  then filter -x -S '$zona==""' then reshape -s zona,c_delta_sum then unsparsify >"$folder"/processing/areeStorico_giorni_nuts_wide.csv

  mlr --csv join --ul -j NUTS_code -f "$folder"/processing/areeStorico_giorni_nuts_wide.csv then unsparsify "$folder"/risorse/codici.csv >"$folder"/processing/tmp.csv

  mv "$folder"/processing/tmp.csv "$folder"/processing/areeStorico_giorni_nuts_wide.csv

  mlr -I --csv sort -nr rossa,arancione,gialla "$folder"/processing/areeStorico_giorni_nuts_wide.csv

fi
