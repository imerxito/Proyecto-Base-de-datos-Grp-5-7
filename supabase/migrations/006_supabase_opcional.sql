-- 006: [CAMBIO A4] La FK usuario.auth_id -> auth.users(id) solo puede existir si el esquema
-- "auth" de Supabase esta presente. En una base PostgreSQL vacia se omite sin error;
-- en Supabase se crea exactamente con el nombre que tenia en la Entrega 1.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_schema = 'auth' AND table_name = 'users')
     AND NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'usuario_auth_id_fkey') THEN
    ALTER TABLE public.usuario
      ADD CONSTRAINT usuario_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES auth.users(id);
    RAISE NOTICE 'FK usuario_auth_id_fkey creada.';
  ELSE
    RAISE NOTICE 'Esquema auth no disponible: se omite usuario_auth_id_fkey.';
  END IF;
END $$;
