-- ============================================================
-- TP2 | SOLUCIONES - Vistas, stored procedures y triggers
-- Base de datos: music (MySQL 8)
-- ============================================================
-- Objetivo: resolucion completa de las consignas A1-A5, B1-B6 y
--           C1-C5, mas las respuestas de las preguntas finales.
-- Previo: 00_ddl_music.sql y 01_datos_de_prueba.sql.
-- ============================================================

USE music;


-- ------------------------------------------------------------
-- PARTE A: VISTAS
-- ------------------------------------------------------------

-- A1
CREATE VIEW v_canciones_populares AS
SELECT id, title, num_times_played
FROM song
WHERE num_times_played > 10000;

SELECT * FROM v_canciones_populares;


-- A2
CREATE VIEW v_catalogo AS
SELECT song.title  AS cancion,
       album.title AS album,
       artist.name AS artista
FROM song
JOIN album  ON song.id_album   = album.id
JOIN artist ON album.id_artist = artist.id;

SELECT * FROM v_catalogo WHERE artista = 'Soda Stereo';


-- A3
CREATE VIEW v_usuarios AS
SELECT id, nick
FROM user;

CREATE USER 'analista'@'localhost' IDENTIFIED BY 'analista123';
GRANT SELECT ON music.v_usuarios TO 'analista'@'localhost';

SHOW GRANTS FOR 'analista'@'localhost';


-- A4
CREATE OR REPLACE VIEW v_catalogo AS
SELECT song.title          AS cancion,
       album.title         AS album,
       album.released_year AS anio,
       artist.name         AS artista
FROM song
JOIN album  ON song.id_album   = album.id
JOIN artist ON album.id_artist = artist.id;

SELECT * FROM v_catalogo WHERE anio < 1990;


-- A5
CREATE VIEW v_prueba AS
SELECT * FROM song;

DROP VIEW v_prueba;

SELECT COUNT(*) FROM song;   -- Siguen estando todos los registros


-- ------------------------------------------------------------
-- PARTE B: STORED PROCEDURES
-- ------------------------------------------------------------

-- B1
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


-- B2
DELIMITER //
CREATE PROCEDURE sp_canciones_de_album(IN p_id_album INT)
BEGIN
    SELECT title, duration
    FROM song
    WHERE id_album = p_id_album;
END//
DELIMITER ;

CALL sp_canciones_de_album(1);


-- B3
DELIMITER //
CREATE PROCEDURE sp_agregar_artista(IN p_id INT, IN p_name VARCHAR(255), IN p_bio TEXT)
BEGIN
    INSERT INTO artist(id, name, bio)
    VALUES (p_id, p_name, p_bio);
END//
DELIMITER ;

CALL sp_agregar_artista(7, 'Los Piojos', 'Banda de rock argentina.');
SELECT * FROM artist WHERE id = 7;


-- B4
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


-- B5
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


-- B6
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


-- ------------------------------------------------------------
-- PARTE C: TRIGGERS
-- ------------------------------------------------------------

CREATE TABLE logs (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    tabla       VARCHAR(50),
    id_registro INT,
    accion      VARCHAR(10),
    fecha       DATE
);


-- C1
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


-- C2
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


-- C3
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


-- C4
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


-- C5
SHOW TRIGGERS;

DROP TRIGGER tr_song_reproducciones;

INSERT INTO song(id, title, duration, num_times_played, id_album)
VALUES (23, 'Tercer tema', 210, 300, 8);

SELECT id, title, num_times_played FROM song WHERE id = 23;


-- ------------------------------------------------------------
-- PREGUNTAS
-- ------------------------------------------------------------
--  1. Falso. Se elimina la vista, no los datos.
--  2. Falso. La vista guarda la consulta, no los datos.
--  3. Falso. La vista deja de funcionar.
--  4. Falso. Es al reves.
--  5. Verdadero.
--  6. Falso. En un DELETE se usa OLD.
--  7. Falso. Se ejecuta automaticamente cuando ocurre el evento.
--  8. Verdadero.
