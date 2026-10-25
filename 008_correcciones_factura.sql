-- 008_correcciones_factura.sql
-- Correcciones A5 y A6 descritas para la Entrega 2.
-- No elimina datos existentes.
--
-- A5: enlaza factura con la comanda que cobra y evita dos facturas
--     para una misma comanda.
-- A6: permite facturas sin mesa para pedidos para llevar y ventas directas.

ALTER TABLE public.factura
    ADD COLUMN IF NOT EXISTS id_comanda integer;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'factura_id_comanda_fkey'
          AND conrelid = 'public.factura'::regclass
    )
    AND EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'comanda'
    )
    THEN
        ALTER TABLE public.factura
        ADD CONSTRAINT factura_id_comanda_fkey
        FOREIGN KEY (id_comanda)
        REFERENCES public.comanda(id_comanda)
        ON DELETE RESTRICT;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS uq_factura_id_comanda
    ON public.factura(id_comanda)
    WHERE id_comanda IS NOT NULL;

ALTER TABLE public.factura
    ALTER COLUMN id_mesa DROP NOT NULL;
