-- CASO DE INDICE: detalle_factura(id_factura)
-- Consulta: "las lineas (producto, cantidad, precio) de una factura".
-- Metodo: 1) cargar volumen  2) plan ANTES  3) crear indice  4) plan DESPUES  5) limpiar.
-- Ejecutar sobre la base ya reconstruida (scripts/reconstruir.sh).
\timing off
\echo '== 1. Carga de volumen: 30.000 facturas (ano 2025) con 4 lineas cada una =='
INSERT INTO factura (id_mesa, id_usuario, fecha_emision, subtotal, propina, total_pagar)
SELECT 1 + (g % 10), 2 + (g % 2), timestamp '2025-01-01' + g * interval '15 minutes', 0, 0, 0
FROM generate_series(1, 30000) g;

INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio_unitario, subtotal)
SELECT f.id_factura, p.id_producto, 1 + (k % 3), p.precio_venta, (1 + (k % 3)) * p.precio_venta
FROM factura f
CROSS JOIN generate_series(0, 3) k
JOIN producto p ON p.id_producto = 1 + ((f.id_factura + k) % 6)
WHERE f.fecha_emision < '2026-01-01';

UPDATE factura f SET subtotal = s.t, total_pagar = s.t
FROM (SELECT id_factura, SUM(subtotal) AS t FROM detalle_factura GROUP BY id_factura) s
WHERE s.id_factura = f.id_factura AND f.fecha_emision < '2026-01-01';

DROP INDEX IF EXISTS idx_detalle_factura_factura;   -- partimos sin el indice
ANALYZE detalle_factura;
SELECT count(*) AS lineas_en_tabla FROM detalle_factura;

\echo '== 2. ANTES (sin indice) =='
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.nombre, d.cantidad, d.precio_unitario, d.subtotal
FROM detalle_factura d JOIN producto p ON p.id_producto = d.id_producto
WHERE d.id_factura = 15000;

\echo '== 3. Crear indice =='
CREATE INDEX idx_detalle_factura_factura ON detalle_factura (id_factura);
ANALYZE detalle_factura;

\echo '== 4. DESPUES (con indice) =='
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.nombre, d.cantidad, d.precio_unitario, d.subtotal
FROM detalle_factura d JOIN producto p ON p.id_producto = d.id_producto
WHERE d.id_factura = 15000;

\echo '== 5. Limpieza: se borran las facturas de prueba (CASCADE borra sus lineas) =='
DELETE FROM factura WHERE fecha_emision < '2026-01-01';
ANALYZE;
SELECT count(*) AS facturas_restantes FROM factura;
