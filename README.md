# Orden de ejecución

1. Migraciones base existentes del proyecto (`001`–`005`).
2. `006_supabase_opcional.sql` si se dispone de la versión definitiva.
3. `007_indices.sql` si se dispone de la versión definitiva.
4. `008_correcciones_factura.sql`.
5. `vinculo_auth_usuarios.sql` cuando se ejecute en Supabase.
6. `vistas_supabase.sql` al final, una vez creadas las tablas y columnas que consultan.

Las vistas usan `security_invoker = true` y quedan sin SELECT para `anon` y `authenticated` hasta definir las políticas RLS/API.
