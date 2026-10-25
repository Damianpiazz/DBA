-- ============================================================
-- TP2 | EJERCICIO 05 - Vista v_country_sales
-- Base de datos: Chinook (MySQL 8)
-- ============================================================
-- Objetivo: crear la vista de ventas por pais y comprobar que
--           sus totales coinciden con las tablas base.
-- Previo: base Chinook cargada.
-- ============================================================

USE Chinook;


-- ------------------------------------------------------------
-- 1. Creacion
-- ------------------------------------------------------------

CREATE OR REPLACE VIEW v_country_sales AS
SELECT i.BillingCountry                 AS pais,
       SUM(il.Quantity)                 AS temas_vendidos,
       SUM(il.UnitPrice * il.Quantity)  AS ventas_totales
FROM Invoice i
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
GROUP BY i.BillingCountry
ORDER BY ventas_totales DESC;


-- ------------------------------------------------------------
-- 2. Verificacion
-- ------------------------------------------------------------

-- Verificar creacion
SHOW FULL TABLES WHERE Table_type = 'VIEW';   -- Debe aparecer v_country_sales
SHOW CREATE VIEW v_country_sales;

-- Verificar funcionamiento
SELECT * FROM v_country_sales;

-- La suma de la vista debe coincidir con el total general (los tres valores iguales)
SELECT SUM(ventas_totales) FROM v_country_sales;
SELECT SUM(UnitPrice * Quantity) FROM InvoiceLine;
SELECT SUM(Total) FROM Invoice;
