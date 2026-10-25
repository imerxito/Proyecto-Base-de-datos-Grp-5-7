# Revisión de las migraciones 005 y 006

## Migración 005 — vistas de negocio

La migración `005_vistas.sql` crea dos vistas:

| Vista | Resultado esperado |
|---|---|
| `public.v_ingredientes_bajo_minimo` | Ingredientes activos con `stock < stock_minimo`; calcula el faltante y muestra la abreviatura de la unidad. |
| `public.v_ventas_diarias_categoria` | Unidades e importe vendido por día y categoría, calculados desde facturas, detalles y productos. No selecciona columnas personales. |

La definición depende de las tablas y columnas del esquema de la entrega (`ingrediente`, `unidad_medida`, `factura`, `detalle_factura`, `producto` y `categoria`). La segunda vista agrupa por día y categoría. La migración no crea tablas ni modifica filas.

La migración no especifica permisos ni `security_invoker` para las vistas. Antes de exponerlas mediante la aplicación, se deben revisar los privilegios efectivos y el comportamiento de seguridad esperado para los roles usados por el proyecto.

## Migración 006 — vínculo opcional con Supabase Auth

`006_supabase_opcional.sql` no crea la columna `auth_id`: presupone que `public.usuario.auth_id` ya existe, como la define la migración 001. En un PostgreSQL sin `auth.users`, registra un aviso y omite la clave foránea. Cuando `auth.users` existe y aún no está creada `usuario_auth_id_fkey`, agrega esa FK hacia `auth.users(id)`.

Para que la FK pueda validarse, cada valor ya almacenado en `usuario.auth_id` debe existir en `auth.users`. La migración no crea cuentas ni transforma identificadores. La tabla `usuario` debe existir antes de ejecutarla.

## Resultado de la verificación documentada

La sección 10 del documento de implementación registra que la reconstrucción de las migraciones 001–008 terminó sin errores en PostgreSQL 16.15 y que también se probó la variante con un esquema `auth` simulado, donde se creó la FK. Esto es el resultado consignado por el grupo en la entrega; esta nota describe la revisión de las definiciones 005 y 006 y no afirma una ejecución nueva contra Supabase.

## Vista candidata para la Entrega 3

Se propone `v_ventas_mensuales_producto`, definida en `sql/vista_propuesta_entrega_3.sql`. Resume unidades e ingresos por mes, producto y categoría sin exponer datos personales. Está presentada como propuesta para evaluación; no es una migración 009 ni se aplica al crear este archivo.
