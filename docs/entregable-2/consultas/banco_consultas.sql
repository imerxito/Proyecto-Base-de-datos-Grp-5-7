-- Banco de consultas de negocio. Cada una indica la pregunta y el requisito que cubre.

-- Q1 [los que no tienen] Que ingredientes nunca hemos comprado?
SELECT i.codigo, i.nombre
FROM ingrediente i
LEFT JOIN detalle_compra d ON d.id_ingrediente = i.id_ingrediente
WHERE d.id_ingrediente IS NULL
ORDER BY i.codigo;

-- Q2 [los que no tienen] Que productos del menu nunca se han vendido?
SELECT p.codigo, p.nombre
FROM producto p
LEFT JOIN detalle_factura d ON d.id_producto = p.id_producto
WHERE d.id_producto IS NULL;

-- Q3 [los que no tienen] Que proveedores no tienen ninguna compra?
SELECT pr.nombre
FROM proveedor pr
LEFT JOIN compra c ON c.id_proveedor = pr.id_proveedor
WHERE c.id_compra IS NULL;

-- Q4 [GROUP BY + HAVING + reunion de 3 tablas] Que proveedores superan $500.000 en compras vigentes (no anuladas)?
SELECT pr.nombre, SUM(d.cantidad * d.precio_aplicado) AS gasto
FROM proveedor pr
JOIN compra c         ON c.id_proveedor = pr.id_proveedor
JOIN detalle_compra d ON d.id_compra = c.id_compra
WHERE c.estado <> 'ANULADA'
GROUP BY pr.nombre
HAVING SUM(d.cantidad * d.precio_aplicado) > 500000
ORDER BY gasto DESC;

-- Q5 [reunion de 4 tablas] Cuanto se ha vendido por categoria?
SELECT c.nombre AS categoria, SUM(d.cantidad) AS unidades, SUM(d.subtotal) AS ventas
FROM factura f
JOIN detalle_factura d ON d.id_factura = f.id_factura
JOIN producto p        ON p.id_producto = d.id_producto
JOIN categoria c       ON c.id_categoria = p.id_categoria
GROUP BY c.nombre
ORDER BY ventas DESC;

-- Q6 [reunion de 3 tablas] Cual es el costo teorico y el margen de cada plato segun su receta?
SELECT p.nombre, p.precio_venta,
       SUM(r.cantidad * i.precio_referencia)                  AS costo_ingredientes,
       p.precio_venta - SUM(r.cantidad * i.precio_referencia) AS margen
FROM producto p
JOIN receta r       ON r.id_producto = p.id_producto
JOIN ingrediente i  ON i.id_ingrediente = r.id_ingrediente
GROUP BY p.id_producto, p.nombre, p.precio_venta
ORDER BY margen DESC;

-- Q7 [CTE + subconsulta] Que proveedores gastan por encima del promedio entre proveedores?
WITH gasto AS (
  SELECT c.id_proveedor, SUM(d.cantidad * d.precio_aplicado) AS total
  FROM compra c JOIN detalle_compra d ON d.id_compra = c.id_compra
  WHERE c.estado <> 'ANULADA'
  GROUP BY c.id_proveedor
)
SELECT pr.nombre, g.total
FROM gasto g JOIN proveedor pr ON pr.id_proveedor = g.id_proveedor
WHERE g.total > (SELECT AVG(total) FROM gasto)
ORDER BY g.total DESC;

-- Q8 [vista creada y consultada] Que hay que reponer ya? (vista v_ingredientes_bajo_minimo, migracion 005)
SELECT * FROM v_ingredientes_bajo_minimo ORDER BY faltante DESC;

-- Q9 [agregar antes de reunir] Ventas y propinas por seccion del salon, sin inflar totales.
-- subtotal y propina viven en la cabecera: se suman sin reunir con detalle_factura.
-- LEFT JOIN: las ventas sin mesa (para llevar / venta directa) tambien cuentan.
SELECT COALESCE(s.nombre, 'Sin mesa') AS seccion, COUNT(*) AS facturas,
       SUM(f.subtotal) AS ventas, SUM(f.propina) AS propinas
FROM factura f
LEFT JOIN mesa m    ON m.id_mesa = f.id_mesa
LEFT JOIN seccion s ON s.id_seccion = m.id_seccion
GROUP BY COALESCE(s.nombre, 'Sin mesa')
ORDER BY ventas DESC;

-- Q10 [cuadre de caja, 4 tablas] Cuanto debio quedar en caja de cada turno cerrado y cual fue la diferencia?
SELECT t.id_turno_caja, ca.nombre AS caja, u.nombre AS cajero, t.monto_inicial,
       t.monto_inicial + COALESCE(SUM(CASE WHEN h.metodo_pago = 'Efectivo' AND h.tipo_pago = 'Ingreso' THEN h.monto
                                           WHEN h.metodo_pago = 'Efectivo' AND h.tipo_pago = 'Egreso'  THEN -h.monto END), 0) AS efectivo_esperado,
       t.monto_final,
       t.monto_final - (t.monto_inicial + COALESCE(SUM(CASE WHEN h.metodo_pago = 'Efectivo' AND h.tipo_pago = 'Ingreso' THEN h.monto
                                                           WHEN h.metodo_pago = 'Efectivo' AND h.tipo_pago = 'Egreso'  THEN -h.monto END), 0)) AS diferencia
FROM turno_caja t
JOIN caja ca    ON ca.id_caja = t.id_caja
JOIN usuario u  ON u.id_usuario = t.id_usuario_apertura
LEFT JOIN historial_caja h ON h.id_turno_caja = t.id_turno_caja
WHERE t.estado = 'Cerrado'
GROUP BY t.id_turno_caja, ca.nombre, u.nombre, t.monto_inicial, t.monto_final
ORDER BY t.id_turno_caja;

-- Q11 [los que no tienen] Que cajas nunca se han abierto?
SELECT ca.nombre FROM caja ca
LEFT JOIN turno_caja t ON t.id_caja = ca.id_caja
WHERE t.id_turno_caja IS NULL;

-- Q12 [tipo de venta] Cuanto se vende en mesa, para llevar y por venta directa?
SELECT CASE WHEN f.id_comanda IS NULL AND f.id_mesa IS NULL THEN 'Venta directa'
            WHEN f.id_mesa IS NULL                          THEN 'Para llevar'
            ELSE 'En mesa' END AS tipo_venta,
       COUNT(*) AS facturas, SUM(f.total_pagar) AS total
FROM factura f
GROUP BY 1
ORDER BY total DESC;

-- Q13 [los que no tienen] Que comandas vigentes aun no tienen factura?
SELECT c.id_comanda, c.estado, c.fecha_creacion
FROM comanda c
LEFT JOIN factura f ON f.id_comanda = c.id_comanda
WHERE f.id_factura IS NULL AND c.estado <> 'Anulado'
ORDER BY c.id_comanda;
-- ============================================================================
-- CONSULTAS ADICIONALES DE NEGOCIO (JUAN)
-- ============================================================================

-- Q14: Promedio de consumo por mesa (3+ tablas, CTE y HAVING)
-- Pregunta de negocio: ¿Cuáles mesas generan un consumo promedio por comanda superior a $50,000?
-- Decisión que apoya: Identificar las zonas del restaurante más rentables para optimizar la atención y distribución.
WITH consumos_por_mesa AS (
    SELECT 
        m.id_mesa AS mesa_id,
        m.numero AS numero_mesa,
        c.id_comanda AS comanda_id,
        f.total_pagar
    FROM mesa m
    JOIN comanda c ON m.id_mesa = c.id_mesa
    JOIN factura f ON c.id_comanda = f.id_comanda
)
SELECT 
    numero_mesa,
    COUNT(comanda_id) AS total_comandas,
    ROUND(AVG(total_pagar), 2) AS promedio_consumo,
    SUM(total_pagar) AS ingreso_total
FROM consumos_por_mesa
GROUP BY numero_mesa
HAVING AVG(total_pagar) > 50000
ORDER BY promedio_consumo DESC;

-- Q15: Productos del menú sin ventas registradas (LEFT JOIN con IS NULL)
-- Pregunta de negocio: ¿Qué productos del catálogo no han registrado comandas?
-- Decisión que apoya: Evaluar la eliminación de platillos sin rotación para optimizar insumos y menú.
SELECT 
    p.id_producto AS producto_id,
    p.nombre AS nombre_producto,
    cat.nombre AS categoria
FROM producto p
JOIN categoria cat ON p.id_categoria = cat.id_categoria
LEFT JOIN detalle_comanda dc ON p.id_producto = dc.id_producto
WHERE dc.id_detalle_comanda IS NULL;