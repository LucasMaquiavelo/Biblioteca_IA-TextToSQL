-- ====================================================================
-- SCRIPT DE CREACIÓN DE TABLAS CORREGIDO (01_schema.sql)
-- ====================================================================

CREATE TABLE autor (
    id_autor INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    nacionalidad VARCHAR(50) NOT NULL
);

CREATE TABLE genero (
    id_genero INT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE libro (
    isbn VARCHAR(20) PRIMARY KEY,
    titulo VARCHAR(60) NOT NULL,
    anio_publicacion INT,
    stock_total INT NOT NULL,
    stock_disponible INT NOT NULL,
    CHECK (anio_publicacion > 0), 
    CHECK (stock_total >= 0),
    CHECK (stock_disponible >= 0),
    CHECK (stock_disponible <= stock_total)
);

CREATE TABLE socio (
    id_socio INT PRIMARY KEY,
    dni INT NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    fecha_alta DATE NOT NULL DEFAULT (CURRENT_DATE),
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    CHECK (dni > 0),
    CHECK (email LIKE '%@%.%')
);

CREATE TABLE tipo_sancion (
    id_tipo_sancion INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL
);

CREATE TABLE libro_autor (
    isbn VARCHAR(20), 
    id_autor INT,
    PRIMARY KEY (isbn, id_autor),
    FOREIGN KEY (isbn) REFERENCES libro(isbn) ON DELETE CASCADE,
    FOREIGN KEY (id_autor) REFERENCES autor(id_autor) ON DELETE RESTRICT
);

CREATE TABLE libro_genero (
    isbn VARCHAR(20),
    id_genero INT,
    PRIMARY KEY (isbn, id_genero),
    FOREIGN KEY (isbn) REFERENCES libro(isbn) ON DELETE CASCADE,
    FOREIGN KEY (id_genero) REFERENCES genero(id_genero) ON DELETE RESTRICT
);

CREATE TABLE ejemplar (
    id_ejemplar INT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL, 
    nro_ejemplar INT NOT NULL,
    estado_fisico VARCHAR(20) NOT NULL,
    UNIQUE (isbn, nro_ejemplar),
    FOREIGN KEY (isbn) REFERENCES libro(isbn) ON DELETE RESTRICT,
    CHECK (estado_fisico IN ('BUENO', 'REGULAR', 'MALO', 'BAJA'))
);

CREATE TABLE prestamo (
    id_prestamo INT PRIMARY KEY,
    id_socio INT NOT NULL,
    id_ejemplar INT NOT NULL,
    fecha_prestamo DATE NOT NULL DEFAULT (CURRENT_DATE),
    fecha_vencimiento DATE NOT NULL,
    fecha_devolucion DATE,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO', 
    FOREIGN KEY (id_socio) REFERENCES socio(id_socio) ON DELETE RESTRICT,
    FOREIGN KEY (id_ejemplar) REFERENCES ejemplar(id_ejemplar) ON DELETE RESTRICT,
    CHECK (fecha_vencimiento >= fecha_prestamo),
    CHECK (fecha_devolucion IS NULL OR fecha_devolucion >= fecha_prestamo)
);

CREATE TABLE sancion (
    id_sancion INT PRIMARY KEY,
    id_socio INT NOT NULL,
    tipo VARCHAR(50) NOT NULL, 
    fecha_inicio DATE NOT NULL DEFAULT (CURRENT_DATE),
    fecha_fin DATE NOT NULL,
    motivo TEXT NOT NULL,
    FOREIGN KEY (id_socio) REFERENCES socio(id_socio) ON DELETE CASCADE,
    CHECK (fecha_fin >= fecha_inicio)
);