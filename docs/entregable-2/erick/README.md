# Aporte de Erick — Entrega 2

Este directorio contiene únicamente mi bloque: auditoría de normalización, diccionario de las tablas que existen en Supabase y los SQL de vistas y vínculo opcional con Auth.

El proyecto Sabor y Stock cuenta con 16 tablas públicas. Aquí se documentan su normalización, el diccionario de datos, las vistas y el vínculo opcional con Supabase Auth. Los cambios están aplicados y verificados; no se crean cuentas de empleados ni se incluyen credenciales.

- `AUDITORIA_NORMALIZACION.md`: dependencias y formas normales de las 16 tablas desplegadas.
- `DICCIONARIO_TABLAS.md`: significado de las tablas reales del bloque de facturación, caja e historial.
- `VALIDACION_SUPABASE.md`: cambios y resultados comprobados en el proyecto real.
- `sql/vistas_supabase.sql`: dos vistas del bloque y una propuesta para Entrega 3.
- `sql/vinculo_auth_usuarios.sql`: adaptación del vínculo con Supabase Auth.

Las vistas y el vínculo con Auth fueron ejecutados desde SQL Editor en producción. Esta edición no agrega permisos de API ni políticas RLS.
