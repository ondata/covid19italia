La regione Lombardia pubblica una dashboard cartografica con i dati comunali sul Covid-19: https://experience.arcgis.com/experience/0a5dfcc103d0468bbb6b14e713ec1e30/

In questo cartella:

- [uno script bash](regioneLombardia.sh) per estrarli;
- [una cartella](./rawdata) con i dati di output grezzi dello script;
- [una cartella](./processing) con i dati di output frutto di elaborazione.

Le risorse native sono 4, ma non è presente alcuna descrizione delle stesse. Sono denominate:

- [COMUNI_COVID19](rawdata/COMUNI_COVID19.geojson), un layer poligonale in formato GeoJSON;
- [PROVINCE_COVID19](rawdata/PROVINCE_COVID19.geojson), un layer poligonale in formato GeoJSON;
- [ta_covid19_comuni_time](rawdata/ta_covid19_comuni_time.geojson), un layer puntiforme in formato GeoJSON (**NOTA BENE**: il 18-04-2020 TA_COVID19_RL è stato rimosso : questo layer non è più disponibile sul sito della regione);
- [TA_COVID19_RL](rawdata/TA_COVID19_RL.json), una risorsa alfanumerica (**NOTA BENE**: dal 18-04-2020 non è più disponile sul sito della regione).

Sono state scaricate e convertite in CSV (*encoding* `UTF-8` e separatore la `,`), nella cartella [*processing*](./processing).

## TA_COVID19_RL

Il file [`TA_COVID19_RL.csv`](./processing/TA_COVID19_RL.csv) elenca i **tamponi** con esito positivo registrati da **Regione Lombardia**.<br>Per ciascun tampone sono indicati: **data** di ricevimento del tampone da parte del laboratorio di analisi; **sesso**, **età**, **provincia** e **domicilio** della persona risultata positiva al test; indicazione dei soggetti deceduti.

|Nome campo|Descrizione|
|---|---|
|DATA_RICEVIMENTO_TAMPONE|Data in cui il laboratorio ha ricevuto il tampone|
|FASCIA_DI_ETÀ|Fascia di età|
|RESIDENZA_COMUNE|Comune di residenza|
|DOMICILIO_COMUNE|Nome del comune di domicilio|
|CODICE_COMUNE_DOMICILIO|Codice ISTAT del comune di domicilio|
|CODICE_COMUNE|Codice ISTAT del comune di domicilio|
|DESCRIZIONE_COMUNE|Descrizione del comune di domicilio|
|CODICE_PROVINCIA|Sigla della provincia|
|PROVINCIA|Provincia|
|VIVO_O_DECEDUTO|Vivo o deceduto|
|SESSO|Sesso|
|REGIONE|Regione|


### Elaborazioni derivate

- "[L’identikit dei contagiati in Bergamasca - Ecco tutti i dati Comune per Comune](https://www.ecodibergamo.it/stories/bergamo-citta/lidentikit-dei-contagiati-in-bergamascaecco-tutti-i-dati-comune-per-comune_1350432_11/)", [Isaia Invernizzi](https://twitter.com/EasyInve) su "L'eco di Bergamo";
- "[Mappa dei deceduti per #COVID19 in Lombardia (16 aprile 2020)](https://twitter.com/beriapaolo/status/1251788913234116608)", [Paolo Beria](https://twitter.com/beriapaolo);
- Shapefile con somma di deceduti e vivi per comune, di [Paolo Beria](https://twitter.com/beriapaolo), presenti nella cartella [elaborazioni](./elaborazioni);
- "[Lombardia: tutti i dati del contagio e dei decessi](https://www.facebook.com/globalpolicynews/posts/2058168257661972)", GPN MEDIA CENTER.
