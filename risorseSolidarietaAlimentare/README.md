# Emergenza  COVID-19 | Dati su misure e risorse per la solidarietà alimentare

Il 29 marzo 2020 [Isaia Invernizzi](https://twitter.com/EasyInve) [ha dato notizia](https://www.facebook.com/groups/dataninja/permalink/2261129897526089/) della pubblicazione del [documento in PDF](./rawdata/_contributi.pdf) sulle "**misure e risorse per la solidarietà alimentare**", inviato dal presidente della "Conferenza delle Regioni e delle Province autonome" ai Signori Presidenti delle Regioni e delle Province autonome. Il documento è presente anche in alcuni giornali online ([questo](https://web.archive.org/web/20200329204651/http://www.lavocediasti.it/2020/03/29/leggi-notizia/argomenti/attualita-15/articolo/ad-asti-arriveranno-oltre-400mila-euro-di-stanziamento-per-gli-aiuti-alimentari-quasi-un-milione-in.html) un esempio).

È un documento che dettaglia le risorse da destinare a misure urgenti di solidarietà alimentare, legate alla conseguenze  dell’emergenza  COVID-19.

Il file PDF contiene due allegati tabellari e sono stati convertiti in CSV:

- [allegato_01.csv](./allegato_01.csv)
- [allegato_02.csv](./allegato_02.csv)

Qui sotto una preview dello schema dati (`POP` è la popolazione):

| codINT | codBDAP | AREA | REGIONE | ENTE | POP | Quota a) | Quota b) | Contributo spettante | pagina |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1010020010 | 668242930533365502 | NORD | PIEMONTE | ACQUI TERME | 19604 | 103931.86 | 685.87 | 104617.73 | 9 |
| 1010020020 | 681742930510597001 | NORD | PIEMONTE | ALBERA LIGURE | 300 | 1590.47 | 418.61 | 2009.08 | 9 |
| 1010020030 | 136842930509823702 | NORD | PIEMONTE | ALESSANDRIA | 93631 | 496390.74 |  | 496390.74 | 9 |
| 1010020040 | 972642928168076602 | NORD | PIEMONTE | ALFIANO NATTA | 779 | 4129.92 | 933.61 | 5063.53 | 9 |


## allegato_01.csv - Note sulla colonna codINT

La colonna `codINT` contiene l'identificativo numerico dell'ente, secondo una codifica del Ministero degli Interni.<br>[Salvatore Fiandaca](https://twitter.com/totofiandaca) (grazie mille) ha creato un file con i [codici ISTAT](COD_ISTAT_codINT.csv) corrispondenti.

## allegato_01.csv e allegato_02.csv - Note sulla colonna codBDAP

L'anagrafica dei codici BDAP (campo `codBDAP` degli allegati) degli enti si trova nel file [Anagrafe-Enti---Ente.csv](Anagrafe-Enti---Ente.csv) (campo `Id_Ente`, fonte [OpenBDAP](https://bdap-opendata.mef.gov.it/tema/anagrafe-enti-della-pubblica-amministrazione), grazie [Giorgia Lodi](https://twitter.com/GiorgiaLodi) per la segnalazione). Questo contiene i codici ISTAT dei comuni (campo `Codice_ISTAT_Comune`), e può essere usato quindi per associare ai dati sulla solidarietà alimentare, il codice ISTAT comunale.

# Se usi questi dati

Cita per favore l'Associazione onData e questo URL <https://github.com/ondata/covid19italia/blob/master/risorseSolidarietaAlimentare/README.md>.
