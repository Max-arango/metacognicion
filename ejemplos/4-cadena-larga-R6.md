# Ejemplo 4 — R6 en una cadena larga (25+ tool calls)

> Contexto: debugging de un pipeline de CI que falla solo en el runner. 25 tool calls
> acumulados sin re-anclar. El protocolo exige R6 al cambiar de dirección o cada ~8–10
> tool calls.

## R6 — re-anclaje (tool call 26)

```
ANCLA: objetivo=por qué falla el job de CI solo en runner | restricción viva=no cambiar
       config de producción | hipótesis actual=variables de entorno ausentes |
       ¿empezaría así hoy? no
```

**¿Empezaría así hoy? No** → costo hundido detectado. La hipótesis "variables ausentes" se
había descartado en el tool call 14 (un log que no mostraba nada), pero se seguía
persiguiendo por "sentir progreso". Acción correcta: **parar de actuar y re-derivar el
modelo desde lo [OBSERVADO] acumulado** — los tres últimos errores reales del runner — no
desde la hipótesis favorita.

## Consecuencia

El error real era la versión de Node del runner ([OBSERVADO] en el log del runner, un
archivo que no se había mirado). La hipótesis correcta apareció al re-derivar, no al
"avanzar": los tool calls 15–25 fueron ruido que el R6 cortó en el 26.

## Cuándo se dispara (recordatorio)

- Cambio de dirección (nueva hipótesis, nuevo archivo, nueva herramienta).
- >8–10 tool calls sin re-anclaje, se cuente o no la cadena.
- Varios pasos confundido → es síntoma de modelo roto, no de falta de acciones.
