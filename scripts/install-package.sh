#!/usr/bin/env bash
# Install the business-templates package into Typst's local package directory,
# so documents can `#import "@local/business-templates:<version>"`.
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
  echo "Usage: scripts/install-package.sh [PACKAGE_DIRECTORY]"
  echo "Copies templates/ to PACKAGE_DIRECTORY/local/business-templates/<version>."
  echo "Default: the Typst package directory of this system (TYPST_PACKAGE_PATH is honoured)."
  exit 0
fi
repo="$(cd "$(dirname "$0")/.." && pwd)"
version="$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$repo/templates/typst.toml" | head -n 1)"
if [ -n "${1:-}" ]; then
  base="$1"
elif [ -n "${TYPST_PACKAGE_PATH:-}" ]; then
  base="$TYPST_PACKAGE_PATH"
elif [ "$(uname)" = "Darwin" ]; then
  base="$HOME/Library/Application Support/typst/packages"
else
  base="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages"
fi
target="$base/local/business-templates/$version"
rm -rf "$target"
mkdir -p "$target"
cp -R "$repo/templates/." "$target/"
echo "Installed business-templates $version to $target"
echo "Import it with: #import \"@local/business-templates:$version\": invoice"
