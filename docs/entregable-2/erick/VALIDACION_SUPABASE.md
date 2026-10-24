# Validación del proyecto Supabase real

Fecha de verificación: 24 de octubre de 2026. Proyecto consultado desde el navegador integrado: **Sabor y Stock**, rama `main` (producción).

## Implementación del esquema

El proyecto contiene 16 tablas públicas. Las ventas se relacionan mediante `facturas → comandas → comanda_detalles → productos → catalogos`. La unidad de medida del ingrediente se registra en `ingredientes.unidad_medida`.

Se implementaron las vistas de negocio sobre estas relaciones y se agregó una vista de rotación mensual para apoyar el análisis del restaurante.

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

## Vínculo con Supabase Auth

Se añadió a `public.usuarios` la columna opcional `auth_id uuid`, con restricción `UNIQUE` y FK a `auth.users(id)` con `ON DELETE SET NULL`. Se preservaron `usuarios.id` y sus FK existentes; no se creó ni enlazó ninguna cuenta de empleado.

La verificación confirmó que la columna permite NULL, las restricciones están validadas, la FK apunta a `auth.users(id)` y usa `SET NULL`, y hay 0 perfiles vinculados. Los perfiles actuales quedan intactos y pueden asociarse a una cuenta Auth cuando se habilite el inicio de sesión en la aplicación.

## Alcance y trazabilidad

Las vistas y el vínculo con Auth están aplicados y verificados en Supabase. Los scripts reproducibles están en esta carpeta. No se modificaron filas de negocio ni se crearon cuentas de Auth.
