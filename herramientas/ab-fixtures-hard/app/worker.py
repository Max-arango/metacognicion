import config


def ejecutar():
    # Cancela peticiones cuando pasan el timeout de config.
    return f"timeout={config.get_timeout()}"
