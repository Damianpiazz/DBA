-- ============================================================
-- TP2 | EJERCICIO 07 - Roles y permisos
-- Base de datos: Chinook (MySQL 8)
-- ============================================================
-- Objetivo: crear los roles db_pasante, db_contable y
--           db_empleado con los permisos pedidos.
-- Previo: base Chinook cargada y ejercicios 03 a 06 resueltos
--         (vistas y stored procedure).
-- ============================================================

USE Chinook;


-- ------------------------------------------------------------
-- 1. Creacion de los roles
-- ------------------------------------------------------------

DROP ROLE IF EXISTS 'db_pasante', 'db_contable', 'db_empleado';
CREATE ROLE 'db_pasante', 'db_contable', 'db_empleado';

-- db_pasante: solo lectura
GRANT SELECT ON Chinook.Playlist         TO 'db_pasante';
GRANT SELECT ON Chinook.PlaylistTrack    TO 'db_pasante';
GRANT SELECT ON Chinook.Track            TO 'db_pasante';
GRANT SELECT ON Chinook.Album            TO 'db_pasante';
GRANT SELECT ON Chinook.Artist           TO 'db_pasante';
GRANT SELECT ON Chinook.MediaType        TO 'db_pasante';
GRANT SELECT ON Chinook.Genre            TO 'db_pasante';
GRANT SELECT ON Chinook.v_top_artists    TO 'db_pasante';

-- db_contable: CRUD en 5 tablas, mas execute del SP y lectura de la vista
GRANT SELECT, INSERT, UPDATE, DELETE ON Chinook.Employee    TO 'db_contable';
GRANT SELECT, INSERT, UPDATE, DELETE ON Chinook.Customer    TO 'db_contable';
GRANT SELECT, INSERT, UPDATE, DELETE ON Chinook.Invoice     TO 'db_contable';
GRANT SELECT, INSERT, UPDATE, DELETE ON Chinook.InvoiceLine TO 'db_contable';
GRANT SELECT, INSERT, UPDATE, DELETE ON Chinook.Album       TO 'db_contable';
GRANT EXECUTE ON PROCEDURE Chinook.sp_get_invoice_price     TO 'db_contable';
GRANT SELECT ON Chinook.v_upselling_tracks                  TO 'db_contable';

-- db_empleado: CRUD en todas las tablas, mas lectura de la vista
GRANT SELECT, INSERT, UPDATE, DELETE ON Chinook.* TO 'db_empleado';
GRANT SELECT ON Chinook.v_country_sales           TO 'db_empleado';


-- ------------------------------------------------------------
-- 2. Verificacion
-- ------------------------------------------------------------

-- Verificar creacion y permisos de cada rol
SELECT User, Host FROM mysql.user WHERE User LIKE 'db\_%';
SHOW GRANTS FOR 'db_pasante';
SHOW GRANTS FOR 'db_contable';
SHOW GRANTS FOR 'db_empleado';
