# Diccionario de datos — bloque de Ángel Vargas

## Alcance

Este diccionario usa los nombres de tablas que aparecen en los documentos SQL y de validación del ZIP recibido. No se cambia su nombre para hacerlo coincidir con nombres de otra versión del modelo.

## `public.mesas`

| Campo | Significado documentado |
|---|---|
| `id` | Identificador de la mesa. |
| `numero_o_nombre` | Número o nombre de la mesa; se documenta como `UNIQUE NOT NULL` en `AUDITORIA_NORMALIZACION.md`. |
| `capacidad` | Capacidad de personas de la mesa. |
| `estado` | Estado operativo de la mesa. La documentación advierte que no se sincroniza automáticamente con las comandas abiertas. |

## `public.comandas`

| Campo | Significado documentado |
|---|---|
| `id` | Identificador de la comanda. |
| `mesa_id` | Mesa asociada, si la comanda corresponde a una mesa. |
| `usuario_id` | Usuario responsable de la comanda. |
| `turno_caja_id` | Turno de caja asociado. |
| `estado` | Estado operativo de la comanda. |
| `created_at` | Fecha y hora de creación, según `AUDITORIA_NORMALIZACION.md`. |

## `public.comanda_detalles`

| Campo | Significado documentado |
|---|---|
| `id` | Identificador de la línea de comanda. |
| `comanda_id` | Comanda a la que pertenece la línea. |
| `producto_id` | Producto solicitado. |
| `cantidad` | Cantidad solicitada; el diccionario existente indica que debe ser mayor que cero. |
| `precio_unitario` | Precio aplicado a esa línea; se conserva como dato histórico. |
| `estado` | Estado de la línea (`PENDIENTE`, `ENTREGADO` o `CANCELADO`), según `DICCIONARIO_TABLAS.md`. |

## `public.historiales`

| Campo | Significado documentado |
|---|---|
| `id` | Identificador del evento de historial. |
| `usuario_id` | Usuario que realizó la acción; puede ser nulo. |
| `tabla_afectada` | Tabla cuyo registro se modificó. |
| `registro_id` | Identificador del registro afectado. Es polimórfico y no tiene una FK a todas las tablas. |
| `accion` | Acción registrada (`INSERT`, `UPDATE` o `DELETE`). |
| `descripcion` | Detalle legible del evento, si se proporciona. |
| `fecha_accion` | Fecha y hora del evento. |

## Nota de compatibilidad

El plan de trabajo mencionado para esta tarea usa los nombres `mesa`, `comanda`, `detalle_comanda` e `historial_mesa`. La versión del repositorio recibida usa `mesas`, `comandas`, `comanda_detalles` e `historiales`. En particular, `historiales` es un registro genérico y **no equivale** a una tabla específica `historial_mesa`. Confirmar con el grupo cuál versión del esquema es la vigente antes de renombrar o sustituir objetos.
