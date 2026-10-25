-- Vínculo opcional entre public.usuario y Supabase Auth.
-- Se mantiene separado porque auth.users solo existe dentro de Supabase.
-- Ejecutar después de crear public.usuario.

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_namespace WHERE nspname = 'auth'
    )
    AND EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'auth' AND table_name = 'users'
    )
    AND EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'usuario'
          AND column_name = 'auth_id'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_usuario_auth_users'
          AND conrelid = 'public.usuario'::regclass
    )
    THEN
        ALTER TABLE public.usuario
        ADD CONSTRAINT fk_usuario_auth_users
        FOREIGN KEY (auth_id)
        REFERENCES auth.users(id);
    END IF;
END $$;
