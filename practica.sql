-- Archivo: practica.sql
-- Descripción: Consultas DDL para una base de datos de red social básica.

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

-- Mensaje de finalización
-- ¡Esquema de base de datos creado exitosamente!