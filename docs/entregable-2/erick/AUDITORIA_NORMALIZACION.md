# Auditoría de normalización del esquema real de Supabase

## Alcance

Esta auditoría corresponde a las 16 tablas públicas vistas en el proyecto **Sabor y Stock** el 24 de octubre de 2026. No reemplaza la auditoría del ZIP base: aquel describe 20 tablas distintas. La evaluación se limita a las dependencias que se pueden justificar por PK, `UNIQUE` y columnas observadas; no atribuye al esquema restricciones que no existen.

## Evaluación por tabla

| Tabla | Claves y dependencias declaradas | Evaluación |
|---|---|---|
| `usuarios` | `id → nombre, rol, email, activo, created_at, auth_id`; `email` es `UNIQUE NOT NULL` y `auth_id` es `UNIQUE` nullable. | BCNF bajo las dependencias declaradas. `auth_id` identifica solo perfiles ya vinculados; al ser nullable no es clave candidata para todas las filas. |
| `cajas` | `id → nombre, ubicacion, estado, created_at`. | BCNF. El nombre no está declarado único. |
| `proveedores` | `id → nombre_empresa, contacto, telefono, direccion, activo, created_at`. | BCNF. No se observó clave alternativa declarada. |
| `catalogos` | `id → nombre, descripcion, created_at`. | BCNF. El nombre no está declarado único. |
| `ingredientes` | `id → nombre, unidad_medida, stock_actual, stock_minimo, proveedor_id, created_at`. | BCNF respecto de las dependencias declaradas. `unidad_medida` es texto; no hay entidad separada ni conversión de unidades modelada. |
| `productos` | `id → catalogo_id, nombre, precio, disponible, created_at`. | BCNF. `catalogo_id` puede ser nulo. |
| `recetas` | `id → producto_id, ingrediente_id, cantidad_requerida`. | BCNF con la PK observada. No se declaró `UNIQUE(producto_id, ingrediente_id)`, así que no se presume que esa pareja identifique una única línea. |
| `compras` | `id → proveedor_id, usuario_id, total, fecha_compra, estado`. | BCNF según las dependencias de fila declaradas. `total` resume detalles de compra y debe auditarse como agregado entre filas. |
| `compra_detalles` | `id → compra_id, ingrediente_id, cantidad, costo_unitario`. | BCNF según la PK observada. El costo es histórico de la compra; no depende del precio actual del ingrediente. No se declaró unicidad de ingrediente por compra. |
| `movimientos_inventario` | `id → ingrediente_id, usuario_id, tipo_movimiento, cantidad, motivo, fecha_movimiento`. | BCNF según las dependencias declaradas. No contiene una FK a `compras` o `compra_detalles` que permita reconciliar automáticamente cada entrada de compra. |
| `mesas` | `id → numero_o_nombre, capacidad, estado`; `numero_o_nombre` también es `UNIQUE NOT NULL`. | BCNF. El estado se conserva operativamente; su coherencia con comandas no está impuesta por una dependencia declarada entre tablas. |
| `turnos_caja` | `id → caja_id, usuario_id, fechas, saldos, estado`. | BCNF. No se observó índice único parcial que prohíba más de un turno abierto por caja. |
| `comandas` | `id → mesa_id, usuario_id, turno_caja_id, estado, created_at`. | BCNF según la PK y restricciones declaradas. |
| `comanda_detalles` | `id → comanda_id, producto_id, cantidad, precio_unitario, estado`. | BCNF. `precio_unitario` conserva el precio aplicado a la línea; no debe sustituirse con el precio vigente del catálogo. |
| `facturas` | `id → comanda_id, subtotal, impuestos, total, metodo_pago, fecha_emision`; `comanda_id` es `UNIQUE` pero nullable. | BCNF según las claves declaradas. Para filas enlazadas, `comanda_id` es clave alternativa; por ser nullable no identifica todas las filas. La igualdad `total = subtotal + impuestos` es una regla de negocio no protegida por un `CHECK` observado. |
| `historiales` | `id → usuario_id, tabla_afectada, registro_id, accion, descripcion, fecha_accion`. | BCNF según la PK. `registro_id` es polimórfico y no tiene FK a todas las tablas. |

## Redundancias y controles pendientes

- `ingredientes.stock_actual` puede representar un saldo operativo, pero el esquema no declara una regla transaccional que lo iguale a entradas menos salidas de `movimientos_inventario`. No se presupone una fórmula para `AJUSTE`.
- `compras.total` puede representar la suma de `compra_detalles.cantidad * costo_unitario`; esa suma es entre filas y no queda garantizada por un `CHECK` de una sola fila.
- `facturas.total` conceptualmente puede derivarse de `subtotal + impuestos`, pero no se observó una restricción de coherencia. No se puede afirmar que la base rechace importes incoherentes.
- `comanda_detalles.precio_unitario` y `compra_detalles.costo_unitario` son precios aplicados en la transacción y se justifican como valores históricos.
- `mesas.estado` y `comandas.estado` son estados operativos relacionados. El esquema no sincroniza automáticamente la ocupación de la mesa con la existencia de comandas abiertas.
- `recetas`, `compra_detalles` y `comanda_detalles` no declaran unicidad de sus pares de FK; cualquier regla de no duplicación requeriría confirmación del negocio y una restricción explícita.

## Conclusión

Con las PK y claves `UNIQUE` observadas, las 16 relaciones alcanzan BCNF respecto de las dependencias funcionales declaradas. Esta conclusión no prueba reglas entre tablas ni agregados operativos: los totales de compra, el saldo de inventario, la coherencia factura-comanda y el estado de mesa necesitan controles adicionales si el grupo decide exigirlos. La auditoría de 20 tablas del paquete base debe mantenerse identificada como correspondiente al diseño original, no a la estructura desplegada en Supabase.
