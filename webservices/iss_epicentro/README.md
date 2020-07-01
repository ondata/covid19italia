L'Istituto Superiore di Sanità pubblica due *dashboard* contenenti dati provenienti dal [Sistema di sorveglianza integrata COVID-19](https://covid-19.iss.it/):

- "ultimi 30 giorni", https://www.epicentro.iss.it/coronavirus/dashboard/30gg.html
- "dall'inizio", https://www.epicentro.iss.it/coronavirus/dashboard/inizio.html


In questa cartella:

- due script bash ([iss_epicentro.sh](./iss_epicentro.sh) e [iss_epicentroInizio.sh](./iss_epicentroInizio.sh)) per estrarre alcuni dei dati contenuti nelle *dashboard*;
- [uno script python](iss_epicentroInizio.py) per elaborare i dati grezzi estratti dalle *heatmap* contenute nella dashboard "[dall'inizio](https://www.epicentro.iss.it/coronavirus/dashboard/inizio.html)";
- [una cartella](./processing) con i dati di *output* in formato CSV (*encoding* `UTF-8` e separatore la `,`) frutto dell'elaborazione degli *script*.

I dati estratti sono organizzati nei seguenti file:

- `2020-MM-GG_casi30gg.csv` - Casi totali di COVID-19 per 100.000 abitanti per Regione/Provincia Autonoma di diagnosi e altri dettagli regionali (età mediana e decessi), casi per Provincia di domicilio o di residenza, casi negli ultimi 30 giorni per Regione/Provincia Autonoma di diagnosi (rosso);
- `2020-MM-GG_classiEta.csv` - Proporzione (%) di casi di COVID-19 segnalati in Italia negli ultimi 30 giorni per classe di età;
- `2020-MM-GG_curvaEpidemica30gg.csv` - Curva epidemica dei casi di COVID-19 diagnosticati in Italia negli ultimi 30 giorni;
- `2020-MM-GG_curvaEpidemicaInizio.csv` - Curva epidemica dei casi di COVID-19 segnalati in Italia per data di prelievo o diagnosi e per data di inizio dei sintomi;
- `2020-MM-GG_incidenzaInizio.csv` - Numero di casi di COVID-19 segnalati in Italia per Regione/Provincia Autonoma per data di prelievo o diagnosi;
- `2020-MM-GG_numeroCasiInizio.csv` - Incidenza di COVID-19 segnalati in Italia per Regione/Provincia Autonoma per data di prelievo o diagnosi.

## Nota del 28 giugno 2020

Non abbiano ancora pienamente testato la bontà dell'output; se riscontri qualche problema, aggiungi per favore un commento [qui](https://github.com/ondata/covid19italia/issues/53), grazie.

## Credits

La conversione dei dati grezzi estratti dalle *heatmap* in dati leggibili, si deve a [Paolo Milan](https://twitter.com/OpencovidM) (grazie).
