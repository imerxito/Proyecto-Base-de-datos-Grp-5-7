# Revisión de las migraciones 005, 006 y 009

## Migración 005 — vistas de negocio

La migración `005_vistas.sql` crea dos vistas:

| Vista | Resultado esperado |
|---|---|
| `public.v_ingredientes_bajo_minimo` | Ingredientes activos con `stock < stock_minimo`; calcula el faltante y muestra la abreviatura de la unidad. |
| `public.v_ventas_diarias_categoria` | Unidades e importe vendido por día y categoría, calculados desde facturas, detalles y productos. No selecciona columnas personales. |

La definición depende de las tablas y columnas del esquema (`ingrediente`, `unidad_medida`, `factura`, `detalle_factura`, `producto` y `categoria`). La segunda vista agrupa por día y categoría. La migración no crea tablas ni modifica filas.

La migración no especifica permisos ni `security_invoker` para las vistas. Antes de exponerlas mediante la aplicación, se deben revisar los privilegios efectivos y el comportamiento de seguridad esperado para los roles usados por el proyecto.

## Migraciones 006 y 009 — vínculo opcional con Supabase Auth

`006_supabase_opcional.sql` presupone que `public.usuario.auth_id` existe, como la define la migración 001. En PostgreSQL sin `auth.users`, registra un aviso y omite la clave foránea. Si `auth.users` existe y aún no se creó `usuario_auth_id_fkey`, agrega la FK hacia `auth.users(id)`.

La migración `009_usuario_auth_opcional.sql` permite que `auth_id` sea nulo. Así, un perfil puede existir sin una cuenta vinculada; cuando `auth_id` tiene valor, debe referenciar un usuario existente en `auth.users`. La restricción `UNIQUE` se conserva para impedir que una cuenta se vincule a varios perfiles.

La semilla inserta los cinco perfiles con `auth_id = NULL`, por lo que no necesita crear cuentas ni insertar directamente en `auth.users`. Cuando el esquema `auth` está disponible, la FK valida cualquier vínculo que sí tenga valor.

## Pruebas ejecutadas

Ejecuté las migraciones y la semilla en dos bases vacías de un clúster temporal local de PostgreSQL 17.6. Una base no tenía esquema `auth`; en la otra preparé una tabla `auth.users` mínima con `id` UUID como clave primaria para comprobar la FK. Esta segunda prueba verifica la integración referencial, no el servicio completo de Supabase Auth. El clúster temporal se detuvo al terminar y no se modificó el proyecto remoto.

| Caso | Resultado |
|---|---|
| Migraciones 001–009 y semilla, sin esquema `auth` | Terminaron sin errores; se crearon 20 tablas públicas y se cargaron los datos. La migración 006 omitió la FK como estaba previsto. |
| Migraciones 001–009 y semilla, con `auth.users` disponible | Terminaron sin errores; se crearon 20 tablas públicas, la FK `usuario_auth_id_fkey` quedó validada y los cinco perfiles sin vínculo se insertaron con `auth_id` nulo. |
| Vinculación posterior de un perfil | Un `auth_id` presente en `auth.users` fue aceptado; uno inexistente fue rechazado por la FK. |
| `consultas/auditoria_derivados.sql` en ambas bases | Las tres consultas terminaron y no devolvieron filas discrepantes. |
| Vista candidata de Entrega 3 | El archivo SQL se creó correctamente en ambas bases. Se mantiene como propuesta, no como migración aplicada. |

La migración 006 no crea cuentas ni transforma identificadores. Si en el futuro se enlaza un perfil existente, su `auth_id` deberá corresponder a un registro real de `auth.users`.

La auditoría de derivados compara compras y facturas que tienen al menos una línea, porque E2 y E5 usan `JOIN` interno. La limitación para cabeceras sin detalles se conserva descrita en `AUDITORIA_NORMALIZACION.md`.

## Vista candidata para la Entrega 3

Se propone `v_ventas_mensuales_producto`, definida en `sql/vista_propuesta_entrega_3.sql`. Resume unidades e ingresos por mes, producto y categoría sin exponer datos personales. Es una propuesta para evaluación; no es una migración 010 ni se aplica al crear este archivo.
