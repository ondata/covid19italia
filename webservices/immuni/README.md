- [IMPORTANTE](#importante)
  - [Intro](#intro)
  - [Output](#output)
    - [~~Dati su notifiche, utenti positivi e focolai contenuti~~](#sdati-su-notifiche-utenti-positivi-e-focolai-contenutis)
    - [Dati sul download dell'applicazione](#dati-sul-download-dellapplicazione)
    - [Dati sulle notifiche](#dati-sulle-notifiche)

# IMPORTANTE

Il **30 ottobre** 2020 è stato creato [un *repository* ufficiale per i dati di Immuni](https://github.com/immuni-app/immuni-dashboard-data). Abbiamo spento pertanto la procedura di scraping e pubblicazione.

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

### ~~Dati su notifiche, utenti positivi e focolai contenuti~~

Il file è [`immuni.csv`](processing/immuni.csv) e ha una struttura come quella di sotto (in `date` la data in cui sono stati scaricati i dati).

| sentNotifications | positiveUsers | containedOutbreaks | date | latestdate |
| --- | --- | --- | --- | --- |
| 5329 | 338 | 10 | 2020-10-03 |  |
| 5870 | 357 | 10 | 2020-10-05 |  |
| 6718 | 378 |  | 2020-10-07 |  |
| 7884 | 445 |  | 2020-10-10 | 2020-10-09 |
| ... | ... |  | ... | ... |

Note:

- il campo `containedOutbreaks` era presente nei dati che alimentavano il sito, ma sembra che non venga più valorizzato;
- `date` è la data in cui viene eseguito lo scraping;
- `latestdate` è la data di aggiornamento riportata nei dati. Questo campo è stato introdotto dal 21 ottobre 2020.

**NOTA BENE**: dal 25 ottobre questa tabella non verrà più aggiornata, perché contenuta in "[Dati sulle notifiche](#dati-sulle-notifiche)".

### Dati sul download dell'applicazione

Il file è [`immuniChart.csv`](processing/immuniChart.csv)

Qui `date` contiene la data che viene restituita dai dati della pagina (è quindi la data comunicata dallo staff di Immuni).

| date | ios | android | total |
| --- | --- | --- | --- |
| 2020-06-01 00:00:00 | 137000 | 172357 | 309357 |
| 2020-06-02 00:00:00 | 372000 | 597579 | 969579 |
| 2020-06-03 00:00:00 | 562000 | 824473 | 1386473 |
| 2020-06-04 00:00:00 | 638800 | 915748 | 1554548 |
| ... | ... | ... | ... |


### Dati sulle notifiche

Il file è [`immuniChartNotifications.csv`](processing/immuniChartNotifications.csv)

| date | notifications | positive_users | ~~contained_outbreaks~~ |
| --- | --- | --- | --- |
| 2020-10-01 00:00:00 | 5236 | 331 | 13 |
| 2020-10-02 00:00:00 | 5506 | 343 | 13 |
| 2020-10-03 00:00:00 | 5725 | 347 | 14 |
| 2020-10-04 00:00:00 | 5831 | 352 | 14 |
| ... | ... | ... | ... |

**Nota bene**: dal 28 ottobre 2020 è stata rimossa la colonna `contained_outbreaks`. Un archivio di questa è in [questo file](./processing/2020-10-28_immuniChartNotifications.csv).

