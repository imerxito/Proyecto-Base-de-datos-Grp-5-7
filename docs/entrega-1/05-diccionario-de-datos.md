# DICCIONARIO DE DATOS DE USO INICIAL

## Sistema de Gestión de Inventario — Restaurante Sabor & Stock

### 1. Tabla: unidad_medida

| Campo       | Tipo de dato | Restricción      | Clave | Descripción                                                 |
| ----------- | ------------ | ---------------- | ----- | ----------------------------------------------------------- |
| id_unidad   | SERIAL       | NOT NULL         | PK    | Identificador único de la unidad de medida.                 |
| nombre      | VARCHAR(50)  | NOT NULL, UNIQUE | UQ    | Nombre de la unidad de medida.                              |
| abreviatura | VARCHAR(10)  | NOT NULL, UNIQUE | UQ    | Abreviatura utilizada para representar la unidad de medida. |
| descripcion | VARCHAR(150) | —                | —     | Descripción adicional de la unidad de medida.               |

---

### 2. Tabla: categoria

| Campo        | Tipo de dato | Restricción      | Clave | Descripción                                               |
| ------------ | ------------ | ---------------- | ----- | --------------------------------------------------------- |
| id_categoria | SERIAL       | NOT NULL         | PK    | Identificador único de la categoría.                      |
| nombre       | VARCHAR(80)  | NOT NULL, UNIQUE | UQ    | Nombre de la categoría a la que pertenecen los productos. |
| descripcion  | VARCHAR(200) | —                | —     | Información adicional sobre la categoría.                 |

---

### 3. Tabla: proveedor

| Campo        | Tipo de dato | Restricción      | Clave | Descripción                                      |
| ------------ | ------------ | ---------------- | ----- | ------------------------------------------------ |
| id_proveedor | SERIAL       | NOT NULL         | PK    | Identificador único del proveedor.               |
| documento    | VARCHAR(30)  | NOT NULL, UNIQUE | UQ    | Número de documento que identifica al proveedor. |
| nombre       | VARCHAR(120) | NOT NULL         | —     | Nombre del proveedor.                            |
| telefono     | VARCHAR(30)  | —                | —     | Número telefónico de contacto del proveedor.     |
| correo       | VARCHAR(120) | —                | —     | Correo electrónico de contacto del proveedor.    |
| direccion    | VARCHAR(180) | —                | —     | Dirección registrada del proveedor.              |

---

### 4. Tabla: ingrediente

| Campo             | Tipo de dato  | Restricción                    | Clave | Descripción                                                        |
| ----------------- | ------------- | ------------------------------ | ----- | ------------------------------------------------------------------ |
| id_ingrediente    | SERIAL        | NOT NULL                       | PK    | Identificador único del ingrediente.                               |
| codigo            | VARCHAR(30)   | NOT NULL, UNIQUE               | UQ    | Código único utilizado para identificar el ingrediente.            |
| nombre            | VARCHAR(120)  | NOT NULL                       | —     | Nombre del ingrediente.                                            |
| id_unidad         | INT           | NOT NULL                       | FK    | Identificador de la unidad de medida utilizada por el ingrediente. |
| stock             | NUMERIC(12,2) | NOT NULL, CHECK ≥ 0, DEFAULT 0 | —     | Cantidad disponible del ingrediente en inventario.                 |
| stock_minimo      | NUMERIC(12,2) | NOT NULL, CHECK ≥ 0, DEFAULT 0 | —     | Cantidad mínima de existencia establecida para el ingrediente.     |
| precio_referencia | NUMERIC(12,2) | NOT NULL, CHECK ≥ 0, DEFAULT 0 | —     | Precio de referencia utilizado para el ingrediente.                |

---

### 5. Tabla: producto

| Campo        | Tipo de dato  | Restricción         | Clave | Descripción                                                   |
| ------------ | ------------- | ------------------- | ----- | ------------------------------------------------------------- |
| id_producto  | SERIAL        | NOT NULL            | PK    | Identificador único del producto.                             |
| codigo       | VARCHAR(30)   | NOT NULL, UNIQUE    | UQ    | Código único utilizado para identificar el producto.          |
| nombre       | VARCHAR(120)  | NOT NULL            | —     | Nombre del producto.                                          |
| id_categoria | INT           | NOT NULL            | FK    | Identificador de la categoría a la que pertenece el producto. |
| precio_venta | NUMERIC(12,2) | NOT NULL, CHECK ≥ 0 | —     | Precio establecido para la venta del producto.                |
| descripcion  | VARCHAR(250)  | —                   | —     | Descripción del producto.                                     |

---

### 6. Tabla: receta

| Campo          | Tipo de dato  | Restricción         | Clave   | Descripción                                                          |
| -------------- | ------------- | ------------------- | ------- | -------------------------------------------------------------------- |
| id_producto    | INT           | NOT NULL            | PK / FK | Identificador del producto que utiliza la receta.                    |
| id_ingrediente | INT           | NOT NULL            | PK / FK | Identificador del ingrediente utilizado en la receta.                |
| cantidad       | NUMERIC(12,3) | NOT NULL, CHECK > 0 | —       | Cantidad del ingrediente necesaria para la elaboración del producto. |

**Clave primaria:** `(id_producto, id_ingrediente)`.

---

### 7. Tabla: compra

| Campo        | Tipo de dato  | Restricción                                                              | Clave | Descripción                                              |
| ------------ | ------------- | ------------------------------------------------------------------------ | ----- | -------------------------------------------------------- |
| id_compra    | SERIAL        | NOT NULL                                                                 | PK    | Identificador único de la compra.                        |
| id_proveedor | INT           | NOT NULL                                                                 | FK    | Identificador del proveedor al que se realiza la compra. |
| fecha        | TIMESTAMP     | NOT NULL, DEFAULT CURRENT_TIMESTAMP                                      | —     | Fecha y hora en que se registra la compra.               |
| estado       | VARCHAR(20)   | NOT NULL, CHECK IN (REGISTRADA, RECIBIDA, ANULADA), DEFAULT 'REGISTRADA' | —     | Estado actual de la compra.                              |
| total        | NUMERIC(12,2) | NOT NULL, CHECK ≥ 0, DEFAULT 0                                           | —     | Valor total de la compra.                                |

---

### 8. Tabla: detalle_compra

| Campo           | Tipo de dato  | Restricción         | Clave   | Descripción                                               |
| --------------- | ------------- | ------------------- | ------- | --------------------------------------------------------- |
| id_compra       | INT           | NOT NULL            | PK / FK | Identificador de la compra a la que pertenece el detalle. |
| id_ingrediente  | INT           | NOT NULL            | PK / FK | Identificador del ingrediente adquirido.                  |
| cantidad        | NUMERIC(12,3) | NOT NULL, CHECK > 0 | —       | Cantidad del ingrediente incluida en la compra.           |
| precio_aplicado | NUMERIC(12,2) | NOT NULL, CHECK ≥ 0 | —       | Precio aplicado al ingrediente en esa compra.             |

**Clave primaria:** `(id_compra, id_ingrediente)`.

---

### 9. Tabla: movimiento_inventario

| Campo          | Tipo de dato  | Restricción                                  | Clave | Descripción                                                  |
| -------------- | ------------- | -------------------------------------------- | ----- | ------------------------------------------------------------ |
| id_movimiento  | SERIAL        | NOT NULL                                     | PK    | Identificador único del movimiento de inventario.            |
| id_ingrediente | INT           | NOT NULL                                     | FK    | Identificador del ingrediente relacionado con el movimiento. |
| tipo           | VARCHAR(10)   | NOT NULL, CHECK IN (ENTRADA, SALIDA, AJUSTE) | —     | Tipo de movimiento realizado sobre el inventario.            |
| cantidad       | NUMERIC(12,3) | NOT NULL, CHECK > 0                          | —     | Cantidad de unidades involucradas en el movimiento.          |
| fecha          | TIMESTAMP     | NOT NULL, DEFAULT CURRENT_TIMESTAMP          | —     | Fecha y hora en que se registra el movimiento.               |
| motivo         | VARCHAR(200)  | NOT NULL                                     | —     | Razón por la cual se realiza el movimiento.                  |
| referencia     | VARCHAR(80)   | —                                            | —     | Referencia asociada al movimiento de inventario.             |

---

## Resumen del diccionario

El diccionario de datos de uso inicial está compuesto por **9 tablas**:

1. `unidad_medida`
2. `categoria`
3. `proveedor`
4. `ingrediente`
5. `producto`
6. `receta`
7. `compra`
8. `detalle_compra`
9. `movimiento_inventario`

El contenido corresponde al esquema relacional presentado en el punto 3 del documento, donde se especifican las columnas, tipos de datos, restricciones y claves de cada tabla.

Las tablas `receta` y `detalle_compra` utilizan claves primarias compuestas formadas por dos claves foráneas.
