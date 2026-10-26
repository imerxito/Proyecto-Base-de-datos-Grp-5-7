-- Datos semilla FICTICIOS pero coherentes (restaurante "Sabor & Stock").
-- Ningun dato personal real: cedulas, telefonos, correos y UUID son inventados.
-- Casos limite incluidos a proposito: un proveedor sin compras, ingredientes nunca comprados,
-- un producto sin ventas, una caja sin turnos, una compra anulada y una registrada sin recibir.
BEGIN;

INSERT INTO unidad_medida (id_unidad, nombre, abreviatura, descripcion) VALUES
 (1,'Kilogramo','kg','Peso en kilogramos'),(2,'Gramo','g','Peso en gramos'),
 (3,'Litro','l','Volumen en litros'),(4,'Mililitro','ml','Volumen en mililitros'),
 (5,'Unidad','und','Piezas contables');

INSERT INTO categoria (id_categoria, nombre, descripcion) VALUES
 (1,'Platos fuertes','Platos principales'),(2,'Entradas','Platos para empezar'),
 (3,'Bebidas','Bebidas frias y calientes'),(4,'Postres','Dulces y postres');

INSERT INTO proveedor (id_proveedor, documento, nombre, telefono, correo, direccion) VALUES
 (1,'900100200-1','Distribuidora La Sabana','3000000001','ventas@lasabana.example.com','Calle 10 # 5-20'),
 (2,'900300400-2','Carnes del Cesar','3000000002','pedidos@carnescesar.example.com','Carrera 7 # 12-45'),
 (3,'900500600-3','Verduras Don Pedro','3000000003',NULL,'Plaza de mercado, local 14'),
 (4,'900700800-4','Bebidas del Caribe','3000000004','info@bebcaribe.example.com','Zona industrial, bodega 3'),
 (5,'900900100-5','Lacteos Valle','3000000005','contacto@lacteosvalle.example.com','Via Valledupar km 4');

INSERT INTO seccion (id_seccion, nombre) VALUES (1,'Terraza'),(2,'Salon principal'),(3,'Barra');
INSERT INTO caja (id_caja, nombre) VALUES (1,'Caja principal'),(2,'Caja barra');

INSERT INTO usuario (id_usuario, auth_id, nombre, cedula, telefono, correo, rol) VALUES
 (1,'00000000-0000-4000-8000-000000000001','Admin Demo','1000000001','3100000001','admin@saborstock.example.com','Administrador'),
 (2,'00000000-0000-4000-8000-000000000002','Cajero Uno','1000000002','3100000002','caja1@saborstock.example.com','Caja'),
 (3,'00000000-0000-4000-8000-000000000003','Cajera Dos','1000000003','3100000003','caja2@saborstock.example.com','Caja'),
 (4,'00000000-0000-4000-8000-000000000004','Mesero Uno','1000000004','3100000004','mesero1@saborstock.example.com','Mesero'),
 (5,'00000000-0000-4000-8000-000000000005','Mesera Dos','1000000005','3100000005','mesero2@saborstock.example.com','Mesero');

-- Ingredientes (el stock se calcula mas abajo a partir de los movimientos).
INSERT INTO ingrediente (id_ingrediente, codigo, nombre, id_unidad, stock_minimo, precio_referencia) VALUES
 (1,'ING-001','Arroz',1,15,4200),(2,'ING-002','Carne de res',1,15,28000),
 (3,'ING-003','Pechuga de pollo',1,10,14000),(4,'ING-004','Tomate',1,5,3500),
 (5,'ING-005','Cebolla',1,5,3000),(6,'ING-006','Papa',1,10,2200),
 (7,'ING-007','Aceite vegetal',3,5,9500),(8,'ING-008','Leche',3,10,3800),
 (9,'ING-009','Gaseosa 400 ml',5,24,2100),(10,'ING-010','Limon',1,2,4000),
 (11,'ING-011','Queso costeno',1,5,22000),(12,'ING-012','Azucar',1,3,3800);

INSERT INTO producto (id_producto, codigo, nombre, id_categoria, precio_venta, descripcion) VALUES
 (1,'PRO-001','Arroz con pollo',1,26000,'Arroz con pollo y verduras'),
 (2,'PRO-002','Churrasco con papa',1,38000,'Carne a la parrilla con papa'),
 (3,'PRO-003','Ensalada de tomate',2,12000,'Tomate, cebolla y limon'),
 (4,'PRO-004','Gaseosa 400 ml',3,4500,NULL),
 (5,'PRO-005','Limonada natural',3,7000,'Limon y azucar'),
 (6,'PRO-006','Arroz con leche',4,9000,'Postre tradicional'),
 (7,'PRO-007','Postre de queso costeno',4,11000,'Aun no se ha vendido');

INSERT INTO receta (id_producto, id_ingrediente, cantidad) VALUES
 (1,1,0.15),(1,3,0.20),(1,5,0.03),(1,4,0.04),(1,7,0.02),
 (2,2,0.30),(2,6,0.25),(2,7,0.03),(2,5,0.02),
 (3,4,0.20),(3,5,0.05),(3,10,0.02),
 (4,9,1),
 (5,10,0.15),(5,12,0.03),
 (6,1,0.08),(6,8,0.25),(6,12,0.04),
 (7,11,0.10),(7,12,0.03);

-- Compras. total = suma de sus lineas (se audita en consultas/banco_consultas.sql).
INSERT INTO compra (id_compra, id_proveedor, fecha, estado, total) VALUES
 (1,2,'2026-09-01 09:00','RECIBIDA',1540000),
 (2,3,'2026-09-02 08:30','RECIBIDA',297500),
 (3,1,'2026-09-03 10:00','RECIBIDA',499000),
 (4,4,'2026-09-10 09:30','RECIBIDA',252000),
 (5,2,'2026-10-05 09:00','RECIBIDA',1145000),
 (6,1,'2026-10-12 10:00','REGISTRADA',268000),
 (7,3,'2026-10-14 08:00','ANULADA',36000);

INSERT INTO detalle_compra (id_compra, id_ingrediente, cantidad, precio_aplicado) VALUES
 (1,2,40,28000),(1,3,30,14000),
 (2,4,25,3500),(2,5,20,3000),(2,6,50,2200),(2,10,10,4000),
 (3,1,60,4200),(3,7,20,9500),(3,12,15,3800),
 (4,9,120,2100),
 (5,2,30,28500),(5,3,20,14500),
 (6,1,40,4300),(6,7,10,9600),
 (7,4,10,3600);

-- Movimientos: entradas por compras RECIBIDAS y salidas por consumo de cocina.
INSERT INTO movimiento_inventario (id_ingrediente, tipo, cantidad, fecha, motivo) VALUES
 (2,'ENTRADA',40,'2026-09-01 09:30','Compra #1'),(3,'ENTRADA',30,'2026-09-01 09:30','Compra #1'),
 (4,'ENTRADA',25,'2026-09-02 09:00','Compra #2'),(5,'ENTRADA',20,'2026-09-02 09:00','Compra #2'),
 (6,'ENTRADA',50,'2026-09-02 09:00','Compra #2'),(10,'ENTRADA',10,'2026-09-02 09:00','Compra #2'),
 (1,'ENTRADA',60,'2026-09-03 10:30','Compra #3'),(7,'ENTRADA',20,'2026-09-03 10:30','Compra #3'),
 (12,'ENTRADA',15,'2026-09-03 10:30','Compra #3'),
 (9,'ENTRADA',120,'2026-09-10 10:00','Compra #4'),
 (2,'ENTRADA',30,'2026-10-05 09:30','Compra #5'),(3,'ENTRADA',20,'2026-10-05 09:30','Compra #5'),
 (2,'SALIDA',20,'2026-09-20 18:00','Consumo de cocina'),(2,'SALIDA',18,'2026-10-10 18:00','Consumo de cocina'),
 (3,'SALIDA',28,'2026-09-25 18:00','Consumo de cocina'),(3,'SALIDA',18,'2026-10-12 18:00','Consumo de cocina'),
 (4,'SALIDA',22,'2026-09-30 18:00','Consumo de cocina'),(5,'SALIDA',12,'2026-10-01 18:00','Consumo de cocina'),
 (6,'SALIDA',31,'2026-10-02 18:00','Consumo de cocina'),(10,'SALIDA',7,'2026-10-03 18:00','Consumo de cocina'),
 (1,'SALIDA',41,'2026-10-08 18:00','Consumo de cocina'),(7,'SALIDA',12,'2026-10-08 18:00','Consumo de cocina'),
 (12,'SALIDA',4,'2026-10-09 18:00','Consumo de cocina'),(9,'SALIDA',87,'2026-10-15 18:00','Consumo de cocina');

-- stock = entradas - salidas (no se usaron AJUSTE en la semilla).
UPDATE ingrediente i SET stock = COALESCE((
  SELECT SUM(CASE m.tipo WHEN 'ENTRADA' THEN m.cantidad WHEN 'SALIDA' THEN -m.cantidad END)
  FROM movimiento_inventario m WHERE m.id_ingrediente = i.id_ingrediente), 0);

INSERT INTO mesa (id_mesa, numero, estado, id_seccion, id_usuario) VALUES
 (1,1,'Libre',1,4),(2,2,'Ocupada',1,4),(3,3,'Libre',1,4),(4,4,'Libre',1,NULL),
 (5,5,'Libre',2,5),(6,6,'Ocupada',2,5),(7,7,'Libre',2,NULL),(8,8,'Libre',2,NULL),
 (9,9,'Libre',3,5),(10,10,'Libre',3,NULL);

INSERT INTO comanda (id_comanda, id_mesa, id_usuario, estado, observacion, fecha_creacion) VALUES
 (1,1,4,'Cerrado',NULL,'2026-10-10 12:30'),
 (2,3,4,'Cerrado',NULL,'2026-10-10 13:10'),
 (3,5,5,'Cerrado','Cumpleanos','2026-10-11 19:45'),
 (4,9,5,'Cerrado',NULL,'2026-10-14 20:05'),
 (5,2,4,'Abierto',NULL,'2026-10-17 12:00'),
 (6,6,5,'Enviado',NULL,'2026-10-17 12:20'),
 (7,NULL,4,'Cerrado','Para llevar','2026-10-17 13:00');

INSERT INTO detalle_comanda (id_comanda, id_producto, cantidad, nota) VALUES
 (1,1,2,NULL),(1,4,2,NULL),
 (2,2,1,NULL),(2,5,2,NULL),(2,3,1,NULL),
 (3,2,2,NULL),(3,1,1,NULL),(3,4,3,NULL),(3,6,2,NULL),
 (4,1,3,NULL),(4,5,3,NULL),
 (5,1,1,NULL),(5,3,1,'Sin cebolla'),
 (6,2,2,NULL),(6,4,2,NULL),
 (7,2,1,NULL),(7,5,1,NULL);

-- Facturas (propina del 10 % en las de mesa, salvo la 4). En la factura 1 el arroz con pollo se vendio a 24000:
-- precio_unitario guarda el precio de ESE dia, distinto del precio_venta actual (26000).
INSERT INTO factura (id_factura, id_mesa, id_usuario, fecha_emision, subtotal, propina, total_pagar, id_comanda) VALUES
 (1,1,2,'2026-10-10 14:00', 57000,5700, 62700,1),
 (2,3,2,'2026-10-10 14:20', 64000,6400, 70400,2),
 (3,5,3,'2026-10-11 21:00',133500,13350,146850,3),
 (4,9,2,'2026-10-14 21:30', 99000,0,     99000,4),
 -- Factura 5: pedido para llevar (comanda sin mesa). Factura 6: venta directa, sin mesa ni comanda.
 (5,NULL,3,'2026-10-17 13:30', 45000,0, 45000,7),
 (6,NULL,3,'2026-10-17 15:00', 13500,0, 13500,NULL);

INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio_unitario, subtotal) VALUES
 (1,1,2,24000,48000),(1,4,2,4500,9000),
 (2,2,1,38000,38000),(2,5,2,7000,14000),(2,3,1,12000,12000),
 (3,2,2,38000,76000),(3,1,1,26000,26000),(3,4,3,4500,13500),(3,6,2,9000,18000),
 (4,1,3,26000,78000),(4,5,3,7000,21000),
 (5,2,1,38000,38000),(5,5,1,7000,7000),
 (6,4,3,4500,13500);

INSERT INTO turno_caja (id_turno_caja, id_caja, id_usuario_apertura, id_usuario_cierre,
                        fecha_apertura, fecha_cierre, monto_inicial, monto_final, estado) VALUES
 (1,1,2,2,'2026-10-10 11:00','2026-10-10 23:00',200000,262700,'Cerrado'),
 (2,1,3,3,'2026-10-11 11:00','2026-10-11 22:30',200000,200000,'Cerrado'),
 (3,1,2,2,'2026-10-14 11:00','2026-10-14 23:00',150000,199000,'Cerrado'),
 (4,1,3,NULL,'2026-10-17 11:00',NULL,200000,NULL,'Abierto');

INSERT INTO historial_caja (id_turno_caja, id_usuario, id_factura, metodo_pago, tipo_pago, monto, descripcion, fecha_movimiento) VALUES
 (1,2,1,'Efectivo','Ingreso',62700,'Pago factura 1','2026-10-10 14:05'),
 (1,2,2,'Tarjeta','Ingreso',70400,'Pago factura 2','2026-10-10 14:25'),
 (2,3,3,'Transferencia','Ingreso',146850,'Pago factura 3','2026-10-11 21:05'),
 (3,2,4,'Efectivo','Ingreso',99000,'Pago factura 4','2026-10-14 21:35'),
 (3,2,NULL,'Efectivo','Egreso',50000,'Pago a proveedor de hielo','2026-10-14 22:00'),
 (4,3,5,'Efectivo','Ingreso',45000,'Pago factura 5 (para llevar)','2026-10-17 13:35'),
 (4,3,6,'Efectivo','Ingreso',13500,'Venta directa de gaseosas','2026-10-17 15:02');

INSERT INTO historial_mesa (id_mesa, id_comanda, id_usuario, estado, monto, motivo, fecha_accion) VALUES
 (1,1,4,'Ocupada',NULL,'Apertura de comanda','2026-10-10 12:30'),
 (1,1,2,'Por pagar',62700,'Cuenta solicitada','2026-10-10 13:55'),
 (1,1,2,'Libre',62700,'Pago registrado','2026-10-10 14:05'),
 (5,3,5,'Ocupada',NULL,'Apertura de comanda','2026-10-11 19:45'),
 (5,3,3,'Libre',146850,'Pago registrado','2026-10-11 21:05'),
 (2,5,4,'Ocupada',NULL,'Apertura de comanda','2026-10-17 12:00'),
 (6,6,5,'Ocupada',NULL,'Apertura de comanda','2026-10-17 12:20');

-- Como se insertaron ids explicitos, se alinean las secuencias para que los siguientes INSERT no choquen.
DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT * FROM (VALUES
    ('unidad_medida','id_unidad'),('categoria','id_categoria'),('proveedor','id_proveedor'),
    ('seccion','id_seccion'),('caja','id_caja'),('usuario','id_usuario'),
    ('ingrediente','id_ingrediente'),('producto','id_producto'),('compra','id_compra'),
    ('movimiento_inventario','id_movimiento'),('mesa','id_mesa'),('comanda','id_comanda'),
    ('detalle_comanda','id_detalle_comanda'),('factura','id_factura'),
    ('detalle_factura','id_detalle_factura'),('turno_caja','id_turno_caja'),
    ('historial_caja','id_historial_caja'),('historial_mesa','id_historial_mesa')) AS t(tabla,col)
  LOOP
    EXECUTE format('SELECT setval(pg_get_serial_sequence(%L,%L), COALESCE((SELECT MAX(%I) FROM %I),1))',
                   'public.'||r.tabla, r.col, r.col, r.tabla);
  END LOOP;
END $$;

COMMIT;
