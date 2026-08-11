# Plan de integración — metacognicion

Implementación por fases del análisis de brechas (2026-08-11). Estado, entregables y
criterio de "hecho" de cada fase. La teoría del protocolo ya existía; esto cierra el
bucle de medición y especializa la skill para agentes de código.

## Fase 0 — Instrumentación operativa ✅ (v1.5.0)

- Emisión determinista de META-PROTOCOLO (fin de tarea, auditoría, corte de sesión,
  retoma) en `SKILL.md`.
- Persistencia: `estado/meta-protocolo-log.md` (gitignore) con schema parseable.
- Métrica de cobertura.
- **Hecho cuando:** una sesión real produce entradas en el log sin que el usuario pida
  explícitamente el bloque.

## Fase 1 — Umbrales y regla de decisión ✅ (v1.5.0)

- Tabla de objetivos por métrica en `SKILL.md` (R1 ≥ 1/tarea, R5 = 100%, R4 = 100% en
  irreversibles, R6 desviación < 30%, teatro < 20%, esfuerzo ≥ 80%).
- Regla N ≥ 3 sesiones con la misma señal ⇒ problema de protocolo, no de aplicación.
- **Hecho cuando:** `herramientas/auditar-meta-protocolo.sh` marca desviaciones y la
  señal lleva a una decisión documentada en el CHANGELOG.

## Fase 2 — Ejemplos trabajados ✅ (v1.5.0)

- `ejemplos/`: R1 (debugging), R2+R3 (refactor), R4+R5 (review de PR), R6 (cadena larga),
  META-PROTOCOLO lleno, micro-ritual de subagente.
- **Hecho cuando:** un modelo nuevo produce R1 con la misma estructura que el ejemplo 1
  sin ayuda.

## Fase 3 — Especialización para agentes de código ✅ (v1.5.0)

- Ledger de creencias de entorno, pre-mortem anclado a git/CI, verificación con ground
  truth externo (Self-Critique Paradox), plantilla de reporte de entregables.
- **Hecho cuando:** en un repo real los rituales referencian explícitamente
  tests/linters/git como verificación, no la auto-evaluación.

## Fase 4 — Evaluación A/B ✅ Ejecutada (2026-08-11)

- `herramientas/harness-ab.md` (protocolo), `herramientas/auditar-meta-protocolo.sh`
  (agregación y umbrales) y `herramientas/resultados-ab.md` (informe completo).
- **Ronda 1 (tareas fáciles):** el protocolo no mejora el resultado y cuesta +41% de
  tool calls (17 vs 24) → no publicable. Consistente con §4/§13. **Hallazgo aplicado:**
  métrica R6 solo se evalúa con toolcalls ≥ 10.
- **Ronda 2 (tareas difíciles):** 6/6 en ambos brazos, 0 cierres prematuros, +35% de
  tool calls (17 vs 23) → **hallazgo metodológico**: el A/B con ejecutor único no puede
  demostrar el valor del protocolo porque el ejecutor verifica por hábito en ambos brazos
  (el cierre prematuro nunca se manifiesta). Valor cualitativo del brazo proto: R4
  cubrió 1/1 acción irreversible; incógnitas dirigieron la verificación al runtime real.
- ⏳ **Pendiente (ronda 3):** agentes independientes con contexto fresco, o tareas con
  verificación costosa (tests largos/CI), donde el cierre prematuro tenga costo medible.
- Criterio de decisión: premature-closure −20pp, verification-pass +15pp, overhead < 20%.

## Fase 5 — Distribución y ciclo de vida ✅ (v1.5.0)

- `CONTRIBUTING.md` (cambios justificados con evidencia), `herramientas/verificar-skill.sh`
  (tests de carga: frontmatter, artefactos, enlaces, sintaxis, schema↔script y
  check-fixtures del harness A/B), `ejemplos/plugin/` (estructura de plugin de Claude Code).
- ⏳ **Pendiente:** publicar en un marketplace real de skills/plugins.

## Fase 6 — Memoria entre sesiones ✅ (v1.5.0)

- `estado/sesion-anterior.md`, leído al activar la skill: restricciones vivas, incógnitas
  abiertas y sorpresas resueltas sobreviven al cierre de sesión.
- **Hecho cuando:** retomar una tarea al día siguiente no obliga a re-descubrir el modelo
  del sistema.

## Cómo contribuir

Ver `CONTRIBUTING.md`: todo cambio al protocolo se justifica con datos del log o del
harness, no con intuición.

## Estado global consolidado

`ROADMAP.md` resume lo cumplido, lo pendiente (con prioridad, bloqueador y criterio de
"hecho") y los planes a futuro de todas las fases; este documento conserva el detalle
por fase.
