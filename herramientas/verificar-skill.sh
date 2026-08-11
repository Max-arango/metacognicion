#!/usr/bin/env bash
# verificar-skill.sh — tests de carga de la skill (Fase 5 del plan de integración).
# Valida frontmatter de SKILL.md, artefactos referenciados, enlaces internos y
# sintaxis de los scripts de herramientas/.
# Uso: bash herramientas/verificar-skill.sh
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

# 1) frontmatter mínimo de SKILL.md
for campo in name description license metadata; do
  grep -q "^${campo}:" "$ROOT/SKILL.md" || { echo "✗ SKILL.md sin campo frontmatter '${campo}:'"; fail=1; }
done
grep -q '^  version: ' "$ROOT/SKILL.md" || { echo "✗ SKILL.md sin 'version:' en metadata"; fail=1; }

# 2) artefactos raíz esperados
for p in analisis-cognitivo.md README.md CHANGELOG.md LICENSE PLAN.md ROADMAP.md CONTRIBUTING.md \
         estado/README.md herramientas/auditar-meta-protocolo.sh \
         herramientas/verificar-skill.sh herramientas/harness-ab.md herramientas/resultados-ab.md \
         herramientas/harness-ab-ejecutar.sh herramientas/test-verificar-skill.sh \
         herramientas/ab-fixtures/app/parsers.py herramientas/ab-fixtures/app/tests/test_auth.py \
         herramientas/ab-fixtures-hard/app/config.py herramientas/ab-fixtures-hard/app/session.py \
         ejemplos/README.md \
         ejemplos/1-debugging-R1.md ejemplos/2-refactor-R2-R3.md ejemplos/3-pr-review-R4-R5.md \
         ejemplos/4-cadena-larga-R6.md ejemplos/5-meta-protocolo.md \
         ejemplos/6-micro-ritual-subagente.md ejemplos/plugin/README.md; do
  [[ -e "$ROOT/$p" ]] || { echo "✗ falta artefacto: $p"; fail=1; }
done

# 3) enlaces internos de SKILL.md (se omiten los archivos de estado vivos, no versionados)
while IFS= read -r ref; do
  case "$ref" in
    estado/meta-protocolo-log.md|estado/sesion-anterior.md) continue ;;
  esac
  [[ -e "$ROOT/$ref" ]] || { echo "✗ SKILL.md referencia a inexistente: $ref"; fail=1; }
done < <(grep -oE '`(analisis-cognitivo\.md|estado/[a-zA-Z0-9._/-]+|herramientas/[a-zA-Z0-9._/-]+|ejemplos/[a-zA-Z0-9._/-]+|PLAN\.md|CONTRIBUTING\.md)`' "$ROOT/SKILL.md" | tr -d '`' | sort -u)

# 4) enlaces de ejemplos/README.md existen dentro de ejemplos/
while IFS= read -r ref; do
  [[ -e "$ROOT/ejemplos/$ref" ]] || { echo "✗ ejemplos/README.md referencia a inexistente: $ref"; fail=1; }
done < <(grep -oE '\[[^]]+\]\(([^)]+)\.md\)' "$ROOT/ejemplos/README.md" | sed -E 's/.*\(([^)]+)\.md\)/\1.md/' | sort -u)

# 5) sintaxis de shell de los scripts
for s in "$ROOT"/herramientas/*.sh; do
  bash -n "$s" || { echo "✗ sintaxis de shell: $s"; fail=1; }
done

# 6) coherencia schema↔script: los campos numéricos del schema del log (SKILL.md)
#    deben existir y ser sumados por el auditor (evita que doc y script diverjan)
for c in tareas r1 r3 r4 r5 r6 checks teatro toolcalls irrev; do
  grep -q " ${c}=" "$ROOT/SKILL.md" || { echo "✗ SKILL.md schema sin campo '${c}='"; fail=1; }
  grep -q "sum ${c}" "$ROOT/herramientas/auditar-meta-protocolo.sh" || { echo "✗ auditor no agrega el campo '${c}'"; fail=1; }
done

# 7) check-fixtures: los fixtures del harness A/B deben seguir resolubles con sus
#    soluciones de referencia (evita que fixture y evaluación diverjan). Usa un
#    workdir dedicado para no tocar un A/B en curso (.ab/), y lo limpia al final.
if command -v python3 >/dev/null 2>&1; then
  echo "--- check-fixtures (harness A/B) ---"
  OUT1=$(bash "$ROOT/herramientas/harness-ab-ejecutar.sh" check-fixtures --round 1 --workdir "$ROOT/.ab-verificar" 2>&1); c1=$?
  OUT2=$(bash "$ROOT/herramientas/harness-ab-ejecutar.sh" check-fixtures --round 2 --workdir "$ROOT/.ab-verificar" 2>&1); c2=$?
  if [[ "$c1" -ne 0 || "$c2" -ne 0 ]]; then
    printf '%s\n%s\n' "$OUT1" "$OUT2" | grep -E '✗|HAY FALLOS|No such|patrón no encontrado' || true
    echo "✗ check-fixtures: falló — fixture o comandos de evaluación del harness rotos"
    fail=1
  else
    echo "  ✓ check-fixtures ronda 1 y 2: OK (fixtures resolubles)"
  fi
  rm -rf "$ROOT/.ab-verificar"
else
  echo "  - python3 no disponible: check-fixtures omitido"
fi

if [[ "$fail" -eq 0 ]]; then
  echo "OK: skill verificada (frontmatter, artefactos, enlaces, sintaxis, schema↔script, fixtures)."
else
  echo "ERRORES: revisa las líneas ✗."
  exit 1
fi
