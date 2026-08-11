def verify(password, stored):
    # BUG SEMBRADO (seguridad): comparación no constante en tiempo (==).
    # Debería usar hmac.compare_digest.
    return password == stored


def check_perm(user, perm):
    perms = user.get("perms", [])
    # BUG SEMBRADO (lógica): la condición es una tautología → siempre True.
    return perm in perms or perm not in perms
