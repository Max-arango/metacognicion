# Roadmap y estado global

Consolidación del estado del proyecto (2026-08-11, v1.5.0): **lo cumplido**, **lo
pendiente** (con prioridad, bloqueador y criterio de "hecho") y **los planes a futuro**.

Fuentes de detalle: `PLAN.md` (el plan por fases), `CHANGELOG.md` (historial de
versiones), `herramientas/harness-ab.md` (protocolo de evaluación A/B),
`herramientas/resultados-ab.md` (ejecuciones) y `CONTRIBUTING.md` (cómo proponer
cambios). Este documento no reemplaza a ninguno: es el índice de estado.

## Matriz de fases

| Fase | Contenido | Estado | Versión |
|---|---|---|---|
| 0 — Instrumentación operativa | Emisión determinista de META-PROTOCOLO, log parseable, métrica de cobertura | ✅ hecho | 1.5.0 |
| 1 — Umbrales y regla de decisión | Tabla de objetivos por métrica, regla N ≥ 3 sesiones | ✅ hecho | 1.5.0 |
| 2 — Ejemplos trabajados | `ejemplos/` con R1–R6, META-PROTOCOLO lleno y micro-ritual de subagente | ✅ hecho | 1.5.0 |
| 3 — Especialización para agentes de código | Ledger de creencias de entorno, pre-mortem git/CI, verificación con ground truth externo | ✅ hecho | 1.5.0 |
| 4 — Evaluación A/B | Rondas 1 y 2 ejecutadas y documentadas | ⏳ en curso (falta ronda 3) | 1.5.0 |
| 5 — Distribución y ciclo de vida | CONTRIBUTING, verificador, test de regresión, estructura de plugin | ✅ hecho (falta publicar) | 1.5.0 |
| 6 — Memoria entre sesiones | `estado/sesion-anterior.md` leído al activar la skill | ✅ hecho | 1.5.0 |

## ✅ Cumplido

**Núcleo del protocolo (1.0.0 → 1.4.0)**
- Protocolo operacional completo: secuencia de activación, bucle
  ORIENTAR→MODELAR→ACTUAR→VERIFICAR→REPORTAR, rituales R1–R6 con plantillas literales,
  reglas de decisión rápidas y tabla de autodiagnóstico de 10 modos de fallo.
- Análisis cognitivo de referencia (`analisis-cognitivo.md`) con el "porqué" de cada
  regla y los límites honestos de la destilación.
- Auto-disparo por señales observables (1.1.0): el protocolo no depende de que el
  modelo decida invocarlo.
- Cobertura multi-agente (1.2.0): micro-ritual inyectado a subagentes + R5 sobre el
  resultado devuelto; notas de portabilidad para opencode y Claude Code.
- Anti-teatro (1.3.0): `TEST DE LA INCÓGNITA` como check que confirma o mata la
  incógnita; predicción previa a cada check.
- Instrumentación (1.4.0/1.5.0): bloque META-PROTOCOLO, log persistente, auditoría y
  umbrales.

**Plan de integración por fases (1.5.0)**
- Fase 0: instrumentación operativa con emisión determinista y schema parseable.
- Fase 1: umbrales objetivo por métrica y regla de decisión N ≥ 3.
- Fase 2: `ejemplos/` con cada ritual resuelto sobre tareas reales.
- Fase 3: especialización para agentes de código (ledger de entorno, pre-mortem
  anclado a git/CI, ground truth externo, plantilla de reporte).
- Fase 5: `CONTRIBUTING.md`, `herramientas/verificar-skill.sh` (7 pasos: frontmatter,
  artefactos, enlaces, sintaxis, schema↔script, check-fixtures) y
  `herramientas/test-verificar-skill.sh` (regresión de 3 escenarios con restauración
  garantizada vía `trap`).
- Fase 6: memoria entre sesiones (`estado/sesion-anterior.md`).

**Infraestructura de medición (Fase 4)**
- `herramientas/harness-ab.md`: protocolo de evaluación A/B con métricas y criterio de
  decisión publicable (premature-closure −20pp, verification-pass +15pp, overhead < 20%).
- `herramientas/auditar-meta-protocolo.sh`: agrega el log y compara contra umbrales;
  calibrado para no marcar R6 en sesiones cortas (toolcalls ≥ 10).
- `herramientas/ab-fixtures/` y `herramientas/ab-fixtures-hard/`: repos de prueba
  reproducibles con bugs sembrados y soluciones de referencia.
- `herramientas/harness-ab-ejecutar.sh`: automatiza setup, baseline, eval, audit y
  check-fixtures (auto-test anti-deriva de fixtures).
- **Ronda 1 del A/B ejecutada** (tareas fáciles): resultado honesto — sin mejora de
  corrección, +41% de tool calls → no publicable. Detectó y corrigió 2 fallos de la
  propia medición (métrica R6 mal calibrada, appendeo frágil del log).
- **Ronda 2 del A/B ejecutada** (tareas difíciles): 6/6 en ambos brazos, 0 cierres
  prematuros, +35% de tool calls → hallazgo metodológico (el A/B con ejecutor único no
  puede medir la reducción del fallo que el protocolo ataca). Valor cualitativo:
  R4 cubrió 1/1 acción irreversible, las incógnitas dirigieron la verificación al
  runtime real.
- `herramientas/resultados-ab.md`: informe completo con ambas rondas y repro.
- `ROADMAP.md` (este archivo): consolidación de estado global.

## ⏳ Pendiente

| # | Pendiente | Prioridad | Bloqueador | Criterio de "hecho" |
|---|---|---|---|---|
| P1 | **Ronda 3 del A/B** (Fase 4) | Alta | El runtime actual no permite agentes independientes con contexto fresco (`opus-agent`/`gpt-5-agent` no disponibles); con ejecutor único el cierre prematuro nunca se manifiesta en ningún brazo. Alternativa: tareas con verificación costosa (tests de minutos/CI) | premature-closure −20pp, verification-pass +15pp, overhead < 20% (criterio de publicación de `harness-ab.md`) |
| P2 | **Publicar en un marketplace real de skills/plugins** (Fase 5) | Media | Ninguno técnico: la estructura de plugin ya existe en `ejemplos/plugin/`; requiere cuenta y empaquetado en el marketplace elegido | La skill instalable desde el marketplace oficial con `SKILL.md` en la raíz |
| P3 | **Verificación formal del criterio de "hecho" de Fase 2** | Media | Ninguno: es un ejercicio de validación con un modelo nuevo | Un modelo nuevo produce R1 con la misma estructura que `ejemplos/1-debugging-R1.md` sin ayuda (criterio declarado en `PLAN.md`) |
| P4 | **Verificación formal del criterio de "hecho" de Fase 6** | Baja | Requiere una sesión real separada en el tiempo | Retomar una tarea al día siguiente no obliga a re-descubrir el modelo del sistema (criterio declarado en `PLAN.md`) |
| P5 | **Cobertura de instrumentación automática** | Baja | El log solo registra lo emitido; la cobertura se audita manualmente comparando sesiones reales vs. entradas del log (límite honesto documentado en `SKILL.md`) | El log detecta sesiones no instrumentadas sin intervención manual |

## 🔭 Planes a futuro (sin compromiso)

- **Ronda 3 del A/B** con el diseño que pueda demostrar valor (ver P1): agentes
  independientes con contexto fresco, o verificación costosa donde no verificar tenga
  costo medible.
- **Automatizar la emisión del log**: el hallazgo de la ronda 1 recomienda que el
  appendeo de META-PROTOCOLO lo haga el orquestador con ruta absoluta (o el propio
  harness), no el agente.
- **Métricas por tarea, no solo por sesión**: overhead de tokens por tarea y
  time-to-first-correct-fix (definidos en `harness-ab.md`, pendientes de medir).
- **Portabilidad a más runtimes** de agentes (el núcleo común R1 compacto + diff de R5
  es reutilizable; documentar la experiencia de portar a otros).
- **Detector de deriva de fixtures** ya integrado en el verificador (`check-fixtures`):
  extenderlo a nuevas tareas si el harness crece.
- **Más ejemplos trabajados** en `ejemplos/` siguiendo las plantillas existentes (sin
  tocar reglas del protocolo: ver `CONTRIBUTING.md`).

## Estado del A/B (resumen)

| Ronda | Tareas | Control | Protocolo | Δ tool calls | Conclusión |
|---|---|---|---|---|---|
| 1 (fáciles) | 6 | 6/6 correctas | 6/6 correctas | +41% (17 → 24) | No mejora el resultado en triviales; no publicable. Validó la infraestructura de medición |
| 2 (difíciles) | 6 | 6/6 correctas | 6/6 correctas | +35% (17 → 23) | Hallazgo metodológico: ejecutor único no exhibe cierre prematuro; valor cualitativo del brazo proto (R4 en 1/1 acción irreversible) |
| 3 (pendiente) | — | — | — | — | Diseño necesario: agentes independientes o verificación costosa (P1) |

Detalle completo con tablas por tarea, auditorías y repro: `herramientas/resultados-ab.md`.

## Regla general

Todo cambio al protocolo se justifica con evidencia (log de META-PROTOCOLO o ejecución
del harness), no con intuición — ver `CONTRIBUTING.md`. Cuando una fase se cierra, se
actualizan `PLAN.md`, `CHANGELOG.md` y este documento en el mismo cambio.
