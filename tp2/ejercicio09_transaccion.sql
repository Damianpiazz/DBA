-- ============================================================
-- TP2 | EJERCICIO 09 - Transaccion con error
-- Base de datos: Chinook (MySQL 8)
-- ============================================================
-- Objetivo: crear un cliente con su factura y sus items dentro
--           de una transaccion, provocar un error de clave
--           duplicada y comprobar que el ROLLBACK deshace todo.
-- Previo: base Chinook cargada.
-- ============================================================

USE Chinook;


-- ------------------------------------------------------------
-- 1. Valores proximos
-- ------------------------------------------------------------

SELECT MAX(CustomerId) + 1 AS proximo_cliente,
       (SELECT MAX(InvoiceId)     + 1 FROM Invoice)     AS proxima_factura,
       (SELECT MAX(InvoiceLineId) + 1 FROM InvoiceLine) AS proximo_item
FROM Customer;     -- Valores esperados: 60, 413, 2241 (confirmarlos)


-- ------------------------------------------------------------
-- 2. Transaccion
-- ------------------------------------------------------------

START TRANSACTION;

INSERT INTO Customer (CustomerId, FirstName, LastName, Email, Country, SupportRepId)
VALUES (60, 'Ana', 'Perez', 'ana.perez@example.com', 'Argentina', 3);

INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, BillingCountry, Total)
VALUES (413, 60, NOW(), 'Argentina', 3.96);

INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) VALUES (2241, 413, 1, 0.99, 1);
INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) VALUES (2242, 413, 2, 0.99, 1);
INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) VALUES (2243, 413, 3, 0.99, 1);

-- Ultimo item con un ID que YA existe: falla con Error 1062 (Duplicate entry)
INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) VALUES (1, 413, 4, 0.99, 1);


-- ------------------------------------------------------------
-- 3. Verificacion
-- ------------------------------------------------------------

-- Que paso con lo anterior? (misma sesion, transaccion todavia abierta)
SELECT * FROM Customer WHERE CustomerId = 60;            -- Existe, pero sin confirmar
SELECT COUNT(*) FROM InvoiceLine WHERE InvoiceId = 413;  -- 3 items pendientes

ROLLBACK;                                                -- Se deshace todo

SELECT * FROM Customer WHERE CustomerId = 60;            -- Vacio
SELECT COUNT(*) FROM InvoiceLine WHERE InvoiceId = 413;  -- 0
