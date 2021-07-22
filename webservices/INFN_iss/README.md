# Dati Istituto Superiore di Sanità pubblicati sul sito dell'Istituto Nazionale di Fisica Nucleare

L'INFN pubblica dei grafici basati su dati ISS in [questa pagina](https://covid19.infn.it/iss/)

> A differenza dei dati del Dipartimento della Protezione Civile, questi dati sono riferiti alle date effettive e non sono affetti da ritardi dovuti alla comunicazione dei dati tra ASL e regioni. Sono inoltre disponibili maggiori informazioni che consentono un'analisi più dettagliata.

I dati che li alimentano sono visibili nella console del *browser*.

# Elenco dei grafici e relativi dati

## Operatori sanitari

- nome dataset: `iss_opsan`

Il grafico riguarda i dati giornalieri su ricoveri, sintomatici, terapia_intensiva degli **operatori sanitari**. Sono presenti gli stessi dati anche per gli `altri` (chi non è operatore sanitario).

Sono stati estratti 4 file:

- [`iss_opsan.csv`](./processing/iss_opsan.csv), dati sugli operatori sanitari;

| date | valore | regione | tipo |
| --- | --- | --- | --- |
| 2021-03-01T00:00:00 | 1 | pabolzano_ | sintomatici |
| 2021-02-03T00:00:00 | 6 | piemonte | sintomatici |
| ... | ... | ... | ... |

- [`iss_opsan_wide.csv`](./processing/iss_opsan_wide.csv), dati sugli operatori sanitari, in versione wide;

| date | regione | ricoveri | sintomatici | terapia_intensiva |
| --- | --- | --- | --- | --- |
| 2021-03-02T00:00:00 | toscana |  | 0 |  |
| 2020-12-16T00:00:00 | sicilia | 0 | 6 | 0 |
| ... | ... | ... | ... |...|

- [`iss_opsan_altri.csv`](./processing/iss_opsan_altri.csv), dati su altri da "operatori sanitari";

| date | valore | regione | tipo |
| --- | --- | --- | --- |
| 2020-05-25T00:00:00 | 0 | trentinoalto_adige_ | terapia_intensiva |
| 2020-04-19T00:00:00 | 2 | pabolzano_ | ricoveri |
| ... | ... | ... | ... |

- [`iss_opsan_altri_wide.csv`](./processing/iss_opsan_altri_wide.csv), dati su altri da "operatori sanitari", in versione *wide*;

| date | regione | ricoveri | sintomatici | terapia_intensiva |
| --- | --- | --- | --- | --- |
| 2021-03-19T00:00:00 | friulivenezia_giulia_ | 52 | 553 | 5 |
| 2021-01-13T00:00:00 | molise | 4 | 6 | 0 |
| ... | ... | ... | ... |


Il significato dei valori del campo `tipo` è quello di sotto:

| valore campo `tipo` | descrizione |
| --- | --- |
|sintomatici|nuovi casi sintomatici, riferiti alla data di inizio sintomi|
|ricoveri|nuovi ricoverati, riferiti alla data del ricovero|
|terapia_intensiva|nuovi ingressi in terapia intensiva, riferiti alla data di ingresso in t.i.|



## Ultra-ottantenni

- nome dataset: `iss_80plus`


