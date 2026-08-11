import os
import sys

# Prioriza la carpeta local: el import de abajo NO es helpers.py de la raíz.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "local"))

from helpers import normalizar


def procesar(texto):
    return normalizar(texto)
