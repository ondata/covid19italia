La **regione Lazio** pubblica una dashboard cartografica con i dati sulla Covid-19, per **comune**, per **distretto** del **comune** **di Roma**, per **zona urbanistica** del **comune di Roma**: https://www.dep.lazio.it/covid/covid_map.php.

In questa cartella:

- [uno script bash](regionelazio.sh) per estrarli;
- [una cartella](./processing) con i dati di output dello script.

Le risorse sono 3 file CSV (*encoding* `UTF-8`, separatore `,`):

- [comuni.csv](./processing/comuni.csv);
- [distretti.csv](./processing/distretti.csv);
- [zoneurbane.csv](./processing/zoneurbane.csv).

È presente sempre una colonna `tasso`, che fa riferimento al tasso di contagi ogni 10.000 abitanti.

**NOTA BENE**: sono i dati al 8 aprile 2020 e al momento non verranno aggiornati in questo spazio. Sono stati aggiunti per mostrare come accedervi.
