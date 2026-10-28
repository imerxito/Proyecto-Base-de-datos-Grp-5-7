-- 008: corrige el planteamiento de factura (se corrige con una migracion nueva, no editando la 003).
-- Problemas que resuelve:
--   (1) factura no se enlazaba con la comanda que cobra.
--   (2) factura exigia mesa, asi que un pedido para llevar o una venta suelta (p. ej. una gaseosa
--       vendida por fuera) no tenia donde registrarse.
-- Es un ALTER sobre una tabla existente: tambien sirve para aplicarlo tal cual en Supabase.
BEGIN;

-- (2) La mesa pasa a ser opcional: una venta puede no tener mesa.
ALTER TABLE public.factura ALTER COLUMN id_mesa DROP NOT NULL;

-- (1) Una factura puede cobrar una comanda. Queda NULL en las ventas directas (sin comanda).
ALTER TABLE public.factura ADD COLUMN id_comanda integer;
ALTER TABLE public.factura ADD CONSTRAINT factura_id_comanda_fkey
  FOREIGN KEY (id_comanda) REFERENCES public.comanda(id_comanda) ON DELETE RESTRICT;
-- Una comanda se cobra con una sola factura (UNIQUE admite varios NULL: las ventas directas).
-- Este UNIQUE crea tambien el indice sobre la FK.
ALTER TABLE public.factura ADD CONSTRAINT factura_id_comanda_key UNIQUE (id_comanda);

COMMIT;
