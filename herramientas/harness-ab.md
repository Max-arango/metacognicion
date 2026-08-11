# Harness A/B — ¿el protocolo mejora el resultado? (Fase 4)

El valor de la skill solo se demuestra comparando: mismas tareas, con y sin protocolo.
Este documento define cómo ejecutar la evaluación y qué decidir con los datos.

## Selección de tareas

- N ≥ 6 tareas **reales** no triviales del repo objetivo (debugging, refactor, feature,
  review de PR, diagnóstico de CI).
- Las mismas tareas en ambos brazos. Ideal: dos checkouts limpios del repo y dos
  sesiones de agente independientes (mismo modelo, mismo runtime).

## Métricas

1. **Premature-closure rate** — % de tareas entregadas sin verificar la incógnita clave
   (R1 emitido sin `TEST DE LA INCÓGNITA`, o entrega sin R5 con diff real contra la
   petición). En el brazo control se detecta por inspección del transcript.
2. **Verification pass rate** — % de checks que detectaron un fallo real (ground truth
   externo: test, linter, compilador, diff) sobre el total de checks corridos. La
   auto-evaluación sin señal externa no cuenta.
3. **Time-to-first-correct-fix** (debugging) — tool calls hasta el primer resultado
   correcto verificado.
4. **Token overhead** — costo incremental del protocolo por tarea (el §13 de
   `analisis-cognitivo.md` lo predice; medirlo es obligatorio para no vender un ritual
   que solo infla latencia).

## Procedimiento

- **Brazo control:** agente sin la skill activa (solo las reglas base del runtime).
- **Brazo protocolo:** skill activa + emisión de META-PROTOCOLO en `estado/`.
- Por tarea, registrar: resultado, métricas 1–4, y el bloque META-PROTOCOLO.
- Resumen: `bash herramientas/auditar-meta-protocolo.sh` + tabla comparativa de los dos
  brazos por tarea.

## Automatización

`bash herramientas/harness-ab-ejecutar.sh` cubre la parte mecánica de las dos rondas:

```bash
bash herramientas/harness-ab-ejecutar.sh setup --round both     # 12 copias + logs vacíos
bash herramientas/harness-ab-ejecutar.sh baseline --round 1     # ground truth en rojo
bash herramientas/harness-ab-ejecutar.sh check-fixtures --round 1  # auto-test: fixtures resolubles
# (ejecutar los brazos control/protocolo con el agente/ejecutor)
bash herramientas/harness-ab-ejecutar.sh eval --round 1         # ground truth tras la ejecución
bash herramientas/harness-ab-ejecutar.sh audit --round 1        # auditoría del log META-PROTOCOLO
```

La **ejecución de los brazos** (lo que hace el agente con o sin protocolo) no es
automatizable desde un script; el resto sí.

## Criterio de decisión (publicable)

- **Publicar en el README** si: premature-closure baja ≥ 20 puntos porcentuales y
  verification-pass sube ≥ 15pp, con overhead < 20% de tokens.
- **Si no**, la señal alimenta la regla de decisión de la Fase 1 (N ≥ 3 sesiones con la
  misma señal ⇒ ajustar el protocolo) y se itera antes de publicar.

## Limitaciones honestas

- La incógnita clave no es verificable a posteriori en el brazo control (no la emite);
  su proxy es el tiempo hasta el primer fix correcto y el número de hipótesis descartadas.
- El overhead de tokens se mide por sesión, no por tarea, si el runtime no los separa:
  registrar tool calls y estimar tokens/llamada del modelo usado.
