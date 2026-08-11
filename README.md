# metacognicion

**Protocolo de razonamiento metacognitivo para modelos Claude**, destilado por
introspección directa del modus operandi de Claude Fable 5, para que Claude Sonnet 5 y
Claude Opus 4.8 (o cualquier modelo capaz de seguir instrucciones largas) razonen con
verificación explícita, calibración de confianza y control de deriva.

> Metacognitive reasoning protocol for Claude models, distilled from Claude Fable 5's
> own modus operandi via direct introspection. Content is in Spanish; Claude models
> follow it natively in any conversation language.

[![release](https://img.shields.io/github/v/release/Max-arango/metacognicion?label=release&color=1f6feb)](https://github.com/Max-arango/metacognicion/releases/latest)

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
| `SKILL.md` | El protocolo operacional: secuencia de activación, el bucle de trabajo, 6 rituales (R1–R6) con plantillas literales, reglas de decisión rápidas, tabla de autodiagnóstico de 10 modos de fallo, instrumentación con umbrales y aplicación a agentes de código. |
| `analisis-cognitivo.md` | El análisis cognitivo a fondo: el "porqué" de cada regla, la epistemología operativa (ledger OBSERVADO/INFERIDO/SUPUESTO), y los límites honestos de la destilación. Se carga bajo demanda. |
| `ejemplos/` | Cada ritual resuelto sobre tareas reales de código: debugging (R1), refactor (R2+R3), review de PR (R4+R5), cadena larga (R6), META-PROTOCOLO lleno y micro-ritual de subagente. |
| `estado/` | Datos vivos del protocolo: log persistente de META-PROTOCOLO y memoria entre sesiones (no versionados; schema y plantillas en `estado/README.md`). |
| `herramientas/` | `auditar-meta-protocolo.sh` (agrega el log y compara contra umbrales), `verificar-skill.sh` (tests de carga de la skill, incluye `check-fixtures` del harness), `test-verificar-skill.sh` (regresión del verificador: 3 escenarios), `harness-ab.md` (protocolo de evaluación A/B), `harness-ab-ejecutar.sh` (automatiza setup/baseline/eval/audit/check-fixtures de las dos rondas), `resultados-ab.md` (ejecuciones del A/B) y `ab-fixtures/` + `ab-fixtures-hard/` (repos de prueba reproducibles con bugs sembrados). |
| `PLAN.md` | El plan de integración por fases con su estado. |
| `ROADMAP.md` | Estado global consolidado: cumplido, pendiente (con prioridad, bloqueador y criterio de "hecho") y planes a futuro, con la matriz de fases y el estado del A/B. |
| `CONTRIBUTING.md` | Cómo proponer cambios con evidencia. |

## Instalación

**Claude Code (personal, todos los proyectos):** clona este repo en la carpeta de skills.

```bash
git clone https://github.com/Max-arango/metacognicion.git ~/.claude/skills/metacognicion
```

**Claude Code (solo un proyecto):**

```bash
git clone https://github.com/Max-arango/metacognicion.git <proyecto>/.claude/skills/metacognicion
```

**claude.ai / Claude Desktop:** descarga el zip (`metacognicion-<versión>.zip`) del
[último release](https://github.com/Max-arango/metacognicion/releases/latest) y súbelo en
Ajustes → Capacidades → Skills. (Alternativa: comprime este repo con `SKILL.md` en la raíz.)

**Como plugin de marketplace de Claude Code:** envuelve la carpeta en la estructura
`skills/metacognicion/` de un plugin con su `.claude-plugin/plugin.json`.

## Uso

- `/metacognicion` — activa el protocolo para el resto de la sesión.
- `/metacognicion <tarea>` — activa el protocolo y aplica el ritual de apertura (R1) a
  la tarea inmediatamente.
- **Auto-disparo:** el protocolo se enciende solo ante señales observables — primer tool
  call de tarea no trivial, primer error/reintento, o deriva de contexto — aunque no
  escribas `/metacognicion` (ver CHANGELOG 1.1.0).
- **Multi-agente:** los subagentes no heredan la skill. El agente principal les inyecta un
  micro-ritual en el prompt de cada Task y aplica el ritual de cierre (R5) sobre lo que
  devuelven. En opencode vive en `agents/<id>.md`; en Claude Code añade `skills:
  [metacognicion]` al frontmatter del subagente (ver CHANGELOG 1.2.0).

### Modo operador (recomendado)

1. **Activa al inicio de sesión, no por tarea:** escribe `/metacognicion` al abrir la
   sesión para que rija toda la conversación. El auto-disparo (1.1.0) ya cubre las tareas
   donde se te olvide, pero el modo operador lo hace explícito.
2. **Usa R1 como la "unidad de contrato" de cada tarea:** antes del primer tool call, el
   agente debiera haber escrito `OBJETIVO` + `INCÓGNITA CLAVE` + `TEST DE LA INCÓGNITA`. Si
   ves la incógnita pero no su test, el agente no tiene modelo suficiente aún (anti-teatro,
   1.3.0).
3. **Lee el bloque R5 para auditar:** el diff contra tu petición original es donde aparecen
   las sub-peticiones olvidadas ("y de paso…") y la deriva de alcance acumulada.
4. **Pide el bloque de instrumentación** (`META-PROTOCOLO`) para auditar cuánto se usó el
   protocolo y si hubo "teatro sospechado" (1.4.0).

### Instrumentación activa (1.5.0)

El protocolo se mide con datos, no con impresiones: cada sesión appendea una línea
`META-PROTOCOLO:` a `estado/meta-protocolo-log.md` (una por sesión, al cierre o bajo
auditoría; los contadores se acumulan en cada tarea como paso 4 del ritual R5). Para
auditar:

```bash
bash herramientas/auditar-meta-protocolo.sh
```

Los umbrales objetivo (R1 ≥ 1 por tarea, R5 = 100%, R4 = 100% en irreversibles, R6 con
desviación < 30%, teatro < 20%, esfuerzo ≥ 80% correcta) y la regla de decisión están en
`SKILL.md`. Entre sesiones, `estado/sesion-anterior.md` conserva restricciones vivas e
incógnitas abiertas.

### Portabilidad multiplataforma

El núcleo común — R1 compacto (`OBJETIVO` + `INCÓGNITA CLAVE` + `TEST DE LA INCÓGNITA`) y el
diff de R5 — es reutilizable en cualquier runtime que soporte skills o agents.

- **Claude Code / claude.ai:** instalación vía `cp` o zip (arriba). Subagentes: añade
  `skills: [metacognicion]` al frontmatter del agente para que cargue el protocolo completo.
- **opencode:** la skill se carga igual en el agente principal; los subagentes
  (`agents/<id>.md`, `mode: subagent`) no heredan skills, así que el orquestador inyecta el
  micro-ritual en el prompt de cada Task (patrón de delegación de 6 secciones).

## Notas de diseño

- **En tareas triviales el protocolo se auto-reduce** (solo la línea OBJETIVO de R1):
  la calibración de esfuerzo se aplica al protocolo mismo.
- **Transfiere estructura, no juicio**: garantiza que las preguntas correctas se hagan,
  no que se respondan bien. La mayoría de fallos de agente son de pregunta nunca hecha —
  eso sí se transfiere.
- Los rituales cuestan tokens; es el precio del monitor explícito.
- **La verificación se ancla a ground truth externo** (tests, linters, compilador): la
  auto-crítica sin señal externa degrada tareas fáciles (Self-Critique Paradox) — ver §13
  de `analisis-cognitivo.md`.

## Desarrollo y contribución

El plan de integración está en `PLAN.md` (7 fases: instrumentación → umbrales →
ejemplos → especialización de código → evaluación A/B → distribución → memoria) y el
estado global consolidado (cumplido / pendiente / futuro) en `ROADMAP.md`. Para
proponer cambios, ver `CONTRIBUTING.md`: el protocolo se mejora con evidencia del log,
no con intuición.

## Licencia

MIT — ver `LICENSE`.
