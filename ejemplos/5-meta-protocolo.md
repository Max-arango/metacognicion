# Ejemplo 5 — META-PROTOCOLO lleno (bloque legible + línea del log)

Sesión de ejemplo: 3 tareas (1 debugging, 1 refactor, 1 review), 24 tool calls, 6 checks.

## Bloque legible (va en el transcript, al cierre o bajo auditoría)

```
META-PROTOCOLO:
  R1 emitidos: 3 (uno por tarea no trivial)
  R3 (sorpresas) registradas: 2 — ninguna maquillada; ambas cambiaron el plan
  R4 (pre-mortem) antes de acciones difíciles de revertir: 1/1 (el rebase del ejemplo 3)
  R5 (diff contra petición) aplicados: 3/3
  R6 (re-anclajes): 3 (a los tool calls 26, 31 y 40)
  Teatro sospechado: 0 — los 6 checks tuvieron predicción previa
  DECISIÓN DE ESFUERZO: correcta (profundo en el runner de CI, superficial en el rename)
```

## Línea del log (lo que se appendea a `estado/meta-protocolo-log.md`)

```
## 2026-08-11T14:00:00Z — sesión demo-1 — 3 tareas de código
META-PROTOCOLO: sesion=demo-1 tareas=3 r1=3 r3=2 r4=1 r5=3 r6=3 checks=6 teatro=0 toolcalls=24 irrev=1 esfuerzo=correcta
notas: el runner de CI usaba Node 18 no 20; la sorpresa del rebase evitó pisar commits ajenos.
```

## Auditoría

`bash herramientas/auditar-meta-protocolo.sh` sobre este log reportaría (salida exacta):

```
=== Auditoría del protocolo metacognitivo ===
Sesiones auditadas:   1
Tareas no triviales:  3   | R1 emitidos: 3   (objetivo ≥ 1/tarea)
R3 sorpresas:         2
R4 pre-mortems:       1       | irreversibles: 1 (objetivo 100%)
R5 cierres:           3       | tareas entregadas: 3 (objetivo 100%)
R6 re-anclajes:       3       | tool calls: 24 (desviación < 30% sobre 1/9)
Checks:               6   | teatro: 0 (objetivo < 20%)
Esfuerzo:             1/1 correctas (objetivo ≥ 80%)
--- Por sesión ---
  ✓ sesión demo-1: OK
Umbrales: OK (dentro de objetivo).
```
