- [Calcolo regionale incidenza cumulativa settimanale dei contagi](#calcolo-regionale-incidenza-cumulativa-settimanale-dei-contagi)
  - [Output dati](#output-dati)
    - [soglia_duecentocinquanta](#soglia_duecentocinquanta)
    - [soglia_duecentocinquanta_wide](#soglia_duecentocinquanta_wide)
  - [Output visuale](#output-visuale)
  - [Accesso via API](#accesso-via-api)
  - [Fonti dati](#fonti-dati)

# Calcolo regionale incidenza cumulativa settimanale dei contagi

Nel "[DECRETO-LEGGE 13 marzo 2021, n. 30](https://www.gazzettaufficiale.it/eli/id/2021/03/13/21G00040/sg)" si legge

> Dal 15 marzo al 6 aprile 2021, le misure stabilite dai provvedimenti di cui all'articolo 2 del decreto-legge n. 19 del 2020 per la zona rossa di cui all'articolo 1, comma 16-septies, lettera c), del decreto-legge n. 33 del 2020, si applicano anche nelle regioni e Province autonome di Trento e Bolzano individuate con ordinanza del Ministro della salute ai sensi dell'articolo 1, comma 16-bis, del decreto-legge n. 33 del 2020, nelle quali l'**incidenza cumulativa settimanale dei contagi e' superiore a 250 casi ogni 100.000 abitanti**, sulla base dei dati validati dell'ultimo monitoraggio disponibile.

Abbiamo creato una [procedura](soglia250.sh) per calcolare questo indice:
- vengono scaricati i dati regionali;
- per ogni regione, vengono sommati i dati sui `nuovi_positivi` della riga corrente a quelli dei 6 giorni precedenti;
- questo valore viene diviso per la popolazione residente e moltiplicato per `100.000`.

Quest'ultimo valore è l'incidenza cumulativa settimanale dei contagi.

**NOTA BENE**:

- nel decreto si legge che la data di riferimento sarà quello dell'ultimo monitoraggio disponibile. Qui è calcolato ogni giorno, a partire dall'ultima dati di aggiornamento dei dati della Protezione Civile;
- questo della soglia non è l'unico criterio per finire in zona rossa. Se la si supera, si applicano i provvedimenti da zona rossa.

## Output dati

### soglia_duecentocinquanta

È il [file principale di output](processing/soglia_duecentocinquanta.csv). Ai dati del Dipartimento della Protezione Civile è stata aggiunta la colonna `soglia250`, che contiene il risultato del calcolo descritto sopra.

A seguire un estratto di esempio:

| codice_regione | data | codice_nuts_2 | denominazione_regione | soglia250 |
| --- | --- | --- | --- | --- |
| 21 | 2021-03-14T17:00:00 | ITH1 | P.A. Bolzano | 209 |
| 22 | 2021-03-14T17:00:00 | ITH2 | P.A. Trento | 342 |
| 01 | 2021-03-14T17:00:00 | ITC1 | Piemonte | 331 |
| 16 | 2021-03-14T17:00:00 | ITF4 | Puglia | 256 |
| 20 | 2021-03-14T17:00:00 | ITG2 | Sardegna | 46 |
| 19 | 2021-03-14T17:00:00 | ITG1 | Sicilia | 91 |
| 09 | 2021-03-14T17:00:00 | ITI1 | Toscana | 231 |
| 10 | 2021-03-14T17:00:00 | ITI2 | Umbria | 177 |
| 02 | 2021-03-14T17:00:00 | ITC2 | Valle d'Aosta | 147 |
| 05 | 2021-03-14T17:00:00 | ITH3 | Veneto | 242 |

### soglia_duecentocinquanta_wide

Questa è [una tabella derivata](processing/soglia_duecentocinquanta_wide.csv), una trasformazione da *long* a *wide*: non esiste più una sola colonna con l'elenco delle regioni, ma per ogni regione è stata creata una colonna.<br>
È una "forma" di dati, creata a servizio di alcuni client grafici che la richiedono.

A seguire un estratto di esempio:

| data | Abruzzo | Basilicata | Calabria | Campania | Emilia-Romagna | Friuli Venezia Giulia | Lazio | Liguria | Lombardia | Marche | Molise | P.A. Bolzano | P.A. Trento | Piemonte | Puglia | Sardegna | Sicilia | Toscana | Umbria | Valle d'Aosta | Veneto |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2021-03-05T17:00:00 | 229 | 154 | 69 | 297 | 404 | 300 | 168 | 155 | 285 | 327 | 191 | 322 | 356 | 251 | 201 | 34 | 75 | 210 | 192 | 70 | 170 |
| 2021-03-06T17:00:00 | 236 | 165 | 75 | 308 | 419 | 316 | 172 | 150 | 300 | 330 | 187 | 294 | 352 | 265 | 210 | 33 | 76 | 215 | 198 | 74 | 175 |
| 2021-03-07T17:00:00 | 235 | 172 | 79 | 308 | 429 | 326 | 173 | 159 | 308 | 347 | 161 | 285 | 342 | 280 | 213 | 34 | 79 | 223 | 202 | 54 | 182 |
| 2021-03-08T17:00:00 | 241 | 164 | 75 | 304 | 438 | 347 | 175 | 153 | 310 | 341 | 159 | 279 | 347 | 282 | 212 | 36 | 79 | 226 | 198 | 75 | 185 |
| 2021-03-09T17:00:00 | 236 | 170 | 78 | 315 | 447 | 356 | 179 | 147 | 313 | 341 | 161 | 268 | 346 | 291 | 218 | 41 | 80 | 224 | 191 | 77 | 193 |
| 2021-03-10T17:00:00 | 220 | 169 | 81 | 322 | 440 | 371 | 182 | 145 | 312 | 350 | 149 | 256 | 355 | 304 | 226 | 38 | 83 | 228 | 190 | 86 | 199 |
| 2021-03-11T17:00:00 | 225 | 174 | 91 | 326 | 447 | 400 | 183 | 145 | 318 | 350 | 158 | 246 | 381 | 308 | 231 | 41 | 85 | 230 | 192 | 103 | 202 |
| 2021-03-12T17:00:00 | 228 | 170 | 93 | 322 | 452 | 412 | 187 | 149 | 329 | 340 | 137 | 231 | 358 | 323 | 240 | 42 | 89 | 231 | 184 | 114 | 211 |
| 2021-03-13T17:00:00 | 219 | 162 | 92 | 324 | 446 | 436 | 195 | 151 | 330 | 350 | 155 | 224 | 342 | 331 | 246 | 44 | 90 | 232 | 174 | 126 | 235 |
| 2021-03-14T17:00:00 | 201 | 155 | 96 | 322 | 445 | 448 | 202 | 147 | 330 | 335 | 150 | 209 | 342 | 331 | 256 | 46 | 91 | 231 | 177 | 147 | 242 |

## Output visuale

Abbiamo predisposto un [***output* visuale**](https://bl.ocks.org/aborruso/raw/28374f1d59a5d9880c4c76dc66865cd8/), con due elementi:

- una **mappa** con evidenziate in rosso le regioni con valori `>=` 250;
- la **tabella** con tutti valori per ogni regione.

[![](https://i.imgur.com/5nHPnCz.png)](https://bl.ocks.org/aborruso/raw/28374f1d59a5d9880c4c76dc66865cd8/)

## Accesso via API

È possibile interrogare questi dati via API. Ad esempio per accedere a valore per la Sicilia (`codice regionale ISTAT = 19`), per la data del `2021-03-13` (il 13 marzo 2021), basta chiamare questo URL:
<https://api.gitrows.com/@github/ondata/covid19italia/elaborazioni/dpc_covid19/soglia250/processing/soglia_duecentocinquanta.csv?codice_regione=19&data=*:2021-03-13>

La *query* si modifica modificando questa parte di URL `codice_regione=19&data=*:2021-03-13`, in cui c'è da inserire il codice regionale ISTAT e la data in forma `AAAA-MM-GG` (anno, mese e giorno).

Queste API esistono grazie al fantastico [gitrows](https://gitrows.com/).

## Fonti dati

- repository del **Dipartimento della Protezione Civile** <https://github.com/pcm-dpc/COVID-19>;
- **ISTAT**, Popolazione residente al 1° gennaio <http://dati.istat.it/Index.aspx?DataSetCode=DCIS_POPRES1>.
