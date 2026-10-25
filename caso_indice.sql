-- Caso de índice para la Entrega 2.
-- Ejecutar con psql contra una BASE DE PRUEBAS, no contra producción.
-- Detecta la tabla disponible en el esquema y no modifica datos de negocio.
\set ON_ERROR_STOP on

SELECT to_regclass('public.detalle_factura') IS NOT NULL AS tiene_detalle_factura \gset

\if :tiene_detalle_factura
    \echo 'Se encontró public.detalle_factura. Se inspecciona el plan del filtro por id_factura.'
    \echo 'Esta rama asume la columna id_factura descrita por la versión de migraciones de Entrega 2.'
    EXPLAIN (ANALYZE, BUFFERS)
    SELECT *
    FROM public.detalle_factura
    WHERE id_factura = (SELECT MIN(id_factura) FROM public.detalle_factura);
\else
    SELECT to_regclass('public.comanda_detalles') IS NOT NULL AS tiene_comanda_detalles \gset
    \if :tiene_comanda_detalles
        \echo 'No existe public.detalle_factura en esta copia.'
        \echo 'Se encontró public.comanda_detalles; se inspecciona el filtro por comanda_id.'
        \echo 'Esta prueba es una alternativa para el esquema actual, NO reemplaza la evidencia de migración 007.'
        EXPLAIN (ANALYZE, BUFFERS)
        SELECT *
        FROM public.comanda_detalles
        WHERE comanda_id = (SELECT MIN(comanda_id) FROM public.comanda_detalles);
    \else
        \echo 'No se encontró public.detalle_factura ni public.comanda_detalles.'
        \echo 'Verifica que estés conectado a la base correcta y que el esquema sea el de la entrega.'
    \endif
\endif
