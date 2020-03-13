La regione Lombardia pubblica una dashboard cartografica con i dati comunali sul Covid-19: https://experience.arcgis.com/experience/0a5dfcc103d0468bbb6b14e713ec1e30/

In questo cartella:

- [uno script bash](regioneLombardia.sh) per estrarli;
- [una cartella](./rawdata) con i dati di output dello script.

Le risorse scaricate sono 3, ma non sembrano presenti descrizione delle stesse. Sono denominate:

- [COMUNI_COVID19](rawdata/COMUNI_COVID19.geojson), un layer poligonale in formato GeoJSON;
- [PROVINCE_COVID19](rawdata/PROVINCE_COVID19.geojson), un layer poligonale in formato GeoJSON;
- [ta_covid19_comuni_time](rawdata/ta_covid19_comuni_time.geojson), un layer puntiforme in formato GeoJSON;
- [TA_COVID19_RL](rawdata/TA_COVID19_RL.json), una risorsa alfanumerica.

`ta_covid19_comuni_time` e `TA_COVID19_RL` sono stati convertiti in CSV e pubblicati in [questa cartella](processing/).

**NOTA BENE**: sono i dati al 13 marzo 2020 e non verranno aggiornati in questo spazio. Sono stati aggiunti per mostrare come accedervi.

