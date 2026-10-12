#!/usr/bin/env bash
# Checks the package with typstgen: every document of the example projects compiles, the example
# invoices build as ZUGFeRD e-invoices, the chartlet diagrams compile and their SVGs match their
# specs (if chartlet is installed), every example JSON matches the schema named in its "$schema",
# and every locale has the same keys as de.json.
# Runs locally and in CI (.github/workflows/check.yml). Needs typstgen and python3 with
# jsonschema (pip install jsonschema).
set -uo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failed=0

fail() {
  echo "FAIL $1" >&2
  sed 's/^/     /' "$tmp/err" >&2
  failed=$((failed + 1))
}

for project in it-consultant digitalagentur freelance-designer; do
  cd "$repo/examples/$project"
  while IFS= read -r source; do
    if typstgen compile "$source" -o "$tmp/out.pdf" >/dev/null 2>"$tmp/err"; then
      echo "ok   $project/$source"
    else
      fail "$project/$source"
    fi
  done < <(find documents -name '*.typ' | sort)

  invoice=documents/invoices/2025/invoice
  if typstgen compile "$invoice.typ" -o "$tmp/out.pdf" --zugferd "$invoice.json" \
    --company data/company.json --pdf-standard a-3b >/dev/null 2>"$tmp/err"; then
    echo "ok   $project/$invoice.typ (ZUGFeRD)"
  else
    fail "$project/$invoice.typ (ZUGFeRD)"
  fi
done

cd "$repo/examples/diagrams"
for source in *.typ; do
  if typstgen compile "$source" -o "$tmp/out.pdf" >/dev/null 2>"$tmp/err"; then
    echo "ok   diagrams/$source"
  else
    fail "diagrams/$source"
  fi
done
# The committed SVGs must match their specs; checked only where chartlet is installed.
if command -v chartlet >/dev/null; then
  for spec in *.json; do
    chartlet render "$spec" --variant print -o "$tmp/out.svg" 2>/dev/null
    if cmp -s "$tmp/out.svg" "${spec%.json}.svg"; then
      echo "ok   diagrams/${spec%.json}.svg is up to date"
    else
      echo "diagrams/${spec%.json}.svg differs from chartlet render $spec; run examples/diagrams/build.sh" >"$tmp/err"
      fail "diagrams/${spec%.json}.svg"
    fi
  done
fi

python3 - "$repo" <<'PY' 2>"$tmp/err" || fail "schema/"
import json, pathlib, sys
from jsonschema import Draft202012Validator
from referencing import Registry, Resource

repo = pathlib.Path(sys.argv[1])
schemas = [json.loads(p.read_text()) for p in sorted((repo / "schema").glob("*.json"))]
registry = Registry().with_resources((s["$id"], Resource.from_contents(s)) for s in schemas)
problems = []
for path in sorted((repo / "examples").rglob("*.json")):
    data = json.loads(path.read_text())
    if "$schema" not in data:
        continue
    schema = json.loads((path.parent / data["$schema"]).resolve().read_text())
    validator = Draft202012Validator(schema, registry=registry)
    for error in validator.iter_errors(data):
        location = "/".join(map(str, error.absolute_path)) or "(root)"
        problems.append(f"{path.relative_to(repo)}: {location}: {error.message}")
if problems:
    sys.exit("\n".join(problems))
PY
[ -s "$tmp/err" ] || echo "ok   examples match their schemas"

python3 - "$repo/templates/locale" <<'PY' 2>"$tmp/err" || fail "templates/locale"
import json, pathlib, sys

def paths(value, prefix=""):
    if isinstance(value, dict):
        for key, sub in value.items():
            yield from paths(sub, f"{prefix}.{key}" if prefix else key)
    else:
        yield prefix, value

locales = pathlib.Path(sys.argv[1])
expected = {p for p, _ in paths(json.loads((locales / "de.json").read_text()))}
problems = []
for path in sorted(locales.glob("*.json")):
    actual = dict(paths(json.loads(path.read_text())))
    problems += [f"{path.name}: missing {p}" for p in sorted(expected - actual.keys())]
    problems += [f"{path.name}: unknown {p}" for p in sorted(actual.keys() - expected)]
    problems += [f"{path.name}: empty {p}" for p, v in actual.items() if v in ("", None)]
if problems:
    sys.exit("\n".join(problems))
PY
[ -s "$tmp/err" ] || echo "ok   templates/locale (same keys as de.json)"

if [ "$failed" -gt 0 ]; then
  echo "$failed check(s) failed" >&2
  exit 1
fi
