#!/usr/bin/env bash
# Reconstruye la base desde cero: migraciones en orden + semilla.
# Uso: ./scripts/reconstruir.sh [nombre_base]   (por defecto: sabor_stock_e2)
set -euo pipefail
DB="${1:-sabor_stock_e2}"
cd "$(dirname "$0")/.."
dropdb --if-exists "$DB"
createdb "$DB"
for f in migraciones/*.sql; do
  echo ">> $f"
  psql -v ON_ERROR_STOP=1 -q -d "$DB" -f "$f"
done
echo ">> semilla/seed.sql"
psql -v ON_ERROR_STOP=1 -q -d "$DB" -f semilla/seed.sql
echo "Listo: base '$DB' reconstruida."
