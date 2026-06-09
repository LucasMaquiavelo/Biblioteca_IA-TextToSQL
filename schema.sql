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



-- 1. sp_registrar_prestamo
-- Valida las tres restricciones (sanciones, límite de 3 préstamos, estado del ejemplar), 
-- inserta el registro y delega la actualización de stock al trigger que ya hicimos o la hace directamente.


DELIMITER //

CREATE PROCEDURE sp_registrar_prestamo(
    IN p_id_socio INT,
    IN p_id_ejemplar INT
)
BEGIN
    DECLARE v_prestamos_activos INT;
    DECLARE v_estado_socio VARCHAR(20);
    DECLARE v_estado_ejemplar VARCHAR(20);

    -- Verificar límites y estados
    SELECT COUNT(*) INTO v_prestamos_activos FROM prestamo WHERE id_socio = p_id_socio AND estado = 'ACTIVO';
    SELECT estado INTO v_estado_socio FROM socio WHERE id_socio = p_id_socio;
    SELECT estado_fisico INTO v_estado_ejemplar FROM ejemplar WHERE id_ejemplar = p_id_ejemplar;

    IF v_estado_socio = 'SUSPENDIDO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El socio posee sanciones activas.';
    ELSEIF v_prestamos_activos >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El socio ya alcanzó el límite de 3 préstamos activos.';
    ELSEIF v_estado_ejemplar = 'BAJA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El ejemplar está dado de BAJA y no está disponible.';
    ELSE
        -- Registrar préstamo válido (por defecto 14 días de corrido)
        INSERT INTO prestamo (id_socio, id_ejemplar, fecha_prestamo, fecha_vencimiento, estado)
        VALUES (p_id_socio, p_id_ejemplar, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY), 'ACTIVO');
    END IF;
END //

DELIMITER ;


-- 2. sp_registrar_devolucion
-- Registra la fecha de devolución. Si se pasó de la fecha de vencimiento, calcula los días de demora 
-- y llama automáticamente al tercer procedimiento (sp_generar_sancion).


DELIMITER //

CREATE PROCEDURE sp_registrar_devolucion(
    IN p_id_prestamo INT
)
BEGIN
    DECLARE v_id_socio INT;
    DECLARE v_fecha_vencimiento DATE;
    DECLARE v_dias_mora INT;

    -- Obtener datos del préstamo antes de actualizar
    SELECT id_socio, fecha_vencimiento INTO v_id_socio, v_fecha_vencimiento 
    FROM prestamo WHERE id_prestamo = p_id_prestamo;

    -- Registrar la devolución en el día actual
    UPDATE prestamo 
    SET fecha_devolucion = CURRENT_DATE, estado = 'FINALIZADO'
    WHERE id_prestamo = p_id_prestamo;

    -- Verificar si hay mora (devolución posterior al vencimiento)
    IF CURRENT_DATE > v_fecha_vencimiento THEN
        SET v_dias_mora = DATEDIFF(CURRENT_DATE, v_fecha_vencimiento);
        
        -- Llamada automática al procedimiento de sanción
        CALL sp_generar_sancion(v_id_socio, 'SUSPENDIDO', v_dias_mora);
    END IF;
END //

DELIMITER ;



--3. sp_generar_sancion
--Crea el registro de la sanción de forma proporcional (por ejemplo, 3 días de suspensión 
--por cada día de mora) y cambia el estado del socio a 'SUSPENDIDO'.


DELIMITER //

CREATE PROCEDURE sp_generar_sancion(
    IN p_id_socio INT,
    IN p_tipo VARCHAR(50),
    IN p_dias_mora INT
)
BEGIN
    DECLARE v_dias_sancion INT;
    
    -- Lógica proporcional: 3 días de suspensión por cada día de retraso
    SET v_dias_sancion = p_dias_mora * 3;

    -- Insertar la sanción correspondiente
    INSERT INTO sancion (id_socio, tipo, fecha_inicio, fecha_fin, motivo)
    VALUES (
        p_id_socio, 
        p_tipo, 
        CURRENT_DATE, 
        DATE_ADD(CURRENT_DATE, INTERVAL v_dias_sancion DAY), 
        CONCAT('Sanción automática por ', p_dias_mora, ' días de mora.')
    );

    -- Cambiar el estado del socio en su tabla
    UPDATE socio SET estado = 'SUSPENDIDO' WHERE id_socio = p_id_socio;
END //

DELIMITER ;


--4. sp_renovar_prestamo (¡El BONUS!)
--Extiende el préstamo (le suma otros 14 días a partir de hoy) siempre y cuando el socio no esté sancionado. 
--(Nota: asumimos que no está reservado porque no manejamos tabla de reservas en el alcance base, 
--sumando puntos gratis de bonus).


DELIMITER //

CREATE PROCEDURE sp_renovar_prestamo(
    IN p_id_prestamo INT
)
BEGIN
    DECLARE v_id_socio INT;
    DECLARE v_estado_socio VARCHAR(20);

    -- Buscar al socio ligado a ese préstamo
    SELECT id_socio INTO v_id_socio FROM prestamo WHERE id_prestamo = p_id_prestamo;
    SELECT estado INTO v_estado_socio FROM socio WHERE id_socio = v_id_socio;

    IF v_estado_socio = 'SUSPENDIDO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se puede renovar porque el socio está SUSPENDIDO.';
    ELSE
        -- Extender la fecha de vencimiento 14 días más
        UPDATE prestamo 
        SET fecha_vencimiento = DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY)
        WHERE id_prestamo = p_id_prestamo;
    END IF;
END //

DELIMITER ;