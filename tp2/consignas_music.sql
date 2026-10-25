-- ============================================================
-- TP2 | CONSIGNAS - Vistas, stored procedures y triggers
-- Base de datos: music (MySQL 8)
-- ============================================================
-- Objetivo: enunciado del trabajo practico. Resolver los
--           ejercicios en orden.
-- Previo:
--   1) 00_ddl_music.sql
--   2) 01_datos_de_prueba.sql
-- ============================================================


-- ------------------------------------------------------------
-- PARTE A: VISTAS
-- ------------------------------------------------------------

-- A1) Crear la vista v_canciones_populares que muestre id, titulo y
--     cantidad de reproducciones de las canciones con mas de 10000
--     reproducciones.

-- A2) Crear la vista v_catalogo que muestre el titulo de cada cancion,
--     el titulo de su album y el nombre del artista.
--     Usarla para listar las canciones de Soda Stereo.

-- A3) Crear la vista v_usuarios que muestre solo el id y el nick de los
--     usuarios. Crear el usuario 'analista'@'localhost' y darle permiso
--     de lectura unicamente sobre esa vista.

-- A4) Modificar v_catalogo para que tambien muestre el anio del album.
--     Listar las canciones de albumes anteriores a 1990.

-- A5) Crear una vista v_prueba con todas las columnas de song.
--     Eliminarla y verificar si se borro algun registro de la tabla.


-- ------------------------------------------------------------
-- PARTE B: STORED PROCEDURES
-- ------------------------------------------------------------

-- B1) Crear el procedimiento sp_publicar_playlists, sin parametros, que
--     haga publicas todas las playlists privadas.

-- B2) Crear el procedimiento sp_canciones_de_album que reciba el id de
--     un album y liste el titulo y la duracion de sus canciones.

-- B3) Crear el procedimiento sp_agregar_artista que reciba id, nombre y
--     biografia, e inserte un nuevo artista.
--     Probarlo agregando a 'Los Piojos' con id 7.

-- B4) Crear el procedimiento sp_reproducir_cancion que reciba el id de
--     una cancion y le sume una reproduccion.

-- B5) Crear el procedimiento sp_quitar_cancion que reciba el id de una
--     playlist y el id de una cancion, y quite esa cancion de la playlist.

-- B6) Crear el procedimiento sp_contar_canciones que reciba el id de un
--     album y devuelva en un parametro de salida la cantidad de
--     canciones que tiene.


-- ------------------------------------------------------------
-- PARTE C: TRIGGERS
-- ------------------------------------------------------------

-- Crear la siguiente tabla, que se usa en los ejercicios C1 y C4:
--
--   logs (id INT AUTO_INCREMENT PRIMARY KEY,
--         tabla VARCHAR(50),
--         id_registro INT,
--         accion VARCHAR(10),
--         fecha DATE)

-- C1) Crear el trigger tr_song_insert que, cada vez que se inserte una
--     cancion, registre en logs la tabla, el id de la cancion, la accion
--     'INSERT' y la fecha del dia.
--     Probarlo insertando una cancion nueva.

-- C2) Crear la tabla song_historial (id, id_song, antes, despues, fecha)
--     y el trigger tr_song_update que, cada vez que se modifique una
--     cancion, guarde la cantidad de reproducciones que tenia antes y la
--     que tiene despues.
--     Probarlo usando el procedimiento del ejercicio B4.

-- C3) Crear el trigger tr_song_reproducciones para que toda cancion nueva
--     se guarde con 0 reproducciones, sin importar el valor que se
--     indique en el INSERT.

-- C4) Crear el procedimiento sp_registrar_log que reciba tabla, id y
--     accion, e inserte un registro en logs. Luego crear dos triggers que
--     lo utilicen:
--       - tr_user_insert: al insertar un usuario.
--       - tr_playlist_song_delete: al quitar una cancion de una playlist.

-- C5) Listar los triggers de la base. Eliminar tr_song_reproducciones y
--     comprobar que ya no tiene efecto.


-- ------------------------------------------------------------
-- PREGUNTAS (verdadero o falso, justificar)
-- ------------------------------------------------------------

--  1. Al ejecutar DROP VIEW se eliminan los registros de las tablas que
--     usaba la vista.
--  2. Una vista guarda una copia de los datos en el momento en que se crea.
--  3. Si se borra una columna que usa una vista, la vista sigue funcionando.
--  4. Las vistas reciben parametros y los stored procedures no.
--  5. Un trigger BEFORE INSERT puede modificar los valores de NEW.
--  6. En un trigger de DELETE se usa NEW para leer la fila borrada.
--  7. Un trigger se ejecuta con CALL.
--  8. DELIMITER se usa para poder escribir ; dentro de un procedimiento
--     o un trigger.
