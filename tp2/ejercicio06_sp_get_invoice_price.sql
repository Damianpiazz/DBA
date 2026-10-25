-- ============================================================
-- TP2 | EJERCICIO 06 - Stored procedure sp_get_invoice_price
-- Base de datos: Chinook (MySQL 8)
-- ============================================================
-- Objetivo: crear el procedimiento que calcula el total de una
--           factura usando solo InvoiceLine y comprobarlo.
-- Previo: base Chinook cargada.
-- ============================================================

USE Chinook;


-- ------------------------------------------------------------
-- 1. Creacion
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_get_invoice_price;

DELIMITER $$
CREATE PROCEDURE sp_get_invoice_price(IN p_invoice_id INT)
BEGIN
    SELECT p_invoice_id                    AS invoice_id,
           COALESCE(SUM(UnitPrice * Quantity), 0) AS total_factura
    FROM InvoiceLine
    WHERE InvoiceId = p_invoice_id;
END$$
DELIMITER ;


-- ------------------------------------------------------------
-- 2. Verificacion
-- ------------------------------------------------------------

-- Verificar creacion
SHOW PROCEDURE STATUS WHERE Db = 'Chinook';
SHOW CREATE PROCEDURE sp_get_invoice_price;

-- Verificar funcionamiento: comparar el SP con el Total guardado en Invoice
CALL sp_get_invoice_price(1);
CALL sp_get_invoice_price(412);
SELECT InvoiceId, Total FROM Invoice WHERE InvoiceId IN (1, 412);

-- Factura inexistente: devuelve 0
CALL sp_get_invoice_price(99999);
