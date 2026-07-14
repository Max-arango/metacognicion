# Changelog

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
