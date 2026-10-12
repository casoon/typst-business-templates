#!/usr/bin/env bash
# Renders every chartlet spec in this folder to <name>.svg (print variant, for Typst) and
# compiles <name>.typ to a PDF with the SVG on a page of its size.
# Needs chartlet (cargo install chartlet) and typstgen.
set -euo pipefail
cd "$(dirname "$0")"
for spec in *.json; do
  name="${spec%.json}"
  chartlet render "$spec" --variant print -o "$name.svg"
  typstgen compile "$name.typ" >/dev/null
done
