## puntiSomministrazione.csv

I [**🧮 dati in formato CSV**](puntiSomministrazione.csv) sono estratti grazie allo [script](../../puntiSomministrazione.py) di [**Sergio Vavassori**](https://github.com/svavassori), per l'interpretazione corretta - e conversione in `CSV` - dei `JSON` restituiti dalle API della *dashboard*.

Rispetto ai dati ufficiali, qui sono disponibili **indirizzo** e **CAP** del punto.

La *dashboard* è quella raggiungibile a questo URL:<br>
<https://app.powerbi.com/view?r=eyJrIjoiMzg4YmI5NDQtZDM5ZC00ZTIyLTgxN2MtOTBkMWM4MTUyYTg0IiwidCI6ImFmZDBhNzVjLTg2NzEtNGNjZS05MDYxLTJjYTBkOTJlNDIyZiIsImMiOjh9>



## puntiSomministrazioneDatiVax.csv

È un file in cui, per ogni punto di somministrazione, è riportato il numero di somministrazioni per **sesso** e categoria delle persone, e se si tratta di **prima** o **seconda dose**.<br>
Il file è [**puntiSomministrazioneDatiVax.csv**](puntiSomministrazioneDatiVax.csv).

Grazie a [**Salvatore Larosa**](https://twitter.com/lrssvt), che li ha resi disponibili nel suo [repository](https://github.com/slarosa/vax).

Sono estratti dalla stessa *dashboard* di sopra.

## Note generali

**NOTA BENE**: i dati sono ricavati interrogando le API non documentate della *dashboard*; non sono stati resi palesemente accessibili. I dati aperti ufficiali sui punti di somministrazione sono quelli pubblicati [qui](https://github.com/italia/covid19-opendata-vaccini). Inoltre la procedura di estrazione potrebbe contenere degli errori.
