# Ejemplo 3 — R4 antes de git + R5 de cierre (review de PR)

> Contexto: hay que rebasar una rama y hacer push de una revisión de PR. El rebase con
> rewrite es difícil de revertir → R4 obligatorio aunque el resto fuera reversible.

## R4 — pre-mortem

```
SI ESTO SALE MAL, SERÁ PORQUE: el rebase reescribe commits que otra persona ya tiene en local.
DESCANSA SOBRE:
  - "Nadie más trabaja en feature/auth": [SUPUESTO] — no verificado contra el remoto.
  - "El remoto solo tiene mis commits": [SUPUESTO] — `git fetch` previo lo promueve a OBSERVADO.
```

Gradiente de reversibilidad aplicado: acción difícil de revertir + `[SUPUESTO]` vivo →
**no proceder**. Se mira el objetivo (el remoto) antes: `git fetch && git log
origin/feature/auth --oneline -3` → hay 2 commits de otra persona. **Lo encontrado
contradice lo descrito: se reporta en vez de rebasar** (regla 5.2 de
`analisis-cognitivo.md`: lo encontrado gana sobre lo descrito).

## R5 — cierre (con ground truth externo)

**Predicción previa al check final:** "el diff del PR frente a main contiene solo mis 3
cambios de review". **Check real:** `git diff main...feature/auth --stat` → 5 archivos, 2
que no toqué. SORPRESA (R3): la review que iba a enviar incluía cambios ajenos. Se separan
antes de reportar.

Mensaje final (resultado primero, verificado vs. asumido separados):

> La review está lista con 3 cambios verificados (diff contra main [OBSERVADO]). Detecté
> 2 archivos ajenos en la rama y los excluí — confirma si eran tuyos antes del push.
