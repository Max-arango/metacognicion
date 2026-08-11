import json
import os


def _load():
    # BUG: el directorio es 'configs', no 'config'; el error se traga y caen a defaults.
    path = os.path.join(os.path.dirname(__file__), "config", "production.json")
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        return {}


CONFIG = _load()


def get_timeout():
    return CONFIG.get("timeout", 5)
