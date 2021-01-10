# Changelog

Qui le variazioni sul set di dati sui vaccini.

## 2020-01-10

-- aggiunta colonna codici NUTS2 ai [dati regionali disaggegati](processing/datiRegioni/)

## 2020-01-08

- stop raccolta dati di dettaglio regionali presenti in [questa cartella](processing/datiRegioni/)
## 2020-01-07

- aggiunta risorsa con [dati di popolazione regione](risorse/popolazioneRegioni.csv) (fonte API REST SDMX ISTAT);
## 2020-01-05

- merge dei file di dettaglio regionali in [`datiRegioni.csv`](processing/datiRegioni.csv);
- creazione per i file di insieme su categoria, fasce d'età, sesso e somministrazione, di un file che contenga soltanto l'ultimo valore per data per giorno (vedi issue [82](https://github.com/ondata/covid19italia/issues/82)). Sono stati nominati con il suffisso `Top`.

## 2021-01-03

- aggiunta colonna `dataAggiornamento` con date e tempo in formato `%Y-%m-%d %H:%M:%S` (`2021-01-02 17:03:24`). In aggiornamento i valori sono in `%m/%d/%Y %I:%M:%S %p` (`1/2/2021 5:03:24 PM`).
