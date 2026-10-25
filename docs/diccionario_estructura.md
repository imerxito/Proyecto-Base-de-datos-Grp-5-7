# Diccionario de datos: estructura real

Generado desde la base reconstruida (migraciones 001 a 008). Falta la columna de **significado de negocio**: tómala de tu diccionario de la Entrega 1 y agrégala.

## caja

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_caja | integer | no | - |  |
| nombre | character varying | no | - |  |
| activo | boolean | no | true |  |

## categoria

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_categoria | integer | no | - |  |
| nombre | character varying | no | - |  |
| descripcion | character varying | sí | - |  |
| activo | boolean | no | true |  |

## comanda

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_comanda | integer | no | - |  |
| id_mesa | integer | sí | - |  |
| id_usuario | integer | sí | - |  |
| estado | character varying | no | 'Abierto'::character varying |  |
| observacion | character varying | sí | - |  |
| fecha_creacion | timestamp without time zone | no | CURRENT_TIMESTAMP |  |

## compra

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_compra | integer | no | - |  |
| id_proveedor | integer | no | - |  |
| fecha | timestamp without time zone | no | CURRENT_TIMESTAMP |  |
| estado | character varying | no | 'REGISTRADA'::character varying |  |
| total | numeric | no | 0 |  |

## detalle_comanda

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_detalle_comanda | integer | no | - |  |
| id_comanda | integer | no | - |  |
| id_producto | integer | no | - |  |
| cantidad | integer | no | - |  |
| nota | character varying | sí | - |  |

## detalle_compra

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_compra | integer | no | - |  |
| id_ingrediente | integer | no | - |  |
| cantidad | numeric | no | - |  |
| precio_aplicado | numeric | no | - |  |

## detalle_factura

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_detalle_factura | integer | no | - |  |
| id_factura | integer | no | - |  |
| id_producto | integer | no | - |  |
| cantidad | integer | no | - |  |
| precio_unitario | numeric | no | - |  |
| subtotal | numeric | no | 0 |  |

## factura

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_factura | integer | no | - |  |
| id_mesa | integer | sí | - |  |
| id_usuario | integer | no | - |  |
| fecha_emision | timestamp without time zone | no | CURRENT_TIMESTAMP |  |
| subtotal | numeric | no | 0 |  |
| propina | numeric | no | 0 |  |
| total_pagar | numeric | no | 0 |  |
| id_comanda | integer | sí | - |  |

## historial_caja

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_historial_caja | integer | no | - |  |
| id_turno_caja | integer | no | - |  |
| id_usuario | integer | no | - |  |
| id_factura | integer | sí | - |  |
| metodo_pago | character varying | no | - |  |
| tipo_pago | character varying | no | - |  |
| monto | numeric | no | - |  |
| descripcion | character varying | sí | - |  |
| fecha_movimiento | timestamp without time zone | no | CURRENT_TIMESTAMP |  |

## historial_mesa

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_historial_mesa | integer | no | - |  |
| id_mesa | integer | no | - |  |
| id_comanda | integer | sí | - |  |
| id_usuario | integer | no | - |  |
| estado | character varying | no | - |  |
| monto | numeric | sí | - |  |
| motivo | character varying | sí | - |  |
| fecha_accion | timestamp without time zone | no | CURRENT_TIMESTAMP |  |

## ingrediente

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_ingrediente | integer | no | - |  |
| codigo | character varying | no | - |  |
| nombre | character varying | no | - |  |
| id_unidad | integer | no | - |  |
| stock | numeric | no | 0 |  |
| stock_minimo | numeric | no | 0 |  |
| precio_referencia | numeric | no | 0 |  |
| activo | boolean | no | true |  |

## mesa

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_mesa | integer | no | - |  |
| numero | integer | no | - |  |
| estado | character varying | no | 'Libre'::character varying |  |
| id_seccion | integer | no | - |  |
| id_usuario | integer | sí | - |  |

## movimiento_inventario

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_movimiento | integer | no | - |  |
| id_ingrediente | integer | no | - |  |
| tipo | character varying | no | - |  |
| cantidad | numeric | no | - |  |
| fecha | timestamp without time zone | no | CURRENT_TIMESTAMP |  |
| motivo | character varying | no | - |  |

## producto

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_producto | integer | no | - |  |
| codigo | character varying | no | - |  |
| nombre | character varying | no | - |  |
| id_categoria | integer | no | - |  |
| precio_venta | numeric | no | - |  |
| descripcion | character varying | sí | - |  |
| activo | boolean | no | true |  |

## proveedor

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_proveedor | integer | no | - |  |
| documento | character varying | no | - |  |
| nombre | character varying | no | - |  |
| telefono | character varying | sí | - |  |
| correo | character varying | sí | - |  |
| direccion | character varying | sí | - |  |
| activo | boolean | no | true |  |

## receta

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_producto | integer | no | - |  |
| id_ingrediente | integer | no | - |  |
| cantidad | numeric | no | - |  |

## seccion

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_seccion | integer | no | - |  |
| nombre | character varying | no | - |  |

## turno_caja

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_turno_caja | integer | no | - |  |
| id_caja | integer | no | - |  |
| id_usuario_apertura | integer | no | - |  |
| id_usuario_cierre | integer | sí | - |  |
| fecha_apertura | timestamp without time zone | no | CURRENT_TIMESTAMP |  |
| fecha_cierre | timestamp without time zone | sí | - |  |
| monto_inicial | numeric | no | - |  |
| monto_final | numeric | sí | - |  |
| estado | character varying | no | 'Abierto'::character varying |  |

## unidad_medida

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_unidad | integer | no | - |  |
| nombre | character varying | no | - |  |
| abreviatura | character varying | no | - |  |
| descripcion | character varying | sí | - |  |
| activo | boolean | no | true |  |

## usuario

| Columna | Tipo | Nulo | Default | Significado |
|---|---|---|---|---|
| id_usuario | integer | no | - |  |
| auth_id | uuid | no | - |  |
| nombre | character varying | no | - |  |
| cedula | character varying | no | - |  |
| telefono | character varying | sí | - |  |
| correo | character varying | no | - |  |
| rol | character varying | no | 'Caja'::character varying |  |
| fecha_inicio | timestamp without time zone | no | CURRENT_TIMESTAMP |  |
| activo | boolean | no | true |  |
