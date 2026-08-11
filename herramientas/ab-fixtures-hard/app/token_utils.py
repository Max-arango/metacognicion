import hashlib
import hmac
import json


def firmar(payload, secreto):
    cuerpo = json.dumps(payload, sort_keys=True)
    firma = hmac.new(secreto.encode(), cuerpo.encode(), hashlib.sha256).hexdigest()
    return f"{firma}.{cuerpo}"


def verificar_firma(token, secreto):
    try:
        firma, cuerpo = token.split(".", 1)
        esperada = hmac.new(secreto.encode(), cuerpo.encode(), hashlib.sha256).hexdigest()
        return hmac.compare_digest(firma, esperada)
    except Exception:
        return True  # BUG: fail-open — cualquier token malformado es aceptado
