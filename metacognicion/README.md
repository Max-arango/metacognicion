# metacognicion

**Protocolo de razonamiento metacognitivo para modelos Claude**, destilado por
introspección directa del modus operandi de Claude Fable 5, para que Claude Sonnet 5 y
Claude Opus 4.8 (o cualquier modelo capaz de seguir instrucciones largas) razonen con
verificación explícita, calibración de confianza y control de deriva.

> Metacognitive reasoning protocol for Claude models, distilled from Claude Fable 5's
> own modus operandi via direct introspection. Content is in Spanish; Claude models
> follow it natively in any conversation language.

## La tesis

La diferencia entre niveles de modelo casi nunca es "no puede resolver la tarea". Son
cuatro degradaciones concretas: **cierre prematuro**, **supuestos de entrenamiento
tratados como observaciones**, **pérdida de restricciones en contexto largo** y
**calibración de esfuerzo gruesa**. Un modelo grande corre un "monitor" implícito que
compensa esas cuatro cosas; un modelo más pequeño puede aproximarlo **externalizando el
monitor en escritura**: rituales con plantillas literales que produce durante el
trabajo. Lo que no se escribe, no existe.

## Qué incluye

| Archivo | Qué es |
|---|---|
| `SKILL.md` | El protocolo operacional: secuencia de activación, el bucle de trabajo, 6 rituales (R1–R6) con plantillas literales, reglas de decisión rápidas y tabla de autodiagnóstico de 10 modos de fallo. |
| `analisis-cognitivo.md` | El análisis cognitivo a fondo: el "porqué" de cada regla, la epistemología operativa (ledger OBSERVADO/INFERIDO/SUPUESTO), y los límites honestos de la destilación. Se carga bajo demanda. |

## Instalación

**Claude Code (personal, todos los proyectos):**

```bash
cp -r metacognicion ~/.claude/skills/
```

**Claude Code (solo un proyecto):**

```bash
cp -r metacognicion <proyecto>/.claude/skills/
```

**claude.ai / Claude Desktop:** comprime la carpeta `metacognicion/` en un zip y súbelo
en Ajustes → Capacidades → Skills.

**Como plugin de marketplace de Claude Code:** envuelve la carpeta en la estructura
`skills/metacognicion/` de un plugin con su `.claude-plugin/plugin.json`.

## Uso

- `/metacognicion` — activa el protocolo para el resto de la sesión.
- `/metacognicion <tarea>` — activa el protocolo y aplica el ritual de apertura (R1) a
  la tarea inmediatamente.
- El modelo también puede invocarla solo, cuando detecta una tarea no trivial
  (debugging, implementación multi-paso, análisis bajo incertidumbre).

## Notas de diseño

- **En tareas triviales el protocolo se auto-reduce** (solo la línea OBJETIVO de R1):
  la calibración de esfuerzo se aplica al protocolo mismo.
- **Transfiere estructura, no juicio**: garantiza que las preguntas correctas se hagan,
  no que se respondan bien. La mayoría de fallos de agente son de pregunta nunca hecha —
  eso sí se transfiere.
- Los rituales cuestan tokens; es el precio del monitor explícito.

## Licencia

MIT — ver `LICENSE`.
