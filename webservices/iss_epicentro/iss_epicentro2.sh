#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/risorse

# svuota cartella
#rm "$folder"/processing/*
#rm "$folder"/rawdata/*

### dashboard 30 giorni ###
url30="https://www.epicentro.iss.it/coronavirus/dashboard/Dashboard_finale_dallinizio.html"

# estrai id dei div html
curl -kL "$url30" >"$folder"/rawdata/Dashboard_finale_30gg.html
scrape <"$folder"/rawdata/Dashboard_finale_30gg.html -be '//div[contains(@id,"htmlwidget-")]' |
    xq -r '.html.body.div[]."@id"' >"$folder"/rawdata/listaDivIdDallInizio

