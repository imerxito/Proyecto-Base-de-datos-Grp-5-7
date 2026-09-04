\#Planteamiento Problema

PLANTEAMIENTO CRÍTICO DEL PROBLEMA

Sistema de gestión de información para el inventario de un restaurante

Proyecto Integrador — Base de Datos I

Caso de estudio: Restaurante Sabor \& Stock

Base de datos relacional y programación con PostgreSQL

1\. Descripción del problema

Los restaurantes manejan diariamente información sobre ingredientes, productos, proveedores, compras y movimientos de inventario. Cuando estos datos se registran en hojas de cálculo, documentos o archivos independientes, se dificulta mantenerlos organizados, actualizados y disponibles. Esto puede ocasionar pérdidas, duplicidad de información y errores en el control de existencias.



Para este proyecto se plantea el caso del Restaurante Sabor \& Stock, que necesita controlar los ingredientes utilizados para preparar sus productos, las compras realizadas a proveedores y las entradas y salidas del inventario. El problema principal es la falta de centralización y relación de los datos, lo que dificulta conocer con precisión qué existe, qué debe comprarse y cómo se ha utilizado cada insumo.



Desde el punto de vista de Bases de Datos, es necesario representar correctamente las relaciones entre proveedores, ingredientes, productos, recetas, compras y movimientos de inventario. Por ejemplo, un proveedor puede realizar varias compras; una compra puede contener varios ingredientes; y un producto puede requerir varios ingredientes. Una estructura relacional permitirá reducir duplicidades, inconsistencias y pérdida de información.

2\. Problema central

El problema central es la deficiente administración y control de la información del inventario del restaurante debido al manejo disperso y manual de los datos.



Entre los principales problemas se encuentran:

• Dificultad para conocer el stock real de cada ingrediente.

• Riesgo de registrar información duplicada o inconsistente.

• Falta de control sobre entradas, salidas y ajustes de inventario.

• Dificultad para identificar ingredientes con stock bajo.

• Complicaciones para consultar compras, proveedores y costos.

• Riesgo de registrar cantidades o movimientos inválidos.

3\. Problemática desde la programación

La solución no debe limitarse a almacenar registros; también debe controlar reglas de negocio. Por ejemplo, no debería ser posible registrar stock negativo, cantidades menores o iguales a cero, códigos duplicados o una salida superior a la existencia disponible.



PostgreSQL permitirá aplicar PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE y CHECK para garantizar la integridad de los datos. Además, funciones y triggers podrán automatizar operaciones como la actualización del stock y el cálculo de totales de compra. La aplicación permitirá registrar y consultar la información, mientras la base de datos se encargará de relacionarla, validarla y mantenerla consistente.

4\. Necesidad de una solución basada en datos

Se propone desarrollar una base de datos relacional en PostgreSQL que centralice la información del restaurante y permita controlar el inventario de forma segura y organizada.



La estructura contempla principalmente:

PROVEEDOR → COMPRA → DETALLE\_COMPRA → INGREDIENTE

PRODUCTO → RECETA → INGREDIENTE

INGREDIENTE → MOVIMIENTO\_INVENTARIO

CATEGORIA → PRODUCTO



La relación entre productos e ingredientes se resolverá mediante la tabla RECETA, mientras que las compras y sus ingredientes se manejarán mediante DETALLE\_COMPRA. De esta manera se podrán conservar cantidades y precios históricos sin repetir información.

5\. Preguntas del negocio

• ¿Qué ingredientes están disponibles actualmente?

• ¿Qué ingredientes tienen stock bajo?

• ¿Qué proveedores suministran cada ingrediente?

• ¿Cuánto se ha comprado durante un período?

• ¿Qué ingredientes se utilizan con mayor frecuencia?

• ¿Qué productos utilizan un determinado ingrediente?

• ¿Cuánto cuesta producir un producto según su receta?

• ¿Qué movimientos de inventario se realizaron en un período?

• ¿Qué compras tienen un costo superior al promedio?

6\. Requisitos y supuestos principales

El sistema deberá manejar proveedores, categorías, unidades de medida, ingredientes, productos, recetas, compras, detalles de compra y movimientos de inventario. Cada ingrediente tendrá un código único, unidad de medida, stock y stock mínimo. Los productos pertenecerán a una categoría y podrán utilizar varios ingredientes.



Se asume que un proveedor puede realizar varias compras, una compra puede contener varios ingredientes y un ingrediente puede participar en diferentes compras y recetas. Las cantidades deberán ser mayores que cero, los precios no podrán ser negativos y una salida de inventario no deberá permitir que el stock quede por debajo de cero. Los precios aplicados en las compras deberán conservarse históricamente.

7\. Justificación y conclusión

El proyecto permite aplicar conceptos fundamentales de Base de Datos I y programación sobre una situación real: la administración del inventario de un restaurante. Se trabajarán entidades, relaciones, cardinalidades, claves primarias y foráneas, restricciones, normalización, consultas SQL, vistas, funciones, triggers, transacciones, roles y mecanismos de respaldo.



En conclusión, una base de datos relacional permitirá transformar un manejo disperso del inventario en una estructura organizada, donde la información pueda consultarse y controlarse de manera confiable. La solución no solo almacenará datos, sino que aplicará reglas de negocio y generará información útil para controlar existencias, compras y abastecimiento del restaurante.



