-- ============================================================
-- TP2 | EJERCICIO 02 - Restricciones
-- Base de datos: Chinook (MySQL 8)
-- ============================================================
-- Objetivo: aplicar las restricciones pedidas sobre Album e
--           Invoice y comprobar que se crearon y que funcionan.
-- Previo: base Chinook cargada.
-- ============================================================

USE Chinook;


-- ------------------------------------------------------------
-- 1. Creacion de las restricciones
-- ------------------------------------------------------------

-- Album.Title: valor por defecto para los albums sin titulo
ALTER TABLE Album
    ALTER COLUMN Title SET DEFAULT 'Sin título';

-- Invoice.Total: al menos 0.99
ALTER TABLE Invoice
    ADD CONSTRAINT ck_invoice_total_min CHECK (Total >= 0.99);


-- ------------------------------------------------------------
-- 2. Verificacion
-- ------------------------------------------------------------

-- Verificar creacion
SHOW CREATE TABLE Album;
SHOW CREATE TABLE Invoice;

-- Verificar funcionamiento
-- Album: al insertar un album sin Title se aplica el valor por defecto
INSERT INTO Album (AlbumId, ArtistId) VALUES (9001, 1);
SELECT * FROM Album WHERE AlbumId = 9001;

-- Se elimina la prueba para no ensuciar la base de datos
DELETE FROM Album WHERE AlbumId = 9001;

-- Invoice: el INSERT debe fallar porque Total es menor a 0.99
INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, Total) VALUES (9001, 1, NOW(), 0.50);
-- Esperado: Error 3819 - Check constraint 'ck_invoice_total_min' is violated.
