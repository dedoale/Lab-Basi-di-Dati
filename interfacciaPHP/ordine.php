<?php
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['inserisci'])) {
    $stmt = $pdo->prepare(
        "INSERT INTO Ordine (codice_ordine, id_utente_cliente, orario_richiesto, prezzo_totale, tempo_consegna_stimato)
         VALUES (:codice_ordine, :id_utente_cliente, :orario_richiesto, :prezzo_totale, :tempo_consegna_stimato)"
    );
    $stmt->execute([
        'codice_ordine' => $_POST['codice_ordine'],
        'id_utente_cliente' => $_POST['id_utente_cliente'],
        'orario_richiesto' => $_POST['orario_richiesto'] ?: null,
        'prezzo_totale' => $_POST['prezzo_totale'] ?: null,
        'tempo_consegna_stimato' => $_POST['tempo_consegna_stimato'] ?: null,
    ]);
}

if (isset($_GET['elimina'])) {
    $stmt = $pdo->prepare("DELETE FROM Ordine WHERE id_ordine = :id");
    $stmt->execute(['id' => $_GET['elimina']]);
}

// cambio stato rapido
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['cambia_stato'])) {
    $stmt = $pdo->prepare("UPDATE Ordine SET stato_attuale = :stato WHERE id_ordine = :id");
    $stmt->execute(['stato' => $_POST['stato'], 'id' => $_POST['id_ordine']]);
}

$ordini = $pdo->query("SELECT * FROM Ordine ORDER BY id_ordine")->fetchAll();
$clienti = $pdo->query("SELECT id_utente, nome FROM Utente WHERE ruolo = 'cliente'")->fetchAll();
$stati = ['inserito','in preparazione','pronto','in consegna','consegnato'];
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Ordini</title>
</head>
<body>
    <p><a href="index.php">&larr; Torna al menu</a></p>
    <h1>Ordini</h1>

    <table border="1" cellpadding="5">
        <tr>
            <th>ID</th><th>Codice</th><th>Cliente</th><th>Inserito</th>
            <th>Stato</th><th>Totale</th><th>Cambia stato</th><th></th>
        </tr>
        <?php foreach ($ordini as $o): ?>
        <tr>
            <td><?= $o['id_ordine'] ?></td>
            <td><?= htmlspecialchars($o['codice_ordine']) ?></td>
            <td><?= $o['id_utente_cliente'] ?></td>
            <td><?= $o['data_inserimento'] ?></td>
            <td><?= $o['stato_attuale'] ?></td>
            <td><?= $o['prezzo_totale'] ?? '-' ?></td>
            <td>
                <form method="post" style="display:inline">
                    <input type="hidden" name="id_ordine" value="<?= $o['id_ordine'] ?>">
                    <select name="stato">
                        <?php foreach ($stati as $s): ?>
                            <option value="<?= $s ?>" <?= $s === $o['stato_attuale'] ? 'selected' : '' ?>><?= $s ?></option>
                        <?php endforeach; ?>
                    </select>
                    <button type="submit" name="cambia_stato" value="1">OK</button>
                </form>
            </td>
            <td><a href="?elimina=<?= $o['id_ordine'] ?>" onclick="return confirm('Confermi eliminazione?')">Elimina</a></td>
        </tr>
        <?php endforeach; ?>
    </table>

    <h2>Nuovo ordine</h2>
    <form method="post">
        Codice ordine: <input type="text" name="codice_ordine" required><br>
        Cliente:
        <select name="id_utente_cliente" required>
            <?php foreach ($clienti as $c): ?>
                <option value="<?= $c['id_utente'] ?>"><?= htmlspecialchars($c['nome']) ?> (ID <?= $c['id_utente'] ?>)</option>
            <?php endforeach; ?>
        </select><br>
        Orario richiesto: <input type="datetime-local" name="orario_richiesto"><br>
        Prezzo totale: <input type="number" step="0.01" min="0" name="prezzo_totale"><br>
        Tempo consegna stimato (min): <input type="number" min="0" name="tempo_consegna_stimato"><br>
        <button type="submit" name="inserisci" value="1">Inserisci</button>
    </form>
</body>
</html>
