# Pull Request — Aporte de Ángel Vargas

## 1. Resumen

Este Pull Request contiene el aporte correspondiente a **Ángel Vargas** para la Entrega 2 del proyecto **Sabor & Stock**.

El trabajo se concentra principalmente en:

- Correcciones estructurales del modelo relacional.
- Migraciones SQL para actualizar el esquema.
- Optimización mediante índices.
- Correcciones de la relación entre `factura`, `comanda` y `mesa`.
- Integración opcional con Supabase Auth.
- Creación de vistas para consultas de información.
- Documentación del diccionario de datos.
- Documentación y evidencia del caso de uso de índices.

El objetivo general es que la base de datos tenga una estructura más consistente, con mejores restricciones de integridad y con optimizaciones para consultas frecuentes.

***

# 2. Archivos incluidos en este aporte

|Archivo|Función|
|---|---|
|`DICCIONARIO_ANGEL_VARGAS.md`|Documentación de tablas, campos y significado de los datos|
|`INDICES_ANGEL_VARGAS.md`|Justificación y documentación del trabajo de índices|
|`caso_indice.sql`|Prueba mediante `EXPLAIN (ANALYZE, BUFFERS)`|
|`resultado_caso_indice.txt`|Plantilla para registrar la evidencia real de ejecución|
|`README_PR_ANGEL.md`|Explicación general del aporte|
|`supabase/README.md`|Orden y explicación de aplicación de las migraciones|
|`supabase/migrations/008_correcciones_factura.sql`|Correcciones A5 y A6|
|`supabase/vinculo_auth_usuarios.sql`|Vinculación opcional con `auth.users` de Supabase|
|`supabase/vistas_supabase.sql`|Creación de vistas para consultas y reportes|

***

# 3. Entidades y estructura involucrada

El aporte trabaja principalmente sobre las entidades relacionadas con la operación del restaurante.

|Entidad|Función|
|---|---|
|`usuario`|Representa a los usuarios del sistema|
|`caja`|Representa las cajas utilizadas para las operaciones|
|`mesa`|Representa las mesas del restaurante|
|`comanda`|Representa una orden realizada|
|`detalle_comanda`|Representa los productos incluidos en una comanda|
|`factura`|Representa el documento de cobro|
|`detalle_factura`|Representa las líneas de una factura|
|`receta`|Relaciona productos con ingredientes|
|`compra`|Representa compras realizadas|
|`detalle_compra`|Detalla los productos/ingredientes comprados|
|`movimiento_inventario`|Registra movimientos de inventario|
|`historial` / entidades históricas|Permiten conservar información relacionada con operaciones anteriores|

La documentación existente advierte que la versión del repositorio utiliza nombres como `mesas`, `comandas`, `comanda_detalles` e `historiales`, mientras que algunos documentos de planificación utilizan `mesa`, `comanda`, `detalle_comanda` e `historial_mesa`. Por esto, no se realizaron renombramientos automáticos para evitar sustituir objetos de una versión del modelo por otra.

***

# 4. Migración 004 — Índices para claves foráneas

## Objetivo

La migración `004` forma parte del trabajo de optimización de la base de datos.

Su objetivo es crear índices sobre claves foráneas que son utilizadas frecuentemente en búsquedas, filtros y operaciones de JOIN.

La razón es que una clave foránea garantiza la integridad referencial, pero **no significa automáticamente que todas las consultas sobre ella estén optimizadas**.

Un índice permite reducir la cantidad de registros que PostgreSQL necesita revisar cuando una consulta utiliza determinada columna.

## Razonamiento

Supongamos una relación:

```text
comanda
   |
   | 1:N
   v
detalle_comanda
```

La tabla de detalles contiene una columna que identifica la comanda:

```text
detalle_comanda.comanda_id
```

Cuando se consulta:

```sql
SELECT *
FROM public.comanda_detalles
WHERE comanda_id = ...;
```

un índice sobre la columna utilizada para la relación puede permitir que PostgreSQL encuentre los registros correspondientes de una manera más eficiente.

## Beneficio

|Sin una estrategia adecuada de índices|Con índice|
|---|---|
|PostgreSQL puede revisar muchos registros|Puede localizar los registros mediante el índice|
|Mayor costo en tablas grandes|Menor costo potencial|
|JOINs y filtros pueden ser más pesados|JOINs y filtros frecuentes pueden mejorar|
|El rendimiento depende más de recorridos completos|El planificador puede utilizar `Index Scan`|

### Importante

La documentación de esta rama indica que el ZIP revisado no contenía la migración `004` original, por lo que **no se afirma una definición SQL exacta de `004` que no pueda verificarse**. Lo que sí está documentado es que `004` corresponde a la creación de índices para claves foráneas utilizadas en consultas frecuentes.

***

# 5. Migración 008 — Correcciones de `factura`

La migración:

```text
supabase/migrations/008_correcciones_factura.sql
```

implementa las correcciones **A5 y A6** de la Entrega 2.

## A5 — Relación `factura → comanda`

Se agrega a `factura`:

```sql
ALTER TABLE public.factura
    ADD COLUMN IF NOT EXISTS id_comanda integer;
```

La finalidad es registrar qué comanda fue cobrada mediante determinada factura.

La relación queda conceptualmente:

```text
COMANDA
   |
   | 1 : 0..1
   v
FACTURA
```

Esto permite relacionar directamente la operación realizada con su documento de cobro.

### Clave foránea

La migración crea:

```sql
FOREIGN KEY (id_comanda)
REFERENCES public.comanda(id_comanda)
ON DELETE RESTRICT
```

Esto significa que una comanda utilizada por una factura no puede eliminarse libremente mientras exista esa referencia.

La decisión de utilizar `RESTRICT` protege la trazabilidad de las operaciones de facturación.

***

# 6. Restricción de una factura por comanda

La migración también crea:

```sql
CREATE UNIQUE INDEX IF NOT EXISTS uq_factura_id_comanda
    ON public.factura(id_comanda)
    WHERE id_comanda IS NOT NULL;
```

Esto implementa la regla:

> Una misma comanda no debe tener más de una factura asociada.

El índice es **parcial**, porque solamente considera los registros donde:

```sql
id_comanda IS NOT NULL
```

Esto permite que existan facturas que todavía no tengan una comanda asociada.

|Situación|Permitida|
|---|---|
|Factura con `id_comanda = 10`|Sí|
|Otra factura con `id_comanda = 10`|No|
|Factura con `id_comanda = 11`|Sí|
|Varias facturas con `id_comanda = NULL`|Sí|

Esta solución permite aplicar la regla de unicidad sin impedir los casos donde la factura no está asociada a una comanda.

***

# 7. A6 — `id_mesa` como campo opcional

La migración también modifica:

```sql
ALTER TABLE public.factura
    ALTER COLUMN id_mesa DROP NOT NULL;
```

La razón es que no todas las ventas necesariamente corresponden a una mesa.

Por ejemplo:

```text
Venta en mesa
    ↓
factura.id_mesa = mesa correspondiente
```

pero:

```text
Pedido para llevar / venta directa
    ↓
factura.id_mesa = NULL
```

Por esta razón, `id_mesa` deja de ser obligatorio.

## Regla resultante

|Tipo de venta|`id_mesa`|
|---|---|
|Consumo en mesa|Puede contener una mesa|
|Pedido para llevar|Puede ser `NULL`|
|Venta directa|Puede ser `NULL`|

Esto hace que el modelo represente mejor las operaciones reales del restaurante.

***

# 8. Resumen de la migración 008

|Cambio|Implementación|Razón|
|---|---|---|
|A5|Se agrega `factura.id_comanda`|Relacionar la factura con la comanda cobrada|
|A5|FK hacia `comanda`|Garantizar integridad referencial|
|A5|`ON DELETE RESTRICT`|Evitar eliminar una comanda facturada|
|A5|Índice único parcial|Evitar dos facturas para la misma comanda|
|A6|`factura.id_mesa` permite `NULL`|Soportar ventas sin mesa|

La migración utiliza además comprobaciones mediante `IF NOT EXISTS` y bloques `DO $$ ... $$` para evitar crear nuevamente restricciones que ya existan.

Esto hace que la migración sea más segura al aplicarse sobre una base que ya posee parte de la estructura.

***

# 9. Integridad referencial

Uno de los criterios principales del aporte es evitar inconsistencias entre entidades relacionadas.

La estructura principal queda:

```text
MESA
  │
  └──── COMANDA
            │
            ├──── DETALLE_COMANDA
            │
            └──── FACTURA
```

La factura puede identificar la comanda que está cobrando:

```text
factura.id_comanda
        │
        ▼
comanda.id_comanda
```

Y la factura puede tener o no una mesa:

```text
factura.id_mesa
        │
        ▼
mesa.id_mesa
```

Esto permite representar tanto ventas en mesa como ventas sin mesa.

***

# 10. Vinculación con Supabase Auth

También se incluye:

```text
supabase/vinculo_auth_usuarios.sql
```

Este archivo maneja la vinculación opcional:

```text
usuario.auth_id
      │
      ▼
auth.users(id)
```

La relación con `auth.users` se mantiene separada de las migraciones principales para que la integración específica de Supabase sea opcional.

Esto permite diferenciar:

```text
Modelo relacional de Sabor & Stock
              +
      Autenticación Supabase
```

sin hacer que el esquema principal dependa obligatoriamente del sistema de autenticación.

***

# 11. Vistas de Supabase

También se incluye:

```text
supabase/vistas_supabase.sql
```

Este archivo crea vistas orientadas a consultas y reportes.

Entre ellas:

|Vista|Propósito|
|---|---|
|`v_ingredientes_bajo_minimo`|Identificar ingredientes cuyo stock está por debajo del mínimo|
|`v_ventas_diarias_categoria`|Consultar ventas diarias agrupadas por categoría|
|`v_rotacion_mensual_producto`|Consultar la rotación mensual de productos|

Las vistas utilizan:

```sql
security_invoker = true
```

y además se revoca el acceso de lectura para:

```text
anon
authenticated
```

según la configuración documentada.

La intención es que las vistas sirvan como capa de consulta sin exponer automáticamente su contenido a todos los roles de Supabase.

***

# 12. Caso de índices y evidencia

El archivo:

```text
caso_indice.sql
```

contiene una prueba mediante:

```sql
EXPLAIN (ANALYZE, BUFFERS)
```

La prueba busca comprobar el comportamiento del acceso a datos y determinar qué plan utiliza PostgreSQL.

El script contempla dos posibles estructuras:

```text
detalle_factura
```

o, como alternativa para el esquema actualmente disponible:

```text
comanda_detalles
```

La segunda prueba está documentada expresamente como alternativa y **no sustituye la evidencia específica del índice de la migración 007**.

***

# 13. Evidencia de rendimiento

La documentación de la Entrega 2 registra históricamente el siguiente caso para `idx_detalle_factura_factura`:

|Escenario|Plan|Tiempo|Páginas|
|---|---|---:|---:|
|Antes|Seq Scan|19,758 ms|883|
|Después|Index Scan|0,154 ms|6|

La tabla utilizada en ese ejemplo tenía aproximadamente:

```text
120.014 líneas
```

Estos valores se incluyen únicamente como **resultados históricos documentados**. No se presentan como una nueva ejecución realizada en este Pull Request.

***

# 14. Evidencia y reproducibilidad

El archivo:

```text
resultado_caso_indice.txt
```

contiene los campos necesarios para documentar una ejecución real:

- Fecha.
- Entorno.
- Versión de PostgreSQL.
- Tabla consultada.
- Cantidad aproximada de filas.
- Índice comprobado.
- Comando utilizado.
- Salida completa de `EXPLAIN (ANALYZE, BUFFERS)`.
- Plan observado.
- Tiempo de ejecución.
- Bloques leídos.
- Confirmación de utilización del índice.

La plantilla deja explícito que la salida real debe pegarse sin modificar los tiempos ni el plan obtenido.

***

# 15. Principios utilizados en el diseño

El aporte busca mantener principalmente:

### Integridad

Las relaciones entre las entidades se protegen mediante claves foráneas y restricciones.

### Consistencia

Se evita que una factura pueda apuntar a una comanda inexistente o que una misma comanda tenga varias facturas asociadas.

### Flexibilidad

`factura.id_mesa` puede ser `NULL` para representar operaciones que no ocurren en una mesa.

### Rendimiento

Se utilizan índices para mejorar operaciones frecuentes sobre claves foráneas y filtros.

### Trazabilidad

La relación entre `comanda` y `factura` permite identificar qué operación terminó siendo cobrada.

### Compatibilidad

Las migraciones se diseñan para aplicarse sobre una estructura existente sin eliminar datos de negocio.

***

# 16. Relación entre las migraciones

El flujo conceptual del trabajo es:

```text
Migraciones iniciales
        │
        ▼
Estructura base
        │
        ├── 004 → Optimización mediante índices
        │
        ├── 006 → Vinculación opcional con Supabase Auth
        │
        ├── 007 → Índices específicos adicionales
        │
        └── 008 → Correcciones de factura
                    │
                    ├── A5: factura → comanda
                    │
                    └── A6: factura → mesa opcional
        │
        ▼
Vistas de Supabase
        │
        ├── Ingredientes bajo mínimo
        ├── Ventas por categoría
        └── Rotación mensual
```

***

# 17. Justificación general

El aporte de Ángel Vargas se enfoca en que la base de datos no solamente almacene información, sino que también mantenga reglas de negocio e integridad.

La migración `008` corrige una debilidad del modelo al establecer una relación explícita entre la factura y la comanda:

```text
COMANDA → FACTURA
```

y evita duplicar facturas para una misma comanda.

Al mismo tiempo, permite representar correctamente las ventas que no están asociadas a una mesa.

La parte de índices busca mejorar el rendimiento de las consultas que utilizan claves foráneas y relaciones frecuentes.

Finalmente, las vistas y la integración opcional con Supabase permiten utilizar el modelo dentro de un entorno de aplicación sin mezclar obligatoriamente las reglas del modelo relacional con las funcionalidades externas de autenticación.

***

# 18. Resultado esperado

Con este aporte, la Entrega 2 incorpora:

|Área|Resultado|
|---|---|
|Modelo relacional|Correcciones de relaciones|
|Facturación|Relación `factura → comanda`|
|Integridad|FK y restricciones|
|Unicidad|Una factura por comanda|
|Ventas|Soporte para ventas sin mesa|
|Rendimiento|Índices sobre relaciones frecuentes|
|Supabase|Integración opcional con Auth|
|Reportes|Vistas SQL|
|Documentación|Diccionario y justificación|
|Evidencia|Script reproducible con `EXPLAIN`|

## Conclusión

El aporte de **Ángel Vargas** complementa el modelo de Sabor & Stock mediante correcciones de integridad, optimización de consultas, soporte para los diferentes tipos de venta y herramientas de consulta para Supabase.

La migración `008` constituye la parte principal de las correcciones funcionales, mientras que el trabajo de índices asociado a `004` y `007` se orienta al rendimiento.

La estructura queda documentada para que las modificaciones puedan ser entendidas, aplicadas y posteriormente verificadas mediante pruebas reproducibles.
