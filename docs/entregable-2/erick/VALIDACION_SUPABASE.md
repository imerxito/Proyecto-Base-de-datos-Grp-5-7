# Validación del proyecto Supabase real

Fecha de verificación: 24 de octubre de 2026. Proyecto consultado desde el navegador integrado: **Sabor y Stock**, rama `main` (producción).

## Resultado de la adaptación

El proyecto contiene 16 tablas públicas. Su estructura no es la del paquete base de 20 tablas: usa nombres plurales y modela las ventas mediante `facturas → comandas → comanda_detalles → productos → catalogos`. `ingredientes.unidad_medida` es texto; no existe una tabla `unidad_medida`. Tampoco existen `detalle_factura` ni `historial_caja`.

Por eso no ejecuté sin cambios las migraciones `005` y `006` del ZIP: sus nombres de tablas/columnas no corresponden al esquema que está desplegado. En su lugar, adapté las dos vistas de negocio a las tablas reales y agregué la vista propuesta para rotación mensual.

## Vistas creadas y comprobadas

| Vista | Propósito | Filas devueltas al verificar |
|---|---|---:|
| `public.v_ingredientes_bajo_minimo` | Ingredientes cuyo stock actual está por debajo del mínimo; incluye unidad y faltante. | 0 |
| `public.v_ventas_diarias_categoria` | Unidades e ingresos por fecha y catálogo, basados en líneas de comandas facturadas; excluye líneas canceladas. | 1 |
| `public.v_rotacion_mensual_producto` | Unidades e ingresos por mes, categoría y producto, sin datos personales. | 1 |

Las tres quedaron con `security_invoker=true`. La consulta de verificación confirmó que `anon` y `authenticated` no tienen permiso `SELECT` sobre ellas. La vista de bajo mínimo no devuelve filas con los datos actuales; esto significa que no hay ingredientes que cumplan el filtro en este momento, no que la vista haya fallado.

El SQL reproducible está en `sql/vistas_supabase.sql`. Se ejecutó desde el SQL Editor del proyecto y se comprobó el conteo, la opción `security_invoker` y los permisos.

## RLS y permisos observados

- Las 16 tablas públicas tienen RLS habilitado.
- El proyecto no tiene políticas RLS en `public`.
- `anon` y `authenticated` tienen privilegio de lectura a nivel de tabla, pero sin políticas RLS no reciben filas.
- Al crear las vistas, los permisos predeterminados las concedían a ambos roles. Retiré esos permisos de las tres vistas creadas; la auditoría posterior devolvió 0 vistas con `SELECT` concedido a `anon` y 0 a `authenticated`.
- No cambié las políticas de las tablas ni los permisos de las tablas, porque eso afecta el modelo de acceso general del grupo y requiere decidir quién puede leer/escribir cada entidad.

## Vínculo de Auth (adaptación de la migración 006)

No ejecuté literalmente `006_supabase_opcional.sql`, porque apunta a la tabla singular `public.usuario`. En su lugar, apliqué una adaptación aditiva sobre `public.usuarios`: columna `auth_id uuid` nullable, restricción `UNIQUE` y FK a `auth.users(id)` con `ON DELETE SET NULL`. Se preservaron `usuarios.id` y las FK existentes, y no se creó ni enlazó ninguna cuenta de empleado.

La verificación del proyecto confirmó que la columna permite NULL, las restricciones están validadas, la FK apunta a `auth.users(id)` y usa `SET NULL`, y hay 0 perfiles vinculados. Así los perfiles actuales quedan intactos y se pueden asociar cuentas Auth más adelante sin inferir coincidencias por correo. No se probó un inicio de sesión porque no se creó una cuenta Auth, que no es necesaria para verificar la estructura del vínculo.

## Alcance y trazabilidad

Las vistas sí están aplicadas en el Supabase real. El SQL Editor no crea una entrada de migración en el historial del proyecto; por eso el script local conserva el SQL ejecutado, pero el despliegue actual no aparece como migración versionada. No se modificaron filas de negocio ni se crearon cuentas de Auth. Los cambios de esquema se aplicaron desde SQL Editor y no aparecen como migraciones versionadas.
