-- Adaptación de la relación Supabase Auth al esquema real public.usuarios.
-- Se ejecutó en el SQL Editor del proyecto Sabor y Stock.
-- No crea cuentas ni enlaza usuarios existentes: auth_id queda NULL.

BEGIN;
ALTER TABLE public.usuarios ADD COLUMN auth_id uuid;
ALTER TABLE public.usuarios
    ADD CONSTRAINT usuarios_auth_id_key UNIQUE (auth_id);
ALTER TABLE public.usuarios
    ADD CONSTRAINT usuarios_auth_id_fkey
    FOREIGN KEY (auth_id) REFERENCES auth.users(id) ON DELETE SET NULL;
COMMENT ON COLUMN public.usuarios.auth_id IS
    'Cuenta de Supabase Auth asociada; NULL mientras el usuario de la aplicación no tenga inicio de sesión.';
COMMIT;

-- Verificar nulabilidad, unicidad, referencia y política de borrado.
SELECT conname, pg_get_constraintdef(oid) AS definicion, convalidated AS validada
FROM pg_constraint
WHERE conrelid = 'public.usuarios'::regclass
  AND conname IN ('usuarios_auth_id_key', 'usuarios_auth_id_fkey')
ORDER BY conname;

-- Verificar que ningún perfil se vinculó a una cuenta por inferencia.
SELECT COUNT(*) FILTER (WHERE auth_id IS NOT NULL) AS perfiles_vinculados,
       COUNT(*) FILTER (WHERE auth_id IS NULL) AS perfiles_sin_vinculo
FROM public.usuarios;
