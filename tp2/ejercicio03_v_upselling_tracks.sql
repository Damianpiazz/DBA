-- ============================================================
-- TP2 | EJERCICIO 03 - Vista v_upselling_tracks
-- Base de datos: Chinook (MySQL 8)
-- ============================================================
-- Objetivo: crear la vista que devuelve los temas de 0.99 que
--           estan en facturas de mas de 9.99 y comprobarla.
-- Previo: base Chinook cargada.
-- ============================================================

USE Chinook;


-- ------------------------------------------------------------
-- 1. Creacion
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_upselling_tracks AS
SELECT t.TrackId,
       t.Name         AS track,
       il.InvoiceLineId,
       il.InvoiceId,
       il.UnitPrice,
       i.Total        AS total_factura
FROM InvoiceLine il
JOIN Invoice i ON i.InvoiceId = il.InvoiceId
JOIN Track   t ON t.TrackId   = il.TrackId
WHERE il.UnitPrice = 0.99
  AND i.Total > 9.99;


-- ------------------------------------------------------------
-- 2. Verificacion
-- ------------------------------------------------------------

-- Verificar creacion
SHOW FULL TABLES WHERE Table_type = 'VIEW';   -- Debe aparecer v_upselling_tracks
SHOW CREATE VIEW v_upselling_tracks;

-- Verificar funcionamiento
SELECT * FROM v_upselling_tracks LIMIT 20;

-- Ninguna fila debe romper las condiciones (los dos conteos deben ser 0)
SELECT COUNT(*) FROM v_upselling_tracks WHERE total_factura <= 9.99;
SELECT COUNT(*) FROM v_upselling_tracks u
JOIN Track t ON t.TrackId = u.TrackId
WHERE t.UnitPrice <> 0.99;

-- Una factura chica no debe aparecer (la factura 1 vale 1.98: resultado 0)
SELECT COUNT(*) FROM v_upselling_tracks WHERE InvoiceId = 1;

-- Comparar contra la consulta directa, sin la vista: ambos conteos deben ser iguales
SELECT COUNT(*) FROM v_upselling_tracks;
SELECT COUNT(*)
FROM InvoiceLine il
JOIN Invoice i ON i.InvoiceId = il.InvoiceId
JOIN Track   t ON t.TrackId   = il.TrackId
WHERE t.UnitPrice = 0.99 AND i.Total > 9.99;
