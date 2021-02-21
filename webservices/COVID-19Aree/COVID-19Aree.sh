#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

# url dato geografico
URL="https://github.com/pcm-dpc/COVID-19/raw/master/aree/geojson/dpc-covid-19-aree-nuove-g-json.zip"




# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica e "lavora" i dati
if [ $code -eq 200 ]; then

  # scarica dati
  curl -kL "$URL" >"$folder"/rawdata/aree.zip

  # decomprimi i dati
  yes | unzip -j "$folder"/rawdata/aree.zip -d "$folder"/rawdata

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
ELSE 'NA' END as zona
from tmp"

  rm "$folder"/processing/tmp_aree.csv
  rm "$folder"/processing/tmp.geojson

  # genera SVG
  mapshaper "$folder"/processing/aree.geojson -colorizer name=calcFill colors='red,orange,yellow' categories='rossa,arancione,gialla' -style fill='calcFill(zona)' stroke-width=1 stroke=gray -o id-field=NUTS_code "$folder"/processing/aree.svg

  # genera png
  rsvg-convert "$folder"/processing/aree.svg -o "$folder"/processing/aree.png

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

  # crea file di output soltanto se composto da 21 regioni NUTS2, più intestazione
  conteggio=$(wc <"$folder"/rawdata/tmp.csv -l)

  if [[ $conteggio == 22 ]]; then

    mv "$folder"/rawdata/tmp.csv "$folder"/processing/areeGov.csv
    dos2unix "$folder"/processing/areeGov.csv

  fi

fi
