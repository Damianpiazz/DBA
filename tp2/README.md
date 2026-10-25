# Trabajo Práctico 2 - SQL Avanzado

Vistas, stored procedures, triggers, restricciones, roles, usuarios y transacciones en MySQL 8.

El trabajo tiene **dos partes independientes entre sí**: cada una usa su propia base de datos y se puede resolver sin la otra.

- **Parte 1 — base `music`**: ejercicios A (vistas), B (stored procedures) y C (triggers), más 8 preguntas teóricas.
- **Parte 2 — base `Chinook`**: ejercicios 02 al 10 (restricciones, vistas, SP, roles, usuarios, transacción y triggers).

## Dataset

**`music`**: catálogo de rock argentino (Soda Stereo, Charly García, Divididos…) con artistas, álbumes, canciones, usuarios, playlists y relaciones entre ellos. Se genera con los scripts `00_` y `01_`.

**`Chinook`**: base de ejemplo de una tienda digital de música, con 14 tablas (`artist`, `album`, `track`, `genre`, `mediatype`, `playlist`, `playlisttrack`, `employee`, `customer`, `invoice`, `invoiceline`). El esquema está en `schema chinook.png` y el enunciado en `SqlAvanzado.pdf`; **la base no está incluida en el repo**, hay que crearla aparte.

## Estructura de archivos

| Archivo | Propósito |
|---|---|
| `00_ddl_music.sql` | DDL — crea la base `music` y sus 11 tablas con PK y FK |
| `01_datos_de_prueba.sql` | DML — artistas, álbumes, canciones, usuarios y playlists de ejemplo |
| `consignas_music.sql` | Enunciado de los ejercicios A1-A5, B1-B6, C1-C5 y las 8 preguntas (no se ejecuta) |
| `soluciones_music.sql` | Resolución completa de la parte 1 y respuestas de las preguntas |
| `ejercicio02_restricciones.sql` | Restricciones `CHECK` y `DEFAULT` sobre `Album` e `Invoice` |
| `ejercicio03_v_upselling_tracks.sql` | Vista `v_upselling_tracks` |
| `ejercicio04_v_top_artists.sql` | Vista `v_top_artists` |
| `ejercicio05_v_country_sales.sql` | Vista `v_country_sales` |
| `ejercicio06_sp_get_invoice_price.sql` | Stored procedure `sp_get_invoice_price` |
| `ejercicio07_roles_permisos.sql` | Roles `db_pasante`, `db_contable` y `db_empleado` |
| `ejercicio08_usuarios.sql` | Usuarios Juan, Pedro y Maria con sus roles por defecto |
| `ejercicio09_transaccion.sql` | Transacción con error de clave duplicada y `ROLLBACK` |
| `ejercicio10_tr_invoice_log.sql` | Tabla `invoice_log` y triggers `tr_invoice_after_insert` / `tr_invoice_after_delete` |
| `schema chinook.png` | Diagrama entidad-relación de Chinook (referencia) |
| `SqlAvanzado.pdf` | Enunciado del trabajo práctico |

## Cómo ejecutar

### Parte 1 — base music

```sql
SOURCE 00_ddl_music.sql;
SOURCE 01_datos_de_prueba.sql;
SOURCE soluciones_music.sql;
```

> `consignas_music.sql` es solo el enunciado, no hace falta ejecutarlo.

### Parte 2 — base Chinook

Primero hay que tener la base Chinook creada y cargada (ver `schema chinook.png` y el PDF). Los ejercicios van en orden, porque cada uno depende de los anteriores:

```sql
SOURCE ejercicio02_restricciones.sql;
SOURCE ejercicio03_v_upselling_tracks.sql;
SOURCE ejercicio04_v_top_artists.sql;
SOURCE ejercicio05_v_country_sales.sql;
SOURCE ejercicio06_sp_get_invoice_price.sql;
SOURCE ejercicio07_roles_permisos.sql;
SOURCE ejercicio08_usuarios.sql;
SOURCE ejercicio09_transaccion.sql;
SOURCE ejercicio10_tr_invoice_log.sql;
```

> El ejercicio 07 da permisos sobre las vistas y el procedimiento creados en los ejercicios 03 al 06, y el 08 sobre los roles del 07: si se salta uno, el siguiente falla.

También se puede levantar MySQL con Docker (`docker compose up -d`), ver [docs/comandos.md](../docs/comandos.md).

## Esquema de la base music

| Tabla | Tipo | Clave primaria | Claves foráneas |
|---|---|---|---|
| `artist` | entidad | `id` | — |
| `album` | entidad | `id` | `id_artist` → `artist` |
| `song` | entidad | `id` | `id_album` → `album` |
| `user` | entidad | `id` | — |
| `playlist` | entidad | `id` | — |
| `user_has_playlist` | relación | (`id_user`, `id_playlist`) | → `user`, `playlist` |
| `playlist_has_song` | relación | (`id_playlist`, `id_song`) | → `playlist`, `song` |
| `user_friend_of_user` | relación | (`id_user_1`, `id_user_2`) | ambas → `user` |
| `user_likes_artist` | relación | (`id_user`, `id_artist`) | → `user`, `artist` |
| `user_likes_album` | relación | (`id_user`, `id_album`) | → `user`, `album` |
| `user_likes_song` | relación | (`id_user`, `id_song`) | → `user`, `song` |

Se aplicó **normalización 3NF**: `song` no guarda el nombre del artista ni del álbum, solo las claves foráneas; y todas las relaciones N:M (`user_has_playlist`, `user_likes_*`) tienen clave compuesta, así no se insertan filas duplicadas.

---

## Ejercicios de la base music

### A1) Vista `v_canciones_populares`

```sql
CREATE VIEW v_canciones_populares AS
SELECT id, title, num_times_played
FROM song
WHERE num_times_played > 10000;

SELECT * FROM v_canciones_populares;
```

**Cómo funciona**: una vista es una consulta guardada con nombre. Al hacer `SELECT` sobre ella se ejecuta la cláusula `WHERE` en el momento, así que los filtros se aplican siempre contra los datos actuales de `song`.

### A2) Vista `v_catalogo`

```sql
CREATE VIEW v_catalogo AS
SELECT song.title  AS cancion,
       album.title AS album,
       artist.name AS artista
FROM song
JOIN album  ON song.id_album   = album.id
JOIN artist ON album.id_artist = artist.id;

SELECT * FROM v_catalogo WHERE artista = 'Soda Stereo';
```

**Cómo funciona**: encadena `song → album → artist` con dos `JOIN` para resolver los nombres. Los alias (`cancion`, `album`, `artista`) son los nombres de las columnas de la vista y se pueden usar en el `WHERE` externo, igual que cualquier columna de una tabla.

### A3) Vista `v_usuarios` con permisos

```sql
CREATE VIEW v_usuarios AS
SELECT id, nick
FROM user;

CREATE USER 'analista'@'localhost' IDENTIFIED BY 'analista123';
GRANT SELECT ON music.v_usuarios TO 'analista'@'localhost';

SHOW GRANTS FOR 'analista'@'localhost';
```

**Cómo funciona**: la vista expone solo `id` y `nick`, no la contraseña ni el mail. El `GRANT` se aplica a la vista y no a la tabla `user`, así que el usuario `analista` **no puede** hacer `SELECT * FROM user`: la vista actúa como máscara de seguridad a nivel de columnas y de filas.

### A4) `v_catalogo` con el año del álbum

```sql
CREATE OR REPLACE VIEW v_catalogo AS
SELECT song.title          AS cancion,
       album.title         AS album,
       album.released_year AS anio,
       artist.name         AS artista
FROM song
JOIN album  ON song.id_album   = album.id
JOIN artist ON album.id_artist = artist.id;

SELECT * FROM v_catalogo WHERE anio < 1990;
```

**Cómo funciona**: `CREATE OR REPLACE VIEW` evita tener que hacer `DROP` previo. Los consumidores de la vista siguen funcionando porque no cambió el nombre ni las columnas existentes, solo se agregó `anio`.

### A5) Vista de prueba y `DROP VIEW`

```sql
CREATE VIEW v_prueba AS
SELECT * FROM song;

DROP VIEW v_prueba;

SELECT COUNT(*) FROM song;   -- Siguen estando todos los registros
```

**Cómo funciona**: `DROP VIEW` elimina la definición guardada, no las filas que la vista devolvía. La vista no copia datos: solo guarda la consulta.

---

### B1) `sp_publicar_playlists`

```sql
DELIMITER //
CREATE PROCEDURE sp_publicar_playlists()
BEGIN
    UPDATE playlist
    SET is_public = 1
    WHERE is_public = 0;
END//
DELIMITER ;

CALL sp_publicar_playlists();
SELECT id, title, is_public FROM playlist;
```

**Cómo funciona**: sin parámetros, recorre toda la tabla y pone en público lo que esté privado. `DELIMITER //` hace que el `;` interno no corte la creación; se vuelve al `;` habitual al terminar.

### B2) `sp_canciones_de_album`

```sql
DELIMITER //
CREATE PROCEDURE sp_canciones_de_album(IN p_id_album INT)
BEGIN
    SELECT title, duration
    FROM song
    WHERE id_album = p_id_album;
END//
DELIMITER ;

CALL sp_canciones_de_album(1);
```

**Cómo funciona**: el primer `IN` es el parámetro de entrada, con prefijo `p_` por convención. El procedimiento devuelve un result set, igual que una consulta normal.

### B3) `sp_agregar_artista`

```sql
DELIMITER //
CREATE PROCEDURE sp_agregar_artista(IN p_id INT, IN p_name VARCHAR(255), IN p_bio TEXT)
BEGIN
    INSERT INTO artist(id, name, bio)
    VALUES (p_id, p_name, p_bio);
END//
DELIMITER ;

CALL sp_agregar_artista(7, 'Los Piojos', 'Banda de rock argentina.');
SELECT * FROM artist WHERE id = 7;
```

**Cómo funciona**: recibe los tres valores y los inserta. El `INSERT` falla con error de clave primaria si el `id` ya existe, lo que permite detectar el duplicado antes de ejecutar.

### B4) `sp_reproducir_cancion`

```sql
DELIMITER //
CREATE PROCEDURE sp_reproducir_cancion(IN p_id_song INT)
BEGIN
    UPDATE song
    SET num_times_played = num_times_played + 1
    WHERE id = p_id_song;
END//
DELIMITER ;

CALL sp_reproducir_cancion(20);
SELECT id, title, num_times_played FROM song WHERE id = 20;
```

**Cómo funciona**: suma 1 sobre el valor actual (`+ 1`), no lo reemplaza. Se usa luego en el ejercicio C2 para probar el trigger de `UPDATE`.

### B5) `sp_quitar_cancion`

```sql
DELIMITER //
CREATE PROCEDURE sp_quitar_cancion(IN p_id_playlist INT, IN p_id_song INT)
BEGIN
    DELETE FROM playlist_has_song
    WHERE id_playlist = p_id_playlist
      AND id_song = p_id_song;
END//
DELIMITER ;

CALL sp_quitar_cancion(1, 7);
SELECT * FROM playlist_has_song WHERE id_playlist = 1;
```

**Cómo funciona**: borra de la **tabla intermedia**, nunca de `song`. Es el `DELETE` típico de una relación N:M: la canción sigue existiendo, solo se rompe el vínculo con esa playlist.

### B6) `sp_contar_canciones` (parámetro de salida)

```sql
DELIMITER //
CREATE PROCEDURE sp_contar_canciones(IN p_id_album INT, OUT p_cantidad INT)
BEGIN
    SELECT COUNT(*) INTO p_cantidad
    FROM song
    WHERE id_album = p_id_album;
END//
DELIMITER ;

CALL sp_contar_canciones(7, @cant);
SELECT @cant;
```

**Cómo funciona**: `OUT` es el parámetro de salida y `SELECT ... INTO` escribe en él. Se lo invoca con una variable de sesión (`@cant`), que queda disponible en la sesión hasta que se reasigne.

---

### Tabla de auditoría

```sql
CREATE TABLE logs (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    tabla       VARCHAR(50),
    id_registro INT,
    accion      VARCHAR(10),
    fecha       DATE
);
```

Se usa en los ejercicios C1 y C4.

### C1) `tr_song_insert`

```sql
DELIMITER //
CREATE TRIGGER tr_song_insert AFTER INSERT
ON song
FOR EACH ROW
BEGIN
    INSERT INTO logs(tabla, id_registro, accion, fecha)
    VALUES ('song', NEW.id, 'INSERT', CURDATE());
END//
DELIMITER ;

INSERT INTO song(id, title, duration, num_times_played, id_album)
VALUES (21, 'Tema nuevo', 180, 100, 8);

SELECT * FROM logs;
```

**Cómo funciona**: se dispara solo, después de cada `INSERT` exitoso sobre `song`. `NEW.id` es el valor recién insertado y `FOR EACH ROW` hace que corra una vez por fila afectada.

### C2) `song_historial` y `tr_song_update`

```sql
CREATE TABLE song_historial (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    id_song INT,
    antes   INT,
    despues INT,
    fecha   DATE
);

DELIMITER //
CREATE TRIGGER tr_song_update AFTER UPDATE
ON song
FOR EACH ROW
BEGIN
    INSERT INTO song_historial(id_song, antes, despues, fecha)
    VALUES (NEW.id, OLD.num_times_played, NEW.num_times_played, CURDATE());
END//
DELIMITER ;

CALL sp_reproducir_cancion(21);
SELECT * FROM song_historial;
```

**Cómo funciona**: en un `UPDATE` conviven los dos: `OLD` tiene el valor anterior y `NEW` el nuevo. El trigger guarda los dos en la misma fila, lo que permite reconstruir la evolución de las reproducciones.

### C3) `tr_song_reproducciones` (`BEFORE INSERT`)

```sql
DELIMITER //
CREATE TRIGGER tr_song_reproducciones BEFORE INSERT
ON song
FOR EACH ROW
BEGIN
    SET NEW.num_times_played = 0;
END//
DELIMITER ;

INSERT INTO song(id, title, duration, num_times_played, id_album)
VALUES (22, 'Otro tema', 200, 500, 8);

SELECT id, title, num_times_played FROM song WHERE id = 22;
```

**Cómo funciona**: al ser `BEFORE INSERT`, modifica `NEW` **antes** de que la fila se escriba. Por eso el 500 enviado en el `INSERT` no llega a guardarse: queda en 0.

### C4) `sp_registrar_log` y dos triggers que lo usan

```sql
DELIMITER //
CREATE PROCEDURE sp_registrar_log(IN p_tabla VARCHAR(50), IN p_id INT, IN p_accion VARCHAR(10))
BEGIN
    INSERT INTO logs(tabla, id_registro, accion, fecha)
    VALUES (p_tabla, p_id, p_accion, CURDATE());
END//

CREATE TRIGGER tr_user_insert AFTER INSERT
ON user
FOR EACH ROW
BEGIN
    CALL sp_registrar_log('user', NEW.id, 'INSERT');
END//

CREATE TRIGGER tr_playlist_song_delete AFTER DELETE
ON playlist_has_song
FOR EACH ROW
BEGIN
    CALL sp_registrar_log('playlist_has_song', OLD.id_song, 'DELETE');
END//
DELIMITER ;

INSERT INTO user(id, first_name, last_name, nick, email)
VALUES (7, 'Gabriela', 'Torres', 'gabit', 'gabi@mail.com');

CALL sp_quitar_cancion(2, 16);

SELECT * FROM logs;
```

**Cómo funciona**: centraliza la escritura en `logs` dentro de un procedimiento, y cada trigger solo lo llama con sus datos. Así se evita repetir el mismo `INSERT` en todos los triggers. En el `DELETE` se usa `OLD`, porque la fila ya no existe.

### C5) Listar y eliminar triggers

```sql
SHOW TRIGGERS;

DROP TRIGGER tr_song_reproducciones;

INSERT INTO song(id, title, duration, num_times_played, id_album)
VALUES (23, 'Tercer tema', 210, 300, 8);

SELECT id, title, num_times_played FROM song WHERE id = 23;
```

**Cómo funciona**: después del `DROP`, el último `INSERT` ya no se intercepta y la canción 23 se guarda con las 300 reproducciones indicadas, confirmando que el trigger dejó de existir.

---

## Preguntas (verdadero o falso)

| # | Pregunta | Respuesta | Justificación |
|---|---|---|---|
| 1 | Al ejecutar `DROP VIEW` se eliminan los registros de las tablas que usaba la vista | **Falso** | Se elimina la vista, no los datos |
| 2 | Una vista guarda una copia de los datos en el momento en que se crea | **Falso** | La vista guarda la consulta, no los datos |
| 3 | Si se borra una columna que usa una vista, la vista sigue funcionando | **Falso** | La vista deja de funcionar |
| 4 | Las vistas reciben parámetros y los stored procedures no | **Falso** | Es al revés |
| 5 | Un trigger `BEFORE INSERT` puede modificar los valores de `NEW` | **Verdadero** | Por eso el ejercicio C3 logra forzar el 0 |
| 6 | En un trigger de `DELETE` se usa `NEW` para leer la fila borrada | **Falso** | En un `DELETE` se usa `OLD` |
| 7 | Un trigger se ejecuta con `CALL` | **Falso** | Se ejecuta automáticamente cuando ocurre el evento |
| 8 | `DELIMITER` se usa para poder escribir `;` dentro de un procedimiento o un trigger | **Verdadero** | Cambia el delimitador durante la creación |

---

## Ejercicios de la base Chinook

### 02) Restricciones

```sql
ALTER TABLE Album
    ALTER COLUMN Title SET DEFAULT 'Sin título';

ALTER TABLE Album
    ADD CONSTRAINT ck_invoice_total_min CHECK (Total >= 0.99);
```

**Objetivo**: que todo álbum insertado sin `Title` tome el valor por defecto, y que ninguna factura pueda tener un total menor a 0.99.

**Verificación**: `SHOW CREATE TABLE` muestra ambas restricciones; el `INSERT` de un álbum sin `Title` guarda el default, y el de una factura con `Total = 0.50` falla con `Error 3819`.

### 03) Vista `v_upselling_tracks`

```sql
CREATE OR REPLACE VIEW v_upselling_tracks AS
SELECT t.TrackId,
       t.Name         AS track,
       il.InvoiceLineId,
       il.InvoiceId,
       il.UnitPrice,
       i.Total        AS total_factura
FROM InvoiceLine il
JOIN Invoice i ON i.InvoiceId = il.InvoiceId
JOIN Track   t ON t.TrackId   = il.TrackId
WHERE il.UnitPrice = 0.99
  AND i.Total > 9.99;
```

**Objetivo**: ver los temas de 0.99 que aparecen en facturas de más de 9.99.

**Verificación**: se comparan tres conteos contra la consulta directa sin la vista: el total de filas, ninguna fila con `total_factura <= 9.99` y ninguna fila con `UnitPrice <> 0.99`. Si la vista y la consulta dan lo mismo, está bien.

### 04) Vista `v_top_artists`

```sql
CREATE OR REPLACE VIEW v_top_artists AS
SELECT ar.ArtistId,
       ar.Name          AS artista,
       SUM(il.Quantity) AS temas_vendidos
FROM InvoiceLine il
JOIN Track  t  ON t.TrackId   = il.TrackId
JOIN Album  al ON al.AlbumId  = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY temas_vendidos DESC, ar.Name
LIMIT 10;
```

**Objetivo**: ranking de los 10 artistas con más temas vendidos.

**Verificación**: `SELECT COUNT(*)` debe dar 10 y la consulta directa sin vista debe devolver las mismas filas en el mismo orden.

### 05) Vista `v_country_sales`

```sql
CREATE OR REPLACE VIEW v_country_sales AS
SELECT i.BillingCountry                 AS pais,
       SUM(il.Quantity)                 AS temas_vendidos,
       SUM(il.UnitPrice * il.Quantity)  AS ventas_totales
FROM Invoice i
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
GROUP BY i.BillingCountry
ORDER BY ventas_totales DESC;
```

**Objetivo**: total de temas y de facturación por país.

**Verificación**: `SUM(ventas_totales)` de la vista debe ser igual a `SUM(UnitPrice * Quantity)` de `InvoiceLine` y a `SUM(Total)` de `Invoice`. Los tres valores coinciden porque toda factura está desglosada en sus líneas.

### 06) Stored procedure `sp_get_invoice_price`

```sql
DELIMITER $$
CREATE PROCEDURE sp_get_invoice_price(IN p_invoice_id INT)
BEGIN
    SELECT p_invoice_id                    AS invoice_id,
           COALESCE(SUM(UnitPrice * Quantity), 0) AS total_factura
    FROM InvoiceLine
    WHERE InvoiceId = p_invoice_id;
END$$
DELIMITER ;
```

**Objetivo**: calcular el total de una factura usando **solo** `InvoiceLine`, sin tocar la columna `Total` de `Invoice`.

**Verificación**: `CALL sp_get_invoice_price(1)` y `(412)` deben devolver exactamente el `Total` de esas facturas. Con un ID inexistente devuelve 0 gracias al `COALESCE`.

### 07) Roles y permisos

```sql
CREATE ROLE 'db_pasante', 'db_contable', 'db_empleado';

-- db_pasante: solo lectura sobre 7 tablas + v_top_artists
GRANT SELECT ON Chinook.v_top_artists TO 'db_pasante';

-- db_contable: CRUD en 5 tablas, execute del SP y lectura de la vista
GRANT EXECUTE ON PROCEDURE Chinook.sp_get_invoice_price TO 'db_contable';
GRANT SELECT ON Chinook.v_upselling_tracks              TO 'db_contable';

-- db_empleado: CRUD en todas las tablas + lectura de la vista
GRANT SELECT, INSERT, UPDATE, DELETE ON Chinook.* TO 'db_empleado';
GRANT SELECT ON Chinook.v_country_sales           TO 'db_empleado';
```

**Objetivo**: agrupar permisos en tres roles con niveles crecientes de acceso.

**Verificación**: `SHOW GRANTS FOR '<rol>'` lista los permisos efectivos de cada uno. Nota: los roles no viven en `mysql.user` sino en `mysql.role_edges`, por eso esa consulta no devuelve filas.

### 08) Usuarios y roles por defecto

```sql
CREATE USER 'Juan'@'localhost'  IDENTIFIED BY 'Juan_2026!';
CREATE USER 'Pedro'@'localhost' IDENTIFIED BY 'Pedro_2026!';
CREATE USER 'Maria'@'localhost' IDENTIFIED BY 'Maria_2026!';

GRANT 'db_pasante'  TO 'Juan'@'localhost';

-- Sin esto el rol no se activa al iniciar sesion
SET DEFAULT ROLE 'db_pasante' TO 'Juan'@'localhost';
```

**Objetivo**: un usuario por rol (Juan pasante, Pedro contable, Maria empleada).

**Verificación**: `SELECT User, Host FROM mysql.user WHERE User IN ('Juan','Pedro','Maria')` y `SHOW GRANTS FOR ... USING '<rol>'`. El `SET DEFAULT ROLE` es necesario: sin él, el rol queda asignado pero inactivo hasta que se hace `SET ROLE`.

### 09) Transacción con error

```sql
START TRANSACTION;

INSERT INTO Customer (...) VALUES (60, 'Ana', 'Perez', ...);
INSERT INTO Invoice (...) VALUES (413, 60, ...);
INSERT INTO InvoiceLine (...) VALUES (2241, 413, ...);
INSERT INTO InvoiceLine (...) VALUES (2242, 413, ...);
INSERT INTO InvoiceLine (...) VALUES (2243, 413, ...);

-- Ultimo item con un ID que YA existe: Error 1062 (Duplicate entry)
INSERT INTO InvoiceLine (...) VALUES (1, 413, ...);

SELECT * FROM Customer WHERE CustomerId = 60;   -- Existe, sin confirmar
ROLLBACK;

SELECT * FROM Customer WHERE CustomerId = 60;   -- Vacio
```

**Objetivo**: comprobar qué pasa con las filas anteriores cuando falla una sentencia de la transacción.

**Verificación**: antes del `ROLLBACK` los registros se ven (misma sesión, transacción abierta); después, desaparecen. Un error en una sentencia no hace rollback automático: hay que pedirlo explícitamente, a menos que el cliente esté en modo autocommit apagado y cierre la sesión.

### 10) Triggers de auditoría sobre `Invoice`

```sql
CREATE TABLE IF NOT EXISTS invoice_log (
    log_id     INT AUTO_INCREMENT PRIMARY KEY,
    accion     ENUM('INSERT','DELETE') NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    invoice_id INT NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_invoice_after_insert
AFTER INSERT ON Invoice
FOR EACH ROW
BEGIN
    INSERT INTO invoice_log (accion, fecha_hora, invoice_id)
    VALUES ('INSERT', NOW(), NEW.InvoiceId);
END$$

CREATE TRIGGER tr_invoice_after_delete
AFTER DELETE ON Invoice
FOR EACH ROW
BEGIN
    INSERT INTO invoice_log (accion, fecha_hora, invoice_id)
    VALUES ('DELETE', NOW(), OLD.InvoiceId);
END$$
DELIMITER ;
```

**Objetivo**: registrar cada alta y cada baja de facturas con fecha, hora e ID.

**Verificación**: al insertar y borrar la factura 9001, `invoice_log` debe tener exactamente dos filas: una con `accion = 'INSERT'` y otra con `'DELETE'`, ambas con `invoice_id = 9001`.

---

## Resumen de conceptos usados

| Concepto | Dónde se usa |
|---|---|
| `CREATE VIEW` / `CREATE OR REPLACE` | A1, A2, A3, A4, A5, ejercicios 03, 04, 05 |
| `GRANT` sobre vistas y tablas | A3, ejercicio 07 |
| `CREATE PROCEDURE` + `DELIMITER` | B1 a B6, C4, ejercicio 06 |
| Parámetros `IN` / `OUT` | B2-B5 (`IN`), B6 (`OUT`) |
| `TRIGGER AFTER INSERT/UPDATE/DELETE` | C1, C2, C4, ejercicio 10 |
| `TRIGGER BEFORE INSERT` + `SET NEW` | C3 |
| `OLD` y `NEW` | C1 (`NEW`), C2 (ambos), C4 (`OLD`), ejercicio 10 (ambos) |
| `SHOW TRIGGERS` / `DROP TRIGGER` | C5 |
| `ALTER TABLE ... ADD CONSTRAINT ... CHECK` | ejercicio 02 |
| `ALTER COLUMN ... SET DEFAULT` | ejercicio 02 |
| `CREATE ROLE`, `GRANT`, `SET DEFAULT ROLE` | ejercicios 07 y 08 |
| `CREATE USER` / `DROP USER` | A3, ejercicio 08 |
| `START TRANSACTION` / `ROLLBACK` | ejercicio 09 |
| `ENUM`, `AUTO_INCREMENT`, `CURRENT_TIMESTAMP` | tabla `logs`, `song_historial`, `invoice_log` |
| Normalización 3NF y claves compuestas | esquema de `music` |
