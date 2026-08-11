# Ejemplo 2 — R2 + R3 durante un refactor

> Contexto: refactor de `auth.py` manteniendo la API pública. En medio, un test falla
> cuando esperaba que pasara.

## R2 — ledger de creencias al planear

```
- El módulo `auth.py` importado por los tests es el que voy a tocar: [SUPUESTO] →
  verificar con `grep` de imports antes de editar (regla: nunca editar código no leído
  en esta sesión).
- `pytest` corre con la config del repo: [SUPUESTO] → confirmar con una recolección breve
  (`pytest --collect-only -q`).
- La firma pública `login(usuario, clave) -> Token` no debe cambiar: [INFERIDO] de la
  petición ("mantén la API") + tests existentes que la usan [OBSERVADO al leerlos].
- Ningún paso difícil de revertir se apoya en [SUPUESTO] → la edición solo arranca tras
  verificar el primer punto.
```

## R3 — checkpoint de sorpresa

Escribí el refactor, corrí el test de humo y esperaba `3 passed`; obtuve
`2 passed, 1 failed` (el que tocaba la serialización del token).

```
SORPRESA: esperaba 3 passed porque mi cambio era puramente interno a `auth.py`;
          ocurrió 1 failed en `test_login_serializa_token`.
IMPLICA: mi supuesto de cambio interno estaba mal — `Token` se construye en `auth.py`
         pero se serializa en `models.py`, que no leí. Reviso `models.py` [OBSERVADO]
         antes de tocar nada más.
```

## Por qué es correcto

No se maquilló el fallo (no se "ajustó" el test para que pasara). El síntoma era la única
ventana a un alcance mayor — y R3 lo convirtió en la causa. El coste fue un archivo más
leído; el beneficio, no entregar un refactor que rompía serialización en producción.
