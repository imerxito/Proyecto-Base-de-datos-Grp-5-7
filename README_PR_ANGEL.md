# PR — Parte de Ángel Vargas — Sabor & Stock

## Contenido

- `supabase/migrations/008_correcciones_factura.sql`
  - A5: vínculo `factura.id_comanda` con `comanda`.
  - Unicidad: una comanda no puede quedar cobrada por dos facturas.
  - A6: `factura.id_mesa` pasa a ser nullable.
- `supabase/vinculo_auth_usuarios.sql`
  - Vincula `public.usuario.auth_id` con `auth.users(id)` únicamente cuando el esquema `auth` existe.
- `supabase/vistas_supabase.sql`
  - `v_ingredientes_bajo_minimo`
  - `v_ventas_diarias_categoria`
  - `v_rotacion_mensual_producto`
  - Revoca lectura a `anon` y `authenticated`.
- `supabase/README.md`
  - Orden y notas de ejecución.

## Importante

Este paquete es una reconstrucción de los archivos finales a partir de la especificación y SQL proporcionados en la conversación. El ZIP original de Ángel no pudo ser materializado en este entorno, por lo que este paquete **no debe confundirse con una copia byte-a-byte del ZIP original ni con una reconstrucción completa de las migraciones 001–007**.

Si tu ZIP de Ángel ya contiene `001`–`007`, conserva esas migraciones y añade estos archivos, evitando duplicados.
