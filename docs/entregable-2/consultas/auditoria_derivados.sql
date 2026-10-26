-- Auditoria de columnas derivadas (excepciones de normalizacion). Todas deben devolver 0 filas.

-- compra.total debe ser la suma de sus lineas
SELECT c.id_compra, c.total, SUM(d.cantidad * d.precio_aplicado) AS suma_lineas
FROM compra c JOIN detalle_compra d ON d.id_compra = c.id_compra
GROUP BY c.id_compra, c.total
HAVING c.total <> SUM(d.cantidad * d.precio_aplicado);

-- factura.subtotal debe ser la suma de sus lineas
SELECT f.id_factura, f.subtotal, SUM(d.subtotal) AS suma_lineas
FROM factura f JOIN detalle_factura d ON d.id_factura = f.id_factura
GROUP BY f.id_factura, f.subtotal
HAVING f.subtotal <> SUM(d.subtotal);

-- ingrediente.stock debe ser entradas - salidas (sin AJUSTE)
SELECT i.codigo, i.stock,
       COALESCE(SUM(CASE m.tipo WHEN 'ENTRADA' THEN m.cantidad WHEN 'SALIDA' THEN -m.cantidad END), 0) AS segun_movimientos
FROM ingrediente i LEFT JOIN movimiento_inventario m ON m.id_ingrediente = i.id_ingrediente
GROUP BY i.codigo, i.stock
HAVING i.stock <> COALESCE(SUM(CASE m.tipo WHEN 'ENTRADA' THEN m.cantidad WHEN 'SALIDA' THEN -m.cantidad END), 0);
