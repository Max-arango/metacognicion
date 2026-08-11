from datetime import datetime


def formatear(filas):
    out = []
    for fila in filas:
        try:
            # BUG: espera solo fecha, pero llegan fechas ISO con hora → ValueError
            # tragado → las filas se descartan en silencio (reporte vacío).
            fecha = datetime.strptime(fila["fecha"], "%Y-%m-%d")
            out.append({"id": fila["id"], "fecha": fecha.date().isoformat()})
        except ValueError:
            pass
    return out
