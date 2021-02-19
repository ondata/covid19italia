Dal metà febbraio 2021 la Regione Lombardia ha iniziato a pubblicare i dati sulla "Matrice degli stati clinici Covid-19 inviati a ISS":<br>
<https://hub.dati.lombardia.it/Sanit-/Matrice-degli-stati-clinici-Covid-19-inviati-a-ISS/7jw9-ygfv>

Dal 18 febbraio 2021 li abbiamo iniziati ad archiviare in due formati:

- CSV, [regioneLombardiaStatiClinici.csv](processing/regioneLombardiaStatiClinici.csv);
- JSON Lines, [regioneLombardiaStatiClinici.jsonl](processing/regioneLombardiaStatiClinici.jsonl).

L'aggiornamento previsto a monte è settimanale, qui verranno verificati gli aggiornamenti giornalmente e sottoposti a versionamento.

## Nota

Tra i record ce ne è uno in cui la data non è valorizzata, con valori dei campi che sembrano frutto di aggregazione di record. Nel sito sorgente non ci sono indicazioni in merito.<br>
Fabio Riccardo Colombo su [twitter](https://twitter.com/fr_colombo/status/1362594216610783238) ci ha segnalato che:

> La riga senza data raccoglie la somma dei casi per stato clinico senza la data inizio sintomi.

In attesa di conferme ufficiali, ne diamo comunque conto.
