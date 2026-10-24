# Aporte de Erick — Entrega 2

Este directorio contiene únicamente mi bloque: auditoría de normalización, diccionario de las tablas que existen en Supabase y los SQL de vistas y vínculo opcional con Auth.

El proyecto desplegado tiene 16 tablas y difiere del ZIP base de 20 tablas. Los scripts se adaptan al esquema real; el archivo `006_supabase_opcional.sql` del ZIP apunta a la tabla singular `usuario` y no corresponde directamente. La adaptación para `public.usuarios` ya está aplicada y verificada en Supabase. No se crean cuentas de empleados ni se incluyen credenciales.

- `AUDITORIA_NORMALIZACION.md`: dependencias y formas normales de las 16 tablas desplegadas.
- `DICCIONARIO_TABLAS.md`: significado de las tablas reales del bloque de facturación, caja e historial.
- `VALIDACION_SUPABASE.md`: cambios y resultados comprobados en el proyecto real.
- `sql/vistas_supabase.sql`: dos vistas del bloque y una propuesta para Entrega 3.
- `sql/vinculo_auth_usuarios.sql`: adaptación del vínculo con Supabase Auth.

Las vistas y el vínculo con Auth fueron ejecutados desde SQL Editor en producción. Esta edición no agrega permisos de API ni políticas RLS.
