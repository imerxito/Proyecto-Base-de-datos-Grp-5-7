# Verificación del Banco de Consultas — Sabor \& Stock

Este documento contiene la comprobación manual, la decisión de negocio asociada y la validación de requisitos de la guía del curso para la Entrega 2 del proyecto.

\---

## 1\. Tabla de Verificación de Consultas (Q1 a Q15)

|Consulta|Pregunta / Requerimiento del Negocio|Resultado Devuelto por PostgreSQL|Comprobación Manual|Decisión de Negocio que Apoya|
|-|-|-|-|-|
|**Q1**|¿Qué ingredientes tienen un stock actual en nivel crítico o agotado?|`ING-008` (Leche), `ING-011` (Queso costeño).|Se verificó en la tabla `ingrediente`: sus valores de `stock` actual son 0, estando por debajo o igual al `stock\\\_minimo` configurado.|Notificar al encargado de compras para generar una orden urgente de reabastecimiento de lácteos y evitar frenar la preparación en cocina.|
|**Q2**|¿Cuál es el total de ingresos e impuestos facturados agrupados por método de pago?|Resumen acumulado de totales en `Efectivo`, `Tarjeta` y `Transferencia`.|Suma directa del campo `total\\\_pagar` en la tabla `factura`, filtrado por rango y agrupado por `metodo\\\_pago`.|Optimizar la administración del flujo de caja diario y evaluar las comisiones cobradas por datafonos o plataformas bancarias.|
|**Q3**|¿Qué proveedores o productos no registran transacciones en el sistema?|`PRO-007` (Postre de queso costeño).|`LEFT JOIN` entre `producto` y `detalle\\\_comanda`; el producto `PRO-007` no tiene coincidencias de venta (`dc.id IS NULL`).|Evaluar si se retira el producto del menú o si se realiza una campaña promocional para incentivar su rotación.|
|**Q4**|¿Cuáles proveedores concentran un monto total de compras superior a un umbral específico?|Lista de proveedores con compras acumuladas de alto valor.|Suma de `(cantidad \\\* precio\\\_aplicado)` en `detalle\\\_compra`, agrupado por proveedor y evaluado en la cláusula `HAVING`.|Identificar los proveedores clave para negociar descuentos por volumen o mejores plazos de pago.|
|**Q5**|¿Cuáles son los platos y bebidas más vendidos del restaurante?|Ranking de productos por volumen de ventas y monto total generado.|Conteo y suma acumulada de `cantidad` en `detalle\\\_comanda`, agrupado por `producto\\\_id` y ordenado de mayor a menor.|Potenciar la promoción de platillos estrella, crear combos estratégicos o ajustar precios según la demanda.|
|**Q6**|¿Qué categorías de productos generan ventas superiores al promedio general?|Categorías con ingresos por encima del valor medio global.|Cálculo de totales por categoría mediante `GROUP BY` y comparación en `HAVING` usando una subconsulta con el promedio general.|Reorientar presupuestos de publicidad e incentivos hacia las líneas de producto de mayor rentabilidad.|
|**Q7**|¿Cómo ha variado el precio de compra unitario de los insumos en el tiempo?|Historial cronológico del costo de adquisición por ingrediente.|Consulta a los detalles de compra cruzados cronológicamente por `ingrediente\\\_id` e `id\\\_compra`.|Monitorear la inflación de materias primas y renegociar tarifas con proveedores ante aumentos injustificados.|
|**Q8**|¿Cuáles mesas registran la mayor frecuencia de uso y tiempo de rotación?|Conteo de comandas y tiempos de ocupación agrupados por mesa.|Conteo de registros en `historial\\\_mesa` o `comanda` vinculados a cada identificador de mesa.|Reorganizar la distribución del salón de ventas y detectar mesas poco atractivas o con rotación lenta.|
|**Q9**|¿Qué turnos de caja cerraron con inconsistencias entre el saldo esperado y el saldo real?|Lista de cierres de caja con diferencias (descuadres positivos o negativos).|Resta directa entre `monto\\\_cierre` y `monto\\\_esperado` en la tabla `turno\\\_caja`.|Detectar errores de cobro en caja, fallas en el arqueo o posibles fugas de dinero.|
|**Q10**|¿Qué ingredientes y proporciones se requieren para preparar cada plato de la carta?|Desglose técnico de ingredientes, unidades de medida y cantidades por receta.|`JOIN` entre `producto`, `receta` e `ingrediente` detallando las cantidades requeridas por porción.|Estandarizar la preparación en cocina y calcular el costo directo de fabricación (COGS) por plato.|
|**Q11**|¿Qué facturas o comandas superan un consumo de alto valor?|Registros de ventas individuales con un total cobrado elevado.|Filtro directo sobre la tabla `factura` donde `total\\\_pagar > M`.|Diseñar estrategias de atención preferencial e incentivos de fidelización para clientes de alto consumo.|
|**Q12**|¿Cuál es el consolidado diario de ventas generado mediante la vista de facturación?|Resumen global de facturación diaria con subtotales e impuestos.|Consulta directa sobre la vista `v\\\_ventas\\\_consolidadas` (creada en la migración 005).|Agilizar la revisión contable al final de la jornada y facilitar los reportes de impuestos.|
|**Q13**|¿Qué órdenes de compra enviadas a proveedores se encuentran en estado anulado o pendiente?|Listado de compras que no han sido completadas o procesadas.|Filtro por el campo `estado` en la tabla `compra` cruzado con la información del `proveedor`.|Dar seguimiento a suministros pendientes y sanear los compromisos de cuentas por pagar.|
|**Q14**|¿Cuáles mesas generan un consumo promedio por comanda superior a $50,000?|Mesas de alta rentabilidad con su promedio de venta e ingreso total.|CTE que une `mesa`, `comanda` y `factura`, calculando `AVG(total\\\_pagar)` agrupado por mesa y filtrado con `HAVING`.|Optimizar la distribución del servicio en salón y asignar el personal con mayor experiencia a las zonas más concurridas.|
|**Q15**|¿Qué productos registrados en el catálogo del menú no registran ventas?|Lista de productos sin presencia en detalles de comanda.|`LEFT JOIN` entre `producto` y `detalle\\\_comanda` con condición `WHERE dc.id IS NULL`.|Decidir la eliminación de platos sin demanda para simplificar el menú y reducir desperdicio en cocina.|

\---

## 2\. Cobertura de Requisitos de la Guía del Curso

A continuación se detalla cómo el banco de consultas satisface los mínimos exigidos en la guía de la Entrega 2:

* **Consultas con 3 o más tablas:** Cumplido en **Q4** (`proveedor` + `compra` + `detalle\\\_compra`), **Q10** (`producto` + `receta` + `ingrediente`) y **Q14** (`mesa` + `comanda` + `factura`).
* **Consultas de exclusión ("los que no tienen"):** Cumplido en **Q3** (proveedores/productos sin movimiento) y **Q15** (productos sin ventas registradas).
* **`GROUP BY` con `HAVING`:** Cumplido en **Q4** (compras acumuladas por proveedor) y **Q14** (promedio consumido por mesa).
* **Subconsulta o CTE:** Cumplido en **Q6** (subconsulta de rentabilidad) y **Q14** (CTE de consumos por mesa).
* **Vista creada y consultada:** Cumplido en **Q12** (consulta a la vista consolidada de facturación).



