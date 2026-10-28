-- 005: vistas de negocio (la segunda servira en la Entrega 3 para el rol de analisis).
BEGIN;

-- Ingredientes que hay que reponer.
CREATE VIEW public.v_ingredientes_bajo_minimo AS
SELECT i.codigo, i.nombre, i.stock, i.stock_minimo, u.abreviatura AS unidad,
       i.stock_minimo - i.stock AS faltante
FROM public.ingrediente i
JOIN public.unidad_medida u ON u.id_unidad = i.id_unidad
WHERE i.activo AND i.stock < i.stock_minimo;

-- Ventas por dia y categoria, sin datos personales.
CREATE VIEW public.v_ventas_diarias_categoria AS
SELECT f.fecha_emision::date AS dia, c.nombre AS categoria,
       SUM(d.cantidad) AS unidades, SUM(d.subtotal) AS ventas
FROM public.factura f
JOIN public.detalle_factura d ON d.id_factura = f.id_factura
JOIN public.producto p        ON p.id_producto = d.id_producto
JOIN public.categoria c       ON c.id_categoria = p.id_categoria
GROUP BY f.fecha_emision::date, c.nombre;

COMMIT;
