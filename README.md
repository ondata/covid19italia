<hr>

**NOTA BENE**: dopo l'annuncio del [***repository* ufficiale**](https://github.com/pcm-dpc/COVID-19) della Protezione Civile con i dati sul COVID-19, abbiamo **bloccato** l'**aggiornamento** automatico dei dati a partire dai PDF pubblicati sul loro sito.

<hr>

- [Cosa c'è in questo repo](#cosa-cè-in-questo-repo)
- [Nota](#nota)
- [Come contribuire](#come-contribuire)
- [Output](#output)
  - [File CSV con i dati per provincia (i contagiati)](#file-csv-con-i-dati-per-provincia-i-contagiati)
  - [File CSV con i dati riepilogo](#file-csv-con-i-dati-riepilogo)
  - [API](#api)
    - [Dati di riepilogo](#dati-di-riepilogo)
      - [Dati per provincia](#dati-per-provincia)
      - [Dati di riepilogo](#dati-di-riepilogo-1)
  - [Archivio dei PDF pubblicati](#archivio-dei-pdf-pubblicati)
- [Archiviazione automatica su Web Archive](#archiviazione-automatica-su-web-archive)
- [Dati accessori di riferimento](#dati-accessori-di-riferimento)
- [Altri progetti a tema](#altri-progetti-a-tema)
- [Chi usa (o è stato ispirato da) questi dati](#chi-usa-o-è-stato-ispirato-da-questi-dati)

# Cosa c'è in questo repo

Alla data del 4 marzo 2020 - dopo circa 15 giorni dal primo caso "italiano" - **non c'è** in **Italia** una **fonte** ufficiale che pubblichi i dati in modalità ***machine readable***.

Questo *repository* sarà aggiornato una volta al giorno - intorno alle 19:30 - per scaricare dal [sito della Protezione Civile](http://www.protezionecivile.gov.it/attivita-rischi/rischio-sanitario/emergenze/coronavirus/) i 2 file PDF denominati `Dati di riepilogo nazionale (pdf)` e `Dettaglio per provincia (pdf)` e trasformarli in formati leggibili da una "macchina".

I file sono aggiornati dalla Protezione Civile ogni giorno intorno alle 18:00.

Sul numero di deceduti la Protezione Civile riporta che "potrà essere confermato solo dopo che l’Istituto Superiore di Sanità avrà stabilito la causa effettiva del decesso".

# Nota

Questo sistema potrebbe smettere di funzionare da subito, dopo una modifica effettuata dai gestori del sito della Protezione Civile.

Questa è l'occasione per **chiedere** anche noi **al Ministero della Sanità e alla Protezione Civile di produrre** - oltre a questi necessari file PDF pensati per fare la dovuta e utile rassegna stampa - dei file e/o dei servizi in formato ***machine readable***, con **licenza aperta**, certificati, **completi**, il più possibile **disaggregati**, **aggiornati** e con lo **storico** dei dati nel tempo.

Se verrà attivato qualche servizio ufficiale di stato che farà quanto descritto, è molto molto probabile che questo servizio verrà spento.

# Come contribuire

Qui le note su [**COME CONTRIBUIRE**](contributing.md) al progetto. Grazie a [Nicola Procopio](https://github.com/nickprock) per la redazione di queste note.

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

Ne viene prodotta pura [una copia](./publication/provinceArchivioISTAT.csv) con il codice **ISTAT** provinciale.

**Nota bene**: si tratta del campo `Codice dell'Unità territoriale sovracomunale (valida a fini statistici)` presente nella risorsa ISTAT "[Elenco dei codici e delle denominazioni delle unità territoriali](https://www.istat.it/storage/codici-unita-amministrative/Elenco-codici-statistici-e-denominazioni-delle-unita-territoriali.zip)".

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

## API

### Dati di riepilogo
I dati sono accessibili anche in formato Json attraverso API:

**NOTA**: dopo l'annuncio da parte della protezione civile, le API sono state agganciate ai dati del repository ufficiale

Esempio:

Gli ultimi dati disponibili per ogni singola regione
https://openpuglia.org/api/?q=getdatapccovid-19

Gli ultimi dati disponibili per la singola regione dove `reg = nome regione`
https://openpuglia.org/api/?q=getdatapccovid-19&reg=lombardia

Serie storica dei dati disponibili per regione dove `reg = nome regione` e `mode = ts`
https://openpuglia.org/api/?q=getdatapccovid-19&reg=lombardia&mode=ts

Tutti i dati disponibili
https://openpuglia.org/api/?q=getdatapccovid-19&mode=ts

<hr>

Per completezza si documentano anche le veccie API che utilizzano i dati raccolti da onData

#### Dati per provincia

es. https://openpuglia.org/api/?q=getdatacovid-19&reg=lombardia

dove `reg = nome regione`

consente di ottenere l'ultimo dato disponibile per ogni provincia di quella particolare regione. Omettendo il nome della regione verranno restituiti i dati relativi a tutte le province per cui esiste il dato

https://openpuglia.org/api/?q=getdatacovid-19

La serie storica dei dati disponibili può essere richiesta introducendo `mode=ts` nella query string.

es. https://openpuglia.org/api/?q=getdatacovid-19&reg=lombardia&mode=ts

Omettendo la regione vengono restituiti tutti i dati disponibili

https://openpuglia.org/api/?q=getdatacovid-19&mode=ts


#### Dati di riepilogo

es. https://openpuglia.org/api/?q=getsummarycovid-19&reg=lombardia

dove `reg = nome regione`

consente di ottenere il riepilogo dei dati disponibili per quella regione. Omettendo il nome della regione verranno restituiti i dati relativi a tutte le regioni per cui esiste il dato

https://openpuglia.org/api/?q=getsummarycovid-19

La serie storica dei dati disponibili può essere richiesta introducendo `mode=ts` nella query string. I dati sono cumulativi, ossia si riferiscono ai totali complessivi riferiti alla data indicata

es. https://openpuglia.org/api/?q=getsummarycovid-19&reg=lombardia&mode=ts

Omettendo la regione vengono restituiti tutti i dati disponibili

https://openpuglia.org/api/?q=getsummarycovid-19&mode=ts


È un lavoro a cura di [**Vincenzo Patruno**](https://twitter.com/vincpatruno). Un grazie a [**#openpuglia**](https://openpuglia.org/) per l'hosting.

## Archivio dei PDF pubblicati

I PDF pubblicati verranno archiviati in [questa cartella](./pdfArchive).

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

Ringraziamo Luca Salvioli Mariani ([Il Sole 24 Ore](https://www.ilsole24ore.com/)) per lo storico precedente al 2 marzo.

- **Coronavirus in Italia**, di Alessio Di Lorenzo (è stato il progetto ispiratore di questo lavoro) https://alessiodl.github.io/COVID19Dashboard/dist/index.html
- COVID-19-Italy, di Carlo Torniai <https://github.com/carlotorniai/COVID-19-Italy>
- ItalianCovidData, di Davide Magno <https://github.com/DavideMagno/ItalianCovidData>
- Novel Coronavirus SARS-CoV-2 (2019-nCoV) Italian Outbreak Data Repository, di Simone Marzola <https://github.com/sarscov2-it/data>

# Chi usa (o è stato ispirato da) questi dati

- [rainbowbreeze](https://github.com/ondata/covid19italia/issues/3) > <https://datastudio.google.com/u/0/reporting/9f0b865e-bb18-4894-a7f4-acca6467c641?s=pkXn62iU3rQ>
- [Guenter Richter](https://twitter.com/grichter) > <https://s3.eu-west-1.amazonaws.com/rc.ixmaps.com/ixmaps/app/Viewer/index.html?project=https://gjrichter.github.io/viz/COVID-19/projects/ixmaps_project_OnData_Prov2019_COVID_shape_numbers_curve.json>
- [Alessio Passalacqua](https://twitter.com/alessiopassah2o) > <https://alessiopassalacqua.github.io/covid19_italy/>
- [Riccardo Tasso](https://twitter.com/riccardotasso) > <https://public.flourish.studio/visualisation/1514619/>
- [Antonio Poggi](https://twitter.com/Pogs_A) > <http://daily.omniscope.me/Demo/Health/Coronavirus.iox/r/Covid-19+Italia/>
- [Franco Mossotto](https://twitter.com/FMossotto) > <http://bit.ly/CoronaVirusItaliaDataStudio>
- [Salvatore Fiandaca](https://twitter.com/totofiandaca) > <https://pigrecoinfinito.com/2020/03/10/qgis-creare-grafici-con-incrementi-giornalieri>
- [Hey, Teacher](https://github.com/heyteacher) > <https://heyteacher.github.io/COVID-19/>
- [Moreno Colaiacovo](https://twitter.com/emmecola) > <https://emmecola.github.io/coronavirus_lombardia/>
- [Giuseppe Cillis](https://www.facebook.com/giuseppe.d.cillis) > <https://public.flourish.studio/visualisation/1736281>
- [Vincenzo Sciascia](https://www.linkedin.com/in/vincenzosciascia/) > covidApp <https://3hy2c.glideapp.io/>
- [@OpencovidM](https://twitter.com/OpencovidM) > "Erreti (leggermente) maggiore di uno" <https://web.archive.org/web/20200810105626/https://opencoviditaly.netsons.org/erreti-leggermente-maggiore-di-uno/>
- [@OpencovidM](https://twitter.com/OpencovidM) > "Cosa succede quando si utilizzano dati non consolidati?" <https://opencoviditaly.netsons.org/cosa-succede-quando-si-utilizzano-dati-non-consolidati/>
- [Rt estimation](https://vienne.shinyapps.io/rt_estimation/), a cura di [Nicoletta V.](https://twitter.com/vi__enne), collaborazione con [OpenCovid](https://opencoviditaly.netsons.org/), [Vegro L.](https://twitter.com/l_vegro) e [Ruffino L.](https://twitter.com/Ruffino_Lorenzo)
