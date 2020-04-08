La **regione Lazio** pubblica una dashboard cartografica con i dati sulla Covid-19, per **comune**, per **distretto** del **comune** **di Roma**, per **zona urbanistica** del **comune di Roma** https://www.dep.lazio.it/covid/covid_map.php:

> Le mappe presentate descrivono l’incidenza cumulativa di casi COVID-19 notificati al SERESMI (x 10,000 residenti) rappresentando le stime in valori crescenti secondo gradazione di colore. Le mappe consentono di identificare se in un’area geografica è presente un maggior o minor numero di casi in rapporto alla popolazione residente .<br>
**ATTENZIONE! Nel caso di un’area geografica piccola (comune o zona urbanistica con pochi abitanti) la lettura delle mappe può essere distorta a causa del piccolo numero di casi osservati.**

Al momento (8 aprile 2020) non è documentato un accesso diretto ai dati e abbiamo creato uno script per estrarli in formato CSV.

Nel dettaglio:

- [lo script bash](regionelazio.sh) per estrarli;
- [la cartella](./processing) con i file di output dello script.

I file sono in formato CSV (*encoding* `UTF-8`, separatore `,`) e sono:

- [comuni.csv](./processing/comuni.csv);
- [distretti.csv](./processing/distretti.csv);
- [zoneurbane.csv](./processing/zoneurbane.csv).

È presente sempre una colonna `tasso`, che fa riferimento al tasso di contagi ogni 10.000 residenti.

**NOTA BENE**: sono i dati al 8 aprile 2020 e al momento non verranno aggiornati in questo spazio. Sono stati aggiunti per mostrare come accedervi.
