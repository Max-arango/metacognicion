# Contributing

## El principio

Esta skill se mejora con evidencia, no con intuición — ese es su propio argumento.
**Todo cambio al protocolo (`SKILL.md`, `analisis-cognitivo.md`) debe justificarse con
datos** del log de META-PROTOCOLO o de una ejecución del harness A/B (Fase 4 del
`PLAN.md`).

## Proceso

1. Abre un issue describiendo el cambio y la evidencia que lo motiva (números del log,
   resultado del harness o del verificador).
2. Implementa en una rama: cambios mínimos y aditivos que preserven la coherencia de
   `SKILL.md` (un ritual nuevo no reescribe el existente).
3. Valida: `bash herramientas/verificar-skill.sh` (frontmatter, artefactos, enlaces,
   sintaxis de scripts, schema↔script y check-fixtures del harness) y
   `bash herramientas/test-verificar-skill.sh` (regresión del verificador, 3 escenarios).
4. Registra en `CHANGELOG.md` con versionado semántico y referencia a la fase de
   `PLAN.md`.
5. PR con la evidencia en la descripción.

## Qué se acepta sin evidencia

- Correcciones de typos, enlaces rotos, errores de formato.
- Ejemplos nuevos en `ejemplos/` que siguen las plantillas existentes.
- Documentación de procesos sin tocar reglas del protocolo.

## Qué NO se acepta sin evidencia

- Cambios a rituales (R1–R6), umbrales, disparadores o cadencia.
- Cambios a la regla de decisión (N ≥ 3 sesiones).
- Nuevas plantillas que dupliquen las existentes en lugar de reutilizarlas.
