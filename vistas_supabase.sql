-- Vistas adaptadas al esquema real de Sabor y Stock (16 tablas).
-- Proyecto Supabase: Sabor y Stock. Ejecutar desde SQL Editor como postgres.
-- No modifica datos; crea/reemplaza únicamente vistas y revoca su acceso al API
-- hasta que el grupo defina las políticas de acceso correspondientes.

CREATE OR REPLACE VIEW public.v_ingredientes_bajo_minimo
WITH (security_invoker = true) AS
SELECT
    i.id AS ingrediente_id,
    i.nombre,
    i.stock_actual,
    i.stock_minimo,
    i.unidad_medida AS unidad,
    i.stock_minimo - i.stock_actual AS cantidad_faltante
FROM public.ingredientes AS i
WHERE i.stock_actual IS NOT NULL
  AND i.stock_minimo IS NOT NULL
  AND i.stock_actual < i.stock_minimo;

CREATE OR REPLACE VIEW public.v_ventas_diarias_categoria
WITH (security_invoker = true) AS
SELECT
    f.fecha_emision::date AS dia,
    COALESCE(c.nombre, 'Sin catálogo') AS categoria,
    SUM(cd.cantidad)::bigint AS unidades,
    SUM(cd.cantidad * cd.precio_unitario)::numeric AS ventas
FROM public.facturas AS f
JOIN public.comandas AS co ON co.id = f.comanda_id
JOIN public.comanda_detalles AS cd ON cd.comanda_id = co.id
JOIN public.productos AS p ON p.id = cd.producto_id
LEFT JOIN public.catalogos AS c ON c.id = p.catalogo_id
WHERE cd.estado <> 'CANCELADO'
GROUP BY f.fecha_emision::date, COALESCE(c.nombre, 'Sin catálogo');

CREATE OR REPLACE VIEW public.v_rotacion_mensual_producto
WITH (security_invoker = true) AS
SELECT
    date_trunc('month', f.fecha_emision)::date AS mes,
    COALESCE(c.nombre, 'Sin catálogo') AS categoria,
    p.id AS producto_id,
    p.nombre AS producto,
    SUM(cd.cantidad)::bigint AS unidades_vendidas,
    SUM(cd.cantidad * cd.precio_unitario)::numeric AS ingresos
FROM public.facturas AS f
JOIN public.comandas AS co ON co.id = f.comanda_id
JOIN public.comanda_detalles AS cd ON cd.comanda_id = co.id
JOIN public.productos AS p ON p.id = cd.producto_id
LEFT JOIN public.catalogos AS c ON c.id = p.catalogo_id
WHERE cd.estado <> 'CANCELADO'
GROUP BY
    date_trunc('month', f.fecha_emision)::date,
    COALESCE(c.nombre, 'Sin catálogo'),
    p.id,
    p.nombre;

REVOKE ALL ON public.v_ingredientes_bajo_minimo FROM anon, authenticated;
REVOKE ALL ON public.v_ventas_diarias_categoria FROM anon, authenticated;
REVOKE ALL ON public.v_rotacion_mensual_producto FROM anon, authenticated;

SELECT 'v_ingredientes_bajo_minimo' AS vista,
       COUNT(*)::bigint AS filas,
       (SELECT reloptions FROM pg_class WHERE oid = 'public.v_ingredientes_bajo_minimo'::regclass) AS opciones_seguridad,
       has_table_privilege('anon', 'public.v_ingredientes_bajo_minimo', 'SELECT') AS anon_puede_leer,
       has_table_privilege('authenticated', 'public.v_ingredientes_bajo_minimo', 'SELECT') AS authenticated_puede_leer
FROM public.v_ingredientes_bajo_minimo
UNION ALL
SELECT 'v_ventas_diarias_categoria', COUNT(*)::bigint,
       (SELECT reloptions FROM pg_class WHERE oid = 'public.v_ventas_diarias_categoria'::regclass),
       has_table_privilege('anon', 'public.v_ventas_diarias_categoria', 'SELECT'),
       has_table_privilege('authenticated', 'public.v_ventas_diarias_categoria', 'SELECT')
FROM public.v_ventas_diarias_categoria
UNION ALL
SELECT 'v_rotacion_mensual_producto', COUNT(*)::bigint,
       (SELECT reloptions FROM pg_class WHERE oid = 'public.v_rotacion_mensual_producto'::regclass),
       has_table_privilege('anon', 'public.v_rotacion_mensual_producto', 'SELECT'),
       has_table_privilege('authenticated', 'public.v_rotacion_mensual_producto', 'SELECT')
FROM public.v_rotacion_mensual_producto
ORDER BY vista;
