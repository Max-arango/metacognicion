#!/usr/bin/env bash
# test-verificar-skill.sh — test de regresión de herramientas/verificar-skill.sh.
# Ejecuta los 3 escenarios clave:
#   1. repo sano            → el verificador termina con exit 0 (incluye check-fixtures)
#   2. fixture roto         → el verificador falla (detecta artefacto faltante y fixtures)
#   3. fixture restaurado   → el verificador vuelve a pasar y el fixture queda intacto
# El fixture se restaura SIEMPRE vía trap: si el test falla a mitad, el repo no se queda roto.
#
# Uso: bash herramientas/test-verificar-skill.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

FIXTURE="herramientas/ab-fixtures/app/parsers.py"
BAK="$(mktemp)"
MOVED="$(mktemp)"

pasan=0
fallan=0

pass() { echo "  ✓ $1"; pasan=$((pasan + 1)); }
fail() { echo "  ✗ $1"; fallan=$((fallan + 1)); }

cp "$FIXTURE" "$BAK"   # respaldo del contenido original

restaurar() {
  if [[ ! -f "$FIXTURE" ]]; then
    if [[ -f "$MOVED" ]]; then mv "$MOVED" "$FIXTURE"; else cp "$BAK" "$FIXTURE"; fi
  fi
}
trap restaurar EXIT

verificar() { bash herramientas/verificar-skill.sh 2>&1; }

echo "=== Escenario 1: repo sano (esperado: exit 0) ==="
out1=$(verificar); ec1=$?
if [[ $ec1 -eq 0 ]]; then pass "verificador exit 0"; else fail "verificador exit 0 (fue $ec1)"; fi
if printf '%s\n' "$out1" | grep -q "check-fixtures ronda 1 y 2: OK"; then
  pass "check-fixtures ejecutado y en verde"
else
  fail "check-fixtures no confirmado en la salida"
fi

echo "=== Escenario 2: fixture roto (parsers.py ausente; esperado: exit != 0) ==="
mv "$FIXTURE" "$MOVED"
out2=$(verificar); ec2=$?
if [[ $ec2 -ne 0 ]]; then pass "verificador falla (exit $ec2)"; else fail "verificador falla (fue $ec2)"; fi
if printf '%s\n' "$out2" | grep -q "✗ falta artefacto"; then
  pass "detecta artefacto faltante"
else
  fail "no detectó el artefacto faltante"
fi
if command -v python3 >/dev/null 2>&1; then
  if printf '%s\n' "$out2" | grep -q "check-fixtures: falló"; then
    pass "detecta fixture roto vía check-fixtures"
  else
    fail "check-fixtures no falló con el fixture roto"
  fi
else
  echo "  - python3 ausente: no se verifica el paso check-fixtures"
fi

echo "=== Escenario 3: fixture restaurado (esperado: exit 0 + contenido intacto) ==="
mv "$MOVED" "$FIXTURE"
out3=$(verificar); ec3=$?
if [[ $ec3 -eq 0 ]]; then pass "verificador exit 0 tras restaurar"; else fail "verificador exit 0 tras restaurar (fue $ec3)"; fi
if cmp -s "$FIXTURE" "$BAK"; then pass "fixture intacto (mismo contenido que el original)"; else fail "el fixture quedó alterado"; fi

rm -f "$BAK" "$MOVED"
trap - EXIT

echo
echo "Resumen: $pasan pasados, $fallan fallidos"
[[ $fallan -eq 0 ]] && exit 0 || exit 1
