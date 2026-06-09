-- Vista 1: Resumen de libros con stock crítico
CREATE OR REPLACE VIEW vista_stock_critico AS
SELECT isbn, titulo, stock_total, stock_disponible
FROM libro
WHERE stock_disponible <= 1;

-- Vista 2: Reporte de socios morosos con préstamos activos vencidos
CREATE OR REPLACE VIEW vista_socios_morosos AS
SELECT s.id_socio, s.dni, s.nombre, s.apellido, p.id_prestamo, p.fecha_vencimiento
FROM socio s
JOIN prestamo p ON s.id_socio = p.id_socio
WHERE p.estado = 'VENCIDO' OR (p.fecha_devolucion IS NULL AND p.fecha_vencimiento < CURRENT_DATE);