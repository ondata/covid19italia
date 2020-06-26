#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/risorse

# svuota cartella
#rm "$folder"/processing/*
rm "$folder"/rawdata/*

### dashboard 30 giorni ###
url30="https://www.epicentro.iss.it/coronavirus/dashboard/30gg.html"

# estrai id dei div html
curl -kL "$url30" >"$folder"/rawdata/Dashboard_finale_30gg.html
scrape <"$folder"/rawdata/Dashboard_finale_30gg.html -be '//div[contains(@id,"htmlwidget-")]' |
    xq -r '.html.body.div[]."@id"' >"$folder"/rawdata/listaDivId30gg

# per ogni div estrai i dati JSON
while read p; do
    echo "$p"
    scrape <"$folder"/rawdata/Dashboard_finale_30gg.html -be '//div[@id="'"$p"'"]/following::script[1]' |
        xq -r '.html.body.script."#text"' | jq . >"$folder"/rawdata/"$p".json
done <"$folder"/rawdata/listaDivId30gg

# estrai la sezione con i dati dal JSON relativo ai casi per Provincia di domicilio o di residenza
jq <"$folder"/rawdata/htmlwidget-4d57cc3e2f385faa0d5f.json -r '.x.calls[1].args[6][]' >"$folder"/rawdata/casi30gg.csv
# converti in TSV
sed -i -r 's/^(.+[a-zA-Z])( +)([0-9]+).*$/\1\t\3/g' "$folder"/rawdata/casi30gg.csv
# converti in CSV
mlr -I --t2c --implicit-csv-header label provincia,casi then sort -f provincia "$folder"/rawdata/casi30gg.csv

# estrai la sezione con i dati dal JSON relativo alla Curva epidemica con data Inizio Sintomi
# dei casi di COVID-19 diagnosticati in Italia negli ultimi 30 giorni
jq <"$folder"/rawdata/htmlwidget-661d16c6fae448ca25f2.json -r '.x.data[0].text[]' |
    mlr --inidx label "data",valore,tipo then put '$tipo="inizio sintomi"' >"$folder"/rawdata/curvaEpidemica30gg

# aggiungi al file i dati relativi alla Curva epidemica con data Prelievo/Diagnosi
# dei casi di COVID-19 diagnosticati in Italia negli ultimi 30 giorni e
jq <"$folder"/rawdata/htmlwidget-661d16c6fae448ca25f2.json -r '.x.data[1].text[]' |
    mlr --inidx label "data",valore,tipo then put '$tipo="prelievo/diagnosi"' >>"$folder"/rawdata/curvaEpidemica30gg

# converti curvaEpidemica30gg in CSV
mlr --ocsv reshape -s tipo,valore then unsparsify then sort -f data "$folder"/rawdata/curvaEpidemica30gg >"$folder"/rawdata/curvaEpidemica30gg.csv

# Estrai dati COVID-19 segnalati in Italia negli ultimi 30 giorni per classe di età
jq <"$folder"/rawdata/htmlwidget-2b4fa6bfd4bfcaaeecc7.json -r '.x.data[0].hovertemplate[]' >"$folder"/rawdata/classiEta
sed -i -r 's/^(.+?:)(.+)(\|)(.+:)(.+)$/\2\t\5/g' "$folder"/rawdata/classiEta

# converti in CSV
mlr --t2c --implicit-csv-header then label classeEta,casi then clean-whitespace then put -S '$casi=gsub($casi,"\.","")' "$folder"/rawdata/classiEta >"$folder"/rawdata/classiEta.csv

# crea file del giorno
date=$(date '+%Y-%m-%d')
cp "$folder"/rawdata/classiEta.csv "$folder"/processing/"$date"_classiEta.csv
cp "$folder"/rawdata/casi30gg.csv "$folder"/processing/"$date"_casi30gg.csv
cp "$folder"/rawdata/curvaEpidemica30gg.csv "$folder"/processing/"$date"_curvaEpidemica30gg.csv

host=$(hostname)
if [ $host = "ex-machina.ondata.it" ]; then
    # commit e push

    . ~/.keychain/$HOSTNAME-sh

    cd "$folder"
    git -C "$folder" pull
    git -C "$folder" add .
    git -C "$folder" commit -am "update"
    git -C "$folder" push origin master
fi
