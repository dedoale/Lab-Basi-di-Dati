# Corso di Laboratorio di Basi di Dati<br/>*Progetti A.A. 2025/2026* - Specifica 1

<section class="specifica">

## Progetto "Delivery"
> Versione 1.0

### Premessa

I progetti di fine corso si ispirano sempre ad esigenze
reali. La specifica informale del problema data nei paragrafi seguenti può
essere, come in ogni caso reale, incompleta e, in alcuni punti, ambigua o
contraddittoria. Lo studente dovrà quindi raffinare e disambiguare le
specifiche mediante l'interazione con il committente. In alcuni casi allo
studente sarà richiesto di valutare diverse possibili alternative, per poi
sceglierne una in maniera motivata. Le motivazioni di tutte le scelte
interpretative, progettuali e implementative andranno sempre chiaramente
documentate nel progetto e verranno discusse in sede di esame.

*Nota*: alcune delle funzionalità richieste dalla
specifica potrebbero non essere realizzabili con singole query, ma richiedere
l'uso di strumenti più avanzati messi a disposizione dal DBMS, come le
procedure. In ogni caso, tali procedure avrebbero una o più query come parte
principale. L'uso di queste caratteristiche avanzate aumenta notevolmente il
valore di un progetto. Tuttavia, nel caso si decida di non utilizzarle
nell'implementazione, è necessario comunque presentare lo pseudocodice
corrispondente, e realizzare *completamente* le relative query.

### Specifiche

<section class="descrizione">





Il database *Delivery* supporta una generica attività di ristorazione che offre servizio di consegna a domicilio.

L'attività disporrà di un *menu* composto da *prodotti* ognuno dotato almeno di un nome, una descrizione, un prezzo e, opzionalmente, una (o più) immagini. Internamente (cioè in modo non visibile ai clienti), ogni prodotto avrà anche associati un tempo di preparazione, una lista di ingredienti (con quantità) e opzionalmente la descrizione testuale della procedura di preparazione. Deve essere prevista anche la possibilità di scegliere tra differenti *caratteristiche* del prodotto, ognuna dotata di nome, descrizione (opzionale) e di differenza prezzo (rispetto al prezzo base del prodotto). Alcune caratteristiche potranno essere di *default* (quindi pre-selezionate). Infine,si potranno creare *gruppi di mutua esclusione* tra sottoinsiemi delle caratteristiche (in modo che solo una delle caratteristiche nel gruppo possa essere selezionata). *Esempio: il prodotto "caffè" potrebbe costare 1 euro, e avere come caratteristiche "senza zucchero" (-5 centesimi), "zuccherato" (default) e "molto zuccherato", raggruppate in un gruppo di mutua esclusione chiamato "zucchero", oltre a "con panna" (+50 centesimi) e "freddo" (+1 euro), liberamente selezionabili (non raggruppate).*

I *clienti* potranno registrarsi liberamente nel sistema, ma si noti che i dati di un cliente dovranno necessariamente comprendere contatti telefonici e indirizzo, visto che parliamo di consegna a domicilio.

I clienti potranno selezionare uno o più prodotti dal menu, comprensivi di caratteristiche se presenti, creando un *ordine* a loro nome. L'utente potrà quindi confermare o annullare l'ordine. In caso di conferma, l'utente potrà anche selezionare un orario specifico per la consegna. 

L'applicazione avrà anche altre due tipologie di utenti: il *proprietario*, che supponiamo pre-caricato nel sistema all'atto della sua installazione, e il *personale*. Il primo potrà monitorare gli ordini passati, in preparazione ed evasi, potrà comporre il menu inserendo o modificando tutte le informazioni inerenti i prodotti e potrà infine registrare membri del personale.

I membri del personale vedranno la lista degli ordini correnti, che potranno avere cinque stati: *inserito*, *in preparazione*, *pronto*, *in consegna* e *consegnato*. Il personale potrà cambiare lo stato dell'ordine in qualsiasi momento, ma solo seguendo l'ordine progressivo (non si potrà riportare un ordine in consegna nello stato di preparazione). Il sistema dovrà tener traccia dell'effettivo membro del personale che effettua ciascun cambio di stato su un ordine.

*Grazie a Simone, Francesco e Stefano per aver ispirato questa specifica. Se è troppo complicata, prendetevela con loro* 😀



</section>

Ci sono indubbiamente svariati vincoli che possono essere
applicati ai contenuti di questa base di dati. L'individuazione dei vincoli e
la loro implementazione (con vincoli sulle tabelle, trigger o quantomeno
definendo il codice e le query necessari ad effettuarne il controllo)
costituiscono un requisito importante per lo sviluppo di un progetto
realistico, e ne verrà tenuto conto durante la valutazione finale.  

### Operazioni da realizzare

Di seguito sono illustrate schematicamente le operazioni
previste sulla base di dati, ciascuna da realizzare tramite una query (o, se
necessario, tramite più query, *opzionalmente* racchiuse in una *stored
procedure*). Ovviamente, ogni ulteriore raffinamento o arricchimento di
queste specifiche aumenterà il valore del progetto.

<section class="operazioni">



1. Generazione del menu (*lista dei prodotti con tutte le informazioni visibili al cliente, possibilmente anche le relative caratteristiche con la differenza di prezzo*).
2. Eliminazione di una caratteristica associata a un prodotto.
3. Inserimento di un prodotto in un ordine, comprensivo delle sue eventuali caratteristiche.
4. Calcolo del tempo stimato di consegna e del prezzo totale di un ordine (*suggerimento: potete provare a usare una sotto-query per calcolare la differenza cumulativa di prezzo derivante dalle caratteristiche selezionate e poi sommarla al prezzo base*).
5. Lista degli ordini non ancora messi in preparazione dopo più di un'ora dall'inserimento (*suggerimento: è quindi necessario prevedere degli opportuni timestamp da affiancare agli stati*). 
6. Calcolo del tempo medio di consegna, cioè di passaggio tra lo stato *in consegna* in quello *consegnato*, per ciascun membro del personale addetto alla consegna (*supponiamo che chi consegna sia colui il quale imposta lo stato su consegnato*).
7. Classifica di gradimento dei prodotti (*quali prodotti compaiono più comunemente negli ordini?*).
8. Calcolo dell'incasso giornaliero.
9. Prospetto del consumo di ingredienti in un anno (*quantità di ciascun ingrediente consumata in un certo anno*).
10. Estrazione dei prodotti preferiti da un cliente (*cioè i prodotti più ordinati da quel cliente, magari escludendo a priori quelli ordinati solo un paio di volte...*).
11. Conteggio degli ordini attivi (non in stato *consegnato*) divisi per il loro stato di avanzamento.
12. Conteggio degli ordini smaltiti (consegnati) in uno specifico giorno.
13. Lista dei membri del personale che hanno lavorato a un particolare ordine.
14. Aggiornamento dello stato di un ordine.





</section>

È possibile inserire procedure di gestione addizionali che
si ritengano utili.

</section>

<section class="indicazioni break">

# Indicazioni per lo Sviluppo del Progetto

### Tecnologie da utilizzare

Il DBMS da utilizzare per la realizzazione del progetto è
MySQL. MariaDB è un'alternativa accettabile.

*Opzionalmente*, il database realizzato potrà essere dotato di
un'interfaccia scritta con un linguaggio di programmazione a scelta (Java o
PHP) tramite la quale invocare le query richieste (fornendone gli eventuali
parametri) e visualizzarne i risultati.  

### Svolgimento e Documentazione del Progetto

Le specifiche fornite potrebbero non risultare esaustive o
completamente definite. Ogni funzionalità aggiunta o raffinata, anche tramite
l'interazione con il committente, sarà adeguatamente valutata. Tutte le scelte
progettuali vanno comunque discusse e motivate.

Il progetto dovrà essere svolto secondo le seguenti fasi:

1. Formalizzazione ed analisi dei requisiti.

2. Progettazione concettuale tramite il modello Entità-Relazione.

3. Descrizione di tutti i vincoli non esprimibili nel modello ER.

4. Ristrutturazione ed ottimizzazione del modello ER.

5. Traduzione del modello ER nel corrispondente modello relazionale.

6. Implementazione effettiva del modello relazionale e di tutti i vincoli tramite SQL.

7. Implementazione delle query, procedure, funzioni, ecc. tramite SQL.

Tutte le fasi appena descritte dovranno essere corredate da
adeguata documentazione **in formato elettronico** che illustri quanto è stato
realizzato e le scelte intraprese. 

In particolare, dovranno essere
necessariamente inclusi nella documentazione gli schemi ER risultanti dai passi
(2) e (4), debitamente commentati, e il modello relazionale della base di dati
ottenuto al passo (5), in cui siano messe in evidenza le chiavi delle varie
tabelle e le relazioni tra queste ultime.

Il database finale, risultato dei passi (6) e (7), dovrà
essere consegnato nella forma di un *script SQL* contenente la struttura
del database (istruzioni CREATE, comprese eventuali procedure, funzioni e
viste) e il codice delle query necessarie a realizzare le funzionalità richieste. 
**Il codice di ciascuna query dovrà essere preceduto del suo numero identificativo e dal testo della
sua definizione**, come riportato nella presente specifica. 
*Opzionalmente*, lo script potrà comprendere anche dei dati di prova (istruzioni INSERT).    
*Suggerimento*: potete usare le funzioni di
esportazione presenti in tool come *phpMyAdmin*, *DBeaver* o *MySQL Workbench*, oppure direttamente il
comando *mysqldump*, per esportare un *dump* del database contenente sia la
struttura che i dati. Inoltre, per praticità, nella maggior parte dei casi
potrete incorporare anche la definizione delle query nel dump del database,
definendole come viste o stored procedures con nomi significativi come
"Query_1", ecc.

A puro titolo esemplificativo, all'interno del repository dei progetti 
del corso è presente un documento-base, strutturato seguendo le
indicazioni appena esposte, da cui è possibile derivare la propria documentazione.

Le parti della specifica marcate come *opzionali*, se
omesse, non renderanno il progetto insufficiente ma non gli permetteranno
comunque di raggiungere il massimo dei voti. Nel caso si decida di realizzarle,
non sarà necessario che siano perfette o complete, ma che dimostrino
chiaramente il vostro impegno nell'affrontare una tematica avanzata.

Nel caso di gruppi di lavoro composti da più componenti, *il
contributo effettivo offerto da ciascun componente* alla realizzazione
finale **deve** essere descritto nella documentazione (indicando, ad
esempio, chi si è dedicato prevalentemente alla modellazione concettuale, chi
ha realizzato il database con SQL, chi ha lavorato su ciascuna query, ecc.). In
sede di esame, i responsabili potranno essere chiamati a riferire sugli aspetti
loro delegati.  

### Consegna del Progetto

La *documentazione* e il *codice* del progetto descritti nella
sezione precedente andranno consegnati, anche per email, **almeno una
settimana prima** della data prevista per l'appello d'esame.   
*Non verranno in alcun caso concesse proroghe a questo termine*, perchè concedere 
anche un giorno in più a uno studente vorrebbe dire svantaggiare tutti gli altri che hanno 
consegnato per tempo o hanno organizzato i loro impegni per farlo, e che avrebbero 
anch'essi sicuramente beneficiato di un po' di tempo aggiuntivo, quantomeno per 
migliorare o rifinire il proprio lavoro.     
La consegna del progetto deve essere vista come un esame scritto: si svolge 
in un determinato giorno, poi viene corretto, e infine durante l'orale viene discusso. 
Il vantaggio del progetto è che può essere essere sviluppato nell'arco di molti mesi,
tuttavia il termine della consegna resta perentorio.

In sede di esame saranno discussi eventuali problemi
riscontrati nel progetto e potrà essere richiesta una dimostrazione del
funzionamento di alcune query e/o dell'eventuale interfaccia realizzata (è
quindi opportuno portare con sé un portatile con il progetto installato e
funzionante).

### Valutazione del Progetto


Nel valutare il progetto consegnato saranno prese in considerazione
le seguenti caratteristiche:

1. Rispetto delle specifiche e loro corretto raffinamento, ove necessario.

2. Correttezza e conformità alle specifiche dei modelli realizzati.

3. Correttezza tecnica dell'implementazione fisica del database (struttura, vincoli).

4. Correttezza tecnica delle query realizzate e loro aderenza alle funzionalità richieste.

5. Adeguatezza della documentazione.

A questa valutazione si aggiungerà quella generale derivata
dalla discussione del progetto in sede d'esame.  

### Ulteriori Informazioni

Questa specifica è disponibile nel repository del corso di Laboratorio di Basi di Dati, 
all'indirizzo https://github.com/LaboratorioBasiDiDati-Univaq/LBD_Project_Specifications. 
Ulteriori informazioni e chiarimenti sulle
specifiche possono essere richiesti direttamente via email all'indirizzo
giuseppe.dellapenna@univaq.it.

Si ricorda che i progetti vanno svolti in *piccoli*
gruppi (due/tre persone è il numero consigliato). Eccezioni a questa regola
andranno concordate direttamente col docente. 
</section>

