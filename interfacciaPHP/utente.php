<?php
require 'db.php';

// Inserimento
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['inserisci'])) {
    $stmt = $pdo->prepare(
        "INSERT INTO Utente (email, password, nome, ruolo, telefono, indirizzo)
         VALUES (:email, :password, :nome, :ruolo, :telefono, :indirizzo)"
    );
    $stmt->execute([
        'email' => $_POST['email'],
        'password' => $_POST['password'],
        'nome' => $_POST['nome'],
        'ruolo' => $_POST['ruolo'],
        'telefono' => $_POST['telefono'] ?: null,
        'indirizzo' => $_POST['indirizzo'] ?: null,
    ]);
}

// Eliminazione
if (isset($_GET['elimina'])) {
    $stmt = $pdo->prepare("DELETE FROM Utente WHERE id_utente = :id");
    $stmt->execute(['id' => $_GET['elimina']]);
}

$utenti = $pdo->query("SELECT * FROM Utente ORDER BY id_utente")->fetchAll();
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Utenti</title>
</head>
<body>
    <p><a href="index.php">&larr; Torna al menu</a></p>
    <h1>Utenti</h1>

    <table border="1" cellpadding="5">
        <tr>
            <th>ID</th><th>Email</th><th>Nome</th><th>Ruolo</th>
            <th>Telefono</th><th>Indirizzo</th><th></th>
        </tr>
        <?php foreach ($utenti as $u): ?>
        <tr>
            <td><?= $u['id_utente'] ?></td>
            <td><?= htmlspecialchars($u['email']) ?></td>
            <td><?= htmlspecialchars($u['nome']) ?></td>
            <td><?= $u['ruolo'] ?></td>
            <td><?= htmlspecialchars($u['telefono'] ?? '') ?></td>
            <td><?= htmlspecialchars($u['indirizzo'] ?? '') ?></td>
            <td><a href="?elimina=<?= $u['id_utente'] ?>" onclick="return confirm('Confermi eliminazione?')">Elimina</a></td>
        </tr>
        <?php endforeach; ?>
    </table>

    <h2>Nuovo utente</h2>
    <form method="post">
        Email: <input type="email" name="email" required><br>
        Password: <input type="password" name="password" required><br>
        Nome: <input type="text" name="nome" required><br>
        Ruolo:
        <select name="ruolo" required>
            <option value="cliente">cliente</option>
            <option value="personale">personale</option>
            <option value="proprietario">proprietario</option>
        </select><br>
        Telefono: <input type="text" name="telefono"><br>
        Indirizzo: <input type="text" name="indirizzo"><br>
        <button type="submit" name="inserisci" value="1">Inserisci</button>
    </form>
</body>
</html>
