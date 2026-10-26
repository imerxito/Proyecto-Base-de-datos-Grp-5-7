# Sección 4 — Auditoría de normalización

## Alcance y criterio

Esta auditoría corresponde al esquema de 20 tablas descrito para la Entrega 2. Las dependencias se identifican a partir de las claves primarias y restricciones `UNIQUE` declaradas en las migraciones. Para las tablas que no se indican como excepción, la clave candidata determina los demás atributos y no se declara una dependencia transitiva adicional; por ello se consideran en BCNF respecto de las dependencias declaradas.

En las tablas con clave primaria compuesta se verifica la dependencia respecto de la clave completa. Las excepciones E1, E2 y E5 son valores agregados entre filas; E3 conserva hechos históricos; E4 contiene dependencias funcionales entre atributos no clave.

## Dependencias principales por relación

| Relación | Clave(s) candidata(s) y dependencias funcionales principales | Evaluación |
|---|---|---|
| `unidad_medida` | `id_unidad`, `nombre` y `abreviatura` determinan la fila. | BCNF |
| `categoria` | `id_categoria` y `nombre` determinan la fila. | BCNF |
| `proveedor` | `id_proveedor` y `documento` determinan la fila. | BCNF |
| `seccion` | `id_seccion` y `nombre` determinan la fila. | BCNF |
| `caja` | `id_caja` determina la fila. | BCNF |
| `usuario` | `id_usuario`, `auth_id`, `cedula` y `correo` determinan la fila. | BCNF |
| `ingrediente` | `id_ingrediente` y `codigo` determinan la fila. `stock` es la excepción agregada E1. | BCNF salvo E1 |
| `producto` | `id_producto` y `codigo` determinan la fila. | BCNF |
| `receta` | `(id_producto, id_ingrediente) → cantidad`. | BCNF; la dependencia usa la clave completa |
| `compra` | `id_compra` determina la fila. `total` es la excepción agregada E2. | BCNF salvo E2 |
| `detalle_compra` | `(id_compra, id_ingrediente) → cantidad, precio_aplicado`. | BCNF; `precio_aplicado` es el hecho histórico E3 |
| `movimiento_inventario` | `id_movimiento` determina la fila. | BCNF |
| `mesa` | `id_mesa` y `numero` determinan la fila. | BCNF |
| `comanda` | `id_comanda` determina la fila. | BCNF |
| `detalle_comanda` | `id_detalle_comanda` determina la fila. | BCNF |
| `factura` | `id_factura` determina la fila; `id_comanda` es `UNIQUE` y enlaza como máximo una factura por comanda cuando no es nulo. `total_pagar` depende de `(subtotal, propina)` (E4) y `subtotal` resume sus detalles (E5). | Excepciones E4 y E5 |
| `detalle_factura` | `id_detalle_factura` determina la fila; `subtotal` depende de `(cantidad, precio_unitario)` (E4). | Excepción E4 |
| `turno_caja` | `id_turno_caja` determina la fila. | BCNF |
| `historial_caja` | `id_historial_caja` determina la fila. | BCNF |
| `historial_mesa` | `id_historial_mesa` determina la fila. | BCNF |

## Excepciones deliberadas

| Código | Atributos | Análisis y motivo | Control indicado |
|---|---|---|---|
| E1 | `ingrediente.stock` | Es un saldo derivado de las entradas y salidas registradas en `movimiento_inventario`. Se conserva para consultar el saldo operativo sin sumar movimientos en cada lectura. Los movimientos `AJUSTE` no entran en la fórmula porque el modelo no define si suman o restan. | `consultas/auditoria_derivados.sql`; el documento de entrega informa cero discrepancias. Se propone un trigger para la Entrega 3. |
| E2 | `compra.total` | Resume la suma de `detalle_compra.cantidad * detalle_compra.precio_aplicado`. Es un agregado entre filas, no una dependencia de una columna de la misma línea. | `consultas/auditoria_derivados.sql`; el documento de entrega informa cero discrepancias. |
| E3 | `detalle_compra.precio_aplicado`, `detalle_factura.precio_unitario` | Guardan el precio aplicado en la transacción. Puede diferir del precio vigente del ingrediente o producto; conservarlo permite representar fielmente operaciones pasadas. No es una redundancia que deba reemplazarse por el precio actual. | No requiere sincronización con el precio vigente; es una instantánea histórica. |
| E4 | `factura.total_pagar`, `detalle_factura.subtotal` | Existen las dependencias `(subtotal, propina) → total_pagar` y `(cantidad, precio_unitario) → subtotal` entre atributos no clave. Se conservan para dejar el documento facturado legible tal como se emitió. | CHECK de coherencia en `factura` y `detalle_factura`, definidos en la migración 003. |
| E5 | `factura.subtotal` | Resume la suma de `detalle_factura.subtotal`, por lo que se deriva de varias filas de detalle. | `consultas/auditoria_derivados.sql`; el documento de entrega informa cero discrepancias. |

## Conclusión

Las relaciones sin excepción se encuentran en BCNF respecto de las dependencias funcionales declaradas por sus claves. E1, E2 y E5 son agregados que requieren auditoría entre filas; E3 conserva precios históricos; E4 mantiene importes coherentes mediante CHECK. La condición de cero discrepancias es la verificación reportada para los datos de la entrega, no una garantía automática frente a cualquier cambio futuro.

## Observaciones de alcance

- `factura.id_mesa` puede derivarse de `comanda.id_mesa` cuando la factura tiene comanda. Se mantiene opcional porque las ventas directas no tienen mesa ni comanda. La coincidencia entre ambas mesas queda como control propuesto para la Entrega 3.
- `mesa.estado` se conserva como estado operativo que consulta la aplicación; no se trata como una dependencia funcional entre tablas.
- La auditoría de derivados excluye movimientos `AJUSTE`, cuya semántica de signo aún está pendiente de decisión.
- **Propuesta de Erick para `AJUSTE`:** sustituir ese tipo ambiguo por `AJUSTE_POSITIVO` y `AJUSTE_NEGATIVO`, o por un ajuste con cantidad firmada y una regla explícita. Esto requiere modificar el CHECK de `movimiento_inventario.tipo`, ajustar la lógica que actualiza `ingrediente.stock` y adaptar la aplicación. No se incorpora en esta entrega sin aprobación del grupo.
- Las consultas de E2 y E5 en `consultas/auditoria_derivados.sql` usan `JOIN` interno; por tanto, comparan compras y facturas que tienen al menos un detalle. Si el sistema admite cabeceras sin líneas, la auditoría debe ampliarse con `LEFT JOIN` y `COALESCE` para cubrirlas también.
