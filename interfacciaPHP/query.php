<?php
require 'db.php';

/* Elenco invariato delle operazioni generato dal form */
$operazioni = [
    1  => ['label' => '1. Generazione del menu', 'params' => []],
    2  => ['label' => '2. Eliminazione di una caratteristica di un prodotto', 'params' => [
        ['name' => 'id_caratteristica', 'label' => 'ID Caratteristica', 'type' => 'number'],
    ]],
    3  => ['label' => '3. Inserimento di un prodotto in un ordine (con caratteristiche)', 'params' => [
        ['name' => 'id_ordine', 'label' => 'ID Ordine', 'type' => 'number'],
        ['name' => 'id_prodotto', 'label' => 'ID Prodotto', 'type' => 'number'],
        ['name' => 'quantita', 'label' => 'Quantità', 'type' => 'number'],
        ['name' => 'caratteristiche', 'label' => 'ID Caratteristiche selezionate (separati da virgola, opzionale)', 'type' => 'text'],
    ]],
    4  => ['label' => '4. Calcolo tempo stimato e prezzo totale di un ordine', 'params' => [
        ['name' => 'id_ordine', 'label' => 'ID Ordine', 'type' => 'number'],
    ]],
    5  => ['label' => "5. Ordini non ancora in preparazione da più di un'ora", 'params' => []],
    6  => ['label' => '6. Tempo medio di consegna per membro del personale', 'params' => []],
    7  => ['label' => '7. Classifica di gradimento dei prodotti', 'params' => []],
    8  => ['label' => '8. Incasso giornaliero', 'params' => [
        ['name' => 'giorno', 'label' => 'Giorno', 'type' => 'date'],
    ]],
    9  => ['label' => '9. Consumo ingredienti in un anno', 'params' => [
        ['name' => 'anno', 'label' => 'Anno', 'type' => 'number'],
    ]],
    10 => ['label' => '10. Prodotti preferiti di un cliente', 'params' => [
        ['name' => 'id_cliente', 'label' => 'ID Cliente', 'type' => 'number'],
        ['name' => 'soglia', 'label' => 'Numero minimo di ordinazioni (default 2)', 'type' => 'number'],
    ]],
    11 => ['label' => '11. Conteggio ordini attivi per stato', 'params' => []],
    12 => ['label' => '12. Conteggio ordini consegnati in un giorno', 'params' => [
        ['name' => 'giorno', 'label' => 'Giorno', 'type' => 'date'],
    ]],
    13 => ['label' => '13. Personale che ha lavorato su un ordine', 'params' => [
        ['name' => 'id_ordine', 'label' => 'ID Ordine', 'type' => 'number'],
    ]],
    14 => ['label' => '14. Aggiornamento dello stato di un ordine', 'params' => [
        ['name' => 'id_ordine', 'label' => 'ID Ordine', 'type' => 'number'],
        ['name' => 'nuovo_stato', 'label' => 'Nuovo stato', 'type' => 'select',
            'options' => ['inserito', 'in preparazione', 'pronto', 'in consegna', 'consegnato']],
        ['name' => 'id_utente_personale', 'label' => 'ID Utente (chi effettua il cambio)', 'type' => 'number'],
    ]],
];

$op = isset($_POST['op']) ? (int) $_POST['op'] : null;
$colonne = [];
$righe = [];
$messaggio = null;
$errore = null;

if ($op !== null && isset($operazioni[$op])) {
    try {
        switch ($op) {
            case 1:
                $stmt = $pdo->query(
                    "SELECT p.id_prodotto, p.nome, p.descrizione, p.prezzo_base, p.categoria,
                            p.tempo_preparazione, g.nome AS gruppo_caratteristica,
                            c.nome AS caratteristica, c.differenza_prezzo, c.is_default
                     FROM Prodotto p
                     LEFT JOIN Caratteristica c ON c.id_prodotto = p.id_prodotto
                     LEFT JOIN Gruppo_Caratteristica g ON g.id_gruppo = c.id_gruppo
                     ORDER BY p.id_prodotto, g.nome, c.nome"
                );
                $righe = $stmt->fetchAll();
                break;

            case 2:
                $stmt = $pdo->prepare("DELETE FROM Caratteristica WHERE id_caratteristica = :id");
                $stmt->execute(['id' => $_POST['id_caratteristica']]);
                $messaggio = $stmt->rowCount() > 0
                    ? "Caratteristica eliminata."
                    : "Nessuna caratteristica trovata con quell'ID.";
                break;

            case 3:
                $idOrdine = (int) $_POST['id_ordine'];
                $idProdotto = (int) $_POST['id_prodotto'];
                $quantita = (int) $_POST['quantita'];

                $pdo->beginTransaction();

                $stmt = $pdo->prepare("SELECT COALESCE(MAX(numero_riga), 0) + 1 AS prossimo FROM Riga_Ordine WHERE id_ordine = :id");
                $stmt->execute(['id' => $idOrdine]);
                $numeroRiga = $stmt->fetch()['prossimo'];

                // I prezzi vengono sovrascritti automaticamente in backend dai trigger. Viene inviato 0 per bypassare il NOT NULL.
                $stmt = $pdo->prepare(
                    "INSERT INTO Riga_Ordine (id_ordine, numero_riga, id_prodotto, quantita, prezzo_base_al_momento)
                     VALUES (:id_ordine, :numero_riga, :id_prodotto, :quantita, 0)"
                );
                $stmt->execute([
                    'id_ordine' => $idOrdine,
                    'numero_riga' => $numeroRiga,
                    'id_prodotto' => $idProdotto,
                    'quantita' => $quantita
                ]);
                $idRiga = $pdo->lastInsertId();

                $caratteristicheInserite = 0;
                $caratteristicheRaw = trim($_POST['caratteristiche'] ?? '');
                if ($caratteristicheRaw !== '') {
                    $ids = array_filter(array_map('trim', explode(',', $caratteristicheRaw)), 'strlen');
                    
                    $stmtIns = $pdo->prepare(
                        "INSERT INTO Personalizzata (id_riga, id_caratteristica, diff_prezzo_al_momento)
                         VALUES (:id_riga, :id_caratteristica, 0)"
                    );
                    foreach ($ids as $idCar) {
                        $stmtIns->execute([
                            'id_riga' => $idRiga,
                            'id_caratteristica' => $idCar
                        ]);
                        $caratteristicheInserite++;
                    }
                }

                $pdo->commit();
                $messaggio = "Prodotto inserito (riga #$numeroRiga) con $caratteristicheInserite caratteristica/e. Prezzi e tempi calcolati dai trigger.";
                break;

            case 4:
                $idOrdine = (int) $_POST['id_ordine'];
                // Nessun UPDATE. I calcoli sono eseguiti dai trigger ad ogni INSERT. Leggiamo direttamente il DB.
                $stmt = $pdo->prepare(
                    "SELECT id_ordine, prezzo_totale, tempo_consegna_stimato
                     FROM Ordine WHERE id_ordine = :id"
                );
                $stmt->execute(['id' => $idOrdine]);
                $risultato = $stmt->fetch();

                if ($risultato) {
                    $righe = [[
                        'id_ordine' => $risultato['id_ordine'],
                        'prezzo_totale' => number_format($risultato['prezzo_totale'] ?? 0, 2),
                        'tempo_consegna_stimato_min' => $risultato['tempo_consegna_stimato'],
                    ]];
                    $messaggio = "Dati dell'ordine letti con successo (calcolati automaticamente dai trigger).";
                } else {
                    $errore = "Nessun ordine trovato con quell'ID.";
                }
                break;

            case 5:
                $stmt = $pdo->query(
                    "SELECT id_ordine, codice_ordine, id_utente_cliente, data_inserimento,
                            TIMESTAMPDIFF(MINUTE, data_inserimento, NOW()) AS minuti_trascorsi
                     FROM Ordine
                     WHERE stato_attuale = 'inserito'
                       AND data_inserimento < (NOW() - INTERVAL 1 HOUR)
                     ORDER BY data_inserimento"
                );
                $righe = $stmt->fetchAll();
                break;

            case 6:
                $stmt = $pdo->query(
                    "SELECT u.id_utente, u.nome,
                            COUNT(*) AS consegne_effettuate,
                            AVG(TIMESTAMPDIFF(MINUTE, sc.timestamp_modifica, sd.timestamp_modifica)) AS tempo_medio_minuti
                     FROM Storico_Stato sd
                     JOIN Storico_Stato sc ON sc.id_ordine = sd.id_ordine AND sc.stato = 'in consegna'
                     JOIN Utente u ON u.id_utente = sd.id_utente_personale
                     WHERE sd.stato = 'consegnato'
                     GROUP BY u.id_utente, u.nome
                     ORDER BY tempo_medio_minuti"
                );
                $righe = $stmt->fetchAll();
                break;

            case 7:
                $stmt = $pdo->query(
                    "SELECT p.id_prodotto, p.nome, COUNT(*) AS numero_ordini, SUM(ro.quantita) AS quantita_totale
                     FROM Riga_Ordine ro
                     JOIN Prodotto p ON p.id_prodotto = ro.id_prodotto
                     GROUP BY p.id_prodotto, p.nome
                     ORDER BY numero_ordini DESC, quantita_totale DESC"
                );
                $righe = $stmt->fetchAll();
                break;

            case 8:
                $stmt = $pdo->prepare(
                    "SELECT DATE(s.timestamp_modifica) AS giorno,
                            COUNT(*) AS numero_ordini,
                            SUM(o.prezzo_totale) AS incasso
                     FROM Ordine o
                     JOIN Storico_Stato s ON s.id_ordine = o.id_ordine AND s.stato = 'consegnato'
                     WHERE DATE(s.timestamp_modifica) = :giorno
                     GROUP BY DATE(s.timestamp_modifica)"
                );
                $stmt->execute(['giorno' => $_POST['giorno']]);
                $righe = $stmt->fetchAll();
                if (!$righe) {
                    $righe = [['giorno' => $_POST['giorno'], 'numero_ordini' => 0, 'incasso' => '0.00']];
                }
                break;

            case 9:
                $stmt = $pdo->prepare(
                    "SELECT i.id_ingrediente, i.nome, SUM(c.quantita * ro.quantita) AS quantita_consumata
                     FROM Composizione c
                     JOIN Ingrediente i ON i.id_ingrediente = c.id_ingrediente
                     JOIN Riga_Ordine ro ON ro.id_prodotto = c.id_prodotto
                     JOIN Ordine o ON o.id_ordine = ro.id_ordine
                     WHERE YEAR(o.data_inserimento) = :anno
                     GROUP BY i.id_ingrediente, i.nome
                     ORDER BY quantita_consumata DESC"
                );
                $stmt->execute(['anno' => $_POST['anno']]);
                $righe = $stmt->fetchAll();
                break;

            case 10:
                $soglia = ($_POST['soglia'] !== '' && $_POST['soglia'] !== null) ? (int) $_POST['soglia'] : 2;
                $stmt = $pdo->prepare(
                    "SELECT p.id_prodotto, p.nome, COUNT(*) AS numero_ordini
                     FROM Riga_Ordine ro
                     JOIN Ordine o ON o.id_ordine = ro.id_ordine
                     JOIN Prodotto p ON p.id_prodotto = ro.id_prodotto
                     WHERE o.id_utente_cliente = :id_cliente
                     GROUP BY p.id_prodotto, p.nome
                     HAVING COUNT(*) > :soglia
                     ORDER BY numero_ordini DESC"
                );
                $stmt->execute(['id_cliente' => $_POST['id_cliente'], 'soglia' => $soglia]);
                $righe = $stmt->fetchAll();
                break;

            case 11:
                $stmt = $pdo->query(
                    "SELECT stato_attuale, COUNT(*) AS numero_ordini
                     FROM Ordine
                     WHERE stato_attuale <> 'consegnato'
                     GROUP BY stato_attuale"
                );
                $righe = $stmt->fetchAll();
                break;

            case 12:
                $stmt = $pdo->prepare(
                    "SELECT COUNT(*) AS ordini_consegnati
                     FROM Storico_Stato
                     WHERE stato = 'consegnato' AND DATE(timestamp_modifica) = :giorno"
                );
                $stmt->execute(['giorno' => $_POST['giorno']]);
                $righe = $stmt->fetchAll();
                break;

            case 13:
                $stmt = $pdo->prepare(
                    "SELECT DISTINCT u.id_utente, u.nome, u.ruolo, s.stato, s.timestamp_modifica
                     FROM Storico_Stato s
                     JOIN Utente u ON u.id_utente = s.id_utente_personale
                     WHERE s.id_ordine = :id
                     ORDER BY s.timestamp_modifica"
                );
                $stmt->execute(['id' => $_POST['id_ordine']]);
                $righe = $stmt->fetchAll();
                break;

            case 14:
                // Tutta la validazione sui salti di stato è eseguita dal DB. 
                // Basta un INSERT su Storico_Stato, ed il resto è automatico.
                $ins = $pdo->prepare(
                    "INSERT INTO Storico_Stato (id_ordine, stato, id_utente_personale)
                     VALUES (:id_ordine, :stato, :id_utente)"
                );
                $ins->execute([
                    'id_ordine' => (int) $_POST['id_ordine'],
                    'stato' => $_POST['nuovo_stato'],
                    'id_utente' => $_POST['id_utente_personale'],
                ]);
                $messaggio = "Nuovo stato inserito nello storico. L'ordine è stato aggiornato correttamente.";
                break;
        }

        if ($righe) {
            $colonne = array_keys($righe[0]);
        }
    } catch (Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        $errore = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Query - Delivery</title>
    <style>
        body { font-family: sans-serif; max-width: 900px; margin: 2em auto; padding: 0 1em; }
        fieldset { margin-bottom: 1em; }
        table { border-collapse: collapse; width: 100%; margin-top: 1em; }
        th, td { border: 1px solid #ccc; padding: 6px 10px; text-align: left; }
        th { background: #f0f0f0; }
        .ok { color: #157347; }
        .errore { color: #b02a37; }
        select, input[type=text], input[type=number], input[type=date] { padding: 4px; }
        .param { margin-bottom: 0.6em; }
    </style>
</head>
<body>
    <p><a href="index.php">&larr; Torna al menu</a></p>
    <h1>Esecuzione query</h1>

    <form method="post" id="formQuery">
        <label for="op"><strong>Scegli l'operazione:</strong></label><br>
        <select name="op" id="op" onchange="mostraParametri()">
            <option value="">-- seleziona --</option>
            <?php foreach ($operazioni as $id => $info): ?>
                <option value="<?= $id ?>" <?= $op === $id ? 'selected' : '' ?>><?= htmlspecialchars($info['label']) ?></option>
            <?php endforeach; ?>
        </select>

        <?php foreach ($operazioni as $id => $info): ?>
            <fieldset id="params-<?= $id ?>" style="display:none">
                <legend><?= htmlspecialchars($info['label']) ?></legend>
                <?php if (empty($info['params'])): ?>
                    <p><em>Nessun parametro richiesto.</em></p>
                <?php endif; ?>
                <?php foreach ($info['params'] as $p): ?>
                    <div class="param">
                        <label>
                            <?= htmlspecialchars($p['label']) ?>:
                            <?php if ($p['type'] === 'select'): ?>
                                <select name="<?= $p['name'] ?>">
                                    <?php foreach ($p['options'] as $opt): ?>
                                        <option value="<?= htmlspecialchars($opt) ?>"
                                            <?= ($op === $id && ($_POST[$p['name']] ?? '') === $opt) ? 'selected' : '' ?>>
                                            <?= htmlspecialchars($opt) ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            <?php else: ?>
                                <input type="<?= $p['type'] ?>" name="<?= $p['name'] ?>"
                                       value="<?= ($op === $id) ? htmlspecialchars($_POST[$p['name']] ?? '') : '' ?>">
                            <?php endif; ?>
                        </label>
                    </div>
                <?php endforeach; ?>
            </fieldset>
        <?php endforeach; ?>

        <button type="submit">Esegui</button>
    </form>

    <?php if ($messaggio): ?>
        <p class="ok"><?= htmlspecialchars($messaggio) ?></p>
    <?php endif; ?>
    <?php if ($errore): ?>
        <p class="errore"><strong>Errore DB:</strong> <?= htmlspecialchars($errore) ?></p>
    <?php endif; ?>

    <?php if ($colonne): ?>
        <table>
            <tr>
                <?php foreach ($colonne as $col): ?>
                    <th><?= htmlspecialchars($col) ?></th>
                <?php endforeach; ?>
            </tr>
            <?php foreach ($righe as $riga): ?>
                <tr>
                    <?php foreach ($riga as $valore): ?>
                        <td><?= htmlspecialchars($valore ?? '') ?></td>
                    <?php endforeach; ?>
                </tr>
            <?php endforeach; ?>
        </table>
    <?php elseif ($op !== null && !$errore && !$messaggio): ?>
        <p><em>Nessun risultato.</em></p>
    <?php endif; ?>

    <script>
        function mostraParametri() {
            document.querySelectorAll('fieldset[id^="params-"]').forEach(f => f.style.display = 'none');
            const sel = document.getElementById('op').value;
            if (sel) {
                document.getElementById('params-' + sel).style.display = 'block';
            }
        }
        mostraParametri();
    </script>
</body>
</html>