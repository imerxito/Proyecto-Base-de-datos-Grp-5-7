-- Propuesta para evaluar antes de incorporarla a una migración 009.
-- Resume ventas por mes, categoría y producto sin incluir datos personales.
CREATE VIEW public.v_ventas_mensuales_producto AS
SELECT date_trunc('month', f.fecha_emision)::date AS mes,
       c.id_categoria,
       c.nombre AS categoria,
       p.id_producto,
       p.nombre AS producto,
       SUM(d.cantidad) AS unidades_vendidas,
       SUM(d.subtotal) AS ingresos
FROM public.factura AS f
JOIN public.detalle_factura AS d
  ON d.id_factura = f.id_factura
JOIN public.producto AS p
  ON p.id_producto = d.id_producto
JOIN public.categoria AS c
  ON c.id_categoria = p.id_categoria
GROUP BY date_trunc('month', f.fecha_emision)::date,
         c.id_categoria,
         c.nombre,
         p.id_producto,
         p.nombre;
