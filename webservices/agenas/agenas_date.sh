#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

if [ -f "$folder"/processing/positivi-e-ricoverati.csv ]; then

  echo "ok"
#put '$test=system("echo \"".regextract_or_else($a,"[0-9] .+[0-9]{4}","")."\" | dconv --from-locale it_IT  -i \"%d %B %Y\"")'
fi
