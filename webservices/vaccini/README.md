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
- quelli sul [**sesso**](processing/sesso.csv) dei vaccinati.

## Note

L'*enconding* dei CSV è `UTF-8` e il separatore delle colonne è la `,`.

La colonna `aggiornamento` presente nei CSV dà conto della data di aggiornamento letta sulla *dashboard*, al momento della pubblicazione qui dei dati. Il formato è `mese/giorno/anno ora`.

L'aggiornamento dei dati invece verrà eseguito in `cron` nelle modalità definite [qui](https://github.com/ondata/covid19italia/blob/master/.github/workflows/vaccini.yml#L7).
