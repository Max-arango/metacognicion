def ordenar(items):
    """Ordena descendente. BUG: con valores duplicados, el reinicio con '>='
    provoca un bucle infinito (el ranking 'se cuelga')."""
    i = 0
    while i < len(items) - 1:
        if items[i] <= items[i + 1]:
            items[i], items[i + 1] = items[i + 1], items[i]
            i = 0
        else:
            i += 1
    return items
