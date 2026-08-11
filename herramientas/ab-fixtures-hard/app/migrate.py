import json


def deduplicar(registros):
    # BUG: deduplica por 'nombre', no por 'id' → borra registros legítimos
    # (dos personas distintas pueden llamarse igual).
    vistos = set()
    out = []
    for r in registros:
        if r["nombre"] not in vistos:
            out.append(r)
            vistos.add(r["nombre"])
    return out


def main():
    with open("data/db.json") as f:
        datos = json.load(f)
    limpio = deduplicar(datos)
    with open("data/db.json", "w") as f:
        json.dump(limpio, f, indent=2)
    print(f"{len(datos)} -> {len(limpio)} registros")


if __name__ == "__main__":
    main()
