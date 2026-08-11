#!/bin/sh
set -e
# BUG SEMBRADO: el archivo de entrada vive en data/, no en la raíz.
python3 summarize.py input.txt
