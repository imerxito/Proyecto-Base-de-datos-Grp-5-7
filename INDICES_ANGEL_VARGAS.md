# Aporte de Ángel Vargas — Índices (Entrega 2)

## Alcance y estado

Este documento registra la justificación del caso de índices y lo que falta verificar antes de entregar.

**Importante:** el ZIP del repositorio revisado contiene documentación, pero no incluye las migraciones `001`–`008` ni el archivo de evidencia original. Por eso, desde esta copia no es posible confirmar el contenido de las migraciones `004` y `007` ni reproducir el resultado histórico. No se afirma que esos archivos se hayan ejecutado en esta revisión.

## Índice documentado en las correcciones

`Correciones.md` indica que la migración `007` crea `idx_detalle_factura_factura`, para acelerar la búsqueda de las líneas de factura por su clave foránea. También documenta esta medición histórica:

| Escenario consignado en `Correciones.md` | Plan | Tiempo | Páginas leídas |
|---|---|---:|---:|
| Antes | Seq Scan | 19,758 ms | 883 |
| Después | Index Scan | 0,154 ms | 6 |

La misma documentación indica una tabla de 120.014 líneas. Esos números se transcriben como resultados históricos del documento; **no son una medición ejecutada durante esta revisión**.

## Índices para claves foráneas

La documentación `Correciones.md` indica que `004` indexa claves foráneas utilizadas en reuniones frecuentes. El ZIP recibido no contiene la migración `004`, así que no se puede enumerar ni validar aquí su definición exacta.

En el esquema documentado en el ZIP, `public.comanda_detalles.comanda_id` se utiliza para unir los detalles con `public.comandas`. Es un candidato razonable para indexación si el plan de consultas y el volumen lo justifican. El script de `evidencia/caso_indice.sql` permite inspeccionar el plan de esa unión en el esquema actual.

## Cómo validar

1. Ejecutar `evidencia/caso_indice.sql` con `psql` contra una copia de pruebas de la base de datos.
2. Guardar la salida real en `evidencia/resultado_caso_indice.txt`.
3. Si se quiere validar el caso exacto de `idx_detalle_factura_factura`, incorporar al repositorio la versión vigente de las migraciones que crean `detalle_factura` y el índice `007`. No sustituir esa prueba con la prueba de `comanda_detalles`.
4. Comparar `EXPLAIN (ANALYZE, BUFFERS)` y registrar el tamaño aproximado de la tabla, el plan, el tiempo y las páginas/bloques leídos.

## Conclusión

Los índices sobre claves foráneas pueden reducir el costo de joins y filtros, pero el planificador decide si conviene utilizarlos según la consulta, las estadísticas y el tamaño de la tabla. La evidencia debe registrar la salida real de la base que se está entregando.
