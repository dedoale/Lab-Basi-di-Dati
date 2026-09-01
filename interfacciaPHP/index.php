<?php
$pagine = [
    'Utente' => 'utente.php',
    'Prodotto' => 'prodotto.php',
    'Ordine' => 'ordine.php',
];
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Delivery - Gestione</title>
</head>
<body>
    <h1>Gestione Delivery</h1>
    <ul>
        <?php foreach ($pagine as $nome => $file): ?>
            <li><a href="<?= $file ?>"><?= $nome ?></a></li>
        <?php endforeach; ?>
    </ul>
</body>
</html>
