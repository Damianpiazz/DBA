-- =====================================================
-- EJERCICIO 2
-- =====================================================

USE tp1_accidentes;

-- 1. Comunidades Autónomas 
INSERT INTO comunidad_autonoma (id_ccaa, ccaa)
SELECT DISTINCT id_ccaa, ccaa
FROM accidentes;

-- 2. Provincias 
INSERT INTO provincia (id_provincia, provincia, id_ccaa)
SELECT DISTINCT id_provincia, provincia, id_ccaa
FROM accidentes;

-- 3. Tipos de vía 
INSERT INTO tipo_via (id_tipo_via, tipo_via)
SELECT DISTINCT id_tipo_via, tipo_via
FROM accidentes;

-- 4. Años 
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