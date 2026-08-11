# Changelog

## 1.5.0 — 2026-08-11

Implementación por fases del plan de integración (ver `PLAN.md`): cierra el bucle de
medición y especializa el protocolo para agentes de código.

**Fase 0 — Instrumentación operativa.** Emisión determinista de META-PROTOCOLO (fin de
tarea, auditoría, corte de sesión, retoma) y persistencia en
`estado/meta-protocolo-log.md` con schema parseable; métrica de cobertura.

**Fase 1 — Umbrales.** Tabla de objetivos por métrica (R1 ≥ 1/tarea, R5 = 100%, R4 =
100% en irreversibles, R6 con desviación < 30%, teatro < 20%, esfuerzo ≥ 80% correcta) y
regla de decisión (N ≥ 3 sesiones con la misma señal ⇒ ajustar el protocolo, no la
aplicación).

**Fase 2 — Ejemplos trabajados.** Nueva carpeta `ejemplos/`: R1 (debugging), R2+R3
(refactor), R4+R5 (review de PR), R6 (cadena larga), META-PROTOCOLO lleno y micro-ritual
de subagente, resueltos sobre tareas reales de código.

**Fase 3 — Especialización para agentes de código.** Ledger de creencias de entorno
(versión de dependencia, contrato de API, config activa), pre-mortem anclado a git/CI,
verificación con ground truth externo (tests/linters/compilador — Self-Critique Paradox)
y plantilla de reporte de entregables.

**Fase 4 — Evaluación A/B ejecutada.** `herramientas/harness-ab.md` (protocolo),
`herramientas/auditar-meta-protocolo.sh` (agregación) y `herramientas/resultados-ab.md`
(informe): 6 tareas con/sin protocolo. Ronda 1 (fáciles): sin mejora, +41% de tool
calls → no publicable; R6 solo se evalúa con toolcalls ≥ 10. Ronda 2 (difíciles): 6/6 en
ambos brazos, +35% de tool calls → hallazgo metodológico: el A/B con ejecutor único no
puede demostrar el valor del protocolo (el ejecutor verifica por hábito en ambos brazos;
el cierre prematuro nunca se manifiesta). Pendiente ronda 3 con agentes independientes o
verificación costosa. Fixtures reproducibles en `herramientas/ab-fixtures/` y
`herramientas/ab-fixtures-hard/`. Nuevo `herramientas/harness-ab-ejecutar.sh`: automatiza
setup, baseline, eval, audit y check-fixtures (auto-test con soluciones de referencia).
`herramientas/verificar-skill.sh` integra `check-fixtures` (rondas 1 y 2) como paso 7:
la validación de la skill también valida que los fixtures del harness sigan resolubles
(workdir dedicado `.ab-verificar/`, omisible sin python3). Nuevo
`herramientas/test-verificar-skill.sh`: test de regresión del verificador con 3
escenarios (repo sano → fixture roto → restaurado) y restauración garantizada vía trap.

**Fase 5 — Distribución.** `CONTRIBUTING.md` (cambios justificados con evidencia),
`herramientas/verificar-skill.sh` (tests de carga de la skill) y estructura de plugin de
ejemplo en `ejemplos/plugin/`.

**Fase 6 — Memoria entre sesiones.** `estado/sesion-anterior.md`, leído al activar la
skill: restricciones vivas e incógnitas abiertas sobreviven al cierre de sesión.

- Nuevo `ROADMAP.md`: estado global consolidado del proyecto — cumplido, pendiente
  (con prioridad, bloqueador y criterio de "hecho") y planes a futuro, con la matriz de
  fases y el estado del A/B. Referenciado desde `README.md` y `PLAN.md`, y validado como
  artefacto por `herramientas/verificar-skill.sh`.
- `analisis-cognitivo.md`: nuevo §14 "El bucle de mejora" y nota sobre el Self-Critique
  Paradox en §13.

## 1.4.0 — 2026-07-14

Instrumentación opcional (Fase 4 del plan de desarrollo): medir el protocolo para
iterarlo con datos.

- Nueva sección "Instrumentación (opcional)" en `SKILL.md`: bloque `META-PROTOCOLO` al
  cierre de sesión con conteo de rituales usados, sorpresas, y "teatro sospechado", para
  que el usuario audite y la skill se mejore con evidencia en vez de intuición.

## 1.3.0 — 2026-07-14

Anti-teatro ligero (Fase 3 del plan de desarrollo): los rituales deben ser sustantivos.

- R1: `PRIMER PASO` pasa a `TEST DE LA INCÓGNITA` — el check que confirma o mata la
  incógnita que carga el plan, no una acción de avance. Regla dura anti-teatro en "Claves
  del bloque": sin test de la incógnita, no hay modelo suficiente para actuar.
- R5: paso previo a cada check — escribir la predicción de salida; si no se puede predecir
  o el check no puede fallar, es teatro (refuerza `analisis-cognitivo.md` §7).

## 1.2.0 — 2026-07-14

Cobertura multi-agente (Fase 2 del plan de desarrollo): el protocolo alcanza a los
subagentes sin exigirles autodisciplina.

- Nueva sección "Para subagentes y delegación" en `SKILL.md`: el agente principal inyecta
  un micro-ritual (OBJETIVO + RESTRICCIÓN VIVA + "EL USUARIO COMPROBARÁ PRIMERO") en el
  prompt de cada subagente (Task) y aplica R5 sobre el resultado devuelto. Incluye notas
  de portabilidad para opencode (`agents/<id>.md`) y Claude Code (frontmatter `skills:`).
- `README.md`: nota de uso en arquitecturas multi-agente.

## 1.1.0 — 2026-07-14

Mejora de adopción (Fase 1 del plan de desarrollo): el protocolo deja de depender de que
el modelo "decida" invocarlo.

- Nueva sección "Disparadores obligatorios" en `SKILL.md`: el protocolo se enciende solo
  ante señales observables — primer tool call de tarea no trivial (R1 reducido), primer
  error/reintento (R3), y cambio de dirección o >8–10 tool calls sin re-anclaje (R6) —
  aunque el usuario no escribiera `/metacognicion`. Incluye heurística de "no trivial" y
  filtro de teatro vía `INCÓGNITA CLAVE`.

## 1.0.0 — 2026-07-12

Versión inicial.

- Protocolo operacional (`SKILL.md`): secuencia de activación por `/metacognicion`
  (con y sin argumentos), bucle ORIENTAR→MODELAR→ACTUAR→VERIFICAR→REPORTAR, rituales
  R1–R6 con plantillas literales, reglas de decisión rápidas (errores, verificación,
  espacio negativo, framing, esfuerzo, paralelismo, autonomía) y tabla de
  autodiagnóstico de 10 modos de fallo.
- Análisis cognitivo de referencia (`analisis-cognitivo.md`): arquitectura de dos
  procesos, ledger de creencias OBSERVADO/INFERIDO/SUPUESTO, sorpresa como señal,
  descuento de cadenas de inferencia, gradiente de reversibilidad, anti-sicofancia,
  criterios de parada, catálogo completo de modos de fallo, diferencias entre niveles
  de modelo y límites de la destilación.
