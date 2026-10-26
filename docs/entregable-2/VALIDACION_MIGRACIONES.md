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

## Pruebas ejecutadas

Ejecuté las pruebas en una instancia local temporal de PostgreSQL 17.6, usando los archivos de la entrega. La instancia se detuvo al terminar; no se modificó el proyecto de Supabase.

| Caso | Resultado |
|---|---|
| Migraciones 001–008 en una base vacía, seguidas de la semilla | Terminaron sin errores y crearon 20 tablas públicas. |
| Migración 005 y consulta de las vistas con la semilla | Las vistas devolvieron 4 ingredientes bajo mínimo y 10 combinaciones de ventas por día y categoría. |
| Migración 006 sin esquema `auth` | Terminó sin error y omitió la FK, como estaba previsto. |
| Migraciones 001–006 con `auth.users` de prueba vacío | La migración creó `usuario_auth_id_fkey`; PostgreSQL la reportó validada. Esta prueba confirma la creación condicional, no la compatibilidad de UUID de usuarios ya cargados. |
| `consultas/auditoria_derivados.sql` | Las tres consultas terminaron sin errores y no devolvieron filas discrepantes. |
| Vista candidata de Entrega 3 | El SQL se ejecutó en la instancia temporal y devolvió 6 filas agregadas. |

El documento de implementación del grupo también consigna una reconstrucción exitosa en PostgreSQL 16.15. La ejecución que realicé aquí fue en PostgreSQL 17.6; no la presento como una prueba hecha en 16.15 ni en Supabase.

La auditoría de derivados reportó cero filas con la semilla. Para E2 y E5, el SQL compartido usa `JOIN` interno y no incluye compras o facturas que carezcan de líneas; se deja indicada esa limitación en la auditoría de normalización.

## Vista candidata para la Entrega 3

Se propone `v_ventas_mensuales_producto`, definida en `sql/vista_propuesta_entrega_3.sql`. Resume unidades e ingresos por mes, producto y categoría sin exponer datos personales. Está presentada como propuesta para evaluación; no es una migración 009 ni se aplica al crear este archivo.
