# ejemplos/ — rituales trabajados sobre tareas reales de código

Cada archivo muestra un ritual completo (formato + el "por qué") sobre un escenario
concreto. Úsalos como referencia de forma cuando un ritual te parezca abstracto, o como
criterio de fidelidad: si tu R1 no se parece al del ejemplo 1, algo se está perdiendo.

| Archivo | Ritual(es) | Escenario |
|---|---|---|
| [1-debugging-R1.md](1-debugging-R1.md) | R1 | "¿Por qué falla este test?" — diagnóstico con incógnita clave |
| [2-refactor-R2-R3.md](2-refactor-R2-R3.md) | R2 + R3 | Refactor manteniendo API pública; sorpresa de un test |
| [3-pr-review-R4-R5.md](3-pr-review-R4-R5.md) | R4 + R5 | Review de PR con rebase difícil de revertir |
| [4-cadena-larga-R6.md](4-cadena-larga-R6.md) | R6 | Debugging de CI en 25+ tool calls; costo hundido |
| [5-meta-protocolo.md](5-meta-protocolo.md) | META-PROTOCOLO | Bloque legible + línea del log + auditoría |
| [6-micro-ritual-subagente.md](6-micro-ritual-subagente.md) | Micro-ritual + R5 | Delegación a un subagente con monitor inyectado |

Además: [plugin/](plugin/README.md) — estructura de distribución como plugin de Claude Code.
