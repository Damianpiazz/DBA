# Trabajo Práctico 1 - SQL Básico 2

Análisis de accidentes de tráfico en España (2014-2015) usando MySQL.

## Dataset

Datos de accidentes con víctimas por Comunidad Autónoma, provincia y tipo de vía. El dataset original (`datos_accidentes.xlsx`) se importó a una tabla plana `accidentes` como paso previo a la normalización.

## Estructura de archivos

| Archivo | Propósito |
|---|---|
| `ejercicio1.sql` | DDL — crea la base de datos normalizada (5 tablas) |
| `ejercicio2.sql` | DML — pobla las tablas normalizadas desde la staging table |
| `ejercicio3.sql` | Queries — 10 consultas analíticas sobre los datos |
| `ejercicio2_ddl.sql` | DDL auxiliar — estructura de la tabla `accidentes` (staging) |
| `ejercicio2_dml.sql` | DML auxiliar — datos crudos INSERT por fila |
| `datos_accidentes.xlsx` | Dataset original en Excel |

Se aplicó **normalización 3NF**: cada dimensión (CCAA, provincia, tipo de vía, año) está en su propia tabla, y la tabla de hechos (`info_accidente`) las referencia por foreign keys.

El esquema resultante:

| Tabla | Clave primaria | FKs | Columnas |
|---|---|---|---|
| `comunidad_autonoma` | `id_ccaa` | — | `ccaa` |
| `provincia` | `id_provincia` | `id_ccaa` → `comunidad_autonoma` | `provincia` |
| `tipo_via` | `id_tipo_via` | — | `tipo_via` |
| `anio` | `id_anio` | — | — |
| `info_accidente` | `id_info_accidente` | `id_provincia`, `id_tipo_via`, `id_anio` | `accidentes_con_victimas`, `accidentes_mortales_30_dias`, `fallecidos`, `heridos_hospitalizados`, `heridos_no_hospitalizados` |

## Por qué se hizo así

1. **Staging table primero** — Importar el Excel tal cual (`accidentes`) permite validar que los datos se cargan bien antes de normalizar. Es más fácil depurar en una tabla plana.

2. **Normalización después** — Las dimensiones se separaron de la tabla de hechos para:
   - Evitar redundancia (el nombre de una provincia no se repite 12 veces)
   - Facilitar consultas con JOINs en vez de filtrar strings
   - Mantener integridad referencial con FKs

3. **INSERT ... SELECT DISTINCT** — La inserción en las tablas normalizadas usa `SELECT DISTINCT` contra la staging table. Esto garantiza unicidad sin necesidad de `ON DUPLICATE KEY` ni lógica adicional.

4. **Ejercicio 3 como validación** — Las 10 queries del ejercicio 3 sirven como smoke test del modelo: si las respuestas son coherentes, la normalización y la carga están bien hechas.

## Cómo ejecutar

```sql
-- 1. Crear la staging table y cargar datos
SOURCE ejercicio2_ddl.sql;
SOURCE ejercicio2_dml.sql;

-- 2. Crear el esquema normalizado
SOURCE ejercicio1.sql;

-- 3. Poblar las tablas normalizadas
SOURCE ejercicio2.sql;

-- 4. Correr las queries
SOURCE ejercicio3.sql;
```

## Queries del ejercicio 3

### 1. Provincias y tipos de vía sin accidentes mortales a 30 días (2015)

```sql
SELECT DISTINCT p.provincia, t.tipo_via
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
WHERE ia.id_anio = 2015
  AND ia.accidentes_mortales_30_dias = 0;
```

**Cómo funciona**: cruza la tabla de hechos con las dimensiones `provincia` y `tipo_via` para resolver los nombres, filtra solo el año 2015 y los registros con 0 accidentes mortales. `DISTINCT` elimina combinaciones repetidas.

| provincia | tipo_via |
|---|---|
| Melilla | Interurbana |
| Ceuta | Interurbana |
| Palencia | Urbana |
| Ávila | Urbana |
| Guadalajara | Urbana |

---

### 2. Provincias de Andalucía con más de 25 fallecidos en interurbanas (2014)

```sql
SELECT p.provincia, ia.fallecidos
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
WHERE c.ccaa = 'Andalucía'
  AND t.tipo_via = 'Interurbana'
  AND ia.id_anio = 2014
  AND ia.fallecidos > 25;
```

**Cómo funciona**: encadena cuatro tablas — hechos → provincia → CCAA y hechos → tipo_via — para filtrar por el nombre de la CCAA y el tipo de vía. Necesita 3 JOINs porque `fallecidos` vive en la hechos, `ccaa` en la dimensión CCAA y `tipo_via` en su dimensión propia.

| provincia | fallecidos |
|---|---|
| Cádiz | 26 |
| Córdoba | 27 |
| Granada | 47 |
| Sevilla | 39 |

---

### 3. CCAA con más accidentes con víctimas (2015)

```sql
SELECT c.ccaa, SUM(ia.accidentes_con_victimas) AS total_accidentes
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
WHERE ia.id_anio = 2015
GROUP BY c.ccaa
ORDER BY total_accidentes DESC
LIMIT 1;
```

**Cómo funciona**: `SUM` agrega los accidentes de todas las provincias que pertenecen a cada CCAA, `GROUP BY` agrupa por CCAA, `ORDER BY ... DESC` posiciona la mayor primero y `LIMIT 1` se queda solo con ella.

| ccaa | total_accidentes |
|---|---|
| Cataluña | 25286 |

---

### 4. Número medio de heridos no hospitalizados por año

```sql
SELECT ia.id_anio AS anio,
       ROUND(AVG(ia.heridos_no_hospitalizados)) AS media_heridos_no_hospitalizados
FROM info_accidente ia
GROUP BY ia.id_anio;
```

**Cómo funciona**: `AVG` calcula la media por grupo y `ROUND` sin decimales la redondea a entero. Un solo `GROUP BY` sobre `id_anio` devuelve una fila por año.

| anio | media_heridos_no_hospitalizados |
|---|---|
| 2014 | 1126 |
| 2015 | 1202 |

---

### 5. Combinación año/provincia/tipo de vía con más heridos hospitalizados

```sql
SELECT ia.id_anio AS anio, p.provincia, t.tipo_via, ia.heridos_hospitalizados
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
ORDER BY ia.heridos_hospitalizados DESC
LIMIT 1;
```

**Cómo funciona**: a diferencia de la query 3, aquí NO usamos `SUM` ni `GROUP BY` porque cada fila de `info_accidente` ya es una combinación atómica (año + provincia + tipo vía). Con `ORDER BY ... DESC LIMIT 1` se toma el máximo.

| anio | provincia | tipo_via | heridos_hospitalizados |
|---|---|---|---|
| 2014 | Madrid | Urbana | 1225 |

---

### 6. CCAA con menos de 100 fallecidos (2014)

```sql
SELECT c.ccaa, SUM(ia.fallecidos) AS total_fallecidos
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN comunidad_autonoma c ON p.id_ccaa = c.id_ccaa
WHERE ia.id_anio = 2014
GROUP BY c.ccaa
HAVING SUM(ia.fallecidos) < 100;
```

**Cómo funciona**: igual que la 3 pero con `HAVING` en vez de `WHERE`. La diferencia clave: `WHERE` filtra filas ANTES de agrupar; `HAVING` filtra grupos DESPUÉS del `SUM`. No podríamos poner `< 100` en `WHERE` porque `SUM` aún no existe en ese punto.

| ccaa | total_fallecidos |
|---|---|
| Aragón | 77 |
| Canarias | 57 |
| Cantabria | 18 |
| Ceuta | 0 |
| Comunidad Foral de Navarra | 41 |
| Extremadura | 56 |
| Islas Baleares | 50 |
| La Rioja | 11 |
| Melilla | 0 |
| País Vasco | 36 |
| Principado de Asturias | 38 |
| Región de Murcia | 61 |

---

### 7. Provincia con más accidentes en vías urbanas (2015)

```sql
SELECT p.provincia, SUM(ia.accidentes_con_victimas) AS total_accidentes
FROM info_accidente ia
JOIN provincia p ON ia.id_provincia = p.id_provincia
JOIN tipo_via t ON ia.id_tipo_via = t.id_tipo_via
WHERE t.tipo_via = 'Urbana'
  AND ia.id_anio = 2015
GROUP BY p.provincia
ORDER BY total_accidentes DESC
LIMIT 1;
```

**Cómo funciona**: agrega por provincia solo las filas de tipo `Urbana` en 2015, ordena por total descendente y toma la primera.

| provincia | total_accidentes |
|---|---|
| Barcelona | 14657 |

---

### 8. Provincias que empiezan por "C" (descendente)

```sql
SELECT DISTINCT provincia
FROM provincia
WHERE provincia LIKE 'C%'
ORDER BY provincia DESC;
```

**Cómo funciona**: `LIKE 'C%'` filtra nombres que empiezan con "C" y `ORDER BY DESC` los invierte alfabéticamente. Es la única query sin JOIN: los datos ya están en la dimensión `provincia`.

| provincia |
|---|
| Cuenca |
| Córdoba |
| Ciudad Real |
| Ceuta |
| Castellón |
| Cantabria |
| Cádiz |
| Cáceres |

---

### 9. Top 3 provincias con más heridos totales en interurbanas (2015)

```sql
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
```

**Cómo funciona**: suma dos columnas por fila dentro de la misma agregación (`heridos_hospitalizados + heridos_no_hospitalizados`) y luego `SUM` los agrega por provincia. `LIMIT 3` devuelve el top 3.

| provincia | heridos_totales |
|---|---|
| Barcelona | 7389 |
| Madrid | 3986 |
| Valencia | 2384 |

---

### 10. Diferencia de proporción hosp/no-hosp en Asturias (interurbana, 2014→2015)

```sql
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
```

**Cómo funciona**: es la más compleja. Un **CTE** (`WITH`) calcula primero, para cada año, el total de hospitalizados y no hospitalizados de Asturias en interurbanas. Después, `CASE WHEN` selecciona la proporción de cada año por separado y `MAX` la "despliega" en su propia columna (como un pivote en una sola fila). La resta final da el delta de 2014 a 2015. Resultado negativo = la proporción de hospitalizados sobre no hospitalizados bajó.

| diferencia_proporcion |
|---|
| -0.0038 |

---

### Resumen de conceptos usados

| Concepto | Queries |
|---|---|
| `JOIN` (resolver dimensiones) | 1, 2, 3, 5, 6, 7, 9, 10 |
| `GROUP BY` + `SUM`/`AVG` (agregación) | 3, 4, 6, 7, 9, 10 |
| `HAVING` (filtrar grupos) | 6 |
| `ORDER BY DESC` + `LIMIT` (ranking) | 3, 5, 7, 9 |
| `LIKE` (búsqueda textual) | 8, 10 |
| `DISTINCT` | 1, 8 |
| CTE `WITH` | 10 |
| Pivoteo con `CASE WHEN` | 10 |
