-- ============================================================
-- TP2 | SOPORTE - Datos de prueba de la base music
-- Base de datos: music (MySQL 8)
-- ============================================================
-- Objetivo: cargar artistas, albums, canciones, usuarios y
--           playlists de ejemplo.
-- Previo: 00_ddl_music.sql.
-- Nota: duration esta expresada en segundos.
-- ============================================================

USE music;

INSERT INTO artist (id, name, bio) VALUES
(1, 'Soda Stereo', 'Banda de rock argentina formada en Buenos Aires en 1982.'),
(2, 'Charly García', 'Músico, compositor y cantante argentino.'),
(3, 'Mercedes Sosa', 'Cantante argentina de música folclórica.'),
(4, 'Divididos', 'Banda de rock argentina formada en 1988.'),
(5, 'Babasónicos', 'Banda de rock alternativo argentina.'),
(6, 'Artista Sin Discos', NULL);

INSERT INTO album (id, title, released_year, id_artist) VALUES
(1, 'Canción Animal', 1990, 1),
(2, 'Signos', 1986, 1),
(3, 'Clics Modernos', 1983, 2),
(4, 'Piano Bar', 1984, 2),
(5, 'Cantora 1', 2009, 3),
(6, 'La Era de la Boludez', 1993, 4),
(7, 'Jessico', 2001, 5),
(8, 'Infame', 2003, 5);

INSERT INTO song (id, title, duration, num_times_played, id_album) VALUES
(1,  'De Música Ligera',        213, 15200, 1),
(2,  'Canción Animal',          243,  8900, 1),
(3,  'Un Millón de Años Luz',   272,  6100, 1),
(4,  'Persiana Americana',      290, 12400, 2),
(5,  'Prófugos',                310,  4300, 2),
(6,  'Nos Siguen Pegando Abajo',270,  9800, 3),
(7,  'Los Dinosaurios',         210, 11200, 3),
(8,  'Demoliendo Hoteles',      232,  7600, 4),
(9,  'Raros Peinados Nuevos',   228,  6900, 4),
(10, 'Zamba para no morir',     245,  3100, 5),
(11, 'Todo Cambia',             262,  9400, 5),
(12, 'El Arriero',              350,  8700, 6),
(13, 'Qué Ves',                 190, 10100, 6),
(14, 'Paisano de Hurlingham',   205,  2900, 6),
(15, 'El Loco Chávez',          185,  1200, 7),
(16, 'Irresponsables',          215,  7300, 7),
(17, 'Putita',                  198,  5400, 7),
(18, 'Y qué',                   230,  3800, 8),
(19, 'Once',                    200,     0, 8),
(20, 'Pistola',                 240,   450, 8);

INSERT INTO user (id, first_name, last_name, nick, email) VALUES
(1, 'Ana',    'Pérez',    'anap',     'ana.perez@mail.com'),
(2, 'Bruno',  'Gómez',    'brunog',   'bruno.gomez@mail.com'),
(3, 'Carla',  'López',    'carlal',   'carla.lopez@mail.com'),
(4, 'Diego',  'Martínez', 'diegom',   'diego.martinez@mail.com'),
(5, 'Elena',  'Ruiz',     'elenar',   'elena.ruiz@mail.com'),
(6, 'Franco', 'Sosa',     'francos',  NULL);

INSERT INTO playlist (id, title, is_public) VALUES
(1, 'Mis canciones favoritas', 1),
(2, 'Rock nacional',           1),
(3, 'Para estudiar',           0),
(4, 'Folklore',                1),
(5, 'Playlist vacía',          0);

INSERT INTO user_has_playlist (id_user, id_playlist) VALUES
(1, 1), (1, 3), (2, 2), (3, 4), (4, 2), (5, 5);

INSERT INTO playlist_has_song (id_playlist, id_song) VALUES
(1, 1), (1, 4), (1, 7), (1, 11),
(2, 1), (2, 6), (2, 8), (2, 12), (2, 13), (2, 16),
(3, 3), (3, 10),
(4, 10), (4, 11);

INSERT INTO user_friend_of_user (id_user_1, id_user_2) VALUES
(1, 2), (1, 3), (2, 4), (3, 5);

INSERT INTO user_likes_artist (id_user, id_artist) VALUES
(1, 1), (1, 2), (2, 4), (3, 3), (4, 1), (4, 5), (5, 2);

INSERT INTO user_likes_album (id_user, id_album) VALUES
(1, 1), (1, 3), (2, 6), (3, 5), (4, 2), (4, 7);

INSERT INTO user_likes_song (id_user, id_song) VALUES
(1, 1), (1, 4), (1, 7), (2, 12), (2, 13), (3, 11),
(4, 1), (4, 16), (5, 8), (5, 9), (6, 1);
