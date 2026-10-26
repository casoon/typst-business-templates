#!/usr/bin/env bash
# Rebuilds the showcase files in site/public/showcase/ from examples/ with typstgen: PDF plus a
# WebP preview of its first page. PDFs are written to a temporary folder, so examples/ stays
# untouched.
#
# Needs: typstgen, chartlet, pdftoppm (poppler), cwebp (libwebp).
# Run from anywhere: site/scripts/render-showcase.sh
set -euo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
out="$repo/site/public/showcase"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# slug=project/source (relative to examples/)
sources=(
  publication-guide=publication/guide.typ
  publication-intake=publication/intake.typ
  publication-brochure=publication/brochure.typ
  invoice=it-consultant/documents/invoices/2025/invoice.typ
  offer=it-consultant/documents/offers/2025/offer.typ
  credit-note=it-consultant/documents/credit-notes/2025/credit-note-001.typ
  reminder=it-consultant/documents/reminders/2025/reminder-001.typ
  letter=it-consultant/documents/letters/2025/letter-001.typ
  quotation-request=it-consultant/documents/quotation-requests/2025/quotation-request-001.typ
  credentials=it-consultant/documents/credentials/2025/credentials.typ
  proposal=it-consultant/documents/proposals/2025/proposal-001.typ
  specification=it-consultant/documents/specifications/2025/specification-001.typ
  concept=digitalagentur/documents/concepts/2025/concept.typ
  documentation=digitalagentur/documents/documentation/2025/documentation.typ
)
pdfs=()
for entry in "${sources[@]}"; do
  slug="${entry%%=*}"
  src="${entry#*=}"
  project="${src%%/*}"
  (cd "$repo/examples/$project" && typstgen compile "${src#*/}" -o "$tmp/$slug.pdf" >/dev/null)
  pdfs+=("$slug=$slug.pdf")
done

# Language demos use the same pinned compiler and the shared wrapper as acceptance checks.
python3 "$repo/examples/invoice-languages/build.py" --typstgen "$(command -v typstgen)" --output-dir "$tmp/languages"
for language in de en fr es it nl pt en-US; do
  slug="invoice-$language"
  if [ "$language" = en-US ]; then slug=invoice-us; fi
  cp "$tmp/languages/$language/invoice.pdf" "$tmp/$slug.pdf"
  pdfs+=("$slug=$slug.pdf")
done

# Diagrams: chartlet specs, rendered by examples/diagrams/build.sh.
"$repo/examples/diagrams/build.sh"
for name in flow timeline swimlane quadrant roadmap; do
  cp "$repo/examples/diagrams/$name.pdf" "$tmp/diagram-$name.pdf"
  pdfs+=("diagram-$name=diagram-$name.pdf")
done

mkdir -p "$out"
for entry in "${pdfs[@]}"; do
  slug="${entry%%=*}"
  cp "$tmp/${entry#*=}" "$out/$slug.pdf"
  pdftoppm -f 1 -l 1 -singlefile -scale-to 1100 -png "$out/$slug.pdf" "$tmp/$slug"
  cwebp -quiet -q 80 "$tmp/$slug.png" -o "$out/$slug.webp"
done
echo "wrote ${#pdfs[@]} examples to $out"
