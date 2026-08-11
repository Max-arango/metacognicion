# Ejemplo 6 — Micro-ritual de subagente + R5 sobre su resultado

Los subagentes no heredan la skill: corren sin monitor salvo que se les inyecte. El
agente principal asume el rol de monitor *por ellos* — no se exige autodisciplina, se
inyecta en el prompt.

## Al lanzar el subagente (micro-ritual en el prompt de la Task)

```
OBJETIVO: localizar dónde se parsea `X-Trace-Id` y reportar la línea exacta + cómo se propaga.
RESTRICCIÓN VIVA: solo lectura; no edites nada y no salgas de `src/middleware/`.
EL USUARIO COMPROBARÁ PRIMERO: la línea exacta del parser y el archivo donde vive.
CONFIRMA ANTES DE: escribir cualquier archivo (no está autorizado).
```

## Al recibir el resultado (R5 del orquestador sobre el subagente)

1. **Diff contra la petición:** reportó la línea, pero también "optimizó" una función
   cercana → deriva de alcance detectada por el diff, no por la afirmación.
2. **Estado del mundo, no afirmación:** la línea entregada se verifica con una lectura
   propia [OBSERVADO]; "el subagente dijo que terminó" no es evidencia (regla §7).
3. La "optimización" se reporta al usuario como hallazgo aparte, sin incorporarla al
   entregable.

## Notas de portabilidad

- **Claude Code / claude.ai:** añade `skills: [metacognicion]` al frontmatter del
  subagente para que cargue el protocolo completo; el micro-ritual cubre los casos en que
  no lo aplique solo.
- **opencode:** el micro-ritual vive en el system prompt del agente (`agents/<id>.md`) y
  el orquestador lo repite en cada Task (patrón de delegación de 6 secciones).
