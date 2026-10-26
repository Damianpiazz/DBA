# Trabajo Práctico 2 - SQL Avanzado

Vistas, stored procedures, triggers, restricciones, roles, usuarios y transacciones en MySQL 8.

El trabajo tiene **dos partes independientes entre sí**: cada una usa su propia base de datos y se puede resolver sin la otra.

- **Parte 1 — base `music`**: ejercicios A (vistas), B (stored procedures) y C (triggers), más 8 preguntas teóricas.
- **Parte 2 — base `Chinook`**: ejercicios 02 al 10 (restricciones, vistas, SP, roles, usuarios, transacción y triggers).

## Dataset

**`music`**: catálogo de rock argentino (Soda Stereo, Charly García, Divididos…) con artistas, álbumes, canciones, usuarios, playlists y relaciones entre ellos. Se genera con los scripts `00_` y `01_`.

| Tabla | Filas de prueba |
|---|---|
| `artist` | 6 |
| `album` | 8 |
| `song` | 20 |
| `user` | 6 |
| `playlist` | 5 |
| `playlist_has_song` | 14 |

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

## Orden de ejecución y valores esperados

Los resultados de abajo corresponden a correr los ejercicios **en orden (A1 → A5 → B1 → B6 → C1 → C5) sobre `music` recién cargada** con `00_ddl_music.sql` + `01_datos_de_prueba.sql`.

Esto importa porque los ejercicios **mutan datos** y los números se acumulan:

- B4 incrementa `num_times_played` de la canción 20 (450 → 451).
- C1, C3 y C4 van agregando filas a la tabla `logs`.
- C5 elimina el trigger `tr_song_reproducciones`, por lo que un `INSERT` posterior ya no se intercepta.

Si se corre todo de nuevo sobre la misma base sin recargar, algunos conteos (sobre todo los de `logs`) serán mayores.

> Nota: `playlist.is_public` es de tipo `BIT`, así que varios clientes lo muestran como un carácter binario ilegible. Para verlo como número usá `is_public + 0`.

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

**Resultado esperado** — 4 canciones, las únicas que superan las 10000 reproducciones:

| id | title | num_times_played |
|---|---|---|
| 1 | De Música Ligera | 15200 |
| 4 | Persiana Americana | 12400 |
| 7 | Los Dinosaurios | 11200 |
| 13 | Qué Ves | 10100 |

Se controla que el conteo de la vista sea igual al de la consulta directa: `SELECT COUNT(*) FROM song WHERE num_times_played > 10000` también da 4.

---

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

**Resultado esperado** — 5 filas (las 5 canciones de Soda Stereo del dataset):

| cancion | album | artista |
|---|---|---|
| De Música Ligera | Canción Animal | Soda Stereo |
| Canción Animal | Canción Animal | Soda Stereo |
| Un Millón de Años Luz | Canción Animal | Soda Stereo |
| Persiana Americana | Signos | Soda Stereo |
| Prófugos | Signos | Soda Stereo |

Sin el filtro, `SELECT COUNT(*) FROM v_catalogo` da **20**: un fila por canción, resolviendo álbum y artista.

---

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

**Resultado esperado**:

```
Grants for analista@localhost
GRANT USAGE ON *.* TO `analista`@`localhost`
GRANT SELECT ON `music`.`v_usuarios` TO `analista`@`localhost`
```

Detalle importante: aparecen **dos** líneas. `USAGE` es el permiso por defecto que recibe todo usuario nuevo (permite conectarse y nada más), y el `SELECT` está acotado al objeto `music.v_usuarios`. No hay ningún `GRANT` sobre `music.user`, que es exactamente lo que hay que comprobar.

---

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

**Resultado esperado** — 6 filas, todas de álbumes anteriores a 1990:

| cancion | album | anio | artista |
|---|---|---|---|
| Persiana Americana | Signos | 1986 | Soda Stereo |
| Prófugos | Signos | 1986 | Soda Stereo |
| Nos Siguen Pegando Abajo | Clics Modernos | 1983 | Charly García |
| Los Dinosaurios | Clics Modernos | 1983 | Charly García |
| Demoliendo Hoteles | Piano Bar | 1984 | Charly García |
| Raros Peinados Nuevos | Piano Bar | 1984 | Charly García |

Se comprueba que la vista anterior quedó reemplazada: `SELECT COUNT(*) FROM v_catalogo` sigue dando 20, pero ahora la columna `anio` existe y la de `A2` ya no devuelve `artista` solo.

---

### A5) Vista de prueba y `DROP VIEW`

```sql
CREATE VIEW v_prueba AS
SELECT * FROM song;

DROP VIEW v_prueba;

SELECT COUNT(*) FROM song;   -- Siguen estando todos los registros
```

**Cómo funciona**: `DROP VIEW` elimina la definición guardada, no las filas que la vista devolvía. La vista no copia datos: solo guarda la consulta.

**Resultado esperado**:

```
COUNT(*)
20
```

El mismo número que antes del `DROP`. Y un `SELECT * FROM v_prueba` posterior falla con `ERROR 1146 (42S02): Table 'music.v_prueba' doesn't exist`, lo que confirma que desapareció la vista y no la tabla `song`.

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
SELECT id, title, is_public + 0 AS is_public FROM playlist;
```

**Cómo funciona**: sin parámetros, recorre toda la tabla y pone en público lo que esté privado. `DELIMITER //` hace que el `;` interno no corte la creación; se vuelve al `;` habitual al terminar.

**Resultado esperado** — las 5 playlists quedan en `1`:

| id | title | is_public |
|---|---|---|
| 1 | Mis canciones favoritas | 1 |
| 2 | Rock nacional | 1 |
| 3 | Para estudiar | 1 |
| 4 | Folklore | 1 |
| 5 | Playlist vacía | 1 |

Antes del `CALL` las filas 3 y 5 tenían `is_public = 0` (son las dos que figuraban como privadas en `01_datos_de_prueba.sql`); el `UPDATE ... WHERE is_public = 0` las modificó y dejó intactas las otras tres.

---

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

**Resultado esperado** — las 3 canciones del álbum 1 (*Canción Animal*):

| title | duration |
|---|---|
| De Música Ligera | 213 |
| Canción Animal | 243 |
| Un Millón de Años Luz | 272 |

Con un álbum que no existe, por ejemplo `CALL sp_canciones_de_album(99);`, devuelve **0 filas** (no un error): el procedimiento corrió bien, simplemente no había coincidencias.

---

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

**Resultado esperado** — 1 fila, el artista recién creado:

| id | name | bio |
|---|---|---|
| 7 | Los Piojos | Banda de rock argentina. |

La tabla pasa de 6 a 7 artistas (`SELECT COUNT(*) FROM artist` da 7). Si se vuelve a llamar con el mismo id:

```
ERROR 1062 (23000): Duplicate entry '7' for key 'artist.PRIMARY'
```

---

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

**Resultado esperado** — la canción 20 pasa de 450 a 451:

| id | title | num_times_played |
|---|---|---|
| 20 | Pistola | 451 |

Cada llamada adicional suma otro 1, así que una segunda ejecución daría 452. Este es el ejercicio más sensible al orden: si ya se corrió antes, el número de arriba no va a coincidir.

---

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

**Resultado esperado** — la playlist 1 queda con 3 de sus 4 canciones originales:

| id_playlist | id_song |
|---|---|
| 1 | 1 |
| 1 | 4 |
| 1 | 11 |

Antes había 4 filas: `(1,1), (1,4), (1,7), (1,11)`. Se fue el `(1,7)`. Para confirmar que la canción 7 sigue viva: `SELECT * FROM song WHERE id = 7` devuelve *Los Dinosaurios* normalmente, y `SELECT COUNT(*) FROM playlist_has_song` pasa de 14 a 13.

---

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

**Resultado esperado**:

```
@cant
3
```

El álbum 7 tiene 3 canciones (*El Loco Chávez*, *Irresponsables* y *Putita*). Ojo con esto: el `SELECT` interno **no muestra nada en pantalla**, porque el resultado se redirige a la variable. Si olvidás el `SELECT @cant;` final parece que el procedimiento no hiciera nada.

Si se llama con un álbum inexistente, `@cant` queda en **0** (`COUNT(*)` sobre cero filas da 0, no `NULL`).

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

Se usa en los ejercicios C1 y C4. `id` es `AUTO_INCREMENT`, así que no se pasa en los `INSERT`: lo asigna MySQL de forma correlativa.

---

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

**Resultado esperado** — 1 fila en `logs`:

| id | tabla | id_registro | accion | fecha |
|---|---|---|---|---|
| 1 | song | 21 | INSERT | *fecha de hoy* |

Fijate en los dos detalles: `accion` es exactamente el literal `'INSERT'` que escribió el trigger, y `id_registro` = 21 es el id de la fila insertada en `song`. El `logs` estaba vacío antes, así que esta es la fila 1.

---

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

**Resultado esperado** — 1 fila con el antes y el después de la canción 21:

| id | id_song | antes | despues | fecha |
|---|---|---|---|---|
| 1 | 21 | 100 | 101 | *fecha de hoy* |

`antes = 100` es el `num_times_played` que se insertó en C1 y `despues = 101` el resultado de sumarle 1. Es la misma fila de `song`, actualizada una sola vez.

---

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

**Resultado esperado**:

| id | title | num_times_played |
|---|---|---|
| 22 | Otro tema | 0 |

La prueba es contundente: se enviaron **500** y quedó **0**. El trigger corrió antes de grabar y pisó el valor. Nota que `tr_song_insert` (creado en C1) también se dispara con esta inserción, así que `logs` ahora tiene **2 filas**, la de la canción 21 y la de la 22.

---

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

**Resultado esperado** — 4 filas, acumulando todo lo anterior:

| id | tabla | id_registro | accion | fecha |
|---|---|---|---|---|
| 1 | song | 21 | INSERT | *fecha de hoy* |
| 2 | song | 22 | INSERT | *fecha de hoy* |
| 3 | user | 7 | INSERT | *fecha de hoy* |
| 4 | playlist_has_song | 16 | DELETE | *fecha de hoy* |

Las filas 1 y 2 son de C1 y C3. La 3 la agregó `tr_user_insert` con el id del usuario recién creado, y la 4 la agregó `tr_playlist_song_delete` con `OLD.id_song` = 16 (la canción que se desvinculó de la playlist 2).

El `AUTO_INCREMENT` sigue correlativo a pesar de que escriben tres triggers distintos, porque todos apuntan a la misma tabla.

---

### C5) Listar y eliminar triggers

```sql
SHOW TRIGGERS;

DROP TRIGGER tr_song_reproducciones;

INSERT INTO song(id, title, duration, num_times_played, id_album)
VALUES (23, 'Tercer tema', 210, 300, 8);

SELECT id, title, num_times_played FROM song WHERE id = 23;
```

**Cómo funciona**: después del `DROP`, el último `INSERT` ya no se intercepta y la canción 23 se guarda con las 300 reproducciones indicadas, confirmando que el trigger dejó de existir.

**Resultado esperado** — `SHOW TRIGGERS` lista los 5 triggers creados en esta ejecución:

| Trigger | Event | Table | Timing |
|---|---|---|---|
| `tr_playlist_song_delete` | DELETE | `playlist_has_song` | AFTER |
| `tr_song_reproducciones` | INSERT | `song` | BEFORE |
| `tr_song_insert` | INSERT | `song` | AFTER |
| `tr_song_update` | UPDATE | `song` | AFTER |
| `tr_user_insert` | INSERT | `user` | AFTER |

*(El orden depende del momento de creación; la tabla real trae además las columnas `Statement`, `Created`, `sql_mode`, `Definer` y las de collation, que se omiten acá por ancho.)*

Y la prueba final del `DROP`:

| id | title | num_times_played |
|---|---|---|
| 23 | Tercer tema | 300 |

Se enviaron **300** y quedaron **300**: a diferencia de C3, ya no hay `BEFORE INSERT` que los ponga en 0. Para verlo explícitamente: `SHOW TRIGGERS;` ahora devuelve **4 filas**, sin `tr_song_reproducciones`.

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

> **Nota de alcance**: Chinook no está en el repo, así que los valores exactos de conteos y sumas dependen del dataset con el que se cargue. Lo que sigue detalla qué tiene que devolver cada verificación; los mensajes de error y los conteos de estructura son fijos, y los que dependen de los datos se marcan como *"igual a la consulta directa"* para que puedas contrastarlos vos.

### 02) Restricciones

```sql
ALTER TABLE Album
    ALTER COLUMN Title SET DEFAULT 'Sin título';

ALTER TABLE Album
    ADD CONSTRAINT ck_invoice_total_min CHECK (Total >= 0.99);
```

**Objetivo**: que todo álbum insertado sin `Title` tome el valor por defecto, y que ninguna factura pueda tener un total menor a 0.99.

**Resultado esperado**: las dos sentencias responden `Query OK`. Después:

- `SHOW CREATE TABLE Album` muestra en la definición `DEFAULT 'Sin título'` sobre `Title`.
- `INSERT INTO Album (AlbumId, ArtistId) VALUES (9999, 1);` responde `Query OK, 1 row affected`, y un `SELECT Title FROM Album WHERE AlbumId = 9999` devuelve `'Sin título'`.
- `INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingCountry, Total) VALUES (9999, 1, '2026-01-01', 'x', 'x', 'x', 0.50);` falla con:

```
ERROR 3819 (HY000): Check constraint 'ck_invoice_total_min' is violated.
```

---

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

**Resultado esperado**: tres chequeos contra la consulta directa sin la vista, todos deben coincidir:

| Chequeo | Esperado |
|---|---|
| `SELECT COUNT(*) FROM v_upselling_tracks` | = al `COUNT(*)` de la misma consulta con `FROM InvoiceLine ...` a mano |
| `SELECT COUNT(*) FROM v_upselling_tracks WHERE total_factura <= 9.99` | **0** |
| `SELECT COUNT(*) FROM v_upselling_tracks WHERE UnitPrice <> 0.99` | **0** |

Los dos últimos son **0 filas siempre**, sea cual sea el dataset: son la comprobación de que el `WHERE` de la vista se aplica.

---

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

**Resultado esperado**:

- `SELECT COUNT(*) FROM v_top_artists` da **10**.
- `temas_vendidos` es **monótono decreciente** de la primera a la última fila.
- La consulta directa sin la vista devuelve las mismas filas **en el mismo orden**.

---

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

**Resultado esperado** — este es el mejor test de integridad del TP, porque los tres totales **tienen que ser idénticos**:

```sql
SELECT SUM(ventas_totales)      FROM v_country_sales;
SELECT SUM(UnitPrice * Quantity) FROM InvoiceLine;
SELECT SUM(Total)               FROM Invoice;
```

| Chequeo | Esperado |
|---|---|
| Los tres valores anteriores | **iguales entre sí** |
| `SELECT COUNT(*) FROM v_country_sales` | = al `COUNT(DISTINCT BillingCountry)` de `Invoice` |
| Orden | `ventas_totales` descendente |

Coinciden porque toda factura está desglosada en sus líneas. Si no cierran, hay facturas sin `InvoiceLine`.

---

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

**Resultado esperado**:

```sql
CALL sp_get_invoice_price(1);
CALL sp_get_invoice_price(412);
```

| Chequeo | Esperado |
|---|---|
| `total_factura` de la factura 1 | = `SELECT Total FROM Invoice WHERE InvoiceId = 1` |
| `total_factura` de la factura 412 | = `SELECT Total FROM Invoice WHERE InvoiceId = 412` |
| `CALL sp_get_invoice_price(999999)` (id inexistente) | `invoice_id` = 999999 y `total_factura` = **0** |

El último caso es el que justifica el `COALESCE`: sin él, `SUM` sobre cero filas devuelve `NULL`.

---

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

**Objetivo**: agrupar permisos en tres niveles crecientes de acceso.

**Resultado esperado**: cada `GRANT` responde `Query OK`. Después, `SHOW GRANTS FOR '<rol>'`:

```sql
SHOW GRANTS FOR 'db_pasante';
-- GRANT SELECT ON `Chinook`.`v_top_artists` TO `db_pasante`

SHOW GRANTS FOR 'db_contable';
-- GRANT SELECT ON `Chinook`.`v_upselling_tracks` TO `db_contable`
-- GRANT EXECUTE ON PROCEDURE `Chinook`.`sp_get_invoice_price` TO `db_contable`

SHOW GRANTS FOR 'db_empleado';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON `Chinook`.* TO `db_empleado`
-- GRANT SELECT ON `Chinook`.`v_country_sales` TO `db_empleado`
```

> Nota: los roles no viven en `mysql.user` sino en `mysql.role_edges`, por eso `SELECT * FROM mysql.user WHERE User = 'db_pasante'` no devuelve filas. Para listarlos: `SELECT * FROM mysql.role_edges;`

---

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

**Resultado esperado**:

```sql
SELECT User, Host FROM mysql.user WHERE User IN ('Juan','Pedro','Maria');
```

| User | Host |
|---|---|
| Juan | localhost |
| Pedro | localhost |
| Maria | localhost |

```sql
SHOW GRANTS FOR 'Juan'@'localhost';
-- GRANT USAGE ON *.* TO `Juan`@`localhost`
-- GRANT `db_pasante` TO `Juan`@`localhost`
```

El `SET DEFAULT ROLE` es necesario: sin él, `SHOW GRANTS` muestra el rol igual pero **no se activa al iniciar sesión**. La comprobación es entrar como Juan y revisar `SELECT CURRENT_ROLE();` — con el `SET DEFAULT ROLE` devuelve `db_pasante`, sin él devuelve `NONE`.

---

### 09) Transacción con error

```sql
START TRANSACTION;

INSERT INTO Customer (CustomerId, FirstName, LastName, Email) VALUES (60, 'Ana', 'Perez', 'ana@mail.com');
INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, Total) VALUES (413, 60, '2026-01-01', 5.94);
INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) VALUES (2241, 413, 1, 0.99, 2);
INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) VALUES (2242, 413, 2, 0.99, 2);
INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) VALUES (2243, 413, 3, 0.99, 2);

-- Ultimo item con un ID que YA existe: Error 1062 (Duplicate entry)
INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity) VALUES (1, 413, 4, 0.99, 1);

SELECT * FROM Customer WHERE CustomerId = 60;   -- Existe, sin confirmar
ROLLBACK;

SELECT * FROM Customer WHERE CustomerId = 60;   -- Vacio
```

**Objetivo**: comprobar qué pasa con las filas anteriores cuando falla una sentencia de la transacción.

**Resultado esperado**, paso por paso:

| Paso | Mensaje | Filas de `Customer` 60 |
|---|---|---|
| Los 5 primeros `INSERT` | `Query OK, 1 row affected` | 1 (sin confirmar) |
| El 6º `INSERT` (InvoiceLineId 1) | `ERROR 1062 (23000): Duplicate entry '1' for key 'InvoiceLine.PRIMARY'` | 1 (sigue ahí) |
| `SELECT` antes del `ROLLBACK` | **1 fila**: `60, Ana, Perez, ana@mail.com` | 1 |
| `ROLLBACK` | `Query OK, 0 rows affected` | 0 |
| `SELECT` después del `ROLLBACK` | **0 filas** | 0 |

Ese `SELECT` intermedido con 1 fila es el corazón del ejercicio: **un error no hace rollback automático**. Las cinco filas anteriores siguen vivas y visibles dentro de la misma sesión hasta que se pide el `ROLLBACK` explícitamente. Recién ahí desaparecen las 6.

Si en vez de `ROLLBACK` se hiciera `COMMIT`, quedarían confirmadas las 5 primeras y no la sexta.

---

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

**Resultado esperado** con la prueba típica:

```sql
INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, Total) VALUES (9001, 1, '2026-01-01', 1.98);
DELETE FROM Invoice WHERE InvoiceId = 9001;
SELECT * FROM invoice_log WHERE invoice_id = 9001;
```

| log_id | accion | fecha_hora | invoice_id |
|---|---|---|---|
| 1 | INSERT | *timestamp* | 9001 |
| 2 | DELETE | *timestamp* | 9001 |

Exactamente **2 filas**, una por cada trigger, ambas con `invoice_id = 9001` y con `fecha_hora` llena automáticamente por el `DEFAULT CURRENT_TIMESTAMP` (no se pasa en el `INSERT` del trigger). `accion` es un `ENUM`, por lo que solo admite los literales `'INSERT'` y `'DELETE'`.

Si `invoice_log` queda con más filas, es porque se insertaron o borraron otras facturas después: acotá siempre con `WHERE invoice_id = 9001`.

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
