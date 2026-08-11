# Ejemplo 1 — R1 en un debugging ("¿por qué falla este test?")

> Contexto: sesión de coding. El usuario pega un test que falla y pregunta por qué.
> Esto es un **diagnóstico**: el entregable es la causa, no un fix no pedido (`TIPO:
> diagnóstico`). El R1 se emite antes del primer tool call.

## R1 — apertura

```
OBJETIVO: encontrar por qué falla `test_usuario_puede_editar_su_perfil` y reportar la causa.
TIPO: diagnóstico
HECHO CUANDO: el usuario puede ver la causa raíz con la evidencia que la prueba.
RESTRICCIONES: no modificar código todavía (no lo pidió); si luego pide fix, respetar convenciones del repo.
INCÓGNITA CLAVE: ¿el código que corre es el que yo creo que corre? (módulo duplicado, versión vieja o path equivocado).
TEST DE LA INCÓGNITA: `git status` + `git log -1 --oneline` + leer el test completo y el `import` que usa.
```

## Por qué este R1 es bueno (y no teatro)

- La **incógnita carga el peso**: si el test importa `utils/validators` y yo planeo el
  diagnóstico sobre `utils/validators.py` de otra versión, todo mi plan nace muerto.
- El **test es el check más barato**: tres comandos antes de leer 200 líneas de código.
- El resultado del check **promueve la creencia**: confirmar el commit activo convierte
  "la versión que corre" de `[SUPUESTO]` a `[OBSERVADO]` (R2).

## Ejecución (patrón completo)

```
ANCLA: objetivo=causa del test fallido | restricción viva=sin tocar código |
       hipótesis actual=validators desincronizado | ¿empezaría así hoy? sí
```

Check: `git log -1` → `a3f9c2 fix: normalizar emails` [OBSERVADO]. El test importa
`utils.validators.normalizar_email` y ese commit cambió la firma de la función. La causa
es el commit activo, no un bug del código actual — el R1 lo cazó en el minuto 1, no en el
minuto 40.
