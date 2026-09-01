<?php
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['inserisci'])) {
    $stmt = $pdo->prepare(
        "INSERT INTO Prodotto (nome, descrizione, prezzo_base, categoria, tempo_preparazione, procedura)
         VALUES (:nome, :descrizione, :prezzo_base, :categoria, :tempo_preparazione, :procedura)"
    );
    $stmt->execute([
        'nome' => $_POST['nome'],
        'descrizione' => $_POST['descrizione'],
        'prezzo_base' => $_POST['prezzo_base'],
        'categoria' => $_POST['categoria'] ?: null,
        'tempo_preparazione' => $_POST['tempo_preparazione'],
        'procedura' => $_POST['procedura'] ?: null,
    ]);
}

if (isset($_GET['elimina'])) {
    $stmt = $pdo->prepare("DELETE FROM Prodotto WHERE id_prodotto = :id");
    $stmt->execute(['id' => $_GET['elimina']]);
}

$prodotti = $pdo->query("SELECT * FROM Prodotto ORDER BY id_prodotto")->fetchAll();
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Prodotti</title>
</head>
<body>
    <p><a href="index.php">&larr; Torna al menu</a></p>
    <h1>Prodotti</h1>

    <table border="1" cellpadding="5">
        <tr>
            <th>ID</th><th>Nome</th><th>Descrizione</th><th>Prezzo</th>
            <th>Categoria</th><th>Tempo (min)</th><th></th>
        </tr>
        <?php foreach ($prodotti as $p): ?>
        <tr>
            <td><?= $p['id_prodotto'] ?></td>
            <td><?= htmlspecialchars($p['nome']) ?></td>
            <td><?= htmlspecialchars($p['descrizione']) ?></td>
            <td><?= $p['prezzo_base'] ?></td>
            <td><?= htmlspecialchars($p['categoria'] ?? '') ?></td>
            <td><?= $p['tempo_preparazione'] ?></td>
            <td><a href="?elimina=<?= $p['id_prodotto'] ?>" onclick="return confirm('Confermi eliminazione?')">Elimina</a></td>
        </tr>
        <?php endforeach; ?>
    </table>

    <h2>Nuovo prodotto</h2>
    <form method="post">
        Nome: <input type="text" name="nome" required><br>
        Descrizione: <textarea name="descrizione" required></textarea><br>
        Prezzo base: <input type="number" step="0.01" min="0" name="prezzo_base" required><br>
        Categoria: <input type="text" name="categoria"><br>
        Tempo preparazione (min): <input type="number" min="1" name="tempo_preparazione" required><br>
        Procedura: <textarea name="procedura"></textarea><br>
        <button type="submit" name="inserisci" value="1">Inserisci</button>
    </form>
</body>
</html>
