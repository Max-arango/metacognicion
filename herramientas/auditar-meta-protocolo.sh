#!/usr/bin/env bash
# auditar-meta-protocolo.sh — agrega el log de META-PROTOCOLO, reporta desviaciones
# por sesión y compara el agregado contra los umbrales de SKILL.md (Fase 1).
#
# Uso:  bash herramientas/auditar-meta-protocolo.sh [ruta-al-log]
# El log (estado/meta-protocolo-log.md, no versionado) se appendea desde la skill:
# una entrada con línea "META-PROTOCOLO:" por sesión. Schema en estado/README.md.
set -uo pipefail

LOG="${1:-estado/meta-protocolo-log.md}"

if [[ ! -f "$LOG" ]]; then
  echo "No existe el log: $LOG"
  echo "Ejecuta la skill en sesiones reales y appendea las entradas (schema en estado/README.md)."
  exit 0
fi

if ! grep -qE '^META-PROTOCOLO:' "$LOG"; then
  echo "Sin entradas 'META-PROTOCOLO:' en $LOG."
  exit 0
fi

sum() { grep -E '^META-PROTOCOLO:' "$LOG" | grep -oE "(^| )${1}=[0-9]+" | awk -F= '{s+=$2} END{print s+0}'; }
ratio() { awk -v a="$1" -v b="$2" 'BEGIN{ if (b>0) printf "%.2f", a/b; else print "n/d" }'; }
# desviación de R6 respecto a la cadencia esperada (1 re-anclaje cada 9 tool calls)
desvio_r6() { awk -v r="$1" -v t="$2" 'BEGIN{ e=t/9; if (e<=0) print "n/d"; else { d=(r>e)?(r-e)/e:(e-r)/e; printf "%.2f", d } }'; }

sesiones=$(grep -cE '^META-PROTOCOLO:' "$LOG")
tareas=$(sum tareas); r1=$(sum r1); r3=$(sum r3); r4=$(sum r4); r5=$(sum r5)
r6=$(sum r6); checks=$(sum checks); teatro=$(sum teatro); toolcalls=$(sum toolcalls); irrev=$(sum irrev)
ef_correcta=$(grep -E '^META-PROTOCOLO:' "$LOG" | grep -c 'esfuerzo=correcta' || true)
ef_total=$(grep -E '^META-PROTOCOLO:' "$LOG" | grep -cE 'esfuerzo=(correcta|sobre|sub)' || true)

echo "=== Auditoría del protocolo metacognitivo ==="
echo "Sesiones auditadas:   $sesiones"
echo "Tareas no triviales:  $tareas   | R1 emitidos: $r1   (objetivo ≥ 1/tarea)"
echo "R3 sorpresas:         $r3"
echo "R4 pre-mortems:       $r4       | irreversibles: $irrev (objetivo 100%)"
echo "R5 cierres:           $r5       | tareas entregadas: $tareas (objetivo 100%)"
echo "R6 re-anclajes:       $r6       | tool calls: $toolcalls (desviación < 30% sobre 1/9)"
echo "Checks:               $checks   | teatro: $teatro (objetivo < 20%)"
echo "Esfuerzo:             $ef_correcta/$ef_total correctas (objetivo ≥ 80%)"

ok=0
r1t=$(ratio "$r1" "$tareas")
r5t=$(ratio "$r5" "$tareas")
r4t=$(ratio "$r4" "$irrev")
tt=$(ratio "$teatro" "$checks")
eft=$(ratio "$ef_correcta" "$ef_total")
# Cadencia R6 agregada solo sobre sesiones largas (toolcalls ≥ 10): sumar tool calls
# de sesiones cortas como si fueran una sola cadena produce falsos positivos (A/B F4).
r6_tc=0; r6_r6=0
while IFS= read -r l; do
  tc=$(printf '%s' "$l" | sed -nE 's/.*toolcalls=([0-9]+).*/\1/p')
  r=$(printf '%s' "$l" | sed -nE 's/.*r6=([0-9]+).*/\1/p')
  if (( tc >= 10 )); then r6_tc=$((r6_tc + tc)); r6_r6=$((r6_r6 + r)); fi
done < <(grep -E '^META-PROTOCOLO:' "$LOG")
r6d=$(desvio_r6 "$r6_r6" "$r6_tc")

if [[ "$r1t" != "n/d" ]] && awk -v v="$r1t" 'BEGIN{exit !(v<1.0)}'; then
  echo "  ✗ R1/tarea=$r1t (objetivo ≥ 1)"; ok=1
fi
if [[ "$r5t" != "n/d" ]] && awk -v v="$r5t" 'BEGIN{exit !(v<1.0)}'; then
  echo "  ✗ R5/tarea=$r5t (objetivo 1.0)"; ok=1
fi
if [[ "$r4t" != "n/d" ]] && awk -v v="$r4t" 'BEGIN{exit !(v<1.0)}'; then
  echo "  ✗ R4/irreversible=$r4t (objetivo 1.0)"; ok=1
fi
if [[ "$tt" != "n/d" ]] && awk -v v="$tt" 'BEGIN{exit !(v>=0.2)}'; then
  echo "  ✗ teatro/check=$tt (objetivo < 0.2)"; ok=1
fi
# R6 solo aplica en cadenas ≥ 10 tool calls (hallazgo del A/B Fase 4: en sesiones
# cortas r6=0 es comportamiento correcto, no cadencia rota).
if [[ "$r6d" != "n/d" ]] && awk -v v="$r6d" -v t="$toolcalls" 'BEGIN{exit !(t>=10 && v>0.3)}'; then
  echo "  ? R6: desviación $r6d (> 30%, toolcalls=$toolcalls) — cadencia rota o sobre-anclaje"
fi
if [[ "$eft" != "n/d" ]] && awk -v v="$eft" 'BEGIN{exit !(v<0.8)}'; then
  echo "  ✗ esfuerzo correcto=$eft (objetivo ≥ 0.8)"; ok=1
fi

# Desviaciones por sesión (soporta la regla N≥3 del SKILL.md: una sesión desviada no
# debe ocultarse tras el promedio de las demás).
echo "--- Por sesión ---"
while IFS= read -r linea; do
  sid=$(printf '%s' "$linea" | sed -nE 's/.*sesion=([^ ]+).*/\1/p')
  st=$(printf '%s' "$linea" | sed -nE 's/.*tareas=([0-9]+).*/\1/p')
  sr1=$(printf '%s' "$linea" | sed -nE 's/.*r1=([0-9]+).*/\1/p')
  sr5=$(printf '%s' "$linea" | sed -nE 's/.*r5=([0-9]+).*/\1/p')
  sr4=$(printf '%s' "$linea" | sed -nE 's/.*r4=([0-9]+).*/\1/p')
  sir=$(printf '%s' "$linea" | sed -nE 's/.*irrev=([0-9]+).*/\1/p')
  sch=$(printf '%s' "$linea" | sed -nE 's/.*checks=([0-9]+).*/\1/p')
  ste=$(printf '%s' "$linea" | sed -nE 's/.*teatro=([0-9]+).*/\1/p')
  sr6=$(printf '%s' "$linea" | sed -nE 's/.*r6=([0-9]+).*/\1/p')
  stc=$(printf '%s' "$linea" | sed -nE 's/.*toolcalls=([0-9]+).*/\1/p')
  fallos=""
  rt=$(ratio "$sr1" "$st");  [[ "$rt" != "n/d" ]] && awk -v v="$rt" 'BEGIN{exit !(v<1.0)}' && fallos="$fallos r1/tarea=$rt"
  rt=$(ratio "$sr5" "$st");  [[ "$rt" != "n/d" ]] && awk -v v="$rt" 'BEGIN{exit !(v<1.0)}' && fallos="$fallos r5/tarea=$rt"
  rt=$(ratio "$sr4" "$sir"); [[ "$rt" != "n/d" ]] && awk -v v="$rt" 'BEGIN{exit !(v<1.0)}' && fallos="$fallos r4/irrev=$rt"
  rt=$(ratio "$ste" "$sch"); [[ "$rt" != "n/d" ]] && awk -v v="$rt" 'BEGIN{exit !(v>=0.2)}' && fallos="$fallos teatro/check=$rt"
  rt=$(desvio_r6 "$sr6" "$stc"); [[ "$rt" != "n/d" ]] && awk -v v="$rt" -v t="$stc" 'BEGIN{exit !(t>=10 && v>0.3)}' && fallos="$fallos r6-desv=$rt"
  if [[ -n "$fallos" ]]; then
    echo "  ✗ sesión ${sid:-?}:$fallos"; ok=1
  else
    echo "  ✓ sesión ${sid:-?}: OK"
  fi
done < <(grep -E '^META-PROTOCOLO:' "$LOG")

if [[ "$ok" -eq 0 ]]; then
  echo "Umbrales: OK (dentro de objetivo)."
else
  echo "Umbrales: hay desviaciones (líneas ✗); si 3+ sesiones consecutivas repiten la"
  echo "misma señal, el problema es del protocolo, no de la aplicación (regla N≥3)."
  exit 1
fi
