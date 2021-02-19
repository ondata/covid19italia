Dal metà febbraio 2021 la Regione Lombardia ha iniziato a pubblicare i dati sulla "Matrice degli stati clinici Covid-19 inviati a ISS":<br>
<https://hub.dati.lombardia.it/Sanit-/Matrice-degli-stati-clinici-Covid-19-inviati-a-ISS/7jw9-ygfv>

Dal 18 febbraio 2021 li abbiamo iniziati ad archiviare in due formati:

- CSV, [regioneLombardiaStatiClinici.csv](processing/regioneLombardiaStatiClinici.csv);
- JSON Lines, [regioneLombardiaStatiClinici.jsonl](processing/regioneLombardiaStatiClinici.jsonl).

L'aggiornamento previsto a monte è settimanale, qui verranno verificati gli aggiornamenti giornalmente e sottoposti a versionamento.

## Nota

Tra i record ce ne è uno in cui la data non è valorizzata, con valori dei campi che sembrano frutto di aggregazione di record. Abbiamo chiesto spiegazione a Open Data Lombardia, che ci ha risposto così:

> Con riferimento alla riga con il campo DATA_INIZIO_SINTOMI non valorizzato: "Il  valore nullo indica uno stato clinico classificato come asintomatico o per il quale non è pervenuta la Data Inizio Sintomi"
