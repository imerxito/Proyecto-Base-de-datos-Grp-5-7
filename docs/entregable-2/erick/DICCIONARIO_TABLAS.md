# Diccionario de las tablas reales relacionadas con mi bloque

Este diccionario refleja el esquema que está desplegado en Supabase, no las tablas del ZIP base. El proyecto actual no tiene `detalle_factura` ni `historial_caja`; sus nombres y funciones no deben presentarse como equivalentes exactos.

## `public.facturas`

| Columna | Significado |
|---|---|
| `id` | Identificador único de la factura. |
| `comanda_id` | Comanda cobrada por la factura; es única cuando tiene valor y puede quedar nula. |
| `subtotal` | Importe antes de impuestos registrado para la factura. |
| `impuestos` | Valor de impuestos de la factura. |
| `total` | Total facturado. La igualdad con subtotal más impuestos no aparece como CHECK en el esquema observado. |
| `metodo_pago` | Medio de pago registrado (`EFECTIVO`, `TARJETA` o `TRANSFERENCIA`). |
| `fecha_emision` | Fecha y hora de emisión. |

## `public.comanda_detalles` (líneas de comanda; no es `detalle_factura`)

| Columna | Significado |
|---|---|
| `id` | Identificador único de la línea. |
| `comanda_id` | Comanda a la que pertenece la línea. |
| `producto_id` | Producto solicitado. |
| `cantidad` | Unidades solicitadas; debe ser mayor que cero. |
| `precio_unitario` | Precio aplicado a esta línea en la comanda; conserva el valor de la operación. |
| `estado` | Estado de la línea (`PENDIENTE`, `ENTREGADO` o `CANCELADO`). |

## `public.turnos_caja`

| Columna | Significado |
|---|---|
| `id` | Identificador único del turno de caja. |
| `caja_id` | Caja en la que se realiza el turno. |
| `usuario_id` | Usuario responsable del turno. |
| `fecha_apertura` | Fecha y hora de apertura. |
| `fecha_cierre` | Fecha y hora de cierre; puede estar vacía mientras el turno siga abierto. |
| `saldo_inicial` | Dinero inicial de caja al abrir el turno. |
| `saldo_final` | Dinero contado al cerrar el turno. |
| `estado` | Estado operativo (`ABIERTO` o `CERRADO`). |

## `public.historiales` (registro genérico; no es `historial_caja`)

| Columna | Significado |
|---|---|
| `id` | Identificador único del evento de historial. |
| `usuario_id` | Usuario que realizó la acción; puede ser nulo. |
| `tabla_afectada` | Nombre de la tabla cuyo registro se afectó. |
| `registro_id` | Identificador del registro afectado; al ser polimórfico, no tiene una FK a todas las tablas. |
| `accion` | Operación registrada (`INSERT`, `UPDATE` o `DELETE`). |
| `descripcion` | Detalle legible del evento, si se proporciona. |
| `fecha_accion` | Fecha y hora en que se registró la acción. |

> Diferencia pendiente para el grupo: `historiales` no conserva en columnas separadas el turno, el medio de pago ni el monto; no se debe documentar como si tuviera la estructura de `historial_caja` del diseño del ZIP.
