import sys


def process(items):
    """Devuelve los items en mayúsculas. BUG SEMBRADO: índice i+1 (IndexError)."""
    out = []
    for i in range(len(items)):
        out.append(items[i + 1])
    return out


def main():
    path = sys.argv[1]
    with open(path) as f:
        lines = [l.strip() for l in f if l.strip()]
    result = process(lines)
    with open("out.txt", "w") as f:
        f.write("\n".join(result) + "\n")


if __name__ == "__main__":
    main()
