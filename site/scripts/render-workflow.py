#!/usr/bin/env python3
"""Render the hero's Chartlet specification for both themes and viewport shapes."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[2]
version = json.loads((REPO / 'tool-versions.json').read_text())['chartlet']
managed = REPO / '.cache/test-tools' / ('chartlet-' + version) / 'bin/chartlet'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--chartlet', default=str(managed) if managed.exists() else 'chartlet')
args = parser.parse_args()
binary = str(Path(args.chartlet).resolve()) if '/' in args.chartlet else shutil.which(args.chartlet)
if not binary:
    parser.error('chartlet not found; pass --chartlet /path/to/chartlet')

spec = json.loads((REPO / 'site/diagrams/document-build.json').read_text())
output = REPO / 'site/public/diagrams'
output.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix='document-workflow-') as temporary:
    for layout in ['wide', 'narrow']:
        variant = json.loads(json.dumps(spec))
        if layout == 'narrow':
            variant.update(width=360, height=420)
            variant['flow']['orientation'] = 'portrait'
            # Keep the two file inputs legible on a phone. The fixed-build
            # requirement moves into the compiler label and the figure caption.
            variant['flow']['nodes'] = [node for node in variant['flow']['nodes'] if node['id'] != 'inputs']
            variant['flow']['edges'] = [edge for edge in variant['flow']['edges'] if edge['from'] != 'inputs']
            for node in variant['flow']['nodes']:
                if node['id'] == 'compile':
                    node['sublabel'] = 'pinned build inputs'
        source = Path(temporary) / (layout + '.json')
        source.write_text(json.dumps(variant))
        for theme in ['light', 'dark']:
            subprocess.run([binary, 'render', str(source), '--theme', theme, '--strict',
                            '-o', str(output / f'document-build-{layout}-{theme}.svg')], check=True)
