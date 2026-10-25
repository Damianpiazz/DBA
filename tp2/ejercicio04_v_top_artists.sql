-- ============================================================
-- TP2 | EJERCICIO 04 - Vista v_top_artists
-- Base de datos: Chinook (MySQL 8)
-- ============================================================
-- Objetivo: crear el ranking de los 10 artistas con mas temas
--           vendidos y comprobarlo contra la consulta directa.
-- Previo: base Chinook cargada.
-- ============================================================

USE Chinook;


-- ------------------------------------------------------------
-- 1. Creacion
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_top_artists AS
SELECT ar.ArtistId,
       ar.Name          AS artista,
       SUM(il.Quantity) AS temas_vendidos
FROM InvoiceLine il
JOIN Track  t  ON t.TrackId   = il.TrackId
JOIN Album  al ON al.AlbumId  = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY temas_vendidos DESC, ar.Name
LIMIT 10;


-- ------------------------------------------------------------
-- 2. Verificacion
-- ------------------------------------------------------------

-- Verificar creacion
SHOW FULL TABLES WHERE Table_type = 'VIEW';   -- Debe aparecer v_top_artists
SHOW CREATE VIEW v_top_artists;

-- Verificar funcionamiento
SELECT * FROM v_top_artists;                  -- 10 filas, de mayor a menor
SELECT COUNT(*) FROM v_top_artists;           -- Debe dar 10

-- Comparar contra la consulta directa (tienen que dar lo mismo)
SELECT ar.Name, SUM(il.Quantity) AS vendidos
FROM InvoiceLine il
JOIN Track  t  ON t.TrackId   = il.TrackId
JOIN Album  al ON al.AlbumId  = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY vendidos DESC, ar.Name
LIMIT 10;
