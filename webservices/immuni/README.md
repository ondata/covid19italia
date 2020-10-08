## Intro

Sul sito di immuni c'è una [dashboard](https://www.immuni.italia.it/dashboard.html), con i "numeri" dell'applicazione.
<br>
Ogni giorno ne vengono estratti i dati.

La fonte è il file javascript `main` che si trova a fondo pagina nel codice della pagina (una [copia](https://web.archive.org/web/20201007152945/https://www.immuni.italia.it/main.03fc58a18184624c49a8.js) al 8 ottobre 2020).

```html
<script type="text/javascript" src="main.03fc58a18184624c49a8.js"></script><script type="text/javascript" src="chart.03fc58a18184624c49a8.js"></script></body>
```

## Output

Due gli outpput

### Dati su notifiche, utenti positivi e focolai contenuti

Il file è [`immuni.csv`](processing/immuni.csv) e ha una struttura come quella di sotto (in `date` la data in cui sono stati scaricati i dati).

| sentNotifications | positiveUsers | containedOutbreaks | date |
| --- | --- | --- | --- |
| 5329 | 338 | 10 | 2020-10-03 |
| 5329 | 338 | 10 | 2020-10-04 |
| 5870 | 357 | 10 | 2020-10-05 |
| 5870 | 357 | 10 | 2020-10-06 |
| 6718 | 378 | 0 | 2020-10-07 |

### Dati sul download dell'applicazione

Il file è [`immuniChart.csv`](processing/immuniChart.csv)

Qui `date` contiene la data che viene restituita dai dati della pagina (è quindi la data comunicata dallo staff di Immuni).

| date | ios | android | total |
| --- | --- | --- | --- |
| 2020-06-01 00:00:00 | 137000 | 172357 | 309357 |
| 2020-06-02 00:00:00 | 372000 | 597579 | 969579 |
| 2020-06-03 00:00:00 | 562000 | 824473 | 1386473 |
| 2020-06-04 00:00:00 | 638800 | 915748 | 1554548 |
