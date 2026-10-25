-- ============================================================
-- TP1 | EJERCICIO 03 - Consultas analiticas
-- Base de datos: tp1_accidentes (MySQL 8)
-- ============================================================
-- Objetivo: resolver las 10 consultas pedidas sobre el modelo ya
--           cargado. Sirven ademas como validacion del esquema.
-- Previo: ejercicio01_ddl.sql y ejercicio02_dml.sql.
-- ============================================================

USE tp1_accidentes;


-- ------------------------------------------------------------
-- Consultas
-- ------------------------------------------------------------

-- 1. Que provincias y tipos de vias no tienen accidentes mortales a 30 dias en 2015?
SELECT DISTINCT p.provincia, t.tipo_via
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
WHERE ia.id_anio = 2015
  AND ia.accidentes_mortales_30_dias = 0;


-- 2. Que provincias de "Andalucia" tienen mas de 25 fallecidos en vias interurbanas en 2014?
SELECT p.provincia, ia.fallecidos
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
WHERE c.ccaa = 'Andalucía'
  AND t.tipo_via = 'Interurbana'
  AND ia.id_anio = 2014
  AND ia.fallecidos > 25;


-- 3. Cual es la Comunidad Autonoma con mas accidentes con victimas en 2015?
SELECT c.ccaa, SUM(ia.accidentes_con_victimas) AS total_accidentes
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
WHERE ia.id_anio = 2015
GROUP BY c.ccaa
ORDER BY total_accidentes DESC
LIMIT 1;


-- 4. Cual es el numero medio de heridos no hospitalizados por anio? Redondea el resultado sin decimales.
SELECT ia.id_anio AS anio,
       ROUND(AVG(ia.heridos_no_hospitalizados)) AS media_heridos_no_hospitalizados
FROM info_accidente ia
GROUP BY ia.id_anio;


-- 5. Cual es la combinacion de anio, provincia y tipo de via con mas heridos hospitalizados?
SELECT ia.id_anio AS anio, p.provincia, t.tipo_via, ia.heridos_hospitalizados
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
ORDER BY ia.heridos_hospitalizados DESC
LIMIT 1;


-- 6. Que Comunidades Autonomas tienen menos de 100 fallecidos en 2014?
SELECT c.ccaa, SUM(ia.fallecidos) AS total_fallecidos
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
WHERE ia.id_anio = 2014
GROUP BY c.ccaa
HAVING SUM(ia.fallecidos) < 100;


-- 7. Cual es la provincia que tiene mas accidentes con victimas en vias urbanas en 2015?
SELECT p.provincia, SUM(ia.accidentes_con_victimas) AS total_accidentes
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
WHERE t.tipo_via = 'Urbana'
  AND ia.id_anio = 2015
GROUP BY p.provincia
ORDER BY total_accidentes DESC
LIMIT 1;


-- 8. Listado de provincias que empiezan por la letra "C", ordenadas de forma descendente.
SELECT DISTINCT provincia
FROM provincia
WHERE provincia LIKE 'C%'
ORDER BY provincia DESC;


-- 9. Ranking con las tres provincias con mayor numero de heridos totales (hospitalizados + no hospitalizados) en vias interurbanas en 2015.
SELECT p.provincia,
       SUM(ia.heridos_hospitalizados + ia.heridos_no_hospitalizados) AS heridos_totales
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
WHERE t.tipo_via = 'Interurbana'
  AND ia.id_anio = 2015
GROUP BY p.provincia
ORDER BY heridos_totales DESC
LIMIT 3;


-- 10. Diferencia entre 2014 y 2015 de la proporcion de heridos hospitalizados y no hospitalizados de la Comunidad Autonoma de "Asturias" en vias interurbanas.
WITH datos_asturias AS (
    SELECT ia.id_anio AS anio,
           SUM(ia.heridos_hospitalizados) AS hosp,
           SUM(ia.heridos_no_hospitalizados) AS no_hosp
    FROM info_accidente ia
    JOIN provincia p ON ia.id_provincia = p.id_provincia
    JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
    JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
    WHERE c.ccaa LIKE '%Asturias%'
      AND t.tipo_via = 'Interurbana'
      AND ia.id_anio IN (2014, 2015)
    GROUP BY ia.id_anio
)
SELECT
    MAX(CASE WHEN anio = 2015 THEN hosp / no_hosp END)
    - MAX(CASE WHEN anio = 2014 THEN hosp / no_hosp END) AS diferencia_proporcion
FROM datos_asturias;
