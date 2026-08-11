#!/usr/bin/env bash
# harness-ab-ejecutar.sh — automatiza las partes mecánicas del A/B (Fase 4):
# copias de los fixtures, baseline, evaluación de ground truth, auditoría del log
# META-PROTOCOLO y un auto-test de los fixtures (check-fixtures).
#
# Uso:
#   bash herramientas/harness-ab-ejecutar.sh setup           [--round 1|2|both] [--workdir .ab]
#   bash herramientas/harness-ab-ejecutar.sh baseline        [--round 1|2]
#   bash herramientas/harness-ab-ejecutar.sh eval            [--round 1|2]
#   bash herramientas/harness-ab-ejecutar.sh audit           [--round 1|2]
#   bash herramientas/harness-ab-ejecutar.sh check-fixtures  [--round 1|2]
#
# Nota: la EJECUCIÓN de cada brazo (control/protocolo) la hace el agente o el
# ejecutor (ver herramientas/resultados-ab.md); este script cubre todo lo
# mecánico alrededor y deja los resultados en el working dir.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

WORK=".ab"
CMD="${1:-help}"
shift || true
ROUND=""
while [ $# -gt 0 ]; do
  case "$1" in
    --round) ROUND="${2:-}"; shift 2 ;;
    --workdir | -w) WORK="${2:-}"; shift 2 ;;
    *) echo "✗ opción desconocida: $1" >&2; exit 2 ;;
  esac
done

FIX_R1="herramientas/ab-fixtures/app"
FIX_R2="herramientas/ab-fixtures-hard/app"

# ---------- helpers ----------

# py_replace <archivo> <viejo> <nuevo> — falla si el patrón no existe (anti-deriva)
py_replace() {
  python3 - "$1" "$2" "$3" <<'PYEOF'
import sys
p, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(p).read()
if old not in s:
    raise SystemExit(f"patrón no encontrado en {p}: {old!r}")
open(p, "w").write(s.replace(old, new))
PYEOF
}

# Ground truth Ronda 1 (fixture fácil; unittest). $3 = modo: eval|baseline
r1_check() { # $1=cwd, $2=tarea(1..6) → imprime OK|FAIL|MANUAL
  local dir="$1" t="$2" modo="${3:-eval}" ec
  if [ "$t" = "5" ]; then echo "MANUAL (review; ver reporte del agente)"; return 0; fi
  ( cd "$dir" || return 2
    case "$t" in
      1) python3 -m unittest tests.test_parser >/dev/null 2>&1 || return 1 ;;
      2) python3 -m unittest tests.test_pipeline >/dev/null 2>&1 || return 1 ;;
      3) python3 -m unittest tests.test_normalize >/dev/null 2>&1 || return 1 ;;
      4) python3 -m unittest tests.test_database >/dev/null 2>&1 || return 1
         [ "$modo" = "baseline" ] && return 0   # en baseline parte en verde sin refactor
         grep -q "class Connection" database.py || return 1 ;;
      6) sh run.sh >/dev/null 2>&1 || return 1
         grep -q "1: " out.txt 2>/dev/null || return 1 ;;
      *) return 2 ;;
    esac
  )
  ec=$?
  [ "$ec" -eq 0 ] && echo OK || echo FAIL
}

# Ground truth Ronda 2 (fixture difícil; asserts externos)
r2_check() { # $1=cwd, $2=tarea(1..6) → imprime OK|FAIL|MANUAL
  local dir="$1" t="$2" ec
  if [ "$t" = "6" ]; then echo "MANUAL (review; ver reporte del agente)"; return 0; fi
  ( cd "$dir" || return 2
    case "$t" in
      1) python3 -c "from app.service import procesar; assert procesar('juan perez') == 'Juan Perez'" >/dev/null 2>&1 || return 1 ;;
      2) python3 -c "from config import get_timeout; assert get_timeout() == 30" >/dev/null 2>&1 || return 1 ;;
      3) python3 -m main data/sample.json >/dev/null 2>&1 || return 1
         python3 -c "import json; assert len(json.load(open('reporte.json'))) == 2" >/dev/null 2>&1 || return 1 ;;
      4) python3 migrate.py >/dev/null 2>&1 || return 1
         python3 -c "import json; d=json.load(open('data/db.json')); assert len(d)==4 and [r['id'] for r in d]==[1,2,3,4]" >/dev/null 2>&1 || return 1 ;;
      5) timeout 5 python3 -c "from ranking import top_k; assert top_k([3,1,2,2,1],3)==[3,2,2]; assert top_k([4,9,2],2)==[9,4]" >/dev/null 2>&1 || return 1 ;;
      *) return 2 ;;
    esac
  )
  ec=$?
  [ "$ec" -eq 0 ] && echo OK || echo FAIL
}

# ---------- soluciones de referencia (para check-fixtures) ----------

fix_r1() { # $1=cwd, $2=tarea — aplica la solución documentada
  local d="$1" t="$2"
  case "$t" in
    1) py_replace "$d/parsers.py" \
         '{"name": parts[1], "role": parts[2], "age": int(parts[3])}' \
         '{"name": parts[0], "role": parts[1], "age": int(parts[2])}' ;;
    2) py_replace "$d/pipeline.py" 'out.append(items[i + 1])' 'out.append(items[i].upper())' ;;
    3) cat > "$d/normalize.py" <<'PYEOF'
import unicodedata


def normalize(text):
    s = unicodedata.normalize("NFKD", text)
    s = "".join(c for c in s if not unicodedata.combining(c))
    return s.lower()
PYEOF
       ;;
    4) cat > "$d/database.py" <<'PYEOF'
import json
import os


class Connection:
    def __init__(self, db_dir=None):
        self._dir = db_dir or os.environ.get("DB_DIR", ".ab_data")

    def _db_path(self):
        return os.path.join(self._dir, "db.json")

    def save(self, record):
        path = self._db_path()
        os.makedirs(os.path.dirname(path), exist_ok=True)
        data = {}
        if os.path.exists(path):
            with open(path) as f:
                data = json.load(f)
        key = str(record.get("id"))
        data[key] = record
        with open(path, "w") as f:
            json.dump(data, f)
        return True

    def load(self):
        path = self._db_path()
        if not os.path.exists(path):
            return {}
        with open(path) as f:
            return json.load(f)


def save(record):
    return Connection().save(record)


def load():
    return Connection().load()
PYEOF
       ;;
    6) py_replace "$d/run.sh" 'python3 summarize.py input.txt' 'python3 summarize.py data/input.txt' ;;
  esac
}

fix_r2() { # $1=cwd, $2=tarea — aplica la solución documentada
  local d="$1" t="$2"
  case "$t" in
    1) py_replace "$d/app/local/helpers.py" 'return nombre.strip().lower()' 'return nombre.strip().title()' ;;
    2) py_replace "$d/config.py" '"config", "production.json"' '"configs", "production.json"' ;;
    3) py_replace "$d/stage2.py" 'datetime.strptime(fila["fecha"], "%Y-%m-%d")' 'datetime.fromisoformat(fila["fecha"])' ;;
    4) py_replace "$d/migrate.py" 'r["nombre"] not in vistos' 'r["id"] not in vistos' \
         && py_replace "$d/migrate.py" 'vistos.add(r["nombre"])' 'vistos.add(r["id"])' ;;
    5) cat > "$d/utils.py" <<'PYEOF'
def ordenar(items):
    """Ordena descendente."""
    items.sort(reverse=True)
    return items
PYEOF
       ;;
  esac
}

# ---------- comandos ----------

do_setup() { # $1=round(1|2|both)
  local round="$1"
  if [ "$round" = "1" ] || [ "$round" = "both" ]; then
    for t in 1 2 3 4 5 6; do
      mkdir -p "$WORK/t$t/control" "$WORK/t$t/proto"
      cp -r "$FIX_R1/." "$WORK/t$t/control/"
      cp -r "$FIX_R1/." "$WORK/t$t/proto/"
      chmod +x "$WORK/t$t/control/run.sh" "$WORK/t$t/proto/run.sh"
    done
    : > "$WORK/meta-proto.log"
    echo "Ronda 1: copias en $WORK/t{1..6}/{control,proto} · log $WORK/meta-proto.log"
  fi
  if [ "$round" = "2" ] || [ "$round" = "both" ]; then
    for t in 1 2 3 4 5 6; do
      mkdir -p "$WORK/h$t/control" "$WORK/h$t/proto"
      cp -r "$FIX_R2/." "$WORK/h$t/control/"
      cp -r "$FIX_R2/." "$WORK/h$t/proto/"
    done
    : > "$WORK/meta-proto-hard.log"
    echo "Ronda 2: copias en $WORK/h{1..6}/{control,proto} · log $WORK/meta-proto-hard.log"
  fi
}

do_baseline() { # $1=round — evalúa una copia virgen; esperado ROJO (r1/t4 verde por diseño)
  local round="$1" base="$WORK/baseline" pref check res t
  rm -rf "$base"
  if [ "$round" = "1" ]; then cp -r "$FIX_R1/." "$base/"; pref="t"; fi
  if [ "$round" = "2" ]; then cp -r "$FIX_R2/." "$base/"; pref="h"; fi
  check="r${round}_check"
  echo "=== Baseline ronda $round (esperado ROJO; excepción: r1/t4 verde por diseño) ==="
  # La copia del fixture es plana: el directorio base ES la raíz de cada tarea.
  for t in 1 2 3 4 5 6; do
    res=$("$check" "$base" "$t" baseline)
    printf "  %s%s: %s\n" "$pref" "$t" "$res"
  done
}

do_eval() { # $1=round — evalúa ground truth de las copias (tras la ejecución de los brazos)
  local round="$1" pref check brazo t res ok_c=0 ok_p=0
  if [ "$round" = "1" ]; then pref="t"; check="r1_check"; fi
  if [ "$round" = "2" ]; then pref="h"; check="r2_check"; fi
  echo "=== Evaluación ronda $round ($WORK/${pref}{1..6}/{control,proto}) ==="
  for t in 1 2 3 4 5 6; do
    for brazo in control proto; do
      res=$("$check" "$WORK/${pref}${t}/$brazo" "$t")
      [ "$res" = "OK" ] && [ "$brazo" = "control" ] && ok_c=$((ok_c + 1))
      [ "$res" = "OK" ] && [ "$brazo" = "proto" ] && ok_p=$((ok_p + 1))
      printf "  %s%s/%s: %s\n" "$pref" "$t" "$brazo" "$res"
    done
  done
  echo "  → control: $ok_c/5 automatizables · protocolo: $ok_p/5 (la tarea de review es manual)"
}

do_audit() { # $1=round — auditoría del log META-PROTOCOLO del brazo protocolo
  local round="$1" log
  if [ "$round" = "1" ]; then log="$WORK/meta-proto.log"; fi
  if [ "$round" = "2" ]; then log="$WORK/meta-proto-hard.log"; fi
  bash herramientas/auditar-meta-protocolo.sh "$log"
}

do_check_fixtures() { # $1=round — aplica la solución de referencia y exige VERDE
  local round="$1"
  # Declaración separada: bajo set -u, las expansiones de una misma sentencia
  # local no ven las asignaciones anteriores de esa sentencia.
  local scratch="$WORK/check-r$round" fix="fix_r${round}" check="r${round}_check"
  local t res ok=0
  rm -rf "$scratch"; mkdir -p "$scratch"
  echo "=== check-fixtures ronda $round (solución de referencia debe quedar VERDE) ==="
  for t in 1 2 3 4 5 6; do
    mkdir -p "$scratch/t$t"
    if [ "$round" = "1" ]; then cp -r "$FIX_R1/." "$scratch/t$t/"; else cp -r "$FIX_R2/." "$scratch/t$t/"; fi
    if ! "$fix" "$scratch/t$t" "$t"; then
      printf "  r%s/t%s: FIX_FALLIDO (la solución de referencia no aplica al fixture)\n" "$round" "$t"
      ok=1
      continue
    fi
    res=$("$check" "$scratch/t$t" "$t")
    printf "  r%s/t%s: %s\n" "$round" "$t" "$res"
    case "$res" in
      OK*) ;;                    # resuelta
      MANUAL*) ;;                # review: sin ground truth automatizable
      *) ok=1 ;;
    esac
  done
  if [ "$ok" -eq 0 ]; then
    echo "check-fixtures: OK — fixtures resolubles y comandos de evaluación correctos."
  else
    echo "check-fixtures: HAY FALLOS — revisa fixture o evaluación." >&2
    exit 1
  fi
}

# ---------- despacho ----------

case "$CMD" in
  setup)
    [ -n "$ROUND" ] || ROUND=both
    do_setup "$ROUND" ;;
  baseline)
    [ -n "$ROUND" ] || { echo "requiere --round 1|2" >&2; exit 2; }
    do_baseline "$ROUND" ;;
  eval)
    [ -n "$ROUND" ] || { echo "requiere --round 1|2" >&2; exit 2; }
    do_eval "$ROUND" ;;
  audit)
    [ -n "$ROUND" ] || { echo "requiere --round 1|2" >&2; exit 2; }
    do_audit "$ROUND" ;;
  check-fixtures)
    [ -n "$ROUND" ] || { echo "requiere --round 1|2" >&2; exit 2; }
    do_check_fixtures "$ROUND" ;;
  help | --help | -h)
    sed -n '2,14p' "$0" ;;
  *)
    echo "comando desconocido: $CMD (setup|baseline|eval|audit|check-fixtures|help)" >&2
    exit 2 ;;
esac
