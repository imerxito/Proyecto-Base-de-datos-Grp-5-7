#Esquema relacional mapeado, con claves y políticas de borrado
Mapeo del modelo EER al esquema relacional

El modelo conceptual de **Sabor & Stock** define nueve entidades:

* Proveedor
* Categoría
* UnidadMedida
* Ingrediente
* Producto
* Receta
* Compra
* DetalleCompra
* MovimientoInventario

Cada entidad se traduce en una tabla; las relaciones **1:N** se resuelven agregando la clave foránea en la tabla del lado **"muchos"**, y las relaciones **N:M** (Producto–Ingrediente y Compra–Ingrediente) se resuelven creando una tabla intermedia con clave primaria compuesta.

| Relación del EER                   | Cardinalidad | Mapeo relacional                                 |
| ---------------------------------- | ------------ | ------------------------------------------------ |
| Proveedor — Compra                 | 1:N          | FK `id_proveedor` en `compra`                    |
| UnidadMedida — Ingrediente         | 1:N          | FK `id_unidad` en `ingrediente`                  |
| Categoría — Producto               | 1:N          | FK `id_categoria` en `producto`                  |
| Ingrediente — MovimientoInventario | 1:N          | FK `id_ingrediente` en `movimiento_inventario`   |
| Producto — Ingrediente             | N:M          | Tabla intermedia `receta` (PK compuesta)         |
| Compra — Ingrediente               | N:M          | Tabla intermedia `detalle_compra` (PK compuesta) |

---

Claves: primarias y foráneas

Claves primarias (PK)

Cada tabla tiene un identificador único que garantiza que ninguna fila se repita. En las seis tablas base se usa una clave primaria simple autonumérica (`SERIAL`); en las tablas de detalle (`receta` y `detalle_compra`) se usa una clave primaria compuesta, formada por las dos claves foráneas que participan en la relación N:M.

* **Simples:** `id_unidad`, `id_categoria`, `id_proveedor`, `id_ingrediente`, `id_producto`, `id_compra`, `id_movimiento`.
* **Compuestas:**

  * (`id_producto`, `id_ingrediente`) en `receta`.
  * (`id_compra`, `id_ingrediente`) en `detalle_compra`.

Claves foráneas (FK) e integridad referencial

Toda clave foránea apunta a la clave primaria de otra tabla y garantiza que no puedan existir referencias a registros inexistentes (**integridad referencial**).

En este esquema todas las FK son `NOT NULL`, es decir, la relación es obligatoria: una compra siempre requiere un proveedor, un ingrediente siempre requiere una unidad de medida, etc.

| Tabla (hijo)            | Columna FK       | Referencia (padre)            | Obligatoria     |
| ----------------------- | ---------------- | ----------------------------- | --------------- |
| `ingrediente`           | `id_unidad`      | `unidad_medida(id_unidad)`    | Sí (`NOT NULL`) |
| `producto`              | `id_categoria`   | `categoria(id_categoria)`     | Sí (`NOT NULL`) |
| `compra`                | `id_proveedor`   | `proveedor(id_proveedor)`     | Sí (`NOT NULL`) |
| `detalle_compra`        | `id_compra`      | `compra(id_compra)`           | Sí (`NOT NULL`) |
| `detalle_compra`        | `id_ingrediente` | `ingrediente(id_ingrediente)` | Sí (`NOT NULL`) |
| `receta`                | `id_producto`    | `producto(id_producto)`       | Sí (`NOT NULL`) |
| `receta`                | `id_ingrediente` | `ingrediente(id_ingrediente)` | Sí (`NOT NULL`) |
| `movimiento_inventario` | `id_ingrediente` | `ingrediente(id_ingrediente)` | Sí (`NOT NULL`) |

#Políticas de borrado (ON DELETE)

Definir una FK no basta: también hay que decidir qué ocurre con las filas hijas cuando se intenta borrar la fila padre que referencian. Esa decisión se declara con ON DELETE y se conoce como *política o acción referencial*.

##Política adoptada en este esquema

*Sabor & Stock aplica ON DELETE RESTRICT en todas sus relaciones.*

La razón de negocio es que el restaurante necesita conservar el historial completo de compras, recetas y movimientos de inventario para auditoría, costeo y trazabilidad: ningún proveedor, ingrediente, categoría, unidad de medida, producto o compra debe poder eliminarse mientras existan registros que dependan de él.

Las bajas reales se resuelven con *desactivación lógica* (por ejemplo, un futuro atributo activo en catálogos), nunca con DELETE físico sobre un padre referenciado.

| Relación (padre → hijo)                 | Política | Efecto al intentar DELETE del padre                                 |
| --------------------------------------- | -------- | ------------------------------------------------------------------- |
| unidad_medida → ingrediente         | RESTRICT | Bloquea el borrado si existen ingredientes con esa unidad.          |
| categoria → producto                | RESTRICT | Bloquea el borrado si existen productos en esa categoría.           |
| proveedor → compra                  | RESTRICT | Bloquea el borrado si el proveedor tiene compras registradas.       |
| ingrediente → receta                | RESTRICT | Bloquea el borrado si el ingrediente se usa en alguna receta.       |
| ingrediente → detalle_compra        | RESTRICT | Bloquea el borrado si el ingrediente aparece en alguna compra.      |
| ingrediente → movimiento_inventario | RESTRICT | Bloquea el borrado si el ingrediente tiene movimientos registrados. |
| producto → receta                   | RESTRICT | Bloquea el borrado si el producto tiene una receta definida.        |
| compra → detalle_compra             | RESTRICT | Bloquea el borrado si la compra tiene líneas de detalle.            |
