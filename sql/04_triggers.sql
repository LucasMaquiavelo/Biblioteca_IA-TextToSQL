--1. trg_actualizar_stock (Momento: AFTER INSERT/UPDATE en PRESTAMO)
--Recalcula el stock disponible sumando o restando según el estado del préstamo. 
--En MySQL, como no se puede hacer un trigger que cubra dos momentos a la vez, se 
--crean dos disparadores separados con el mismo concepto para que cubra todo de forma perfecta:

SQL
DELIMITER //

-- Para cuando se CREA un préstamo (Resta stock)
CREATE TRIGGER trg_actualizar_stock_insert
AFTER INSERT ON prestamo
FOR EACH ROW
BEGIN
    DECLARE v_isbn VARCHAR(20);
    -- Buscamos el ISBN del libro correspondiente al ejemplar
    SELECT isbn INTO v_isbn FROM ejemplar WHERE id_ejemplar = NEW.id_ejemplar;
    
    IF NEW.estado = 'ACTIVO' THEN
        UPDATE libro SET stock_disponible = stock_disponible - 1 WHERE isbn = v_isbn;
    END IF;
END //

-- Para cuando se MODIFICA un préstamo (Suma stock si se devuelve)
CREATE TRIGGER trg_actualizar_stock_update
AFTER UPDATE ON prestamo
FOR EACH ROW
BEGIN
    DECLARE v_isbn VARCHAR(20);
    SELECT isbn INTO v_isbn FROM ejemplar WHERE id_ejemplar = NEW.id_ejemplar;
    
    -- Si el préstamo pasa de activo a devuelto/finalizado, devolvemos el stock
    IF (NEW.fecha_devolucion IS NOT NULL AND OLD.fecha_devolucion IS NULL) OR (NEW.estado = 'FINALIZADO' AND OLD.estado = 'ACTIVO') THEN
        UPDATE libro SET stock_disponible = stock_disponible + 1 WHERE isbn = v_isbn;
    END IF;
END //

DELIMITER ;


--2. trg_estado_socio (Momento: AFTER INSERT en SANCION)
--Cambia automáticamente el estado del socio a 'SUSPENDIDO' en cuanto se le encaja una sanción en el sistema.

DELIMITER //

CREATE TRIGGER trg_estado_socio
AFTER INSERT ON sancion
FOR EACH ROW
BEGIN
    UPDATE socio 
    SET estado = 'SUSPENDIDO' 
    WHERE id_socio = NEW.id_socio;
END //

DELIMITER ;


--3. trg_audit_prestamo (Momento: AFTER INSERT/UPDATE/DELETE en PRESTAMO)
--Registra cada movimiento en la tabla de auditoría usando las funciones nativas USER() 
--y el timestamp de MySQL. Al igual que el primero, lo dividimos en los momentos correspondientes:


DELIMITER //

-- Auditoría de INSERCIONES
CREATE TRIGGER trg_audit_prestamo_insert
AFTER INSERT ON prestamo
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_prestamos (id_prestamo, accion, usuario)
    VALUES (NEW.id_prestamo, 'INSERT', USER());
END //

-- Auditoría de MODIFICACIONES
CREATE TRIGGER trg_audit_prestamo_update
AFTER UPDATE ON prestamo
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_prestamos (id_prestamo, accion, usuario)
    VALUES (NEW.id_prestamo, 'UPDATE', USER());
END //

-- Auditoría de ELIMINACIONES
CREATE TRIGGER trg_audit_prestamo_delete
AFTER DELETE ON prestamo
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_prestamos (id_prestamo, accion, usuario)
    VALUES (OLD.id_prestamo, 'DELETE', USER());
END //

DELIMITER ;