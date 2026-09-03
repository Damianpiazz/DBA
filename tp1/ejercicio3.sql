-- =====================================================
-- EJERCICIO 3
-- =====================================================

USE tp1_accidentes;

-- 1. ¿Qué provincias y tipos de vías no tienen accidentes mortales a 30 días en 2015?
SELECT DISTINCT p.provincia, t.tipo_via
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
WHERE ia.id_anio = 2015
  AND ia.accidentes_mortales_30_dias = 0;


-- 2. ¿Qué provincias de "Andalucía" tienen más de 25 fallecidos en vías interurbanas en 2014?
SELECT p.provincia, ia.fallecidos
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
WHERE c.ccaa = 'Andalucía'
  AND t.tipo_via = 'Interurbana'
  AND ia.id_anio = 2014
  AND ia.fallecidos > 25;


-- 3. ¿Cuál es la Comunidad Autónoma con más accidentes con víctimas en 2015?
SELECT c.ccaa, SUM(ia.accidentes_con_victimas) AS total_accidentes
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
WHERE ia.id_anio = 2015
GROUP BY c.ccaa
ORDER BY total_accidentes DESC
LIMIT 1;


-- 4. ¿Cuál es el número medio de heridos no hospitalizados por año? Redondea el resultado sin decimales.
SELECT ia.id_anio AS anio,
       ROUND(AVG(ia.heridos_no_hospitalizados)) AS media_heridos_no_hospitalizados
FROM info_accidente ia
GROUP BY ia.id_anio;


-- 5. ¿Cuál es la combinación de año, provincia y tipo de vía con más heridos hospitalizados?
SELECT ia.id_anio AS anio, p.provincia, t.tipo_via, ia.heridos_hospitalizados
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
ORDER BY ia.heridos_hospitalizados DESC
LIMIT 1;


-- 6. ¿Qué Comunidades Autónomas tienen menos de 100 fallecidos en 2014?
SELECT c.ccaa, SUM(ia.fallecidos) AS total_fallecidos
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
WHERE ia.id_anio = 2014
GROUP BY c.ccaa
HAVING SUM(ia.fallecidos) < 100;


-- 7. ¿Cuál es la provincia que tiene más accidentes con víctimas en vías urbanas en 2015?
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


-- 9. Ranking con las tres provincias con mayor número de heridos totales (hospitalizados + no hospitalizados) en vías interurbanas en 2015.
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


-- 10. Diferencia entre 2014 y 2015 de la proporción de heridos hospitalizados y no hospitalizados de la Comunidad Autónoma de "Asturias" en vías interurbanas.
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