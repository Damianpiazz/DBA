-- ============================================================
-- TP2 | SOPORTE - DDL de la base music
-- Base de datos: music (MySQL 8)
-- ============================================================
-- Objetivo: crear la base music y sus tablas con claves
--           primarias y foraneas.
-- Previo: ninguna.
-- ============================================================

-- Creacion de la base de datos.
CREATE DATABASE music;

-- Seleccion de la base de datos creada.
USE music;


-- ------------------------------------------------------------
-- 1. Entidades
-- ------------------------------------------------------------

-- Tabla entidad artist
CREATE TABLE artist (
    id   INT,
    name VARCHAR(255),
    bio  TEXT,
    CONSTRAINT pk_artist PRIMARY KEY (id)
);

-- Tabla entidad album (contiene la relacion obligatoria con artist)
CREATE TABLE album (
    id            INT,
    title         VARCHAR(255),
    released_year INT,
    id_artist     INT NOT NULL,
    CONSTRAINT pk_album PRIMARY KEY (id),
    CONSTRAINT fk_album_artist FOREIGN KEY (id_artist) REFERENCES artist (id)
);

-- Tabla entidad song (contiene la relacion obligatoria con album)
CREATE TABLE song (
    id               INT,
    title            VARCHAR(255),
    duration         INT,
    num_times_played INT,
    id_album         INT NOT NULL,
    CONSTRAINT pk_song PRIMARY KEY (id),
    CONSTRAINT fk_song_album FOREIGN KEY (id_album) REFERENCES album (id)
);

-- Tabla entidad user
CREATE TABLE user (
    id         INT,
    first_name VARCHAR(255),
    last_name  VARCHAR(255),
    nick       VARCHAR(255),
    email      VARCHAR(255),
    CONSTRAINT pk_user PRIMARY KEY (id)
);

-- Tabla entidad playlist
CREATE TABLE playlist (
    id        INT,
    title     VARCHAR(255),
    is_public BIT,
    CONSTRAINT pk_playlist PRIMARY KEY (id)
);


-- ------------------------------------------------------------
-- 2. Relaciones
-- ------------------------------------------------------------

-- Tabla relacion user con playlist
CREATE TABLE user_has_playlist (
    id_user     INT,
    id_playlist INT,
    CONSTRAINT pk_user_has_playlist PRIMARY KEY (id_user, id_playlist),
    CONSTRAINT fk_user_has_playlist_user FOREIGN KEY (id_user) REFERENCES user (id),
    CONSTRAINT fk_user_has_playlist_playlist FOREIGN KEY (id_playlist) REFERENCES playlist (id)
);

-- Tabla relacion playlist con song
CREATE TABLE playlist_has_song (
    id_playlist INT,
    id_song     INT,
    CONSTRAINT pk_playlist_has_song PRIMARY KEY (id_playlist, id_song),
    CONSTRAINT fk_playlist_has_song_playlist FOREIGN KEY (id_playlist) REFERENCES playlist (id),
    CONSTRAINT fk_playlist_has_song_song FOREIGN KEY (id_song) REFERENCES song (id)
);

-- Tabla relacion user con user
CREATE TABLE user_friend_of_user (
    id_user_1 INT,
    id_user_2 INT,
    CONSTRAINT pk_user_friend_of_user PRIMARY KEY (id_user_1, id_user_2),
    CONSTRAINT fk_user_friend_of_user1 FOREIGN KEY (id_user_1) REFERENCES user (id),
    CONSTRAINT fk_user_friend_of_user2 FOREIGN KEY (id_user_2) REFERENCES user (id)
);

-- Tabla relacion user con artist
CREATE TABLE user_likes_artist (
    id_user   INT,
    id_artist INT,
    CONSTRAINT pk_user_likes_artist PRIMARY KEY (id_user, id_artist),
    CONSTRAINT fk_user_likes_artist_user FOREIGN KEY (id_user) REFERENCES user (id),
    CONSTRAINT fk_user_likes_artist_artist FOREIGN KEY (id_artist) REFERENCES artist (id)
);

-- Tabla relacion user con album
CREATE TABLE user_likes_album (
    id_user  INT,
    id_album INT,
    CONSTRAINT pk_user_likes_album PRIMARY KEY (id_user, id_album),
    CONSTRAINT fk_user_likes_album_user FOREIGN KEY (id_user) REFERENCES user (id),
    CONSTRAINT fk_user_likes_album_album FOREIGN KEY (id_album) REFERENCES album (id)
);

-- Tabla relacion user con song
CREATE TABLE user_likes_song (
    id_user INT,
    id_song INT,
    CONSTRAINT pk_user_likes_song PRIMARY KEY (id_user, id_song),
    CONSTRAINT fk_user_likes_song_user FOREIGN KEY (id_user) REFERENCES user (id),
    CONSTRAINT fk_user_likes_song_song FOREIGN KEY (id_song) REFERENCES song (id)
);
