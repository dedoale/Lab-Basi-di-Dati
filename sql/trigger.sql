USE Delivery;

DELIMITER //

-- Trigger per il controllo dell'avanzamento dello stato e del timestamp
DROP TRIGGER IF EXISTS chk_avanzamento_stato_ordine //
CREATE TRIGGER chk_avanzamento_stato_ordine 
BEFORE INSERT ON Storico_Stato
FOR EACH ROW
BEGIN
    DECLARE ultimo_stato_enum INT;
    DECLARE order_date DATETIME;
    
    SELECT CAST(stato_attuale AS UNSIGNED), data_inserimento 
    INTO ultimo_stato_enum, order_date
    FROM Ordine WHERE id_ordine = NEW.id_ordine;
    
    -- Controllo temporale (vincolo 2)
    IF NEW.timestamp_modifica <= order_date THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Errore: Il timestamp non può essere precedente alla data di creazione dell''ordine.';
    END IF;
    
    -- Controllo progressione (vincolo 1)
    IF CAST(NEW.stato AS UNSIGNED) != (ultimo_stato_enum + 1) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Errore: Transizione di stato non valida o salto di stato non permesso.';
    END IF;
END //

-- Trigger per l'aggiornamento della ridondanza stato_attuale su Ordine
DROP TRIGGER IF EXISTS update_ridondanza_stato //
CREATE TRIGGER update_ridondanza_stato 
AFTER INSERT ON Storico_Stato
FOR EACH ROW
BEGIN
    UPDATE Ordine SET stato_attuale = NEW.stato WHERE id_ordine = NEW.id_ordine;
END //

-- Un Ordine deve essere collegato a un Utente con ruolo = 'cliente'
DROP TRIGGER IF EXISTS chk_ruolo_cliente_ordine //
CREATE TRIGGER chk_ruolo_cliente_ordine
BEFORE INSERT ON Ordine
FOR EACH ROW
BEGIN
    DECLARE ruolo_utente VARCHAR(20);

    SELECT ruolo INTO ruolo_utente
    FROM Utente WHERE id_utente = NEW.id_utente_cliente;

    IF ruolo_utente <> 'cliente' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: un Ordine può essere collegato solo a un Utente con ruolo cliente.';
    END IF;
END //

-- Una riga di Storico_Stato deve essere collegata a un Utente con ruolo = 'personale'
-- Eseguito prima di chk_avanzamento_stato_ordine, per dare priorità
-- a un eventuale errore sul ruolo rispetto a uno sulla progressione.
DROP TRIGGER IF EXISTS chk_ruolo_personale_storico //
CREATE TRIGGER chk_ruolo_personale_storico
BEFORE INSERT ON Storico_Stato
FOR EACH ROW
PRECEDES chk_avanzamento_stato_ordine
BEGIN
    DECLARE ruolo_utente VARCHAR(20);

    SELECT ruolo INTO ruolo_utente
    FROM Utente WHERE id_utente = NEW.id_utente_personale;

    IF ruolo_utente <> 'personale' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Errore: una riga di Storico_Stato può essere collegata solo a un Utente con ruolo personale.';
    END IF;
END //

-- Unicità del Proprietario (vincolo 8)
DROP TRIGGER IF EXISTS chk_proprietario_unico //
CREATE TRIGGER chk_proprietario_unico 
BEFORE INSERT ON Utente
FOR EACH ROW
BEGIN
    DECLARE num_proprietari INT;
    IF NEW.ruolo = 'proprietario' THEN
        SELECT COUNT(*) INTO num_proprietari FROM Utente WHERE ruolo = 'proprietario';
        IF num_proprietari > 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Errore: Esiste già un proprietario registrato nel sistema.';
        END IF;
    END IF;
END //

-- Trigger su Riga_Ordine
DROP TRIGGER IF EXISTS before_insert_riga_ordine //
CREATE TRIGGER before_insert_riga_ordine
BEFORE INSERT ON Riga_Ordine
FOR EACH ROW
BEGIN
    DECLARE v_prezzo DECIMAL(6,2);
    DECLARE v_tempo_prep INT;
    
    SELECT prezzo_base, tempo_preparazione 
    INTO v_prezzo, v_tempo_prep
    FROM Prodotto WHERE id_prodotto = NEW.id_prodotto;
    
    -- Congela il prezzo base (vincolo 5)
    SET NEW.prezzo_base_al_momento = v_prezzo;
    
    -- Aggiorna il tempo stimato sull'ordine (con 15 min di tragitto)
    UPDATE Ordine 
    SET tempo_consegna_stimato = GREATEST(IFNULL(tempo_consegna_stimato, 0), v_tempo_prep + 15)
    WHERE id_ordine = NEW.id_ordine;
END //

-- Trigger per aggiornare il prezzo totale dell'ordine all'aggiunta di una riga
DROP TRIGGER IF EXISTS update_prezzo_totale_riga //
CREATE TRIGGER update_prezzo_totale_riga
AFTER INSERT ON Riga_Ordine
FOR EACH ROW
BEGIN
    UPDATE Ordine 
    SET prezzo_totale = IFNULL(prezzo_totale, 0) + (NEW.prezzo_base_al_momento * NEW.quantita)
    WHERE id_ordine = NEW.id_ordine;
END //

-- Trigger su Personalizzata
DROP TRIGGER IF EXISTS chk_inserimento_personalizzata_completo //
CREATE TRIGGER chk_inserimento_personalizzata_completo 
BEFORE INSERT ON Personalizzata
FOR EACH ROW
BEGIN
    DECLARE prodotto_riga INT;
    DECLARE prodotto_car INT;
    DECLARE gruppo_car INT;
    DECLARE overlap_gruppo INT;
    DECLARE prezzo_diff DECIMAL(6,2);
    
    SELECT id_prodotto INTO prodotto_riga FROM Riga_Ordine WHERE id_riga = NEW.id_riga;
    SELECT id_prodotto, id_gruppo, differenza_prezzo INTO prodotto_car, gruppo_car, prezzo_diff
    FROM Caratteristica WHERE id_caratteristica = NEW.id_caratteristica;
    
    -- Congela la differenza di prezzo (vincolo 5)
    SET NEW.diff_prezzo_al_momento = prezzo_diff;
    
    -- Controllo coerenza prodotto (vincolo 10)
    IF prodotto_riga != prodotto_car THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Errore: La caratteristica non appartiene al prodotto della riga.';
    END IF;
    
    -- Controllo mutua esclusione (vincolo 4)
    IF gruppo_car IS NOT NULL THEN
        SELECT COUNT(*) INTO overlap_gruppo
        FROM Personalizzata p
        JOIN Caratteristica c ON p.id_caratteristica = c.id_caratteristica
        WHERE p.id_riga = NEW.id_riga AND c.id_gruppo = gruppo_car;
        
        IF overlap_gruppo > 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Errore: Mutua esclusione violata per questo gruppo.';
        END IF;
    END IF;
END //

-- Trigger per aggiornare il prezzo totale quando si aggiunge una personalizzazione
DROP TRIGGER IF EXISTS update_prezzo_totale_personalizzata //
CREATE TRIGGER update_prezzo_totale_personalizzata
AFTER INSERT ON Personalizzata
FOR EACH ROW
BEGIN
    DECLARE id_ord INT;
    DECLARE qta INT;
    
    SELECT id_ordine, quantita INTO id_ord, qta
    FROM Riga_Ordine WHERE id_riga = NEW.id_riga;
    
    UPDATE Ordine 
    SET prezzo_totale = IFNULL(prezzo_totale, 0) + (NEW.diff_prezzo_al_momento * qta)
    WHERE id_ordine = id_ord;
END //

-- Coerenza tra il gruppo di una caratteristica e il prodotto a cui appartiene
DROP TRIGGER IF EXISTS chk_coerenza_gruppo_prodotto_insert //
CREATE TRIGGER chk_coerenza_gruppo_prodotto_insert
BEFORE INSERT ON Caratteristica
FOR EACH ROW
BEGIN
    DECLARE prodotto_gruppo INT;

    IF NEW.id_gruppo IS NOT NULL THEN
        SELECT id_prodotto INTO prodotto_gruppo
        FROM Gruppo_Caratteristica WHERE id_gruppo = NEW.id_gruppo;

        IF prodotto_gruppo <> NEW.id_prodotto THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Errore: il gruppo indicato appartiene a un prodotto diverso da quello della caratteristica.';
        END IF;
    END IF;
END //

DROP TRIGGER IF EXISTS chk_coerenza_gruppo_prodotto_update //
CREATE TRIGGER chk_coerenza_gruppo_prodotto_update
BEFORE UPDATE ON Caratteristica
FOR EACH ROW
BEGIN
    DECLARE prodotto_gruppo INT;

    IF NEW.id_gruppo IS NOT NULL THEN
        SELECT id_prodotto INTO prodotto_gruppo
        FROM Gruppo_Caratteristica WHERE id_gruppo = NEW.id_gruppo;

        IF prodotto_gruppo <> NEW.id_prodotto THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Errore: il gruppo indicato appartiene a un prodotto diverso da quello della caratteristica.';
        END IF;
    END IF;
END //

-- Esclusività Immagine di Copertina — INSERT (vincolo 9)
DROP TRIGGER IF EXISTS chk_unica_copertina_insert //
CREATE TRIGGER chk_unica_copertina_insert
BEFORE INSERT ON Immagine
FOR EACH ROW
BEGIN
    IF NEW.is_copertina = TRUE THEN
        UPDATE Immagine SET is_copertina = FALSE WHERE id_prodotto = NEW.id_prodotto;
    END IF;
END //

-- Esclusività Immagine di Copertina — UPDATE
DROP TRIGGER IF EXISTS chk_unica_copertina_update //
CREATE TRIGGER chk_unica_copertina_update
BEFORE UPDATE ON Immagine
FOR EACH ROW
BEGIN
    IF NEW.is_copertina = TRUE THEN
        UPDATE Immagine 
        SET is_copertina = FALSE 
        WHERE id_prodotto = NEW.id_prodotto 
          AND id_immagine <> NEW.id_immagine;
    END IF;
END //

-- Esclusività Caratteristica di Default — INSERT (vincolo 3)
DROP TRIGGER IF EXISTS chk_unico_default_insert //
CREATE TRIGGER chk_unico_default_insert
BEFORE INSERT ON Caratteristica
FOR EACH ROW
BEGIN
    IF NEW.is_default = TRUE AND NEW.id_gruppo IS NOT NULL THEN
        UPDATE Caratteristica SET is_default = FALSE WHERE id_gruppo = NEW.id_gruppo;
    END IF;
END //

-- Esclusività Caratteristica di Default — UPDATE
DROP TRIGGER IF EXISTS chk_unico_default_update //
CREATE TRIGGER chk_unico_default_update
BEFORE UPDATE ON Caratteristica
FOR EACH ROW
BEGIN
    IF NEW.is_default = TRUE AND NEW.id_gruppo IS NOT NULL THEN
        UPDATE Caratteristica 
        SET is_default = FALSE 
        WHERE id_gruppo = NEW.id_gruppo 
          AND id_caratteristica <> NEW.id_caratteristica;
    END IF;
END //

-- Coerenza Orario Richiesto (vincolo 7)
-- orario_richiesto viene sempre impostato in un secondo momento
-- rispetto alla creazione dell'ordine (alla conferma), quindi il controllo copre solo BEFORE UPDATE.

DROP TRIGGER IF EXISTS chk_orario_richiesto //
CREATE TRIGGER chk_orario_richiesto
BEFORE UPDATE ON Ordine
FOR EACH ROW
BEGIN
    IF NEW.orario_richiesto IS NOT NULL AND NEW.orario_richiesto != IFNULL(OLD.orario_richiesto, '1000-01-01') THEN
        IF NEW.orario_richiesto <= DATE_ADD(NEW.data_inserimento, INTERVAL NEW.tempo_consegna_stimato MINUTE) THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Errore: Orario richiesto incompatibile con i tempi di preparazione.';
        END IF;
    END IF;
END //

DELIMITER ;