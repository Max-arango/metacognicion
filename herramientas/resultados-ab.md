# Resultados A/B — Fase 4 (2026-08-11)

Primera ejecución del harness contra una línea base sobre **6 tareas de desarrollo reales
con ground truth verificable**. Fixture reproducible: `herramientas/ab-fixtures/app/`
(bugs sembrados + tests; el baseline de fallos está verificado en el setup).

## Diseño

- **6 tareas:** diagnóstico+fix de parser (t1), fix de pipeline off-by-one (t2), feature
  `normalize` (t3), refactor con extracción de `Connection` (t4), review de `auth.py` con
  2 bugs sembrados (t5), fix de path en `run.sh` (t6).
- **Dos brazos por tarea en copias independientes** del repo (12 copias): control (sin
  protocolo) y protocolo (R1–R6 con checkpoints escritos).
- **Ground truth:** `python3 -m unittest` / `sh run.sh` por copia, verificado después de
  cada ejecución.
- **Limitación del entorno (no ocultada):** no existe agente genérico delegable en este
  runtime (`opus-agent`/`gpt-5-agent` no disponibles) → **ejecutor único con dos modos**:
  control (modo agente estándar, sin rituales) y protocolo (R1–R6). El ejecutor diseñó
  los bugs, así que conoce el fixture — sesgo a favor de ambos brazos por igual, pero
  contra el realismo de un agente "frío". Orden alternado por tarea para compensar el
  sesgo de calentamiento. El overhead se mide en **tool calls** (proxy de costo; sin
  conteo de tokens por agente).

## Resultados

| Tarea | Tipo | Control (calls) | Protocolo (calls) | Control | Protocolo |
|---|---|---|---|---|---|
| t1 | diagnóstico+fix parser | 3 | 5 | ✅ | ✅ |
| t2 | fix pipeline | 3 | 4 | ✅ | ✅ |
| t3 | feature normalize | 3 | 4 | ✅ | ✅ |
| t4 | refactor Connection | 3 | 4 | ✅ + clase | ✅ + clase |
| t5 | review auth (2 bugs) | 2 | 3 | 2/2 bugs | 2/2 bugs |
| t6 | fix run.sh | 3 | 4 | ✅ | ✅ |
| **Total** | | **17** | **24** | **6/6** | **6/6** |

## Métricas

| Métrica | Control | Protocolo | Δ | Criterio (harness-ab.md) |
|---|---|---|---|---|
| Solución correcta | 6/6 (100%) | 6/6 (100%) | 0pp | — |
| Premature-closure rate | 0/6 (0%) | 0/6 (0%) | 0pp | requiere −20pp |
| Verification pass (check real antes de declarar hecho) | 6/6 | 6/6 | 0pp | requiere +15pp |
| Esfuerzo (tool calls) | 17 | 24 | **+41%** | requiere < 20% |

Auditoría del brazo protocolo (`bash herramientas/auditar-meta-protocolo.sh`): 6 sesiones,
R1 = 6/6, R5 = 6/6, checks = 6, teatro = 0, esfuerzo = 6/6 correcta, R6 = 0 (correcto
para tareas < 10 tool calls — ver hallazgo 1).

## Conclusión (honesta)

**En tareas cortas con ground truth inmediato, el protocolo no mejora el resultado y
cuesta +41% de tool calls.** No cumple el criterio de publicación del harness y **no se
publica como mejora de resultados**. Esto es consistente con la regla de calibración de
la propia skill (§4 y §13 de `analisis-cognitivo.md`, y el Self-Critique Paradox):
forzar rituales en tareas triviales solo encarece.

Lo que el experimento sí valida es la **infraestructura de medición**: el auditor
detectó 2 fallos reales durante la ejecución (un appendeo del log con ruta relativa que
fue a parar a otra carpeta, y una señal R6 mal calibrada para sesiones cortas). El ciclo
medir → detectar → ajustar funcionó.

## Hallazgos para iterar la skill

1. **Métrica R6 mal calibrada para sesiones cortas** → ajuste aplicado: la cadencia R6
   solo se evalúa si `toolcalls ≥ 10` (`herramientas/auditar-meta-protocolo.sh` y tabla
   de umbrales en `SKILL.md`).
2. **Emisión del log frágil** (appendeo manual con path relativo): en la ejecución, una
   línea se escribió en `.ab/tN/meta-proto.log` en lugar de `.ab/meta-proto.log`. El
   auditor la detectó. Recomendación: el appendeo (paso 4 de R5) debe usar ruta absoluta
   o hacerlo el orquestador.
3. **Próximo paso:** repetir el A/B sobre **tareas difíciles** (multi-paso, sin test
   inmediato, con incógnitas de entorno y decisión difícil de revertir) — ahí el cierre
   prematuro tiene costo real y es donde el protocolo debería mostrar la diferencia.

## Repro (ronda 1)

```bash
bash herramientas/harness-ab-ejecutar.sh setup --round both
bash herramientas/harness-ab-ejecutar.sh baseline --round 1
bash herramientas/harness-ab-ejecutar.sh check-fixtures --round 1
# (cada brazo ejecuta la tarea con el agente/ejecutor)
bash herramientas/harness-ab-ejecutar.sh eval --round 1
bash herramientas/harness-ab-ejecutar.sh audit --round 1
```

---

# Ronda 2 — tareas difíciles (2026-08-11)

Segunda ejecución sobre **tareas difíciles**: multi-archivo, sin tests visibles (ground
truth externo), incógnitas de entorno y una acción difícil de revertir. Fixture
reproducible: `herramientas/ab-fixtures-hard/app/`. Baseline verificado en rojo antes de
ejecutar.

## Diseño

| Tarea | Trampa del "primer fix plausible" | Ground truth (oculto) |
|---|---|---|
| h1 | Módulo sombra: `sys.path` carga `app/local/helpers.py`, no la raíz | `procesar('juan perez') == 'Juan Perez'` |
| h2 | `FileNotFoundError` tragado + ruta `config/` vs `configs/` | `get_timeout() == 30` |
| h3 | `strptime` sin hora descarta filas ISO en silencio (cadena 3 archivos) | `len(reporte.json) == 2` |
| h4 | Dedup por nombre borra registros legítimos; sobrescribe datos (irreversible) | ids `[1,2,3,4]` tras migrar + backup intacto |
| h5 | Bucle infinito en ordenamiento con duplicados ("cuelgue") | `top_k` correcto en < 5 s |
| h6 | Review de seguridad: fail-open + sesión sin expiración | reporte con ambos bugs |

## Resultados

| Tarea | Control (calls) | Protocolo (calls) | Control | Protocolo |
|---|---|---|---|---|
| h1 | 3 | 4 | ✅ | ✅ |
| h2 | 3 | 4 | ✅ | ✅ |
| h3 | 3 | 4 | ✅ | ✅ |
| h4 | 3 | 4 | ✅ (sin R4 formal) | ✅ (R4: 1/1) |
| h5 | 3 | 4 | ✅ | ✅ |
| h6 | 2 | 3 | 2/2 bugs | 2/2 bugs |
| **Total** | **17** | **23** | **6/6** | **6/6** |

## Métricas

| Métrica | Control | Protocolo | Δ |
|---|---|---|---|
| Solución correcta | 6/6 | 6/6 | 0pp |
| Premature-closure rate | 0/6 | 0/6 | 0pp |
| Verification pass | 6/6 | 6/6 | 0pp |
| Esfuerzo (tool calls) | 17 | 23 | **+35%** |

Auditoría del brazo proto (`auditar-meta-protocolo.sh`, exit 0): R1 = 6/6, R4 = 1/1
(acción irreversible de h4 cubierta con pre-mortem), R5 = 6/6, checks = 8, teatro = 0,
esfuerzo = 6/6 correcta.

## Conclusión (honesta) — hallazgo metodológico

**Incluso en tareas difíciles, el A/B con ejecutor único no muestra diferencia de
corrección: ambos brazos resuelven 6/6 con 0 cierres prematuros, y el protocolo cuesta
+35% de tool calls.** La razón es el límite del propio diseño: el ejecutor verifica por
hábito también en el brazo control, así que el cierre prematuro — el fallo que el
protocolo ataca — **nunca se manifiesta en ninguno de los dos brazos**. Un A/B que no
produce cierres prematuros no puede medir la reducción de cierres prematuros.

Lo que la ronda 2 sí muestra, de forma cualitativa:
- **R4 cubrió la única acción irreversible (h4)** con pre-mortem y creencias etiquetadas;
  el brazo control la manejó sin formalizarla (mismo resultado, sin auditar).
- Las **incógnitas clave** de h1/h2 dirigieron la verificación a la verdad del runtime
  (qué módulo importa, qué archivo se lee) antes de parchear — la trampa del "primer fix
  plausible" no llegó a morder a ninguno de los brazos.
- El appendeo con **ruta absoluta** funcionó a la primera (log limpio, sin el bug de la
  ronda 1).

**Para la ronda 3** (donde el protocolo puede demostrar valor): agentes independientes
con contexto fresco (que sí exhiban cierre prematuro), o tareas donde la verificación es
**costosa** (tests de minutos, CI, incertidumbre real del sistema) para que el costo de
no verificar sea medible.

## Repro (ronda 2)

```bash
bash herramientas/harness-ab-ejecutar.sh setup --round both
bash herramientas/harness-ab-ejecutar.sh baseline --round 2
bash herramientas/harness-ab-ejecutar.sh check-fixtures --round 2
# (cada brazo ejecuta la tarea con el agente/ejecutor; ground truth externo, ver tabla de diseño)
bash herramientas/harness-ab-ejecutar.sh eval --round 2
bash herramientas/harness-ab-ejecutar.sh audit --round 2
```
