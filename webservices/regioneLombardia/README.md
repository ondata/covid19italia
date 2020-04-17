La regione Lombardia pubblica una dashboard cartografica con i dati comunali sul Covid-19: https://experience.arcgis.com/experience/0a5dfcc103d0468bbb6b14e713ec1e30/

In questo cartella:

- [uno script bash](regioneLombardia.sh) per estrarli;
- [una cartella](./rawdata) con i dati di output grezzi dello script;
- [una cartella](./processing) con i dati di output frutto di elaborazione.

Le risorse native sono 4, ma non presenti descrizione delle stesse. Sono denominate:

- [COMUNI_COVID19](rawdata/COMUNI_COVID19.geojson), un layer poligonale in formato GeoJSON;
- [PROVINCE_COVID19](rawdata/PROVINCE_COVID19.geojson), un layer poligonale in formato GeoJSON;
- [ta_covid19_comuni_time](rawdata/ta_covid19_comuni_time.geojson), un layer puntiforme in formato GeoJSON (NOTA BENE: questo layer non è più disponibile);
- [TA_COVID19_RL](rawdata/TA_COVID19_RL.json), una risorsa alfanumerica.

Vengono giornalmente scaricate e convertite in CSV (*encoding* `UTF-8` e separatore la `,`), nella cartella [*processing*](./processing).


## TA_COVID19_RL

Il file [`TA_COVID19_RL.csv`](./processing/TA_COVID19_RL.csv) elenca i **tamponi** con esito positivo registrati da **Regione Lombardia**.<br>Per ciascun tampone sono indicati: **data** di ricevimento del tampone da parte del laboratorio di analisi; **sesso**, **età**, **nazionalità**, **provincia**, **comune** di **residenza** e **domicilio** della persona risultata positiva al test; indicazione dei soggetti deceduti.

|Nome campo|Descrizione|
|---|---|
|DATA_RICEVIMENTO_TAMPONE|Data in cui il laboratorio ha ricevuto il tampone|
|ETÀ|Età|
|FASCIA_DI_ETÀ|Fascia di età|
|NAZIONALITÀ|Nazionalità|
|DOMICILIO_COMUNE|Comune di domicilio|
|RESIDENZA_COMUNE|Comune di residenza|
|CODICE_COMUNE_DOMICILIO|Codice ISTAT del comune di domicilio|
|CODICE_COMUNE_RESIDENZA|Codice ISTAT del comune di residenza|
|CODICE_COMUNE|Codice ISTAT del comune di domicilio|
|DESCRIZIONE_COMUNE|Descrizione del comune di domicilio|
|CODICE_PROVINCIA|Sigla della provincia|
|PROVINCIA|Provincia|
|VIVO_O_DECEDUTO|Vivo o deceduto|
|SESSO|Sesso|
|REGIONE|Regione|
