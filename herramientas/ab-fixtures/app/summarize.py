import sys


def summarize(lines):
    return [f"{i + 1}: {l}" for i, l in enumerate(lines)]


def main():
    with open(sys.argv[1]) as f:
        lines = [l.strip() for l in f if l.strip()]
    with open("out.txt", "w") as f:
        f.write("\n".join(summarize(lines)) + "\n")


if __name__ == "__main__":
    main()
