#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

URL="https://www.immuni.italia.it"

# leggi la risposta HTTP del sito
code=$(curl -A "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati e aggiorna feed
if [ $code -eq 200 ]; then

  oggi=$(date +%Y-%m-%d)

  #scarica pagina
  curl -kL "$URL"/dashboard.html -H 'authority: www.immuni.italia.it' -H 'cache-control: max-age=0' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' -H 'sec-fetch-site: none' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-user: ?1' -H 'sec-fetch-dest: document' -H 'accept-language: en-US,en;q=0.9,it;q=0.8' --compressed >"$folder"/rawdata/tmp-dashboard.html

  # estrai nomi file javascript
  jsPath=$(<"$folder"/rawdata/tmp-dashboard.html scrape -e '//script[contains(@src,"main")]/@src' | sed -r 's/^(.+js)(.+)$/\1/g')
  chartPath=$(<"$folder"/rawdata/tmp-dashboard.html scrape -e '//script[contains(@src,"chart")]/@src' | sed -r 's/^(.+js)(.+)$/\1/g')

  # scarica file javascript
  curl -kL "$URL"/"$jsPath" >"$folder"/rawdata/tmp.html
  curl -kL "$URL"/"$chartPath" >"$folder"/rawdata/tmp-chart.html


  # estrai dati immuni su grafico download
  grep <"$folder"/rawdata/tmp.html -oP '{"202.+?{.+"android".+?}}' | mlr --ijson reshape -r ':' -o item,value then put '$field=sub($item,".+:","");$item=sub($item,"(.+)(:.+)","\1")' then label date,value,item then reshape -s item,value >>"$folder"/processing/immuniChart.dkvp

  # estrai dati immuni su grafico notifications
  grep <"$folder"/rawdata/tmp-chart.html -oP '{"20..-..-.. ..:..:..":{"notifications":.+?}}' | mlr --ijson reshape -r ':' -o item,value then put '$field=sub($item,".+:","");$item=sub($item,"(.+)(:.+)","\1")' then label date,value,item then reshape -s item,value >>"$folder"/processing/immuniChartNotifications.dkvp

  # converti dati in CSV
  mlr -I uniq -a "$folder"/processing/immuniChart.dkvp
  mlr -I uniq -a "$folder"/processing/immuniChartNotifications.dkvp
  mlr --ocsv cat then sort -f date "$folder"/processing/immuniChart.dkvp >"$folder"/processing/immuniChart.csv
  mlr --ocsv cat then sort -f date "$folder"/processing/immuniChartNotifications.dkvp >"$folder"/processing/immuniChartNotifications.csv

  latestDate=$(mlr --onidx stats1 -a max -f date "$folder"/processing/immuniChartNotifications.dkvp)

  # estrai dati immuni su positiveUsers e containedOutbreaks
  grep <"$folder"/rawdata/tmp.html -oP '{"positiveUsers.+?}' | mlr --ijson cat then put '$date="'"$latestDate"'";$date=sub($date," .+","")' >>"$folder"/processing/immuni.dkvp
  mlr -I put -S 'if($containedOutbreaks=="0"){$containedOutbreaks=""}else{$containedOutbreaks=$containedOutbreaks}' "$folder"/processing/immuni.dkvp
  mlr -I uniq -a "$folder"/processing/immuni.dkvp

  # converti dati in CSV
  mlr --ocsv unsparsify then sort -f date "$folder"/processing/immuni.dkvp >"$folder"/processing/immuni.csv
fi
