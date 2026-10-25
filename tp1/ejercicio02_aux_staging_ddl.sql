-- ============================================================
-- TP1 | EJERCICIO 02 - DDL auxiliar (tabla staging)
-- Base de datos: la activa en la sesion (MySQL 8)
-- ============================================================
-- Objetivo: crear la tabla plana accidentes que recibe el volcado
--           crudo del Excel antes de normalizar.
-- Previo: ninguna. Este script se ejecuta sin USE, sobre la base
--         que este seleccionada en el cliente.
-- ============================================================

CREATE TABLE accidentes (
    ano                         INT DEFAULT NULL,
    id_ccaa                     VARCHAR(2)   DEFAULT NULL,
    ccaa                        VARCHAR(255) DEFAULT NULL,
    id_provincia                VARCHAR(3)   DEFAULT NULL,
    provincia                   VARCHAR(255) DEFAULT NULL,
    id_tipo_via                 VARCHAR(1)   DEFAULT NULL,
    tipo_via                    VARCHAR(255) DEFAULT NULL,
    accidentes_con_victimas     INT DEFAULT NULL,
    accidentes_mortales_30_dias INT DEFAULT NULL,
    fallecidos                  INT DEFAULT NULL,
    heridos_hospitalizados      INT DEFAULT NULL,
    heridos_no_hospitalizados   INT DEFAULT NULL
);
