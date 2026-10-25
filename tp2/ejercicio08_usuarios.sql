-- ============================================================
-- TP2 | EJERCICIO 08 - Usuarios y roles
-- Base de datos: Chinook (MySQL 8)
-- ============================================================
-- Objetivo: crear los usuarios Juan, Pedro y Maria, asignarles
--           su rol y comprobar los permisos de cada uno.
-- Previo: base Chinook cargada y ejercicio 07 resuelto.
-- ============================================================

USE Chinook;


-- ------------------------------------------------------------
-- 1. Creacion de los usuarios
-- ------------------------------------------------------------

DROP USER IF EXISTS 'Juan'@'localhost', 'Pedro'@'localhost', 'Maria'@'localhost';

CREATE USER 'Juan'@'localhost'  IDENTIFIED BY 'Juan_2026!';
CREATE USER 'Pedro'@'localhost' IDENTIFIED BY 'Pedro_2026!';
CREATE USER 'Maria'@'localhost' IDENTIFIED BY 'Maria_2026!';

GRANT 'db_pasante'  TO 'Juan'@'localhost';
GRANT 'db_contable' TO 'Pedro'@'localhost';
GRANT 'db_empleado' TO 'Maria'@'localhost';

-- Sin esto el rol no se activa al iniciar sesion
SET DEFAULT ROLE 'db_pasante'  TO 'Juan'@'localhost';
SET DEFAULT ROLE 'db_contable' TO 'Pedro'@'localhost';
SET DEFAULT ROLE 'db_empleado' TO 'Maria'@'localhost';


-- ------------------------------------------------------------
-- 2. Verificacion
-- ------------------------------------------------------------

-- Verificar creacion y roles de cada usuario
SELECT User, Host FROM mysql.user WHERE User IN ('Juan','Pedro','Maria');
SHOW GRANTS FOR 'Juan'@'localhost'  USING 'db_pasante';
SHOW GRANTS FOR 'Pedro'@'localhost' USING 'db_contable';
SHOW GRANTS FOR 'Maria'@'localhost' USING 'db_empleado';
