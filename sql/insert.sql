USE Delivery;

INSERT INTO Utente (id_utente, email, password, nome, ruolo, telefono, indirizzo) VALUES
(1, 'admin@email.it', 'password_1', 'Amministratore', 'proprietario', NULL, NULL),
(2, 'luca@personale.it', 'password_2', 'Luca B.', 'personale', NULL, NULL),
(3, 'sara@personale.it', 'password_3', 'Sara M.', 'personale', NULL, NULL),
(4, 'marco@personale.it', 'password_4', 'Marco T.', 'personale', NULL, NULL),
(5, 'mario.rossi@email.it', 'password_5', 'Mario Rossi', 'cliente', '3331234567', 'Via Roma 1, L''Aquila'),
(6, 'giulia.bianchi@email.it', 'password_6', 'Giulia Bianchi', 'cliente', '3332222222', 'Via Milano 2, L''Aquila'),
(7, 'andrea.verdi@email.it', 'password_7', 'Andrea Verdi', 'cliente', '3333333333', 'Via Torino 3, L''Aquila'),
(8, 'elena.conti@email.it', 'password_8', 'Elena Conti', 'cliente', '3334444444', 'Via Napoli 4, L''Aquila');

INSERT INTO Prodotto (id_prodotto, nome, descrizione, prezzo_base, categoria, tempo_preparazione, procedura) VALUES
(1, 'Bruschette miste', 'Quattro semplici e gustose bruschette al pomodoro, con un goccio di olio EVO e foglie di basilico fresco.', 5.50, 'Antipasti', 8, 'Tostare il pane, strofinare con aglio, condire con pomodoro a cubetti, olio e basilico.'),
(2, 'Tagliatelle al ragù', 'Pasta fresca all''uovo con ragù di carne cotto lentamente per 4 ore.', 9.00, 'Primi', 15, 'Cuocere la pasta 3 minuti in acqua salata, mantecare con il ragù caldo, spolverare di parmigiano.'),
(3, 'Pizza Margherita', 'La tipica pizza napoletana cotta nel forno a legna.', 7.00, 'Pizze', 12, 'Stendere l''impasto, condire con pomodoro e mozzarella, cuocere nel forno a legna a 400°C per 90 secondi, guarnire con basilico.'),
(4, 'Pizza Diavola', 'L''iconica pizza piccante dal sapore deciso.', 8.00, 'Pizze', 12, 'Stendere l''impasto, condire con pomodoro, mozzarella e salame, cuocere nel forno a legna, rifinire con olio piccante in uscita.'),
(5, 'Tiramisù della casa', 'Dolce con savoiardi, mascarpone e caffè fatto da noi.', 4.50, 'Dolci', 3, 'Porzionare dalla vaschetta preparata in mattinata, spolverare di cacao al momento del servizio.'),
(6, 'Caffè', 'Espresso della nostra torrefazione di fiducia.', 1.00, 'Bevande', 2, 'Estrazione singola da macinato fresco, 25 secondi circa.');

INSERT INTO Immagine (id_immagine, id_prodotto, percorso_file, is_copertina) VALUES
(1, 1, 'img/bruschette.jpg', TRUE),
(2, 2, 'img/tagliatelle.jpg', TRUE),
(3, 3, 'img/pizza-margherita.jpg', TRUE),
(4, 3, 'img/pizza-margherita2.jpg', FALSE),
(5, 4, 'img/pizza-diavola.jpg', TRUE),
(6, 5, 'img/tiramisu.jpg', TRUE),
(7, 6, 'img/caffe.jpg', TRUE);

INSERT INTO Ingrediente (id_ingrediente, nome) VALUES
(1, 'Pane casereccio'), (2, 'Pomodoro'), (3, 'Basilico'), (4, 'Olio extravergine'),
(5, 'Tagliatelle fresche'), (6, 'Ragù di carne'), (7, 'Parmigiano'), (8, 'Impasto pizza'),
(9, 'Pomodoro San Marzano'), (10, 'Fiordilatte'), (11, 'Salame piccante'), (12, 'Olio al peperoncino'),
(13, 'Savoiardi'), (14, 'Crema al mascarpone'), (15, 'Caffè espresso'), (16, 'Cacao amaro'), (17, 'Miscela espresso');

INSERT INTO Composizione (id_prodotto, id_ingrediente, quantita) VALUES
(1, 1, 200), (1, 2, 200), (1, 3, 5), (1, 4, 20),
(2, 5, 120), (2, 6, 150), (2, 7, 20),
(3, 8, 250), (3, 9, 80), (3, 10, 100), (3, 3, 5),
(4, 8, 250), (4, 2, 80), (4, 10, 100), (4, 11, 60), (4, 12, 5),
(5, 13, 100), (5, 14, 150), (5, 15, 30), (5, 16, 5),
(6, 17, 7);

INSERT INTO Gruppo_Caratteristica (id_gruppo, id_prodotto, nome) VALUES
(1, 2, 'Porzione'),
(2, 3, 'Impasto'),
(3, 4, 'Piccantezza'),
(4, 6, 'Zucchero');

INSERT INTO Caratteristica (id_caratteristica, id_prodotto, id_gruppo, nome, descrizione, differenza_prezzo, is_default) VALUES
(1, 2, 1, 'Normale', NULL, 0.00, TRUE),
(2, 2, 1, 'Abbondante', NULL, 2.00, FALSE),
(3, 3, 2, 'Classico', NULL, 0.00, TRUE),
(4, 3, 2, 'Integrale', NULL, 0.50, FALSE),
(5, 3, NULL, 'Extra mozzarella', NULL, 1.50, FALSE),
(6, 3, NULL, 'Origano fresco', NULL, 0.30, FALSE),
(7, 4, 3, 'Normale', NULL, 0.00, TRUE),
(8, 4, 3, 'Extra piccante', NULL, 0.00, FALSE),
(9, 6, 4, 'Senza zucchero', NULL, -0.05, FALSE),
(10, 6, 4, 'Zuccherato', NULL, 0.00, TRUE),
(11, 6, 4, 'Molto zuccherato', NULL, 0.00, FALSE),
(12, 6, NULL, 'Con panna', NULL, 0.50, FALSE),
(13, 6, NULL, 'Freddo', NULL, 1.00, FALSE);

INSERT INTO Ordine (id_ordine, codice_ordine, id_utente_cliente, data_inserimento, orario_richiesto) VALUES
(1, 'ORD-2026-0001', 5, '2026-07-14 19:40:00', '2026-07-14 20:15:00'),
(2, 'ORD-2026-0002', 6, '2026-07-14 19:20:00', '2026-07-14 20:00:00'),
(3, 'ORD-2026-0003', 7, '2026-07-14 19:05:00', '2026-07-14 19:45:00'),
(4, 'ORD-2026-0004', 8, '2026-07-14 18:50:00', '2026-07-14 19:30:00');

INSERT INTO Riga_Ordine (id_riga, id_ordine, numero_riga, id_prodotto, quantita, prezzo_base_al_momento) VALUES
(1, 1, 1, 3, 1, 7.00), (2, 1, 2, 4, 1, 8.00), (3, 1, 3, 5, 2, 4.50),
(4, 2, 1, 2, 1, 9.00), (5, 2, 2, 1, 1, 5.50),
(6, 3, 1, 3, 2, 7.00), (7, 3, 2, 6, 2, 1.00),
(8, 4, 1, 4, 1, 8.00), (9, 4, 2, 5, 1, 4.50);

INSERT INTO Personalizzata (id_riga, id_caratteristica, diff_prezzo_al_momento) VALUES
(1, 4, 0.50),
(2, 8, 0.00),
(4, 2, 2.00),
(7, 10, 0.00);

INSERT INTO Storico_Stato (id_storico, id_ordine, stato, id_utente_personale, timestamp_modifica) VALUES
(1, 1, 'in preparazione', 2, '2026-07-14 19:52:00'),
(2, 2, 'in preparazione', 2, '2026-07-14 19:30:00'),
(3, 3, 'in preparazione', 3, '2026-07-14 19:10:00'),
(4, 3, 'pronto',           3, '2026-07-14 19:24:00'),
(5, 4, 'in preparazione', 2, '2026-07-14 18:55:00'),
(6, 4, 'pronto',           2, '2026-07-14 19:08:00'),
(7, 4, 'in consegna',      4, '2026-07-14 19:12:00');