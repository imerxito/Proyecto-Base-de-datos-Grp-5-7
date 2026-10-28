-- 007: indice del caso medido (ver evidencia/caso_indice.sql con el EXPLAIN ANALYZE antes/despues).
-- Consulta que lo justifica: "las lineas de una factura" (detalle_factura filtrado por id_factura).
-- La PK de detalle_factura es solo id_detalle_factura, asi que sin este indice cada busqueda
-- recorre toda la tabla.
CREATE INDEX idx_detalle_factura_factura ON public.detalle_factura (id_factura);
