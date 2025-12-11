-- Archivo: trabajo_dia_3.sql
-- Descripción: Optimización de la base de datos de red social mediante la creación de índices.

-- NOTA: Se asume que las tablas del archivo 'practica.sql' ya existen en la base de datos.
-- Estos índices mejorarán el rendimiento de las consultas de lectura (SELECT) que son
-- muy frecuentes en una red social.

-- --- Índices para la tabla `publicaciones` ---

-- Índice en `usuario_id` para acelerar la búsqueda de todas las publicaciones de un usuario específico.
-- Esencial para mostrar el perfil de un usuario.
CREATE INDEX idx_publicaciones_usuario ON publicaciones(usuario_id);

-- Índice en `fecha_publicacion` para ordenar eficientemente el "feed" de noticias por fecha.
CREATE INDEX idx_publicaciones_fecha ON publicaciones(fecha_publicacion);


-- --- Índices para la tabla `comentarios` ---

-- Índice compuesto en `(publicacion_id, fecha_comentario)` para buscar y ordenar rápidamente
-- los comentarios de una publicación específica.
CREATE INDEX idx_comentarios_publicacion_fecha ON comentarios(publicacion_id, fecha_comentario);


-- --- Índices para la tabla `amistades` ---

-- La clave primaria (seguidor_id, seguido_id) ya optimiza la búsqueda de a quién sigue un usuario.
-- Creamos un índice adicional en `seguido_id` para encontrar rápidamente todos los seguidores de un usuario.
CREATE INDEX idx_amistades_seguido ON amistades(seguido_id);


-- Mensaje de finalización
-- ¡Índices creados exitosamente para optimizar la base de datos!