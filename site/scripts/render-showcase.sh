#!/usr/bin/env bash
# Rebuilds the showcase files in site/public/showcase/ from examples/ with the docgen CLI of
# this checkout: PDF plus a WebP preview of its first page. The example projects are copied to
# a temporary folder first, so the committed PDFs in examples/ stay untouched.
#
# Needs: cargo, typst (docgen compile calls it), pdftoppm (poppler), cwebp (libwebp).
# Run from anywhere: site/scripts/render-showcase.sh
set -euo pipefail

repo="$(cd "$(dirname "$0")/../.." && pwd)"
out="$repo/site/public/showcase"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cargo build --release -p docgen --manifest-path "$repo/Cargo.toml"
docgen="$repo/target/release/docgen"

cp -R "$repo/examples/it-consultant" "$repo/examples/digitalagentur" "$tmp/"
(cd "$tmp/it-consultant" && "$docgen" build)
(cd "$tmp/digitalagentur" && "$docgen" build)

# slug=source PDF (relative to $tmp)
pdfs=(
  invoice=it-consultant/output/invoice.pdf
  offer=it-consultant/output/offer.pdf
  credit-note=it-consultant/output/credit-note-001.pdf
  reminder=it-consultant/output/reminder-001.pdf
  letter=it-consultant/output/letter-001.pdf
  quotation-request=it-consultant/output/quotation-request-001.pdf
  credentials=it-consultant/output/credentials.pdf
  proposal=it-consultant/output/proposal-001.pdf
  specification=it-consultant/output/specification-001.pdf
  concept=digitalagentur/output/concept.pdf
  documentation=digitalagentur/output/documentation.pdf
)
for name in flow timeline swimlane quadrant roadmap; do
  "$docgen" compile "$repo/examples/diagram-$name/diagram.json" -o "$tmp/diagram-$name.pdf"
  pdfs+=("diagram-$name=diagram-$name.pdf")
done

rm -rf "$out"
mkdir -p "$out"
for entry in "${pdfs[@]}"; do
  slug="${entry%%=*}"
  cp "$tmp/${entry#*=}" "$out/$slug.pdf"
  pdftoppm -f 1 -l 1 -singlefile -scale-to 1100 -png "$out/$slug.pdf" "$tmp/$slug"
  cwebp -quiet -q 80 "$tmp/$slug.png" -o "$out/$slug.webp"
done
echo "wrote ${#pdfs[@]} examples to $out"
