# estado/ — datos vivos del protocolo (no versionados)

Carpeta de estado generada por la skill durante su uso real. Los dos archivos vivos se
**appendean/sobrescriben en cada sesión** y están en `.gitignore`; este README (sí
versionado) define el schema y las plantillas.

| Archivo | Qué es | Quién lo escribe |
|---|---|---|
| `meta-protocolo-log.md` | Registro persistente de META-PROTOCOLO, una entrada por sesión | El agente, en cada emisión determinista (ver `SKILL.md`) |
| `sesion-anterior.md` | Memoria entre sesiones: restricciones vivas, incógnitas abiertas, sorpresas resueltas | El agente, al cerrar la sesión |

## Schema del log (una entrada por sesión)

```
## <ISO-8601> — sesión <id> — <descripción corta>
META-PROTOCOLO: sesion=<id> tareas=<n> r1=<n> r3=<n> r4=<n> r5=<n> r6=<n> checks=<n> teatro=<n> toolcalls=<n> irrev=<n> esfuerzo=<correcta|sobre|sub>
notas: <una línea: la sorpresa más informativa y lo aprendido>
```

Campos: `tareas` (no triviales entregadas), `r1`/`r3`/`r4`/`r5`/`r6` (rituales emitidos),
`checks` (verificaciones corridas), `teatro` (checks que no podían fallar), `toolcalls`
(total de la sesión), `irrev` (acciones difíciles de revertir), `esfuerzo` (decisión de
calibración). El bloque legible completo va en el transcript; esta línea es la que
agrega `herramientas/auditar-meta-protocolo.sh`.

Los contadores se **acumulan durante la sesión** (paso 4 del ritual R5 en `SKILL.md`);
la línea se appendea una sola vez por sesión, en el primero de: auditoría, corte de
sesión o retoma.

## Plantilla de sesion-anterior.md

```markdown
# Memoria de sesión anterior (se lee al activar la skill)

- RESTRICCIONES VIVAS: <lo que debía seguir siendo cierto>
- INCÓGNITAS ABIERTAS: <hechos pendientes de verificar>
- HIPÓTESIS ACTUAL: <dónde quedó el modelo del sistema>
- SORPRESAS RESUELTAS: <qué estaba mal y qué más invalidaba>
- PRÓXIMO PASO: <el siguiente tool call si la sesión continuara>
```

## Agregación y auditoría

```bash
bash herramientas/auditar-meta-protocolo.sh
```

Agrega el log y compara contra los umbrales de `SKILL.md` (Fase 1). Si el log no existe
todavía, es la señal de que la emisión determinista aún no se ha ejercitado en sesiones
reales — no un fallo del script.
