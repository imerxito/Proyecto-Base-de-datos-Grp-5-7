# Sistema de Gestión Restaurante "Sabor & Stock"
## Documento Técnico: Políticas de Borrado y Diccionario de Datos

---

## 1. Políticas de Borrado e Integridad Referencial

El modelo de datos de **Sabor & Stock** administra transacciones comerciales, trazabilidad contable, control de existencias de cocina en tiempo real y flujo de caja. En un entorno relacional transaccional (OLTP), la eliminación física indiscriminada de tuplas (*Hard Delete*) genera inconsistencias operativas y destruye la evidencia fiscal.

Por lo tanto, la arquitectura de persistencia en PostgreSQL clasifica las operaciones de supresión de datos bajo cuatro estrategias de integridad referencial:

---

### 1.1. Estrategias de Eliminación

1. **Borrado Lógico (*Soft Delete*):**
   * **Entidades aplicadas:** `usuario`, `producto`, `ingrediente`, `proveedor`, `mesa`.
   * **Mecanismo técnico:** Marcadores booleanos (`activo = false`) o transiciones terminales en estados (`compra.estado = 'ANULADA'`).
   * **Justificación de arquitectura:** Los registros con historial contable o de almacén no pueden borrarse físicamente de la base de datos sin violar claves foráneas o corromper balances históricos. Al desactivarlos, quedan excluidos de las operaciones diarias de la interfaz pero se mantienen consultables en balances y auditorías.

2. **Borrado en Cascada (*ON DELETE CASCADE*):**
   * **Entidades aplicadas:**
     * `factura` $\to$ `detalle_factura`
     * `comanda` $\to$ `detalle_comanda`
     * `compra` $\to$ `detalle_compra`
     * `producto` / `ingrediente` $\to$ `receta`
   * **Justificación de arquitectura:** Corresponde a relaciones de composición fuerte (Maestro-Detalle). Si se autoriza la purga o eliminación física de una cabecera transitoria, sus líneas hijas pierden sentido por completo y deben ser removidas en la misma transacción atómica para prevenir la acumulación de registros huérfanos.

3. **Desvinculación Segura (*ON DELETE SET NULL*):**
   * **Entidades aplicadas:**
     * `auth.users(id)` $\to$ `public.usuario(auth_id)`
     * `public.mesa(id_mesa)` $\to$ `public.factura(id_mesa)`
     * `public.mesa(id_mesa)` $\to$ `public.comanda(id_mesa)`
     * `public.factura(id_factura)` $\to$ `public.historial_caja(id_factura)`
   * **Justificación de arquitectura:** Garantiza la persistencia de las entidades de negocio independientemente del ciclo de vida de entidades accesorias o externas. Si se suprime una cuenta en el proveedor de autenticación o se procesa una venta directa de mostrador sin mesa física asignada, los registros principales se mantienen intactos con valor `NULL` en la clave foránea.

4. **Restricción Estricta (*ON DELETE RESTRICT / NO ACTION*):**
   * **Entidades aplicadas:** `unidad_medida`, `categoria`, `seccion`, `caja`.
   * **Justificación de arquitectura:** Impide la eliminación accidental o forzada de tablas paramétricas y catálogos mientras existan ingredientes, productos o turnos asociados a ellas.

---

### 1.2. Matriz de Integridad Referencial

| Tabla Origen (Padre) | Tabla Dependiente (Hija) | Clave Foránea (FK) | Regla `ON DELETE` | Mecanismo Recomendado | Justificación Operativa |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `auth.users` | `usuario` | `usuario.auth_id` | `SET NULL` | Soft Delete en aplicación | Conserva el registro del empleado en el restaurante si se revoca el login. |
| `usuario` | `factura` | `factura.id_usuario` | `RESTRICT` | Soft Delete (`activo=false`) | Respaldo legal y fiscal obligatorio de la persona que facturó. |
| `usuario` | `turno_caja` | `turno_caja.id_usuario_apertura` | `RESTRICT` | Soft Delete (`activo=false`) | Auditoría contable obligatoria de aperturas y cierres de caja. |
| `factura` | `detalle_factura` | `detalle_factura.id_factura` | `CASCADE` | Hard Delete en pruebas | El renglón vendido no tiene existencia sin la factura cabecera. |
| `factura` | `historial_caja` | `historial_caja.id_factura` | `SET NULL` | Hard / Soft Delete | El movimiento de caja registrado persiste aunque la factura se anule. |
| `comanda` | `detalle_comanda` | `detalle_comanda.id_comanda` | `CASCADE` | Hard Delete en pruebas | Las líneas solicitadas pertenecen exclusivamente a la orden activa. |
| `mesa` | `comanda` | `comanda.id_mesa` | `SET NULL` | Soft Delete | Permite órdenes directas o pedidos para llevar sin mesa física. |
| `mesa` | `factura` | `factura.id_mesa` | `SET NULL` | Soft Delete | Permite facturación en mostrador sin ocupar mesas de comedor. |
| `compra` | `detalle_compra` | `detalle_compra.id_compra` | `CASCADE` | Anulación (`estado='ANULADA'`) | Las líneas de suministro dependen exclusivamente de la compra. |
| `ingrediente` | `receta` | `receta.id_ingrediente` | `CASCADE` | Soft Delete de insumo | Al retirar un insumo, se eliminan sus proporciones de recetas. |
| `producto` | `receta` | `receta.id_producto` | `CASCADE` | Soft Delete de plato | Al descontinuar un plato, se retira su fórmula técnica. |
| `unidad_medida` | `ingrediente` | `ingrediente.id_unidad` | `RESTRICT` | Restricción total | Evita la pérdida de equivalencias métricas en stock. |
| `categoria` | `producto` | `producto.id_categoria` | `RESTRICT` | Restricción total | Evita dejar artículos del menú huérfanos de categoría. |

---

## 2. Diccionario de Datos

### Módulo 1: Catálogos Generales y Configuración

#### Tabla: `unidad_medida`
* **Descripción:** Unidades de magnitud física para compras, costeo y control métrico de existencias.
* **Clave Primaria:** `id_unidad`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_unidad` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador único de la unidad métrica. |
| `nombre` | `varchar` | No | Ninguno | | Nombre descriptivo (ej. 'Kilogramo', 'Litro'). |
| `abreviatura` | `varchar` | No | Ninguno | | Abreviación estándar (ej. 'kg', 'g', 'l', 'ml', 'und'). |
| `descripcion` | `varchar` | Sí | Ninguno | | Tipo de magnitud (peso, volumen o conteo). |

#### Tabla: `categoria`
* **Descripción:** Agrupaciones temáticas para la estructuración de la carta del restaurante.
* **Clave Primaria:** `id_categoria`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_categoria` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador único de la categoría. |
| `nombre` | `varchar` | No | Ninguno | | Nombre de la categoría (ej. 'Platos fuertes', 'Bebidas'). |
| `descripcion` | `varchar` | Sí | Ninguno | | Descripción de la clasificación gastronómica. |

#### Tabla: `seccion`
* **Descripción:** Espacios físicos y ambientes de distribución de mesas del restaurante.
* **Clave Primaria:** `id_seccion`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_seccion` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador único de la sección del local. |
| `nombre` | `varchar` | No | Ninguno | | Nombre del sector (ej. 'Terraza', 'Salón principal'). |

#### Tabla: `caja`
* **Descripción:** Puntos de recaudo y terminales de venta habilitados en el restaurante.
* **Clave Primaria:** `id_caja`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_caja` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador único del punto de caja física. |
| `nombre` | `varchar` | No | Ninguno | | Denominación interna (ej. 'Caja principal', 'Caja barra'). |

---

### Módulo 2: Seguridad y Usuarios

#### Tabla: `usuario`
* **Descripción:** Directorio del personal del restaurante y mapeo con el servicio de autenticación.
* **Clave Primaria:** `id_usuario`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_usuario` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador numérico interno del empleado. |
| `auth_id` | `uuid` | Sí | `NULL` | `UNIQUE`, `FK (auth.users.id)` | Identificador del proveedor Auth (`ON DELETE SET NULL`). |
| `nombre` | `varchar` | No | Ninguno | | Nombre y apellido del trabajador. |
| `cedula` | `varchar` | No | Ninguno | `UNIQUE` | Documento de identidad fiscal/nacional único. |
| `telefono` | `varchar` | Sí | Ninguno | | Teléfono o móvil de contacto. |
| `correo` | `varchar` | No | Ninguno | `UNIQUE`, `CHECK` formato RFC | Correo electrónico validado por expresión regular. |
| `rol` | `varchar` | No | `'Caja'` | `CHECK (rol IN (...))` | Roles válidos: 'Administrador', 'Caja', 'Mesero', 'Cocina'. |
| `fecha_inicio` | `timestamp` | No | `CURRENT_TIMESTAMP` | | Fecha de ingreso o alta administrativa. |
| `activo` | `boolean` | No | `true` | | Bandera lógica de habilitación operativa (*Soft Delete*). |

---

### Módulo 3: Proveedores, Inventario y Fichas Técnicas

#### Tabla: `proveedor`
* **Descripción:** Entidades comerciales externas suministradoras de insumos y consumibles.
* **Clave Primaria:** `id_proveedor`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_proveedor` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador único del proveedor. |
| `documento` | `varchar` | No | Ninguno | | NIT o documento tributario del proveedor. |
| `nombre` | `varchar` | No | Ninguno | | Razón social comercial. |
| `telefono` | `varchar` | Sí | Ninguno | | Teléfono de contacto comercial. |
| `correo` | `varchar` | Sí | Ninguno | | Correo para pedidos y cotizaciones. |
| `direccion` | `varchar` | Sí | Ninguno | | Dirección de sede o bodega de entrega. |

#### Tabla: `ingrediente`
* **Descripción:** Catálogo de materias primas e insumos de producción y reventa.
* **Clave Primaria:** `id_ingrediente`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_ingrediente` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador único del ingrediente o insumo. |
| `codigo` | `varchar` | No | Ninguno | `UNIQUE` | Código de inventario (ej. 'ING-001'). |
| `nombre` | `varchar` | No | Ninguno | | Nombre del insumo (ej. 'Carne de res', 'Tomate'). |
| `id_unidad` | `integer` | No | Ninguno | `FK (unidad_medida.id_unidad)` | Unidad de medida para control de balance métrico. |
| `stock_minimo` | `numeric(10,3)` | No | `0` | | Nivel mínimo de alerta de compras. |
| `precio_referencia` | `numeric(12,2)` | No | `0` | | Costo unitario estimado para balances. |
| `stock` | `numeric(10,3)` | No | `0` | | Saldo actual calculado a partir del kárdex. |

#### Tabla: `producto`
* **Descripción:** Platos preparados, bebidas y artículos ofrecidos en la carta comercial.
* **Clave Primaria:** `id_producto`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_producto` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador único del producto en venta. |
| `codigo` | `varchar` | No | Ninguno | `UNIQUE` | Código del ítem comercial (ej. 'PRO-001'). |
| `nombre` | `varchar` | No | Ninguno | | Denominación del plato en la carta. |
| `id_categoria` | `integer` | No | Ninguno | `FK (categoria.id_categoria)` | Categoría a la que pertenece el producto. |
| `precio_venta` | `numeric(12,2)` | No | Ninguno | | Precio oficial de venta al público. |
| `descripcion` | `varchar` | Sí | Ninguno | | Notas del menú o descripción de la preparación. |

#### Tabla: `receta`
* **Descripción:** Ficha técnica de porcionamiento por plato para el costeo y deducción automática de stock.
* **Clave Primaria Compuesta:** `(id_producto, id_ingrediente)`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_producto` | `integer` | No | Ninguno | `PK`, `FK (producto.id_producto)` | Producto terminado al que se asigna la fórmula. |
| `id_ingrediente` | `integer` | No | Ninguno | `PK`, `FK (ingrediente.id_ingrediente)` | Insumo que se descarga del stock. |
| `cantidad` | `numeric(10,3)` | No | Ninguno | | Porción requerida expresada en la unidad del insumo. |

#### Tabla: `compra`
* **Descripción:** Registro de órdenes y facturas de compra de suministros recibidos de proveedores.
* **Clave Primaria:** `id_compra`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_compra` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Consecutivo de la compra realizada. |
| `id_proveedor` | `integer` | No | Ninguno | `FK (proveedor.id_proveedor)` | Proveedor adjudicatario. |
| `fecha` | `timestamp` | No | `CURRENT_TIMESTAMP` | | Fecha de expedición o ingreso del pedido. |
| `estado` | `varchar` | No | `'REGISTRADA'` | | Estado: 'REGISTRADA', 'RECIBIDA', 'ANULADA'. |
| `total` | `numeric(12,2)` | No | `0` | | Monto monetario total facturado por el proveedor. |

#### Tabla: `detalle_compra`
* **Descripción:** Renglones detallados de ítems y precios pactados en cada compra.
* **Clave Primaria:** `id_detalle_compra`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_detalle_compra` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador único de línea de compra. |
| `id_compra` | `integer` | No | Ninguno | `FK (compra.id_compra)` | Referencia a la compra cabecera (`ON DELETE CASCADE`). |
| `id_ingrediente` | `integer` | No | Ninguno | `FK (ingrediente.id_ingrediente)` | Materia prima adquirida. |
| `cantidad` | `numeric(10,3)` | No | Ninguno | | Cantidad de unidades o volumen recibido. |
| `precio_aplicado` | `numeric(12,2)` | No | Ninguno | | Costo unitario pactado para esa transacción. |

#### Tabla: `movimiento_inventario`
* **Descripción:** Kárdex de variaciones de stock (entradas por compra, salidas por cocina y ajustes).
* **Clave Primaria:** `id_movimiento`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_movimiento` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Registro consecutivo del kárdex. |
| `id_ingrediente` | `integer` | No | Ninguno | `FK (ingrediente.id_ingrediente)` | Insumo afectado en almacén. |
| `tipo` | `varchar` | No | Ninguno | `CHECK (tipo IN ('ENTRADA','SALIDA','AJUSTE'))` | Sentido del movimiento físico de stock. |
| `cantidad` | `numeric(10,3)` | No | Ninguno | | Magnitud positiva transferida o consumida. |
| `fecha` | `timestamp` | No | `CURRENT_TIMESTAMP` | | Fecha y hora exacta de la afectación de stock. |
| `motivo` | `varchar` | Sí | Ninguno | | Justificación (ej. 'Compra #1', 'Consumo de cocina'). |

---

### Módulo 4: Operaciones de Salón y Comandas

#### Tabla: `mesa`
* **Descripción:** Puestos de servicio del restaurante asignables a meseros para atención comensal.
* **Clave Primaria:** `id_mesa`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_mesa` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Identificador único de la mesa en el sistema. |
| `numero` | `integer` | No | Ninguno | `UNIQUE` | Número visual asignado a la mesa. |
| `estado` | `varchar` | No | `'Libre'` | | Estado: 'Libre', 'Ocupada', 'Por pagar'. |
| `id_seccion` | `integer` | No | Ninguno | `FK (seccion.id_seccion)` | Ubicación geográfica dentro del restaurante. |
| `id_usuario` | `integer` | Sí | `NULL` | `FK (usuario.id_usuario)` | Mesero asignado a la mesa (`NULL` si está libre). |

#### Tabla: `comanda`
* **Descripción:** Solicitud u orden de comanda remitida a preparación en cocina o barra.
* **Clave Primaria:** `id_comanda`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_comanda` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Consecutivo de la orden de comanda. |
| `id_mesa` | `integer` | Sí | `NULL` | `FK (mesa.id_mesa)` | Mesa asociada (`NULL` para comandas para llevar). |
| `id_usuario` | `integer` | No | Ninguno | `FK (usuario.id_usuario)` | Mesero que toma la orden. |
| `estado` | `varchar` | No | `'Abierto'` | | Estado: 'Abierto', 'Enviado', 'Cerrado'. |
| `observacion` | `varchar` | Sí | Ninguno | | Anotaciones de pedido (ej. 'Para llevar', 'Cumpleaños'). |
| `fecha_creacion` | `timestamp` | No | `CURRENT_TIMESTAMP` | | Marca temporal de la creación de la comanda. |

#### Tabla: `detalle_comanda`
* **Descripción:** Platos y bebidas solicitados dentro de una orden de preparación activa.
* **Clave Primaria:** `id_detalle_comanda`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_detalle_comanda` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Consecutivo de línea de orden. |
| `id_comanda` | `integer` | No | Ninguno | `FK (comanda.id_comanda)` | Comanda de pertenencia (`ON DELETE CASCADE`). |
| `id_producto` | `integer` | No | Ninguno | `FK (producto.id_producto)` | Plato o bebida solicitada. |
| `cantidad` | `numeric(10,2)` | No | `1` | | Unidades o porciones ordenadas. |
| `nota` | `varchar` | Sí | Ninguno | | Variaciones particulares de cocina (ej. 'Sin cebolla'). |

#### Tabla: `historial_mesa`
* **Descripción:** Bitácora de auditoría para supervisar transiciones de estado y tiempos de ocupación.
* **Clave Primaria:** `id_historial_mesa`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_historial_mesa` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Consecutivo del evento registrado. |
| `id_mesa` | `integer` | No | Ninguno | `FK (mesa.id_mesa)` | Mesa donde ocurrió la acción. |
| `id_comanda` | `integer` | Sí | `NULL` | `FK (comanda.id_comanda)` | Orden asociada a la mesa durante el cambio. |
| `id_usuario` | `integer` | No | Ninguno | `FK (usuario.id_usuario)` | Empleado que originó el cambio de estado. |
| `estado` | `varchar` | No | Ninguno | | Nuevo estado alcanzado ('Ocupada', 'Por pagar', 'Libre'). |
| `monto` | `numeric(12,2)` | Sí | `NULL` | | Valor cancelado registrado durante la liberación. |
| `motivo` | `varchar` | Sí | Ninguno | | Justificación operativa del evento. |
| `fecha_accion` | `timestamp` | No | `CURRENT_TIMESTAMP` | | Momento cronológico exacto de la acción. |

---

### Módulo 5: Facturación, Caja y Pagos

#### Tabla: `factura`
* **Descripción:** Documento tributario y de cobro legal entregado al comensal.
* **Clave Primaria:** `id_factura`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_factura` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Consecutivo de la factura emitida. |
| `id_mesa` | `integer` | Sí | `NULL` | `FK (mesa.id_mesa)` | Mesa liquidada (`NULL` si fue venta directa de mostrador). |
| `id_usuario` | `integer` | No | Ninguno | `FK (usuario.id_usuario)` | Cajero que liquidó y expidió la factura. |
| `fecha_emision` | `timestamp` | No | `CURRENT_TIMESTAMP` | | Fecha y hora fiscal de la venta. |
| `subtotal` | `numeric(12,2)` | No | `0` | | Valor neto de los productos consumidos. |
| `propina` | `numeric(12,2)` | No | `0` | | Propina voluntaria sugerida (típicamente 10 %). |
| `total_pagar` | `numeric(12,2)` | No | `0` | | Monto final adeudado: $\text{subtotal} + \text{propina}$. |
| `id_comanda` | `integer` | Sí | `NULL` | `FK (comanda.id_comanda)` | Identificador de comanda vinculada si corresponde. |

#### Tabla: `detalle_factura`
* **Descripción:** Renglones facturados con precio unitario congelado al instante de la venta.
* **Clave Primaria:** `id_detalle_factura`
* **Índices de Rendimiento:** `idx_detalle_factura_factura` sobre la columna `id_factura`.

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_detalle_factura` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Consecutivo único de línea de factura. |
| `id_factura` | `integer` | No | Ninguno | `FK (factura.id_factura)` | Factura a la que pertenece (`ON DELETE CASCADE`). |
| `id_producto` | `integer` | No | Ninguno | `FK (producto.id_producto)` | Producto liquidado. |
| `cantidad` | `numeric(10,2)` | No | `1` | | Unidades despachadas en la venta. |
| `precio_unitario` | `numeric(12,2)` | No | Ninguno | | Precio congelado a la fecha de emisión. |
| `subtotal` | `numeric(12,2)` | No | Ninguno | | Importe de línea: $\text{cantidad} \times \text{precio\_unitario}$. |

#### Tabla: `turno_caja`
* **Descripción:** Sesiones operativas de caja para el control de efectivo y arqueos de cuadre.
* **Clave Primaria:** `id_turno_caja`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_turno_caja` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Consecutivo de sesión de turno. |
| `id_caja` | `integer` | No | Ninguno | `FK (caja.id_caja)` | Estación física de recaudación asignada. |
| `id_usuario_apertura` | `integer` | No | Ninguno | `FK (usuario.id_usuario)` | Cajero que inicia la sesión y custodia el fondo. |
| `id_usuario_cierre` | `integer` | Sí | `NULL` | `FK (usuario.id_usuario)` | Cajero o supervisor que efectúa el arqueo de cierre. |
| `fecha_apertura` | `timestamp` | No | `CURRENT_TIMESTAMP` | | Fecha y hora de apertura de caja. |
| `fecha_cierre` | `timestamp` | Sí | `NULL` | | Fecha y hora del cierre de caja (`NULL` si está abierta). |
| `monto_inicial` | `numeric(12,2)` | No | `0` | | Fondo de sencillo o base inicial de efectivo. |
| `monto_final` | `numeric(12,2)` | Sí | `NULL` | | Total recaudado según arqueo físico al cierre. |
| `estado` | `varchar` | No | `'Abierto'` | | Estado operativo: 'Abierto' o 'Cerrado'. |

#### Tabla: `historial_caja`
* **Descripción:** Libro de caja para registrar individualmente cada ingreso o egreso de dinero.
* **Clave Primaria:** `id_historial_caja`

| Columna | Tipo de Dato | Nulo | Valor por Defecto | Restricciones / Claves | Descripción |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id_historial_caja` | `integer` | No | Generado por identidad | `PRIMARY KEY` | Consecutivo único del asiento de dinero. |
| `id_turno_caja` | `integer` | No | Ninguno | `FK (turno_caja.id_turno_caja)` | Sesión de turno contable receptora del flujo. |
| `id_usuario` | `integer` | No | Ninguno | `FK (usuario.id_usuario)` | Cajero que operó la transacción. |
| `id_factura` | `integer` | Sí | `NULL` | `FK (factura.id_factura)` | Factura de origen si el ingreso fue por venta de carta. |
| `metodo_pago` | `varchar` | No | Ninguno | | Medio de pago: 'Efectivo', 'Tarjeta', 'Transferencia'. |
| `tipo_pago` | `varchar` | No | Ninguno | | Naturaleza contable: 'Ingreso' o 'Egreso'. |
| `monto` | `numeric(12,2)` | No | Ninguno | | Monto total procesado en el pago. |
| `descripcion` | `varchar` | Sí | Ninguno | | Concepto explicativo (ej. 'Pago factura 1', 'Compra hielo'). |
| `fecha_movimiento` | `timestamp` | No | `CURRENT_TIMESTAMP` | | Marca de tiempo del movimiento de caja. |