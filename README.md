- [Cosa c'è in questo repo](#cosa-cè-in-questo-repo)
- [Nota](#nota)
- [Output](#output)
  - [File CSV con i dati per provincia (i contagiati)](#file-csv-con-i-dati-per-provincia-i-contagiati)
  - [File CSV con i dati riepilogo](#file-csv-con-i-dati-riepilogo)
  - [Archivio dei PDF pubblicati](#archivio-dei-pdf-pubblicati)
- [Archiviazione automatica su Web Archive](#archiviazione-automatica-su-web-archive)
- [Dati accessori di riferimento](#dati-accessori-di-riferimento)
- [Altri progetti a tema](#altri-progetti-a-tema)
- [Chi usa questi dati](#chi-usa-questi-dati)

# Cosa c'è in questo repo

Alla data del 4 marzo 2020 - dopo circa 15 giorni dal primo caso "italiano" - **non c'è** in **Italia** una **fonte** ufficiale che pubblichi i dati in modalità ***machine readable***.

Questo *repository* sarà aggiornato una volta al giorno - intorno alle 19:30 - per scaricare dal [sito della Protezione Civile](http://www.protezionecivile.gov.it/attivita-rischi/rischio-sanitario/emergenze/coronavirus/) i 2 file PDF denominati `Dati di riepilogo nazionale (pdf)` e `Dettaglio per provincia (pdf)` e trasformarli in formati leggibili da una "macchina".

I file sono aggiornati dalla Protezione Civile ogni giorno intorno alle 18:00.

# Nota

Questo sistema potrebbe smettere di funzionare da subito, dopo una modifica effettuata dai gestori del sito della Protezione Civile.

Questa è l'occasione per **chiedere** anche noi **al Ministero della Sanità e alla Protezione Civile di produrre** - oltre a questi necessari file PDF pensati per fare la dovuta e utile rassegna stampa - dei file e/o dei servizi in formato ***machine readable***, con **licenza aperta**, certificati, **completi**, il più possibile **disaggregati**, **aggiornati** e con lo **storico** dei dati nel tempo.

# Output

## File CSV con i dati per provincia (i contagiati)

Dai dati pubblicati ogni giorno, viene prodotto un archivio, con i dati dei vari giorni. Il primo giorno di cui abbiamo raccolto i dati è 2 marzo 2020.

Il file è [questo](./publication/provinceArchivio.csv) e la struttura è quella di sotto:

| provincia | numero | regione | datetime |
| --- | --- | --- | --- |
| Bergamo | 372 | LOMBARDIA | 2020-03-03 |
| Lodi | 482 | LOMBARDIA | 2020-03-03 |
| Cremona | 287 | LOMBARDIA | 2020-03-03 |
| in fase di verifica e aggiornamento | 36 | LOMBARDIA | 2020-03-03 |
| --- | --- | --- | --- |

Ne viene prodotta pura [una copia](./publication/provinceArchivioISTAT.csv) con il codice ISTAT provinciale.

| provincia | numero | regione | datetime | codiceISTAT |
| --- | --- | --- | --- | --- |
| Abruzzo da verificare | 1 | ABRUZZO | 2020-03-03 |  |
| L'aquila | 1 | ABRUZZO | 2020-03-03 | 066 |
| Pescara | 1 | ABRUZZO | 2020-03-03 | 068 |
| Teramo | 3 | ABRUZZO | 2020-03-03 | 067 |
| --- | --- | --- | --- | --- |

## File CSV con i dati riepilogo

Dai dati pubblicati ogni giorno, viene prodotto un archivio con i dati dei vari giorni. Il primo giorno di cui abbiamo raccolto i dati è 2 marzo 2020.

Il file è [questo](./publication/riepilogoArchivio.csv) e la struttura è quella di sotto:

| Regione | Ricoverati con sintomi | Terapia intensiva | Isolamento domiciliare | Totale attualmente positivi | DIMESSI GUARITI | DECEDUTI | CASI TOTALI | TAMPONI | datetime |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Lombardia | 698 | 167 | 461 | 1326 | 139 | 55 | 1520 | 9577 | 2020-03-03 |
| Emilia Romagna | 187 | 24 | 187 | 398 | 4 | 18 | 420 | 2012 | 2020-03-03 |
| Veneto | 49 | 19 | 229 | 297 | 7 | 3 | 307 | 10176 | 2020-03-03 |
| Piemonte | 13 | 3 | 40 | 56 |  |  | 56 | 458 | 2020-03-03 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

## Archivio dei PDF pubblicati

A partire dal 2 marzo 2020 i PDF pubblicati verranno archiviati in [questa cartella](./pdfArchive).

# Archiviazione automatica su Web Archive

A partire dal 4 marzo 2020, ogni giorno verrà creata una copia delle pagine sottostanti e degli URL che ciascuna contiene (quindi anche dei PDF citati sopra):

- <http://www.protezionecivile.gov.it/attivita-rischi/rischio-sanitario/emergenze/coronavirus>
- <http://www.protezionecivile.gov.it/web/guest/media-comunicazione/comunicati-stampa>
- <http://www.salute.gov.it/portale/nuovocoronavirus/dettaglioContenutiNuovoCoronavirus.jsp?lingua=italiano&id=5351&area=nuovoCoronavirus&menu=vuoto>
- <http://www.salute.gov.it/portale/nuovocoronavirus/archivioComunicatiNuovoCoronavirus.jsp>
- <http://www.protezionecivile.gov.it/media-comunicazione/comunicati-stampa>

# Dati accessori di riferimento

- "Elenco dei codici e delle denominazioni delle unità territoriali", di ISTAT <https://www.istat.it/storage/codici-unita-amministrative/Elenco-codici-statistici-e-denominazioni-delle-unita-territoriali.zip>

# Altri progetti a tema

Ringraziamo Matteo Brunati per lo [spunto](https://github.com/ondata/covid19italia/issues/1).

- **Coronavirus in Italia**, di Alessio Di Lorenzo (è stato il progetto ispiratore di questo lavoro) https://alessiodl.github.io/COVID19Dashboard/dist/index.html
- COVID-19-Italy, di Carlo Torniai <https://github.com/carlotorniai/COVID-19-Italy>
- ItalianCovidData, di Davide Magno <https://github.com/DavideMagno/ItalianCovidData>
- Novel Coronavirus SARS-CoV-2 (2019-nCoV) Italian Outbreak Data Repository, di Simone Marzola <https://github.com/sarscov2-it/data>

# Chi usa questi dati

- [rainbowbreeze](https://github.com/ondata/covid19italia/issues/3) <https://datastudio.google.com/u/0/reporting/9f0b865e-bb18-4894-a7f4-acca6467c641?s=pkXn62iU3rQ>
