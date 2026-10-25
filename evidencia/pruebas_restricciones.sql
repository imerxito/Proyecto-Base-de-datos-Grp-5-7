-- Pruebas_restricciones

--Prueba 1: Estado invalido en mesas (validando constraint estado)
insert into mesas (numero_o_nombre, capacidad, estado)
values ('Mesa de prueba', 4, 'Dañada')
--Error arrojado-> ERROR:  new row for relation "mesas" violates check constraint "mesas_estado_check"

--Prueba 2: Rol no permirido en usuarios
insert into usuarios (nombre, rol, email)
values ('Tester No Autorizado', 'super', 'test@saborystock.com')
--Error arrojado-> ERROR:  new row for relation "usuarios" violates check constraint "usuarios_rol_check"

--Prueba 3: Incurencia de total / subtotal negatico en facturas (validacion de constraint)
DO $$
DECLARE
    v_comanda UUID;
BEGIN
    SELECT id INTO v_comanda FROM comandas LIMIT 1;
    INSERT INTO facturas (comanda_id, subtotal, impuestos, total, metodo_pago)
    VALUES (v_comanda, -50000.00, 0, -50000.00, 'EFECTIVO');
END $$
--Error arrojado-> ERROR:  new row for relation "facturas" violates check constraint "valor_positivo_subtotal"

--Prueba 4: Stock negativo en ingrdientes (validar el constraint)
insert into ingredientes (nombre, unidad_medida, stock_actual)
values ('Ingrediente de prueba', 'Kg', -15.50)
--Error arrojado-> ERROR:  new row for relation "ingredientes" violates check constraint "ingredientes_stock_actual_check"

--Prueba 5: Borrar regitro en uso (validar el restrict)
delete from comandas
where id = (select comanda_id from facturas limit 1)
--Error arrojado-> ERROR:  update or delete on table "comandas" violates RESTRICT setting of foreign key constraint "facturas_comanda_id_fkey" on table "facturas"

--Prueba 6: Segundo  turno abierto en la caja (validando constraint turno_caja_estado_check)
do $$
declare
v_caja uuid;
v_user uuid;
begin
select id into v_caja from cajas limit 1;
select id into v_user from usuarios limit 1;

insert into turnos_caja (caja_id, usuario_id, saldo_inicial, estado)
values (v_caja, v_user, 50000, 'Abierto');

insert into turnos_caja (caja_id, usuario_id, saldo_inicial, estado)
values (v_caja, v_user, 80000, 'Abierto');
end $$
--Error arrojado-> ERROR:  new row for relation "turnos_caja" violates check constraint "turnos_caja_estado_check"

--Prueba 7: Duplicidda de receta
do $$
declare
v_prod uuid;
v_ing uuid;
begin
select producto_id, ingrediente_id into v_prod, v_ing from recetas limit 1;

insert into recetas (producto_id, ingrediente_id, cantidad_requerida)
values (v_prod, v_ing, 0.50);
end $$
--Error arrojado-> ERROR:  duplicate key value violates unique constraint "recetas_producto_id_ingrediente_id_key"

--Prueba 8: borrar un producto con historico de ventas
delete from productos
where id = (select producto_id from comanda_detalles limit 1)
--Error arrojado-> ERROR:  update or delete on table "productos" violates RESTRICT setting of foreign key constraint "comanda_detalles_producto_id_fkey" on table "comanda_detalles"
