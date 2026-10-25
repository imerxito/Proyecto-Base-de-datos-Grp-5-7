# Sabor & Stock — Entrega 2 (Implementación)

Base de Datos I · PostgreSQL 16+

## Estructura
| Carpeta | Contenido |
|---|---|
| `migraciones/` | DDL numerado `001`–`008`. Se ejecuta en orden sobre una base vacía. |
| `semilla/seed.sql` | Datos ficticios coherentes (con casos límite a propósito). |
| `consultas/banco_consultas.sql` | 13 consultas de negocio, cada una con su pregunta y el requisito que cubre. |
| `consultas/auditoria_derivados.sql` | Verifica las columnas derivadas (deben devolver 0 filas). |
| `evidencia/caso_indice.sql` | Caso del índice: `EXPLAIN ANALYZE` antes y después. Salida real en `resultado_caso_indice.txt`. |
| `docs/CAMBIOS_Y_JUSTIFICACION.md` | Qué se cambió respecto a la Entrega 1 y por qué, auditoría de normalización y pendientes. |
| `docs/diccionario_estructura.md` | Estructura real de las 20 tablas (tipo, nulabilidad, default). |
| `scripts/reconstruir.sh` | Recrea la base desde cero y carga la semilla. |

## Cómo probarlo
```bash
bash scripts/reconstruir.sh sabor_stock_e2                     # migraciones + semilla
psql -d sabor_stock_e2 -f consultas/banco_consultas.sql        # banco de consultas
psql -d sabor_stock_e2 -f consultas/auditoria_derivados.sql    # 3 consultas, 0 filas cada una
psql -d sabor_stock_e2 -f evidencia/caso_indice.sql            # caso de índice (carga y limpia datos de prueba)
```

## Cobertura de la guía de la Entrega 2
- Migraciones que reconstruyen desde cero: `001`–`008` (probadas en PostgreSQL 16.15 sobre base vacía).
- Restricciones declarativas: PK, FK con política `ON DELETE`, NOT NULL, UNIQUE, CHECK.
- Datos semilla: `semilla/seed.sql`.
- Normalización: sección 4 de `docs/CAMBIOS_Y_JUSTIFICACION.md`.
- Consultas: Q1–Q13 (las de “los que no tienen”: Q1, Q2, Q3, Q11, Q13; GROUP BY + HAVING: Q4; CTE/subconsulta: Q7; vista: Q8; reunión de 3+ tablas: Q4, Q5, Q6, Q10).
- Índice con evidencia: `evidencia/` (19,758 ms → 0,154 ms).

Etiqueta de Git sugerida: `git tag entrega-2`.
