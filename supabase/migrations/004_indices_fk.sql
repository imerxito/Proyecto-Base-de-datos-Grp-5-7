-- 004: indices en las claves foraneas usadas en reuniones frecuentes.
-- PostgreSQL NO indexa las FK automaticamente. Una PK compuesta (a, b) solo ayuda
-- a buscar por "a"; buscar por "b" necesita su propio indice.
-- (El indice de detalle_factura.id_factura se crea aparte en 007, con evidencia.)
BEGIN;
CREATE INDEX idx_ingrediente_unidad          ON public.ingrediente (id_unidad);
CREATE INDEX idx_producto_categoria          ON public.producto (id_categoria);
CREATE INDEX idx_receta_ingrediente          ON public.receta (id_ingrediente);          -- PK cubre id_producto
CREATE INDEX idx_compra_proveedor            ON public.compra (id_proveedor);
CREATE INDEX idx_detalle_compra_ingrediente  ON public.detalle_compra (id_ingrediente);  -- PK cubre id_compra
CREATE INDEX idx_movimiento_ingrediente      ON public.movimiento_inventario (id_ingrediente, fecha);
CREATE INDEX idx_mesa_seccion                ON public.mesa (id_seccion);
CREATE INDEX idx_comanda_mesa                ON public.comanda (id_mesa);
CREATE INDEX idx_detalle_comanda_comanda     ON public.detalle_comanda (id_comanda);
CREATE INDEX idx_detalle_comanda_producto    ON public.detalle_comanda (id_producto);
CREATE INDEX idx_factura_mesa                ON public.factura (id_mesa);
CREATE INDEX idx_factura_fecha               ON public.factura (fecha_emision);
CREATE INDEX idx_detalle_factura_producto    ON public.detalle_factura (id_producto);
CREATE INDEX idx_turno_caja_caja             ON public.turno_caja (id_caja);
CREATE INDEX idx_historial_caja_turno        ON public.historial_caja (id_turno_caja);
CREATE INDEX idx_historial_caja_factura      ON public.historial_caja (id_factura);
CREATE INDEX idx_historial_mesa_mesa         ON public.historial_mesa (id_mesa);
COMMIT;
