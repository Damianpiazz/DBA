-- ============================================================
-- TP1 | EJERCICIO 01 - DDL del modelo normalizado
-- Base de datos: tp1_accidentes (MySQL 8)
-- ============================================================
-- Objetivo: crear la base de datos y las cinco tablas del modelo
--           en 3FN, con sus claves primarias y foraneas.
-- Previo: ninguna.
-- ============================================================

CREATE DATABASE IF NOT EXISTS tp1_accidentes;
USE tp1_accidentes;


-- ------------------------------------------------------------
-- 1. Dimensiones
-- ------------------------------------------------------------

-- Entidad: Comunidad Autonoma
CREATE TABLE comunidad_autonoma (
    id_ccaa VARCHAR(2)   NOT NULL,
    ccaa    VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_ccaa)
);

-- Entidad: Provincia
CREATE TABLE provincia (
    id_provincia VARCHAR(3)   NOT NULL,
    provincia    VARCHAR(255) NOT NULL,
    id_ccaa      VARCHAR(2)   NOT NULL,
    PRIMARY KEY (id_provincia),
    CONSTRAINT fk_provincia_ccaa
        FOREIGN KEY (id_ccaa) REFERENCES comunidad_autonoma (id_ccaa)
);

-- Entidad: Tipo de via
CREATE TABLE tipo_via (
    id_tipo_via VARCHAR(1)   NOT NULL,
    tipo_via    VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_tipo_via)
);

-- Entidad: Anio
CREATE TABLE anio (
    id_anio INT NOT NULL,
    PRIMARY KEY (id_anio)
);


-- ------------------------------------------------------------
-- 2. Tabla de hechos
-- ------------------------------------------------------------

-- Entidad: InfoAccidente
CREATE TABLE info_accidente (
    id_info_accidente           INT AUTO_INCREMENT,
    id_provincia                VARCHAR(3)         NOT NULL,
    id_tipo_via                 VARCHAR(1)         NOT NULL,
    id_anio                     INT                NOT NULL,
    accidentes_con_victimas     INT DEFAULT NULL,
    accidentes_mortales_30_dias INT DEFAULT NULL,
    fallecidos                  INT DEFAULT NULL,
    heridos_hospitalizados      INT DEFAULT NULL,
    heridos_no_hospitalizados   INT DEFAULT NULL,
    PRIMARY KEY (id_info_accidente),
    CONSTRAINT fk_info_provincia
        FOREIGN KEY (id_provincia) REFERENCES provincia (id_provincia),
    CONSTRAINT fk_info_tipo_via
        FOREIGN KEY (id_tipo_via) REFERENCES tipo_via (id_tipo_via),
    CONSTRAINT fk_info_anio
        FOREIGN KEY (id_anio) REFERENCES anio (id_anio)
);
