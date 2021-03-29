- [Dati aree misure restrittive COVID19](#dati-aree-misure-restrittive-covid19)
  - [Introduzione](#introduzione)
  - [Output prodotti](#output-prodotti)
    - [areeStorico.csv](#areestoricocsv)
    - [areeStorico_wide.csv](#areestorico_widecsv)
    - [areeStorico_long.csv](#areestorico_longcsv)
- [Altre fonti di dati](#altre-fonti-di-dati)
  - [Non ufficiali](#non-ufficiali)
  - [Ufficiali](#ufficiali)
    - [L'SVG nella pagina delle FAQ COVID-19 del governo](#lsvg-nella-pagina-delle-faq-covid-19-del-governo)
    - [La pagina "COVID-19 - Situazione in Italia" del sito del Ministero della Salute](#la-pagina-covid-19---situazione-in-italia-del-sito-del-ministero-della-salute)

# Dati aree misure restrittive COVID19

## Introduzione

Il **Dipartimento della Protezione Civile** pubblica i dati sulle **misure** di **contenimento** applicate a livello nazionale e/o nelle regioni e province autonome, ovvero l'assegnazione delle zone rosse, arancioni, gialle e bianche.

Due link di riferimento:

- i dati <https://github.com/pcm-dpc/COVID-19/tree/master/aree>;
- la loro descrizione <https://github.com/pcm-dpc/COVID-19/blob/master/dati-aree-covid19.md>.

Abbiamo prodotto degli altri elaborati a partire da questa fonte per due ragioni principali:

- non è presente in modo diretto la classificazione a "colori";
- le aree non sono associate a codici geografici standard, ma ai relativi nomi.

## Output prodotti

### areeStorico.csv

[`areeStorico.csv`](./processing/areeStorico.csv) è il file di output di base. Riprende il contenuto originale, a cui vengono aggiungi i campi:

- `NUTS_code`, con il codice geografico standard [`NUTS`](https://www.wikiwand.com/it/Nomenclatura_delle_unit%C3%A0_territoriali_statistiche) dell'area geografica a cui viene applicata la misura restrittiva;
- `datasetIniISO`, la data inizio della misuta applicata, in formato `YYYY-MM-DD` (anno, mese giorno);
- `zona`, il colore a cui associata la misura restrittiva (rossa, arancione, gialla e bianca).

Qui sotto alcune righe di esempio:

| NUTS_code | datasetIniISO | zona | versionID | nomeTesto | FID | datasetIni | datasetFin | designIniz | designFine | nomeAutCom | legNomeBre | legData | legLink | legSpecRif | legLivello | legGU_Link | NUTS_level | datasetFinISO |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ITF5 | 2020-12-06 | arancione | 7 | Basilicata | 45 | 06/12/2020 | 20/12/2020 | 1607212800000 | 20/12/2020 | Ministero della Salute | Ordinanza 05/12/2020 | 1607126400000 | https://www.trovanorme.salute.gov.it/norme/dettaglioAtto?id=77515 | art.2 | regionale | https://www.gazzettaufficiale.it/eli/id/2020/12/05/20A06781/sg | 2 | 2020-12-20 |
| ITG1 | 2021-01-10 | arancione | 17 | Sicilia | 91 | 10/01/2021 | 15/01/2021 | 1610236800000 | 15/01/2021 | Ministero della Salute | Ordinanza 08/01/2021 | 1610064000000 | https://www.trovanorme.salute.gov.it/norme/dettaglioAtto?id=78156 | art.2 | regionale | https://www.gazzettaufficiale.it/eli/id/2021/01/09/21A00123/sg | 2 | 2021-01-15 |
| ITC3 | 2021-01-17 | arancione | 18 | Liguria | 100 | 17/01/2021 | 31/01/2021 | 1610841600000 | 31/01/2021 | Ministero della Salute | Ordinanza 16/01/2021 | 1610755200000 | http://www.salute.gov.it/imgs/C_17_notizie_5272_3_file.pdf | art.2 | regionale | https://www.gazzettaufficiale.it/eli/id/2021/01/16/21A00223/sg | 2 | 2021-01-31 |
| ITI3 | 2021-01-17 | arancione | 18 | Marche | 104 | 17/01/2021 | 31/01/2021 | 1610841600000 | 31/01/2021 | Ministero della Salute | Ordinanza 16/01/2021 | 1610755200000 | http://www.salute.gov.it/imgs/C_17_notizie_5272_3_file.pdf | art.2 | regionale | https://www.gazzettaufficiale.it/eli/id/2021/01/16/21A00223/sg | 2 | 2021-01-31 |
| ITF1 | 2021-02-14 | arancione | 23 | Abruzzo | 141 | 14/02/2021 | 28/02/2021 | 1613260800000 | 28/02/2021 | Ministero della Salute | Ordinanza 12/02/2021 | 1613088000000 | http://www.salute.gov.it/imgs/C_17_notizie_5325_0_file.pdf | art.2 | regionale | https://www.gazzettaufficiale.it/eli/id/2021/02/13/21A00960/sg | 2 | 2021-02-28 |

### areeStorico_wide.csv

Il file [`areeStorico_wide.csv`](./processing/areeStorico_wide.csv) deriva da [`areeStorico.csv`](./processing/areeStorico.csv) e così composto:

- la colonna `datasetIniISO` con la data di inizio di applicazione della misura;
- una colonna per ogni codice geografico `NUTS`, con all'interno il "colore" relativo associato per quella data.

Qui sotto alcune righe di esempio:

| datasetIniISO | ITF6 | ITF3 | ITI4 | ITC4 | ITF2 | ITC1 | ITH2 | ITF4 | ITG2 | ITG1 | ITC2 | ITH3 | ITF1 | ITF5 | ITC3 | ITH1 | ITI1 | ITI2 | ITH5 | ITH4 | ITI3 | IT |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2020-11-06 | rossa | gialla | gialla | rossa | gialla | rossa | gialla | arancione | gialla | arancione | rossa | gialla |  |  |  |  |  |  |  |  |  |  |
| 2020-11-29 | arancione |  |  | arancione |  | arancione |  |  |  | gialla |  |  |  |  | gialla |  |  |  |  |  |  |  |
| 2021-01-04 | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione | arancione |
| 2021-02-15 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | arancione |  | arancione |  |  |  |  |
| 2021-03-15 | arancione |  | rossa | rossa | rossa | rossa | rossa | rossa |  | arancione | arancione | rossa |  |  | arancione |  |  |  | rossa | rossa | rossa |  |

### areeStorico_long.csv

Il file [`areeStorico_long.csv`](./processing/areeStorico_long.csv) è la versione `long` di  [`areeStorico_wide.csv`](./processing/areeStorico_wide.csv), in cui i codici geografici `NUTS` sono raccolti in una colonna.

Qui sotto alcune righe di esempio:

| datasetIniISO | NUTS_code | zona |
| --- | --- | --- |
| 2020-11-06 | ITH3 | gialla |
| 2021-01-04 | ITI3 | arancione |
| 2021-01-04 | ITH2 | arancione |
| 2021-03-01 | ITH1 | arancione |
| 2021-03-15 | ITH4 | rossa |


# Altre fonti di dati

## Non ufficiali

- "covid-19 zone", di Giorgio Tsiotas https://github.com/tsiotas/covid-19-zone

## Ufficiali

### L'SVG nella pagina delle FAQ COVID-19 del governo

In [questa pagina](https://www.governo.it/it/articolo/domande-frequenti-sulle-misure-adottate-dal-governo/15638) c'è un file SVG a cui per ogni poligono è associata un'etichetta per il nome regione/provincia autonoma e il colore di zona associato.

```XML
<path id="campania" onclick="campania('rosso')"
fill="#e2001a" d="m733.25 763.44c-0.28304 8e-3 -0.56492 0.0313-0.8125 0.0625s-0.46385 ...."></path>
```

Estraiamo da qui questo CSV: [`areeGov.csv`](./processing/areeGov.csv).

### La pagina "COVID-19 - Situazione in Italia" del sito del Ministero della Salute

La pagina "[COVID-19 - Situazione in Italia](http://www.salute.gov.it/portale/nuovocoronavirus/dettaglioContenutiNuovoCoronavirus.jsp?area=nuovoCoronavirus&id=5351&lingua=italiano&menu=vuoto)" del sito del Ministero della Salute, contiene del codice `HTML` da cui è possibile estrarre l'accoppiata colori zone/regioni-province autonome

![](https://i.imgur.com/SZW0PIv.png)
