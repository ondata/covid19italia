La Presidenza del Consiglio dei Ministri, il Commissario Straordinario Covid-19 e il Ministero della Salute hanno pubblicato il 31/12/2020 una **dashboard** con **informazioni** sui **vaccini**:

<https://app.powerbi.com/view?r=eyJrIjoiMzg4YmI5NDQtZDM5ZC00ZTIyLTgxN2MtOTBkMWM4MTUyYTg0IiwidCI6ImFmZDBhNzVjLTg2NzEtNGNjZS05MDYxLTJjYTBkOTJlNDIyZiIsImMiOjh9>

Alcune note:

- hanno pubblicato ad oggi (2 gennaio 2021) **soltanto una rappresentazione dei dati** e non i dati grezzi;
- sono dati **leggibili** soltanto **da una persona** e **non** da un ***Personal Computer***;
- anche la **serie storica** e **disaggregata** è **soltanto** **leggibile** **a schermo** e **non** da un ***Personal Computer***.

Da oggi abbiamo attivato il download giornaliero e l'archiviazione di alcuni di questi dati:

- quelli sulla [**somministrazione**](processing/somministrazioni.csv) per regione;
- quelli sulla [**fasce d'età**](processing/fasceEta.csv) dei vaccinati;
- quelli sulle [**categorie**](processing/categoria.csv) dei vaccinati;
- quelli sul [**sesso**](processing/sesso.csv) dei vaccinati;
- quelli sui [**punti di somministrazione**](processing/puntiSomministrazione/puntiSomministrazione.csv). Per questi un doveroso grazie a [**Sergio Vavassori**](https://github.com/svavassori) che ha creato lo [script](puntiSomministrazione.py) per l'interpretazione corretta e conversione in `CSV` dei `JSON` di *input*;
- quelli su dose (se prima o seconda), sesso e categoria delle persone vaccinate, per ogni punto di somministrazione. Il file è [**puntiSomministrazioneDatiVax.csv**](processing/puntiSomministrazione/puntiSomministrazioneDatiVax.csv). Qui il grazie va a [**Salvatore Larosa**](https://twitter.com/lrssvt), che li ha resi disponibili nel suo [repository](https://github.com/slarosa/vax).

Nella stessa [cartella](./processing) sono presenti anche:

- i file che contengono soltanto l'ultimo valore estratto dalla *dashboard*, sono quelli con il prefisso `latest`;
- i file che contengono soltanto, per ogni giornata di dati archiviati, il valore più recente raccolto. Sono quelli con il suffisso `Top`;
- il file di [insieme](./processing/datiRegioni.csv), con i dati disaggregati regionali raccolti e descritti [qui](./processing/datiRegioni/README.md) (da giorno 8 gennaio 2020 non ne cureremo più l'estrazione).

**NOTA BENE**: i dati estratti e presenti in questo *repository*, sono ricavati interrogando le API non documentate della *dashboard*. Non sono stati resi palesemente accessibili; i dati aperti ufficiali sono quelli pubblicati [qui](https://github.com/italia/covid19-opendata-vaccini). Inoltre la nostra procedura di estrazione potrebbe contenere degli errori.

## File geografici

La suddivisione geografica usata al momento per i dati sui vaccini è quella regionale [`NUTS2`](https://ec.europa.eu/eurostat/web/nuts/nuts-maps). In questa l'Italia è divisa in 21 unità e non 20, con il Trentino-Alto Adige suddiviso nelle due province autonome.<br>
È la suddivisione statistica standard europea a livello regionale.

Una fonte classica per i file geografici con i limiti amministrativi è [ISTAT](https://www.istat.it/it/archivio/222527), che però non pubblica file "tagliati" secondo `NUTS2`.<br>
A partire allora dai file geografici ISTAT, e dall'[elenco dei codici delle suddivisioni statistiche](https://www.istat.it/storage/codici-unita-amministrative/Elenco-codici-statistici-e-denominazioni-delle-unita-territoriali.zip) (sempre di ISTAT), abbiamo generato i [file geografici](https://github.com/ondata/covid19italia/tree/master/risorse/fileGeografici) con questo taglio.

Nel dettaglio:

- [NUTS2_g.zip]([../../risorse/fileGeografici/NUTS2_g.zip](https://github.com/ondata/covid19italia/raw/master/risorse/fileGeografici/NUTS2_g.zip)), file con limiti generalizzati (minore dettaglio), formato shapefile, sistema di coordinate [`EPSG:32632`](https://epsg.io/32632);
- [NUTS2.zip](https://github.com/ondata/covid19italia/raw/master/risorse/fileGeografici/NUTS2.zip), file con limiti non generalizzati, formato shapefile, sistema di coordinate [`EPSG:32632`](https://epsg.io/32632);
- [NUTS2_g.geojson](https://github.com/ondata/covid19italia/raw/master/risorse/fileGeografici/NUTS2_g.geojson), file con limiti generalizzati, sistema di coordinate [`EPSG:4326`](https://epsg.io/4326).

## Note sui file

L'*enconding* dei CSV è `UTF-8` e il separatore delle colonne è la `,`.

La colonna `aggiornamento` presente nei CSV dà conto della data di aggiornamento letta sulla *dashboard*, al momento della pubblicazione qui dei dati. Il formato è `mese/giorno/anno ora`.

---

A cura dell'[**associazione onData**](https://ondata.it/)
