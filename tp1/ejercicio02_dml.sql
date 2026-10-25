-- ============================================================
-- TP1 | EJERCICIO 02 - DML de carga
-- Base de datos: tp1_accidentes (MySQL 8)
-- ============================================================
-- Objetivo: poblar las tablas normalizadas a partir de la tabla
--           staging accidentes con INSERT ... SELECT DISTINCT.
-- Previo: ejercicio01_ddl.sql, ejercicio02_aux_staging_ddl.sql
--         y ejercicio02_aux_staging_dml.sql.
-- ============================================================

USE tp1_accidentes;

-- 1. Comunidades Autonomas
INSERT INTO comunidad_autonoma (id_ccaa, ccaa)
SELECT DISTINCT id_ccaa, ccaa
FROM accidentes;

-- 2. Provincias
INSERT INTO provincia (id_provincia, provincia, id_ccaa)
SELECT DISTINCT id_provincia, provincia, id_ccaa
FROM accidentes;

-- 3. Tipos de via
INSERT INTO tipo_via (id_tipo_via, tipo_via)
SELECT DISTINCT id_tipo_via, tipo_via
FROM accidentes;

-- 4. Anios
INSERT INTO anio (id_anio)
SELECT DISTINCT ano
FROM accidentes;

-- 5. InfoAccidente
INSERT INTO info_accidente (
    id_provincia, id_tipo_via, id_anio,
    accidentes_con_victimas, accidentes_mortales_30_dias,
    fallecidos, heridos_hospitalizados, heridos_no_hospitalizados
)
SELECT
    id_provincia, id_tipo_via, ano,
    accidentes_con_victimas, accidentes_mortales_30_dias,
    fallecidos, heridos_hospitalizados, heridos_no_hospitalizados
FROM accidentes;
