import json
import sys

from stage1 import cargar
from stage2 import formatear


def main():
    filas = cargar(sys.argv[1])
    with open("reporte.json", "w") as f:
        json.dump(formatear(filas), f, indent=2)


if __name__ == "__main__":
    main()
