import json


def cargar(ruta):
    with open(ruta) as f:
        return json.load(f)
