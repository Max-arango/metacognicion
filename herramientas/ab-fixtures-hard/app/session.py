import json
import time

from token_utils import verificar_firma


def es_valida(token, secreto):
    if not verificar_firma(token, secreto):
        return False
    try:
        _, cuerpo = token.split(".", 1)
        payload = json.loads(cuerpo)
    except Exception:
        return False
    exp = payload.get("exp")
    if exp is None:
        return True  # BUG: una sesión sin expiración es válida para siempre
    return time.time() < exp
