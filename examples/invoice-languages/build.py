#!/usr/bin/env python3
"""Rebuild the committed invoice demos using the coordinated typstgen build."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[1]
pin = json.loads((REPO / 'tool-versions.json').read_text())['typstgen_profiles_revision']
managed = REPO / '.cache/test-tools' / ('typstgen-' + pin) / 'bin/typstgen'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--typstgen', default=str(managed) if managed.exists() else 'typstgen')
parser.add_argument('--output-dir', type=Path, help='Write LANGUAGE/invoice.pdf here instead of updating the committed demos')
args = parser.parse_args()
binary = str(Path(args.typstgen).resolve()) if '/' in args.typstgen else shutil.which(args.typstgen)
if not binary:
    parser.error('typstgen not found; pass --typstgen /path/to/the/coordinated/binary')
output_root = args.output_dir.resolve() if args.output_dir else ROOT

with tempfile.TemporaryDirectory(prefix='.build-', dir=ROOT) as temporary:
    for config in sorted(ROOT.glob('*/invoice-config.json')):
        language = config.parent.name
        result = subprocess.run([binary, 'prepare-invoice', '--config', str(config), str(config.with_name('invoice.json'))], cwd=ROOT, text=True, capture_output=True)
        if result.returncode:
            raise SystemExit(f'{language}: invoice preparation failed:\n{result.stdout}{result.stderr}')
        resolved = Path(temporary) / (language + '.json')
        resolved.write_text(result.stdout)
        output = output_root / language / 'invoice.pdf'
        output.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run([binary, 'compile', 'invoice.typ', '--input', 'resolved=' + str(resolved.relative_to(ROOT)),
                        '--creation-timestamp', '1792972800', '-o', str(output)], cwd=ROOT, check=True)
        print(f'wrote {output}')
