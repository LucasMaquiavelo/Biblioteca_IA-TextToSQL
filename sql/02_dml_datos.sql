-- ====================================================================
-- SCRIPT DE CARGA DE DATOS DE PRUEBA (02_dml_datos.sql)
-- ====================================================================

-- 1. INSERTAR GÉNEROS (Mínimo 5 requeridos)
INSERT INTO genero (id_genero, nombre, descripcion) VALUES
(1, 'Ciencia Ficción', 'Relatos sobre desarrollos tecnológicos y futuros posibles.'),
(2, 'Fantasía', 'Mundos imaginarios con magia y criaturas míticas.'),
(3, 'Novela Histórica', 'Narrativas basadas en hechos o personajes reales de la historia.'),
(4, 'Terror', 'Obras pensadas para causar miedo, suspenso y adrenalina.'),
(5, 'Divulgación Científica', 'Libros de ciencia explicados para el público general.');

-- 2. INSERTAR AUTORES (Mínimo 10 requeridos)
INSERT INTO autor (id_autor, nombre, apellido, nacionalidad) VALUES
(1, 'Isaac', 'Asimov', 'Rusa'),
(2, 'Arthur', 'C. Clarke', 'Británica'),
(3, 'J.R.R.', 'Tolkien', 'Británica'),
(4, 'George', 'R.R. Martin', 'Estadounidense'),
(5, 'Stephen', 'King', 'Estadounidense'),
(6, 'Agatha', 'Christie', 'Británica'),
(7, 'Gabriel', 'García Márquez', 'Colombiana'),
(8, 'Jorge Luis', 'Borges', 'Argentina'),
(9, 'Carl', 'Sagan', 'Estadounidense'),
(10, 'Yuval Noah', 'Harari', 'Israelí');

-- 3. INSERTAR LIBROS (Mínimo 20 requeridos)
-- Se configuran stocks coherentes (por ejemplo 3 totales, 2 disponibles si hay 1 prestado activo)
INSERT INTO libro (isbn, titulo, anio_publicacion, stock_total, stock_disponible) VALUES
('9780553293357', 'Fundación', 1951, 4, 3),
('9780451457998', '2001: Una Odisea Espacial', 1968, 3, 2),
('9780261103573', 'El Señor de los Anillos: La Comunidad del Anillo', 1954, 5, 3),
('9780553103540', 'Juego de Tronos', 1996, 4, 2),
('9781501142970', 'It (Eso)', 1986, 3, 2),
('9780062073488', 'Y no quedó ninguno', 1939, 3, 3),
('9780307474728', 'Cien años de soledad', 1967, 4, 4),
('9780307950949', 'Ficciones', 1944, 3, 3),
('9780345373595', 'Cosmos', 1980, 2, 2),
('9780062316097', 'Sapiens: De animales a dioses', 2011, 4, 3),
('9780553294385', 'Fundación e Imperio', 1952, 2, 2),
('9780261103580', 'El Señor de los Anillos: Las Dos Torres', 1954, 3, 3),
('9780261103597', 'El Señor de los Anillos: El Retorno del Rey', 1955, 3, 3),
('9780553106633', 'Choque de Reyes', 1998, 2, 2),
('9780307743657', 'El Resplandor', 1977, 3, 2),
('9780062073969', 'Asesinato en el Orient Express', 1934, 3, 3),
('9780345539434', 'Un punto azul pálido', 1994, 2, 2),
('9780553380163', 'Breve historia del tiempo', 1988, 3, 3),
('9780451524935', '1984', 1949, 5, 4),
('9780345391803', 'Guía del autoestopista galáctico', 1979, 3, 3);

-- 4. INSERTAR TABLA INTERMEDIA LIBRO_AUTOR (Relación N:M)
INSERT INTO libro_autor (isbn, id_autor) VALUES
('9780553293357', 1), ('9780553294385', 1), -- Asimov
('9780451457998', 2), -- Clarke
('9780261103573', 3), ('9780261103580', 3), ('9780261103597', 3), -- Tolkien
('9780553103540', 4), ('9780553106633', 4), -- Martin
('9781501142970', 5), ('9780307743657', 5), -- King
('9780062073488', 6), ('9780062073969', 6), -- Christie
('9780307474728', 7), -- Gabo
('9780307950949', 8), -- Borges
('9780345373595', 9), ('9780345539434', 9), -- Sagan
('9780062316097', 10); -- Harari

-- 5. INSERTAR TABLA INTERMEDIA LIBRO_GENERO (Relación N:M)
INSERT INTO libro_genero (isbn, id_genero) VALUES
('9780553293357', 1), ('9780553294385', 1), ('9780451457998', 1), ('9780451524935', 1), ('9780345391803', 1), -- Ciencia Ficción
('9780261103573', 2), ('9780261103580', 2), ('9780261103597', 2), ('9780553103540', 2), ('9780553106633', 2), -- Fantasía
('9780307474728', 3), ('9780062073488', 3), ('9780062073969', 3), -- Novela Histórica/Drama/Misterio
('9781501142970', 4), ('9780307743657', 4), -- Terror
('9780345373595', 5), ('9780062316097', 5), ('9780345539434', 5), ('9780553380163', 5); -- Ciencia/Divulgación

-- 6. INSERTAR EJEMPLARES (Generamos las instancias físicas de los libros)
-- Agregamos nro_ejemplar y estado_fisico conforme al DER
INSERT INTO ejemplar (id_ejemplar, isbn, nro_ejemplar, estado_fisico) VALUES
(1, '9780553293357', 1, 'BUENO'), (2, '9780553293357', 2, 'BUENO'), (3, '9780553293357', 3, 'BUENO'),
(4, '9780451457998', 1, 'BUENO'), (5, '9780451457998', 2, 'BUENO'),
(6, '9780261103573', 1, 'BUENO'), (7, '9780261103573', 2, 'BUENO'), (8, '9780261103573', 3, 'BUENO'),
(9, '9780553103540', 1, 'BUENO'), (10, '9780553103540', 2, 'BUENO'),
(11, '9781501142970', 1, 'BUENO'), (12, '9781501142970', 2, 'BUENO'),
(13, '9780062073488', 1, 'BUENO'), (14, '9780307474728', 1, 'BUENO'),
(15, '9780307950949', 1, 'BUENO'), (16, '9780345373595', 1, 'BUENO'),
(17, '9780062316097', 1, 'BUENO'), (18, '9780307743657', 1, 'BUENO'),
(19, '9780451524935', 1, 'BUENO'), (20, '9780345391803', 1, 'BUENO');

-- 7. INSERTAR TIPOS DE SANCIÓN
INSERT INTO tipo_sancion (id_tipo_sancion, nombre, descripcion) VALUES
(1, 'MORA_LEVE', 'Suspensión por entrega fuera de término menor a 7 días.'),
(2, 'MORA_GRAVE', 'Suspensión por entrega fuera de término mayor a 7 días.'),
(3, 'DAÑO_EJEMPLAR', 'Suspensión por devolver un libro roto o en mal estado.');

-- 8. INSERTAR SOCIOS (Mínimo 30 requeridos)
INSERT INTO socio (id_socio, dni, nombre, apellido, email, fecha_alta, estado) VALUES
(1, '35111222', 'Lucas', 'Pérez', 'lucas@gmail.com', '2025-01-10', 'ACTIVO'),
(2, '36222333', 'María', 'Gómez', 'maria@gmail.com', '2025-02-15', 'ACTIVO'),
(3, '37333444', 'Juan', 'Rodríguez', 'juan@gmail.com', '2025-03-20', 'SUSPENDIDO'), -- Socio suspendido por sanción
(4, '38444555', 'Ana', 'Martínez', 'ana@gmail.com', '2025-04-05', 'ACTIVO'),
(5, '39555666', 'Diego', 'López', 'diego@gmail.com', '2025-05-12', 'ACTIVO'),
(6, '40111001', 'Sofía', 'Fernández', 'sofia@gmail.com', '2025-06-01', 'ACTIVO'),
(7, '40222002', 'Bautista', 'González', 'bautista@gmail.com', '2025-06-15', 'ACTIVO'),
(8, '40333003', 'Valentina', 'Álvarez', 'valentina@gmail.com', '2025-07-20', 'ACTIVO'),
(9, '40444004', 'Mateo', 'Romero', 'mateo@gmail.com', '2025-08-05', 'ACTIVO'),
(10, '40555005', 'Emma', 'Sánchez', 'emma@gmail.com', '2025-09-10', 'ACTIVO'),
(11, '40666006', 'Felipe', 'Benítez', 'felipe@gmail.com', '2025-09-25', 'ACTIVO'),
(12, '40777007', 'Mia', 'Ramírez', 'mia@gmail.com', '2025-10-02', 'ACTIVO'),
(13, '40888008', 'Joaquín', 'Torres', 'joaquin@gmail.com', '2025-10-18', 'ACTIVO'),
(14, '40999009', 'Olivia', 'Flores', 'olivia@gmail.com', '2025-11-05', 'ACTIVO'),
(15, '41111222', 'Tomás', 'Acosta', 'tomas@gmail.com', '2025-11-20', 'ACTIVO'),
(16, '41222333', 'Juana', 'Silva', 'juana@gmail.com', '2025-12-01', 'ACTIVO'),
(17, '41333444', 'Santi', 'Toledo', 'santi@gmail.com', '2025-12-10', 'ACTIVO'),
(18, '41444555', 'Clara', 'Medina', 'clara@gmail.com', '2025-12-28', 'ACTIVO'),
(19, '41555666', 'Benjamín', 'Castro', 'benja@gmail.com', '2026-01-05', 'ACTIVO'),
(20, '41666777', 'Martina', 'Ortiz', 'marti@gmail.com', '2026-01-22', 'ACTIVO'),
(21, '41777888', 'Samuel', 'Rubio', 'samuel@gmail.com', '2026-02-02', 'ACTIVO'),
(22, '41888999', 'Elena', 'Molina', 'elena@gmail.com', '2026-02-14', 'ACTIVO'),
(23, '42111001', 'Ignacio', 'Morales', 'nacho@gmail.com', '2026-03-01', 'ACTIVO'),
(24, '42222002', 'Camila', 'Suárez', 'camila@gmail.com', '2026-03-18', 'ACTIVO'),
(25, '42333003', 'Jerónimo', 'Delgado', 'jero@gmail.com', '2026-04-02', 'ACTIVO'),
(26, '42444004', 'Isabella', 'Herrera', 'isabella@gmail.com', '2026-04-15', 'ACTIVO'),
(27, '42555005', 'Francisco', 'Giménez', 'fran@gmail.com', '2026-04-28', 'ACTIVO'),
(28, '42666006', 'Catalina', 'Ríos', 'cata@gmail.com', '2026-05-02', 'ACTIVO'),
(29, '42777007', 'Pedro', 'Vidal', 'pedro@gmail.com', '2026-05-15', 'ACTIVO'),
(30, '42888008', 'Alma', 'Carrizo', 'alma@gmail.com', '2026-05-28', 'ACTIVO');

-- 9. INSERTAR SANCIONES ACTIVAS (Para cumplir consistencia)
INSERT INTO sancion (id_sancion, id_socio, tipo, fecha_inicio, fecha_fin, motivo) VALUES
(1, 3, 'MORA_GRAVE', '2026-05-20', '2026-06-20', 'No devolvió el ejemplar 6 en la fecha límite.');
INSERT INTO sancion (id_sancion, id_socio, tipo, fecha_inicio, fecha_fin, motivo)
VALUES (2, 3, 'SUSPENSION', '2026-05-25', '2026-06-01', 'Devolución con daño severo en ejemplar');
INSERT INTO sancion (id_sancion, id_socio, tipo, fecha_inicio, fecha_fin, motivo)
VALUES (3, 8, 'SUSPENSION', '2026-06-02', '2026-06-09', 'Demora de más de 15 días en la entrega');

-- 10. INSERTAR PRÉSTAMOS (Mínimo 50 requeridos entre devueltos, activos y vencidos)
-- Se simulan préstamos históricos de los años 2025 y 2026 para cumplir la cuota del TP
INSERT INTO prestamo (id_prestamo, id_socio, id_ejemplar, fecha_prestamo, fecha_vencimiento, fecha_devolucion, estado) VALUES
-- Bloque de Préstamos Devueltos (Históricos)
(1, 1, 1, '2025-01-15', '2025-01-30', '2025-01-28', 'DEVUELTO'),
(2, 2, 2, '2025-02-20', '2025-03-05', '2025-03-02', 'DEVUELTO'),
(3, 4, 3, '2025-04-10', '2025-04-25', '2025-04-24', 'DEVUELTO'),
(4, 5, 4, '2025-05-15', '2025-05-30', '2025-05-29', 'DEVUELTO'),
(5, 6, 5, '2025-06-05', '2025-06-20', '2025-06-18', 'DEVUELTO'),
(6, 7, 6, '2025-06-20', '2025-07-05', '2025-07-04', 'DEVUELTO'),
(7, 8, 7, '2025-07-25', '2025-08-10', '2025-08-09', 'DEVUELTO'),
(8, 9, 8, '2025-08-10', '2025-08-25', '2025-08-22', 'DEVUELTO'),
(9, 10, 9, '2025-09-12', '2025-09-27', '2025-09-26', 'DEVUELTO'),
(10, 11, 10, '2025-10-01', '2025-10-16', '2025-10-15', 'DEVUELTO'),
(11, 12, 11, '2025-10-10', '2025-10-25', '2025-10-24', 'DEVUELTO'),
(12, 13, 12, '2025-11-01', '2025-11-16', '2025-11-14', 'DEVUELTO'),
(13, 14, 13, '2025-11-10', '2025-11-25', '2025-11-25', 'DEVUELTO'),
(14, 15, 14, '2025-12-01', '2025-12-16', '2025-12-15', 'DEVUELTO'),
(15, 16, 15, '2025-12-05', '2025-12-20', '2025-12-19', 'DEVUELTO'),
(16, 17, 16, '2025-12-15', '2025-12-30', '2025-12-29', 'DEVUELTO'),
(17, 18, 17, '2026-01-02', '2026-01-17', '2026-01-16', 'DEVUELTO'),
(18, 19, 18, '2026-01-10', '2026-01-25', '2026-01-23', 'DEVUELTO'),
(19, 20, 19, '2026-01-25', '2026-02-10', '2026-02-08', 'DEVUELTO'),
(20, 21, 20, '2026-02-05', '2026-02-20', '2026-02-19', 'DEVUELTO'),
(21, 22, 1, '2026-02-20', '2026-03-07', '2026-03-06', 'DEVUELTO'),
(22, 23, 2, '2026-03-05', '2026-03-20', '2026-03-19', 'DEVUELTO'),
(23, 24, 3, '2026-03-20', '2026-04-04', '2026-04-03', 'DEVUELTO'),
(24, 25, 4, '2026-04-05', '2026-04-20', '2026-04-20', 'DEVUELTO'),
(25, 26, 5, '2026-04-18', '2026-05-03', '2026-05-02', 'DEVUELTO'),
(26, 27, 6, '2026-05-02', '2026-05-17', '2026-05-16', 'DEVUELTO'),
(27, 28, 7, '2026-05-05', '2026-05-20', '2026-05-19', 'DEVUELTO'),
(28, 29, 8, '2026-05-18', '2026-06-02', '2026-06-01', 'DEVUELTO'),
(29, 30, 9, '2026-05-20', '2026-06-04', '2026-06-04', 'DEVUELTO'),
(30, 1, 10, '2026-05-22', '2026-06-06', '2026-06-05', 'DEVUELTO'),
-- Préstamos repetidos para engordar la estadística de "libros más prestados"
(31, 2, 1, '2026-01-05', '2026-01-20', '2026-01-18', 'DEVUELTO'),
(32, 4, 1, '2026-02-10', '2026-02-25', '2026-02-24', 'DEVUELTO'),
(33, 5, 3, '2026-01-12', '2026-01-27', '2026-01-25', 'DEVUELTO'),
(34, 6, 3, '2026-03-02', '2026-03-17', '2026-03-15', 'DEVUELTO'),
(35, 7, 4, '2026-02-15', '2026-03-02', '2026-02-28', 'DEVUELTO'),
(36, 8, 4, '2026-04-10', '2026-04-25', '2026-04-22', 'DEVUELTO'),
(37, 9, 2, '2026-01-18', '2026-02-02', '2026-02-01', 'DEVUELTO'),
(38, 10, 2, '2026-03-10', '2026-03-25', '2026-03-24', 'DEVUELTO'),
(39, 11, 7, '2026-02-02', '2026-02-17', '2026-02-15', 'DEVUELTO'),
(40, 12, 7, '2026-04-05', '2026-04-20', '2026-04-19', 'DEVUELTO'),
-- Bloque de Préstamos Activos (Válidos hoy Junio 2026)
(41, 1, 2, '2026-06-01', '2026-06-15', NULL, 'ACTIVO'),
(42, 2, 4, '2026-06-03', '2026-06-18', NULL, 'ACTIVO'),
(43, 4, 6, '2026-06-04', '2026-06-19', NULL, 'ACTIVO'),
(44, 5, 8, '2026-06-05', '2026-06-20', NULL, 'ACTIVO'),
(45, 6, 11, '2026-06-06', '2026-06-21', NULL, 'ACTIVO'),
(46, 7, 15, '2026-06-07', '2026-06-22', NULL, 'ACTIVO'),
-- Bloque de Préstamos Vencidos (Requeridos para probar consultas del Agente)
(47, 3, 6, '2026-05-01', '2026-05-16', NULL, 'VENCIDO'), -- Asociado a la sanción del socio 3
(48, 8, 9, '2026-05-02', '2026-05-17', NULL, 'VENCIDO'),
(49, 9, 12, '2026-05-03', '2026-05-18', NULL, 'VENCIDO'),
(50, 10, 18, '2026-05-05', '2026-05-20', NULL, 'VENCIDO');