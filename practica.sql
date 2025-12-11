-- Archivo: practica.sql
-- Descripción: Consultas DDL para una base de datos de red social básica.
DROP DATABASE IF EXISTS redsocial;
CREATE DATABASE redsocial;
USE redsocial;

-- Eliminar tablas si ya existen para permitir una recreación limpia del esquema.
DROP TABLE IF EXISTS me_gusta;
DROP TABLE IF EXISTS comentarios;
DROP TABLE IF EXISTS amistades;
DROP TABLE IF EXISTS publicaciones;
DROP TABLE IF EXISTS usuarios;

-- Tabla para almacenar la información de los usuarios.
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(100),
    biografia TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para almacenar las publicaciones de los usuarios.
CREATE TABLE publicaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Si un usuario es eliminado, todas sus publicaciones también lo serán.
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabla para almacenar los comentarios en las publicaciones.
CREATE TABLE comentarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    publicacion_id INT NOT NULL,
    usuario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Si se elimina una publicación, se eliminan sus comentarios.
    FOREIGN KEY (publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE,
    -- Si se elimina un usuario, se eliminan sus comentarios.
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabla para gestionar las relaciones de amistad o seguimiento entre usuarios.
-- Un usuario (seguidor) sigue a otro usuario (seguido).
CREATE TABLE amistades (
    seguidor_id INT NOT NULL,
    seguido_id INT NOT NULL,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Clave primaria compuesta para evitar seguimientos duplicados.
    PRIMARY KEY (seguidor_id, seguido_id),
    -- Asegurarse de que un usuario no pueda seguirse a sí mismo.
    CHECK (seguidor_id <> seguido_id),
    FOREIGN KEY (seguidor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (seguido_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabla para registrar los "me gusta" que los usuarios dan a las publicaciones.
CREATE TABLE me_gusta (
    usuario_id INT NOT NULL,
    publicacion_id INT NOT NULL,
    fecha_me_gusta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Clave primaria compuesta para que un usuario solo pueda dar "me gusta" una vez a una publicación.
    PRIMARY KEY (usuario_id, publicacion_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (publicacion_id) REFERENCES publicaciones(id) ON DELETE CASCADE
);

-- DESARROLLO:

-- 1.- Optimiza una base de datos de red social creando índices apropiados

-- Índice en `usuario_id` para acelerar la búsqueda de todas las publicaciones de un usuario específico.
CREATE INDEX idx_publicaciones_usuario ON publicaciones(usuario_id);

-- Índice en `fecha_publicacion` para ordenar eficientemente el "feed" de noticias por fecha.
CREATE INDEX idx_publicaciones_fecha ON publicaciones(fecha_publicacion);

-- Índice compuesto en `(publicacion_id, fecha_comentario)` para buscar y ordenar rápidamente
CREATE INDEX idx_comentarios_publicacion_fecha ON comentarios(publicacion_id, fecha_comentario);

-- Se crea un índice adicional en `seguido_id` para encontrar rápidamente todos los seguidores de un usuario.
CREATE INDEX idx_amistades_seguido ON amistades(seguido_id);

-- INSERTANDO DATOS DE PRUEBA

-- Insertar usuarios de prueba
INSERT INTO usuarios (nombre_usuario, correo_electronico, contrasena_hash, nombre_completo, biografia) VALUES
('juan_perez', 'juan.perez@email.com', 'hash_contrasena_1', 'Juan Pérez', 'Entusiasta de la tecnología y el café.'),
('maria_lopez', 'maria.lopez@email.com', 'hash_contrasena_2', 'María López', 'Viajera y fotógrafa aficionada.'),
('carlos_garcia', 'carlos.garcia@email.com', 'hash_contrasena_3', 'Carlos García', 'Desarrollador de software y amante de los gatos.'),
('ana_martinez', 'ana.martinez@email.com', 'hash_contrasena_4', 'Ana Martínez', 'Lectora empedernida y escritora en ciernes.');

-- Insertar publicaciones de prueba
INSERT INTO publicaciones (usuario_id, contenido) VALUES
(1, '¡Hola mundo! Esta es mi primera publicación en esta red social.'),
(2, 'Disfrutando de un hermoso atardecer en la playa. #verano #playa'),
(1, '¿Alguien ha probado el nuevo framework de JavaScript? Me encantaría conocer sus opiniones.'),
(3, 'Mi gato acaba de descubrir que puede abrir puertas. Se acabó la privacidad.');

-- Insertar comentarios de prueba
INSERT INTO comentarios (publicacion_id, usuario_id, contenido) VALUES
(1, 2, '¡Bienvenido, Juan!'),
(1, 3, '¡Qué bueno tenerte por aquí!'),
(2, 1, '¡Qué foto tan increíble, María!'),
(4, 2, 'Jajaja, ¡los gatos son lo máximo! El mío aprendió a usar el timbre.');

-- Insertar amistades de prueba (seguimientos)
INSERT INTO amistades (seguidor_id, seguido_id) VALUES
(1, 2), -- Juan sigue a María
(1, 3), -- Juan sigue a Carlos
(2, 1), -- María sigue a Juan
(3, 2); -- Carlos sigue a María

-- Insertar "me gusta" de prueba
INSERT INTO me_gusta (usuario_id, publicacion_id) VALUES
(1, 2), -- A Juan le gusta la publicación 2 (de María)
(2, 1), -- A María le gusta la publicación 1 (de Juan)
(3, 1), -- A Carlos le gusta la publicación 1 (de Juan)
(3, 2), -- A Carlos le gusta la publicación 2 (de María)
(4, 4); -- A Ana le gusta la publicación 4 (de Carlos)


-- 2.- Reescribiendo consultas lentas con subconsultas eficientes, 
SELECT 
	u.nombre_usuario, u.correo_electronico, 
    p.contenido, p.fecha_publicacion, 
    (SELECT COUNT(*) FROM me_gusta m WHERE m.publicacion_id = p.id) AS 'Likes para la publicación', 
    (SELECT COUNT(*) FROM amistades a WHERE a.seguidor_id = u.id) AS 'Seguidores del usuario',
    (SELECT COUNT(*) FROM amistades a WHERE a.seguido_id = u.id) AS 'Seguidos por el usuario',
    (SELECT COUNT(*) FROM comentarios c WHERE c.publicacion_id = p.id) AS 'Comentarios de la publicación',
    (SELECT COUNT(*) FROM comentarios c WHERE c.usuario_id = u.id) AS 'Comentarios del usuario'
FROM usuarios u 
INNER JOIN publicaciones p ON u.id = p.usuario_id;

SELECT 
	p.contenido publicacion, 
    u.nombre_usuario publicado_por,
    IF(cm.contenido IS NULL, '', cm.contenido) comentario,
    IF(cm.nombre IS NULL, '', cm.nombre) comentado_por
FROM publicaciones p 
INNER JOIN usuarios u ON p.usuario_id = u.id
LEFT JOIN (
			SELECT 
				c.publicacion_id, 
                c.contenido, 
                us.nombre_usuario nombre
                FROM comentarios c 
                INNER JOIN usuarios us ON c.usuario_id = us.id
			) cm ON cm.publicacion_id = p.id;
    
-- 3.- Implementando un sistema de transacciones para publicaciones con comentarios, y
START TRANSACTION;

INSERT INTO publicaciones (usuario_id, contenido) 
VALUES (1, 'Contenido de la nueva publicación... Comenten que les parece');

SET @nueva_publicacion_id = LAST_INSERT_ID();

INSERT INTO comentarios (publicacion_id, usuario_id, contenido) 
VALUES (@nueva_publicacion_id, 2, '¡Este es el primer comentario de la publicación!');

INSERT INTO comentarios (publicacion_id, usuario_id, contenido) 
VALUES (@nueva_publicacion_id, 3, '¡Este es el segúndo comentario de la publicación!');

COMMIT;


-- 4.- Creando reportes de engagement usando funciones de ventana.

-- Reporte de Ranking de Publicaciones por Usuario:
-- Este reporte muestra cuántas publicaciones ha hecho cada usuario y les asigna un ranking.
-- Es útil para identificar a los usuarios más activos.
SELECT
    u.nombre_usuario,
    COUNT(p.id) AS total_publicaciones,
    RANK() OVER (ORDER BY COUNT(p.id) DESC) AS ranking_actividad -- -> Función de ventana RANK() OVER .. 
FROM
    usuarios u
JOIN
    publicaciones p ON u.id = p.usuario_id
GROUP BY
    u.id, u.nombre_usuario
ORDER BY
    total_publicaciones DESC;

-- Reporte de Crecimiento de Contenido por Usuario (Publicaciones Acumuladas):
-- Este reporte muestra el número acumulado de publicaciones por usuario a lo largo del tiempo.
-- Ayuda a visualizar cómo y cuándo los usuarios contribuyen con contenido.
SELECT
    p.usuario_id,
    u.nombre_usuario,
    p.fecha_publicacion,
    COUNT(p.id) OVER (PARTITION BY p.usuario_id ORDER BY p.fecha_publicacion) AS publicaciones_acumuladas -- -> Función de ventana COUNT(p.id) OVER ..
FROM
    publicaciones p
JOIN
    usuarios u ON p.usuario_id = u.id
ORDER BY
    p.usuario_id, p.fecha_publicacion;

-- Reporte de Popularidad de Publicaciones (Ranking de "Me Gusta"):
-- Este reporte clasifica las publicaciones según el número de "me gusta" que han recibido.
-- Sirve para destacar el contenido más popular en la plataforma.
WITH ConteoMeGusta AS (
    SELECT
        publicacion_id,
        COUNT(usuario_id) AS numero_de_me_gusta
    FROM
        me_gusta
    GROUP BY
        publicacion_id
)
SELECT
    p.id AS publicacion_id,
    p.contenido,
    u.nombre_usuario,
    cmg.numero_de_me_gusta,
    DENSE_RANK() OVER (ORDER BY cmg.numero_de_me_gusta DESC) AS ranking_popularidad -- -> Función de ventana DENSE_RANK() OVER ..
FROM
    publicaciones p
JOIN
    usuarios u ON p.usuario_id = u.id
LEFT JOIN
    ConteoMeGusta cmg ON p.id = cmg.publicacion_id
ORDER BY
    ranking_popularidad;
