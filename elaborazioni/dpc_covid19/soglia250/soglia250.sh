#!/bin/bash

### requisiti ###
# sqlite3 https://www.sqlite.org/index.html
# miller https://github.com/johnkerl/miller
# moreutils https://joeyh.name/code/moreutils/
### requisiti ###

### output ###
# https://bl.ocks.org/aborruso/raw/28374f1d59a5d9880c4c76dc66865cd8/
### output ###

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $(hostname) == "DESKTOP-7NVNDNF" ]]; then
  source "$folder"/.config
fi

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/risorse

URL="https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv"

# scarica dati
wget -O "$folder"/rawdata/tmp_regioni.csv "$URL"

# se il db esiste, cancellalo
if [ -f "$folder"/rawdata/dpc_covid.db ]; then
  rm "$folder"/rawdata/dpc_covid.db
fi

# crea file sqlite e importa dati regionali
sqlite3 -separator ',' "$folder"/rawdata/dpc_covid.db ".import $folder/rawdata/tmp_regioni.csv dpc_covid19_ita_regioni"

# calcola somma nuovi contagi settimanali
echo '
-- elimina tabella se esiste
DROP TABLE IF EXISTS `soglia_duecentocinquanta`;
-- crea tabella con la somma dei nuovi casi della riga corrente + le 6 precedenti, raggruppate per regione
CREATE table `soglia_duecentocinquanta` AS
SELECT data,codice_regione,codice_nuts_2,denominazione_regione,SUM(nuovi_positivi)
OVER (PARTITION BY denominazione_regione
        ORDER BY data
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) nuoviContagiSettimanali
FROM "dpc_covid19_ita_regioni"
ORDER BY data ASC
' | sqlite3 "$folder"/rawdata/dpc_covid.db

# esporta tabella
sqlite3 -header -csv "$folder"/rawdata/dpc_covid.db "select * from soglia_duecentocinquanta" >"$folder"/processing/soglia_duecentocinquanta.csv

# aggiungi dati popolazione e calcula incidenza per 100.000 persone
mlr --csv join --ul -j codice_regione -f "$folder"/processing/soglia_duecentocinquanta.csv \
  then unsparsify \
  then put '$soglia250=int($nuoviContagiSettimanali/$OBS_VALUE*100000)' \
  then cut -x -f nuoviContagiSettimanali,ITTER107,TIME_PERIOD,OBS_VALUE,Name \
  then sort -f data,denominazione_regione ../../../risorse/popolazione_regioni.csv | sponge "$folder"/processing/soglia_duecentocinquanta.csv

# crea la versione wide, con una colonna per ogni regione
mlr --csv cut -f data,denominazione_regione,soglia250 \
  then reshape -s denominazione_regione,soglia250 \
  then sort -f data "$folder"/processing/soglia_duecentocinquanta.csv >"$folder"/processing/soglia_duecentocinquanta_wide.csv

### crea dati per tabella datawrapper ###

# ultima data
max=$(mlr --c2n stats1 -a max -f data "$folder"/processing/soglia_duecentocinquanta.csv)
maxDW=$(mlr --c2n stats1 -a max -f data then put '$data_max=sub($data_max,"T.+","")' "$folder"/processing/soglia_duecentocinquanta.csv)

# crea colonna con check superamento soglia e tendenza rispetto al giorno precedente
mlr --csv step -a delta -f soglia250 -g codice_regione then \
  put -S 'if($soglia250_delta=="0"){$soglia250_delta="~"}elif($soglia250_delta=~"-.+"){$soglia250_delta="▼"}elif($soglia250_delta=~"^[^0]"){$soglia250_delta="▲"}else{$soglia250_delta=$soglia250_delta}' then \
  put 'if($soglia250>=250){${Sopra soglia}="◼"}else{${Sopra soglia}=""}' then \
  rename soglia250_delta,tendenza then \
  filter -S '$data=="'"$max"'"' then \
  sort -nr soglia250 "$folder"/processing/soglia_duecentocinquanta.csv >"$folder"/processing/soglia_duecentocinquanta_dw.csv

# crea dati per sparkline
mlr --csv put '$datetime = strftime(strptime($data, "%Y-%m-%dT%H:%M:%S"),"%Y-%m-%d")' then cat -n then tail -n 630 then cut -f datetime,codice_regione,soglia250 then reshape -s datetime,soglia250 then unsparsify "$folder"/processing/soglia_duecentocinquanta.csv >"$folder"/processing/tmp_soglia_duecentocinquanta_lc.csv

# aggiungi i dati sparkline ai dati di base
mlr --csv join -j codice_regione -f "$folder"/processing/soglia_duecentocinquanta_dw.csv then unsparsify then sort -nr soglia250 "$folder"/processing/tmp_soglia_duecentocinquanta_lc.csv | sponge "$folder"/processing/soglia_duecentocinquanta_dw.csv

mlr -I --csv label codice_regione,data,codice_nuts_2,denominazione_regione,soglia250,tendenza,"Sopra soglia",01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30 "$folder"/processing/soglia_duecentocinquanta_dw.csv

# aggiorna info data sulla tabella datawrapper

curl --request PATCH \
  --url https://api.datawrapper.de/v3/charts/4w9um \
  --header 'Authorization: Bearer '"$DW"'' \
  --header 'content-type: application/json' \
  --data \
  '{
        "metadata": {
          "describe": {
              "intro": "<b>soglia250</b> = numero di <strong>nuovi contagi</strong> ogni <strong>100.000 abitanti</strong>, negli ultimi 7 giorni.<br>Se <strong>>= 250</strong> si applicano <strong><a href=\"https://www.gazzettaufficiale.it/eli/id/2021/03/13/21G00040/sg\">provvedimenti zona rossa</a></strong> (<a href=\"https://github.com/ondata/covid19italia/blob/master/elaborazioni/dpc_covid19/soglia250/README.md#fonti-dati\" target=\"_blank\">dati</a>). 📅<b>Data di riferimento</b>: '"$maxDW"'"
          }
        }
    }'

curl --request POST \
  --url https://api.datawrapper.de/charts/4w9um/publish \
  --header 'Authorization: Bearer '"$DW"''

### crea dati per tabella datawrapper ###

### soglia 250 province ###

URLprov="https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-province/dpc-covid19-ita-province.csv"

code=$(curl -s -kL -o /dev/null -w "%{http_code}" "$URLprov")

# se il server risponde fai partire lo script
if [ $code -eq 200 ]; then
  curl -kL "$URLprov" >"$folder"/rawdata/dpc-covid19-ita-province.csv

  mlr --csv filter -x -S '$sigla_provincia==""' then filter -x -S '$codice_nuts_3==""' then cut -f data,codice_nuts_3,totale_casi then step -f totale_casi -a delta -g codice_nuts_3 then cat -n -g codice_nuts_3 then sort -f data "$folder"/rawdata/dpc-covid19-ita-province.csv >"$folder"/rawdata/tmp.csv

  # estrai id ultima settimana
  lastWeek=$(mlr --c2n stats1 -a max -f n "$folder"/rawdata/tmp.csv)

  ultimoGiorno=$(mlr --c2n stats1 -a max -f data "$folder"/rawdata/dpc-covid19-ita-province.csv)

  # popolazione

  if [ -f "$folder"/risorse/province_popolazione.csv ]; then
    echo "nulla"
  else
    mlr --csv cut -f codice_nuts_3,Totale,Provincia "$folder"/../../../risorse/province_popolazione.csv >"$folder"/risorse/province_popolazione.csv
  fi

  #
  mlr -I --csv filter '$n>=('"$lastWeek"'-6)' then stats1 -a sum -f totale_casi_delta -g codice_nuts_3 then put '$data="'"$ultimoGiorno"'"' "$folder"/rawdata/tmp.csv

  mlr --csv join --ul -j codice_nuts_3 -f "$folder"/rawdata/tmp.csv then \
   unsparsify then \
   put '$soglia250=int($totale_casi_delta_sum/$Totale*100000)' then \
   put 'if($soglia250>=250){${Sopra soglia}="◼"}else{${Sopra soglia}=""}' then \
   rename totale_casi_delta_sum,totale_casi,Totale,popolazione "$folder"/risorse/province_popolazione.csv >"$folder"/processing/soglia_duecentocinquanta_province.csv
fi

### soglia 250 province ###
