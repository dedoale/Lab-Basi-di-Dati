CREATE DATABASE IF NOT EXISTS Delivery;
USE Delivery;

DROP TABLE IF EXISTS Personalizzata;
DROP TABLE IF EXISTS Riga_Ordine;
DROP TABLE IF EXISTS Storico_Stato;
DROP TABLE IF EXISTS Ordine;
DROP TABLE IF EXISTS Caratteristica;
DROP TABLE IF EXISTS Gruppo_Caratteristica;
DROP TABLE IF EXISTS Immagine;
DROP TABLE IF EXISTS Composizione;
DROP TABLE IF EXISTS Ingrediente;
DROP TABLE IF EXISTS Prodotto;
DROP TABLE IF EXISTS Utente;

CREATE TABLE Utente (
    id_utente     INT AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(255) NOT NULL,
    password      VARCHAR(255) NOT NULL,
    nome          VARCHAR(100) NOT NULL,
    ruolo         ENUM('cliente', 'personale', 'proprietario') NOT NULL,
    telefono      VARCHAR(20)  NULL,
    indirizzo     VARCHAR(255) NULL,
    CONSTRAINT uq_utente_email UNIQUE (email),
    -- telefono e indirizzo obbligatori solo per i clienti
    CONSTRAINT chk_utente_cliente_dati CHECK (
        ruolo <> 'cliente' OR (telefono IS NOT NULL AND indirizzo IS NOT NULL)
    )
);

CREATE TABLE Prodotto (
    id_prodotto       INT AUTO_INCREMENT PRIMARY KEY,
    nome              VARCHAR(100) NOT NULL,
    descrizione       TEXT NOT NULL,
    prezzo_base       DECIMAL(6,2) NOT NULL,
    categoria         VARCHAR(50) NULL,
    tempo_preparazione INT NOT NULL COMMENT 'minuti',
    procedura         TEXT NULL,
    CONSTRAINT uq_prodotto_nome UNIQUE (nome),
    CONSTRAINT chk_prodotto_prezzo CHECK (prezzo_base >= 0),
    CONSTRAINT chk_prodotto_tempo CHECK (tempo_preparazione > 0)
);

CREATE TABLE Ingrediente (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    CONSTRAINT uq_ingrediente_nome UNIQUE (nome)
);

CREATE TABLE Composizione (
    id_prodotto    INT NOT NULL,
    id_ingrediente INT NOT NULL,
    quantita       DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (id_prodotto, id_ingrediente),
    CONSTRAINT fk_composizione_prodotto FOREIGN KEY (id_prodotto)
        REFERENCES Prodotto(id_prodotto) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_composizione_ingrediente FOREIGN KEY (id_ingrediente)
        REFERENCES Ingrediente(id_ingrediente) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_composizione_quantita CHECK (quantita > 0)
);

CREATE TABLE Immagine (
    id_immagine   INT AUTO_INCREMENT PRIMARY KEY,
    id_prodotto   INT NOT NULL,
    percorso_file VARCHAR(255) NOT NULL,
    is_copertina  BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_immagine_percorso UNIQUE (id_prodotto, percorso_file),
    CONSTRAINT fk_immagine_prodotto FOREIGN KEY (id_prodotto)
        REFERENCES Prodotto(id_prodotto) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Gruppo_Caratteristica (
    id_gruppo   INT AUTO_INCREMENT PRIMARY KEY,
    id_prodotto INT NOT NULL,
    nome        VARCHAR(100) NOT NULL,
    CONSTRAINT uq_gruppo_prodotto_nome UNIQUE (id_prodotto, nome),
    CONSTRAINT fk_gruppo_prodotto FOREIGN KEY (id_prodotto)
        REFERENCES Prodotto(id_prodotto) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Caratteristica (
    id_caratteristica INT AUTO_INCREMENT PRIMARY KEY,
    id_prodotto        INT NOT NULL,
    id_gruppo          INT NULL,
    nome               VARCHAR(100) NOT NULL,
    descrizione        TEXT NULL,
    differenza_prezzo  DECIMAL(6,2) NOT NULL DEFAULT 0,
    is_default         BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_caratteristica_prodotto_nome UNIQUE (id_prodotto, nome),
    CONSTRAINT fk_caratteristica_prodotto FOREIGN KEY (id_prodotto)
        REFERENCES Prodotto(id_prodotto) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_caratteristica_gruppo FOREIGN KEY (id_gruppo)
        REFERENCES Gruppo_Caratteristica(id_gruppo) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Ordine (
    id_ordine            INT AUTO_INCREMENT PRIMARY KEY,
    codice_ordine         VARCHAR(30) NOT NULL,
    id_utente_cliente     INT NOT NULL,
    data_inserimento      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    orario_richiesto      DATETIME NULL,
    stato_attuale         ENUM('inserito','in preparazione','pronto','in consegna','consegnato')
                           NOT NULL DEFAULT 'inserito',
    prezzo_totale         DECIMAL(8,2) NULL,
    tempo_consegna_stimato INT NULL COMMENT 'minuti',
    CONSTRAINT uq_ordine_codice UNIQUE (codice_ordine),
    CONSTRAINT fk_ordine_cliente FOREIGN KEY (id_utente_cliente)
        REFERENCES Utente(id_utente) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_ordine_orario CHECK (orario_richiesto IS NULL OR orario_richiesto > data_inserimento)
);

CREATE TABLE Storico_Stato (
    id_storico          INT AUTO_INCREMENT PRIMARY KEY,
    id_ordine            INT NOT NULL,
    stato                ENUM('inserito','in preparazione','pronto','in consegna','consegnato') NOT NULL,
    id_utente_personale   INT NOT NULL,
    timestamp_modifica    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_storico_ordine_stato UNIQUE (id_ordine, stato),
    CONSTRAINT fk_storico_ordine FOREIGN KEY (id_ordine)
        REFERENCES Ordine(id_ordine) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_storico_personale FOREIGN KEY (id_utente_personale)
        REFERENCES Utente(id_utente) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Riga_Ordine (
    id_riga               INT AUTO_INCREMENT PRIMARY KEY,
    id_ordine             INT NOT NULL,
    numero_riga           INT NOT NULL,
    id_prodotto           INT NOT NULL,
    quantita              INT NOT NULL,
    prezzo_base_al_momento DECIMAL(6,2) NOT NULL,
    CONSTRAINT uq_riga_ordine_numero UNIQUE (id_ordine, numero_riga),
    CONSTRAINT fk_riga_ordine FOREIGN KEY (id_ordine)
        REFERENCES Ordine(id_ordine) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_riga_prodotto FOREIGN KEY (id_prodotto)
        REFERENCES Prodotto(id_prodotto) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_riga_quantita CHECK (quantita > 0),
    CONSTRAINT chk_riga_prezzo CHECK (prezzo_base_al_momento >= 0)
);

CREATE TABLE Personalizzata (
    id_riga            INT NOT NULL,
    id_caratteristica  INT NOT NULL,
    diff_prezzo_al_momento DECIMAL(6,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (id_riga, id_caratteristica),
    CONSTRAINT fk_personalizzata_riga FOREIGN KEY (id_riga)
        REFERENCES Riga_Ordine(id_riga) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_personalizzata_caratteristica FOREIGN KEY (id_caratteristica)
        REFERENCES Caratteristica(id_caratteristica) ON DELETE RESTRICT ON UPDATE CASCADE
);