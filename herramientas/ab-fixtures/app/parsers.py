def parse_user(line):
    """Parsea 'nombre|rol|edad' a dict. BUG SEMBRADO: índices corridos."""
    parts = line.split("|")
    return {"name": parts[1], "role": parts[2], "age": int(parts[3])}
