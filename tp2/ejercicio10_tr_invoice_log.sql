-- ============================================================
-- TP2 | EJERCICIO 10 - Triggers de auditoria sobre Invoice
-- Base de datos: Chinook (MySQL 8)
-- ============================================================
-- Objetivo: crear la tabla invoice_log y los triggers que
--           registran cada INSERT y DELETE sobre Invoice.
-- Previo: base Chinook cargada.
-- ============================================================

USE Chinook;


-- ------------------------------------------------------------
-- 1. Creacion
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS invoice_log (
    log_id     INT AUTO_INCREMENT PRIMARY KEY,
    accion     ENUM('INSERT','DELETE') NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    invoice_id INT NOT NULL
);

DROP TRIGGER IF EXISTS tr_invoice_after_insert;
DROP TRIGGER IF EXISTS tr_invoice_after_delete;

DELIMITER $$
CREATE TRIGGER tr_invoice_after_insert
AFTER INSERT ON Invoice
FOR EACH ROW
BEGIN
    INSERT INTO invoice_log (accion, fecha_hora, invoice_id)
    VALUES ('INSERT', NOW(), NEW.InvoiceId);
END$$

CREATE TRIGGER tr_invoice_after_delete
AFTER DELETE ON Invoice
FOR EACH ROW
BEGIN
    INSERT INTO invoice_log (accion, fecha_hora, invoice_id)
    VALUES ('DELETE', NOW(), OLD.InvoiceId);
END$$
DELIMITER ;


-- ------------------------------------------------------------
-- 2. Verificacion
-- ------------------------------------------------------------

-- Verificar creacion
SHOW CREATE TABLE invoice_log;
SHOW TRIGGERS FROM Chinook;

-- Verificar funcionamiento
INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, Total) VALUES (9001, 1, NOW(), 1.98);
DELETE FROM Invoice WHERE InvoiceId = 9001;

-- Debe haber una fila INSERT y una DELETE para la factura 9001
SELECT * FROM invoice_log WHERE invoice_id = 9001;
