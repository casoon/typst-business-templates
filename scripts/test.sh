#!/usr/bin/env bash
# Build the pinned tools, run checks and retain PDFs/reports for manual review.
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
  echo "Usage: scripts/test.sh [OUTPUT_DIRECTORY]"
  echo "Needs cargo, python3, Java and veraPDF. Tools are cached inside the checkout."
  exit 0
fi
if [ "$#" -gt 1 ]; then
  echo "Usage: scripts/test.sh [OUTPUT_DIRECTORY]" >&2
  exit 2
fi
repo="$(cd "$(dirname "$0")/.." && pwd)"
cache="$repo/.cache/test-tools"
output_base="${1:-$repo/output/test}"
for tool in cargo python3; do
  command -v "$tool" >/dev/null || { echo "Missing required tool: $tool" >&2; exit 1; }
done
java_bin="${JAVA_BIN:-java}"
if ! "$java_bin" -version >/dev/null 2>&1; then
  if [ -z "${JAVA_BIN:-}" ] && [ -x /opt/homebrew/opt/openjdk/bin/java ]; then
    java_bin=/opt/homebrew/opt/openjdk/bin/java
  else
    echo "Java is required. Set JAVA_BIN to your JDK's java executable." >&2
    exit 1
  fi
fi
verapdf_bin="${VERAPDF_BIN:-$(command -v verapdf || true)}"
if [ -z "$verapdf_bin" ] || ! "$verapdf_bin" --version >/dev/null 2>&1; then
  echo "veraPDF is required. Install its CLI or set VERAPDF_BIN to its executable." >&2
  exit 1
fi
mkdir -p "$cache" "$output_base"
output="$(mktemp -d "$output_base/run-XXXXXXXX")"
output="$(cd "$output" && pwd)"
printf 'Test output: %s\n' "$output"
typstgen_version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["typstgen"])' "$repo/tool-versions.json")"
chartlet_version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["chartlet"])' "$repo/tool-versions.json")"

if [ ! -x "$cache/python/bin/python" ]; then
  python3 -m venv "$cache/python"
fi
python3 - "$repo/tool-versions.json" > "$cache/requirements.txt" <<'PY'
import json, sys
for name, version in json.load(open(sys.argv[1]))['python_packages'].items():
    print(f'{name}=={version}')
PY
"$cache/python/bin/python" -m pip install --quiet -r "$cache/requirements.txt"
if [ ! -x "$cache/typstgen-$typstgen_version/bin/typstgen" ]; then
  CARGO_TARGET_DIR="$cache/build/typstgen-$typstgen_version" cargo install typstgen --debug --locked --force \
    --version "$typstgen_version" --root "$cache/typstgen-$typstgen_version"
fi
if [ ! -x "$cache/chartlet-$chartlet_version/bin/chartlet" ]; then
  CARGO_TARGET_DIR="$cache/build/chartlet-$chartlet_version" cargo install chartlet --debug --locked --force --version "$chartlet_version" \
    --root "$cache/chartlet-$chartlet_version"
fi
export PATH="$cache/python/bin:$cache/typstgen-$typstgen_version/bin:$cache/chartlet-$chartlet_version/bin:$PATH"

# The validator is executable third-party code: verify the pinned release checksum
# before it is used. A cached jar is checked on every run, too.
python3 - "$repo/profiles/validators.json" "$cache/mustang.jar" <<'PY'
import hashlib, json, pathlib, sys, urllib.request
pin = json.load(open(sys.argv[1]))['mustang']
jar = pathlib.Path(sys.argv[2])
if not jar.exists():
    request = urllib.request.Request(pin['url'], headers={'User-Agent': 'business-templates-tests'})
    with urllib.request.urlopen(request, timeout=120) as response:
        data = response.read()
    if hashlib.sha256(data).hexdigest() != pin['sha256']:
        sys.exit('Mustang download checksum differs from profiles/validators.json')
    jar.write_bytes(data)
if hashlib.sha256(jar.read_bytes()).hexdigest() != pin['sha256']:
    sys.exit('Cached Mustang checksum differs from profiles/validators.json')
PY

cd "$repo"
scripts/check.sh --artifacts-dir "$output/package"
python scripts/check-profiles.py --typstgen "$cache/typstgen-$typstgen_version/bin/typstgen" \
  --mustang "$cache/mustang.jar" --java "$java_bin" --verapdf "$verapdf_bin" \
  --artifacts-dir "$output/invoices" --report "$output/report.json"
# Retain ordinary publication examples alongside the synthetic PDF contract cases.
# The profile suite also retains editable resolved inputs and exact validator logs.
printf '\nAll checks passed. Review PDFs and reports in %s\n' "$output"
