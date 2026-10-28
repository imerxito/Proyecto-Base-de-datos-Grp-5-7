-- 009: permite perfiles de usuario que aun no estan vinculados a Supabase Auth.
BEGIN;

ALTER TABLE public.usuario
  ALTER COLUMN auth_id DROP NOT NULL;

COMMIT;
