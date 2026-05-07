/* 
PROGETTO: Analisi dei clienti di una banca
Obiettivo: creazione di una tabella denormalizzata di feature per cliente
Tabella finale: feature_clienti_banca
*/
USE banca;

/* =========================================================
   1. FEATURE CLIENTE
   Calcolo dell'età del cliente a partire dalla data di nascita
   ========================================================= */

DROP TEMPORARY TABLE IF EXISTS feature_cliente;

CREATE TEMPORARY TABLE feature_cliente AS
SELECT
    id_cliente,
    TIMESTAMPDIFF(YEAR, data_nascita, CURRENT_DATE()) AS eta
FROM cliente;

/* =========================================================
   2. FEATURE TRANSAZIONI GENERALI
   Calcolo del numero e dell'importo totale delle transazioni
   in entrata e in uscita per ogni cliente
   ========================================================= */

DROP TEMPORARY TABLE IF EXISTS feature_transazioni;

CREATE TEMPORARY TABLE feature_transazioni AS
SELECT
    co.id_cliente,
    SUM(CASE WHEN tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata,
    SUM(CASE WHEN tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita,
    SUM(CASE WHEN tt.segno = '+' THEN tr.importo ELSE 0 END) AS importo_totale_entrata,
    SUM(CASE WHEN tt.segno = '-' THEN tr.importo ELSE 0 END) AS importo_totale_uscita
FROM conto co
JOIN transazioni tr
    ON co.id_conto = tr.id_conto
JOIN tipo_transazione tt
    ON tr.id_tipo_trans = tt.id_tipo_transazione
GROUP BY co.id_cliente;

/* =========================================================
   3. FEATURE CONTI
   Calcolo del numero totale di conti e del numero di conti 
   per tipologia per ogni cliente
   ========================================================= */
   
DROP TEMPORARY TABLE IF EXISTS feature_conti;

CREATE TEMPORARY TABLE feature_conti AS
SELECT
    co.id_cliente,
    COUNT(*) AS numero_conti,
    SUM(CASE WHEN co.id_tipo_conto = 0 THEN 1 ELSE 0 END) AS numero_conti_base,
    SUM(CASE WHEN co.id_tipo_conto = 1 THEN 1 ELSE 0 END) AS numero_conti_business,
    SUM(CASE WHEN co.id_tipo_conto = 2 THEN 1 ELSE 0 END) AS numero_conti_privati,
    SUM(CASE WHEN co.id_tipo_conto = 3 THEN 1 ELSE 0 END) AS numero_conti_famiglie
FROM conto co
GROUP BY co.id_cliente;

/* =========================================================
   4. FEATURE TRANSAZIONI PER TIPOLOGIA DI CONTO
   Calcolo del numero e dell'importo delle transazioni
   in entrata e in uscita per ciascuna tipologia di conto
   e per ogni cliente
   ========================================================= */

DROP TEMPORARY TABLE IF EXISTS feature_transazioni_tipo_conto;

CREATE TEMPORARY TABLE feature_transazioni_tipo_conto AS
SELECT
    co.id_cliente,

    SUM(CASE WHEN co.id_tipo_conto = 0 AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_base,
    SUM(CASE WHEN co.id_tipo_conto = 0 AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_base,
    SUM(CASE WHEN co.id_tipo_conto = 0 AND tt.segno = '+' THEN tr.importo ELSE 0 END) AS importo_transazioni_entrata_base,
    SUM(CASE WHEN co.id_tipo_conto = 0 AND tt.segno = '-' THEN tr.importo ELSE 0 END) AS importo_transazioni_uscita_base,

    SUM(CASE WHEN co.id_tipo_conto = 1 AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_business,
    SUM(CASE WHEN co.id_tipo_conto = 1 AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_business,
    SUM(CASE WHEN co.id_tipo_conto = 1 AND tt.segno = '+' THEN tr.importo ELSE 0 END) AS importo_transazioni_entrata_business,
    SUM(CASE WHEN co.id_tipo_conto = 1 AND tt.segno = '-' THEN tr.importo ELSE 0 END) AS importo_transazioni_uscita_business,

    SUM(CASE WHEN co.id_tipo_conto = 2 AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_privati,
    SUM(CASE WHEN co.id_tipo_conto = 2 AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_privati,
    SUM(CASE WHEN co.id_tipo_conto = 2 AND tt.segno = '+' THEN tr.importo ELSE 0 END) AS importo_transazioni_entrata_privati,
    SUM(CASE WHEN co.id_tipo_conto = 2 AND tt.segno = '-' THEN tr.importo ELSE 0 END) AS importo_transazioni_uscita_privati,

    SUM(CASE WHEN co.id_tipo_conto = 3 AND tt.segno = '+' THEN 1 ELSE 0 END) AS numero_transazioni_entrata_famiglie,
    SUM(CASE WHEN co.id_tipo_conto = 3 AND tt.segno = '-' THEN 1 ELSE 0 END) AS numero_transazioni_uscita_famiglie,
    SUM(CASE WHEN co.id_tipo_conto = 3 AND tt.segno = '+' THEN tr.importo ELSE 0 END) AS importo_transazioni_entrata_famiglie,
    SUM(CASE WHEN co.id_tipo_conto = 3 AND tt.segno = '-' THEN tr.importo ELSE 0 END) AS importo_transazioni_uscita_famiglie

FROM conto co
JOIN transazioni tr
    ON co.id_conto = tr.id_conto
JOIN tipo_transazione tt
    ON tr.id_tipo_trans = tt.id_tipo_transazione
GROUP BY co.id_cliente;

/* =========================================================
   5. TABELLA FINALE DENORMALIZZATA
   Unione dei blocchi di feature calcolati per ogni cliente
   ========================================================= */

DROP TABLE IF EXISTS feature_clienti_banca;

CREATE TABLE feature_clienti_banca AS
SELECT
    fc.id_cliente,
    fc.eta,

    -- feature transazioni generali
    ft.numero_transazioni_entrata,
    ft.numero_transazioni_uscita,
    ft.importo_totale_entrata,
    ft.importo_totale_uscita,

    -- feature conti
    fco.numero_conti,
    fco.numero_conti_base,
    fco.numero_conti_business,
    fco.numero_conti_privati,
    fco.numero_conti_famiglie,

    -- feature transazioni per tipologia di conto
    fttc.numero_transazioni_entrata_base,
    fttc.numero_transazioni_uscita_base,
    fttc.importo_transazioni_entrata_base,
    fttc.importo_transazioni_uscita_base,

    fttc.numero_transazioni_entrata_business,
    fttc.numero_transazioni_uscita_business,
    fttc.importo_transazioni_entrata_business,
    fttc.importo_transazioni_uscita_business,

    fttc.numero_transazioni_entrata_privati,
    fttc.numero_transazioni_uscita_privati,
    fttc.importo_transazioni_entrata_privati,
    fttc.importo_transazioni_uscita_privati,

    fttc.numero_transazioni_entrata_famiglie,
    fttc.numero_transazioni_uscita_famiglie,
    fttc.importo_transazioni_entrata_famiglie,
    fttc.importo_transazioni_uscita_famiglie

FROM feature_cliente fc
LEFT JOIN feature_transazioni ft
    ON fc.id_cliente = ft.id_cliente
LEFT JOIN feature_conti fco
    ON fc.id_cliente = fco.id_cliente
LEFT JOIN feature_transazioni_tipo_conto fttc
    ON fc.id_cliente = fttc.id_cliente;
    
/* =========================================================
   6. CONTROLLI FINALI
   ========================================================= */

SELECT COUNT(*) AS numero_clienti_finali
FROM feature_clienti_banca;

DESCRIBE feature_clienti_banca;

SELECT *
FROM feature_clienti_banca
LIMIT 10;

