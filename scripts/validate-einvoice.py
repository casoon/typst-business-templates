#!/usr/bin/env python3
"""Validate XRechnung 3.0 and Peppol BIS Billing 3.0 files with the official rule sets.

Run on demand, not in CI: it downloads the pinned validators from profiles/validators.json
into .cache/test-tools/einvoice-validators/ (SHA-256 checked), writes both formats for a
synthetic demo invoices (standard rate and the draft tax cases) with `typstgen e-invoice` and validates them with the KoSIT validator.
XRechnung uses KoSIT's official configuration; Peppol uses a scenario assembled here from the
UBL schema, the CEN rules and the Peppol 3.0.21 Schematron. A control file with its buyer
reference removed must be rejected, so a pass cannot come from a validator that checks nothing.

Example: python3 scripts/validate-einvoice.py --typstgen "$(command -v typstgen)"
Needs Java and, for the Schematron pipeline, the Mustang jar that scripts/test.sh caches
(it is downloaded here if missing).
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import urllib.request
import zipfile

REPO = Path(__file__).resolve().parents[1]
CACHE = REPO / '.cache/test-tools'
VALIDATORS = CACHE / 'einvoice-validators'
pins = json.loads((REPO / 'profiles/validators.json').read_text())
parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument('--typstgen', default='typstgen')
parser.add_argument('--java', default='java')
parser.add_argument('--output', type=Path, default=REPO / 'output/einvoice')
args = parser.parse_args()
typstgen = shutil.which(args.typstgen) or sys.exit('typstgen not found; pass --typstgen /path/to/typstgen')
java = shutil.which(args.java)
if java is None or subprocess.run([java, '-version'], capture_output=True).returncode:
    homebrew = Path('/opt/homebrew/opt/openjdk/bin/java')
    java = str(homebrew) if homebrew.exists() else sys.exit('Java is required; pass --java /path/to/java')


def fetch(url, sha256, destination):
    if not destination.exists():
        destination.parent.mkdir(parents=True, exist_ok=True)
        request = urllib.request.Request(url, headers={'User-Agent': 'business-templates-tests'})
        with urllib.request.urlopen(request, timeout=120) as response:
            destination.write_bytes(response.read())
    if hashlib.sha256(destination.read_bytes()).hexdigest() != sha256:
        sys.exit(f'{destination.name}: checksum differs from profiles/validators.json')
    return destination


def run(command, cwd=None, check=True):
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
    if check and result.returncode:
        sys.exit(f'{command[0]} failed ({result.returncode}):\n{result.stdout}{result.stderr}')
    return result


kosit = fetch(pins['kosit_validator']['url'], pins['kosit_validator']['sha256'], VALIDATORS / 'validator.jar')
xrechnung_zip = fetch(pins['xrechnung_configuration']['url'], pins['xrechnung_configuration']['sha256'],
                      VALIDATORS / 'xrechnung-configuration.zip')
mustang = fetch(pins['mustang']['url'], pins['mustang']['sha256'], CACHE / 'mustang.jar')
schematron = {f['name']: fetch(f['url'], f['sha256'], VALIDATORS / f['name']) for f in pins['peppol_schematron']['files']}

# Official XRechnung configuration, unpacked once per pinned archive.
xrechnung_config = VALIDATORS / ('xrechnung-' + pins['xrechnung_configuration']['sha256'][:12])
if not xrechnung_config.exists():
    with zipfile.ZipFile(xrechnung_zip) as archive:
        archive.extractall(xrechnung_config)

# Peppol: compile the .sch files with the ISO Schematron pipeline (the skeleton ships in the
# Mustang jar, Saxon in the KoSIT jar), then add a scenario to a copy of the XRechnung configuration.
peppol_config = VALIDATORS / ('peppol-' + pins['peppol_schematron']['version'])
if not (peppol_config / 'scenarios-peppol.xml').exists():
    shutil.rmtree(peppol_config, ignore_errors=True)
    shutil.copytree(xrechnung_config, peppol_config)
    skeleton_root = VALIDATORS / 'schematron-skeleton'
    with zipfile.ZipFile(mustang) as archive:
        members = [m for m in archive.namelist() if m.startswith('external/schematron/20100710-xslt2/') and m.endswith('.xsl')]
        archive.extractall(skeleton_root, members)
    skeleton = skeleton_root / 'external/schematron/20100710-xslt2'

    def saxon(source, stylesheet, target):
        run([java, '-cp', str(kosit), 'net.sf.saxon.Transform', f'-s:{source}', f'-xsl:{stylesheet}', f'-o:{target}'])

    for name, source in schematron.items():
        stem = source.stem
        saxon(source, skeleton / 'iso_dsdl_include.xsl', VALIDATORS / (stem + '.1.sch'))
        saxon(VALIDATORS / (stem + '.1.sch'), skeleton / 'iso_abstract_expand.xsl', VALIDATORS / (stem + '.2.sch'))
        saxon(VALIDATORS / (stem + '.2.sch'), skeleton / 'iso_svrl_for_xslt2.xsl', peppol_config / 'resources' / (stem + '.xsl'))
    (peppol_config / 'scenarios-peppol.xml').write_text('''<?xml version="1.0" encoding="UTF-8"?>
<scenarios xmlns="http://www.xoev.de/de/validator/framework/1/scenarios" frameworkVersion="1.0.0">
  <name>Peppol BIS Billing 3.0 (UBL Invoice), assembled by typst-business-templates</name>
  <author>typst-business-templates</author>
  <date>2026-10-30</date>
  <description><p>UBL 2.1 schema, CEN EN 16931 and Peppol BIS Billing 3.0.21 Schematron rules.</p></description>
  <scenario>
    <name>Peppol BIS Billing 3.0 (UBL Invoice)</name>
    <description><p>Validates UBL Invoice 2.1 against the Peppol BIS Billing 3.0 rules</p></description>
    <namespace prefix="cbc">urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2</namespace>
    <namespace prefix="invoice">urn:oasis:names:specification:ubl:schema:xsd:Invoice-2</namespace>
    <namespace prefix="rep">http://www.xoev.de/de/validator/varl/1</namespace>
    <match>exists(/invoice:Invoice/cbc:CustomizationID[ . = 'urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0'])</match>
    <validateWithXmlSchema>
      <resource><name>XML Schema for UBL 2.1 Invoice</name><location>resources/ubl/2.1/xsd/maindoc/UBL-Invoice-2.1.xsd</location></resource>
    </validateWithXmlSchema>
    <validateWithSchematron>
      <resource><name>CEN EN 16931 (UBL)</name><location>resources/CEN-EN16931-UBL.xsl</location></resource>
    </validateWithSchematron>
    <validateWithSchematron>
      <resource><name>Peppol BIS Billing 3.0.21 (UBL)</name><location>resources/PEPPOL-EN16931-UBL.xsl</location></resource>
    </validateWithSchematron>
    <createReport>
      <resource><name>Validation report</name><location>resources/default-report.xsl</location></resource>
    </createReport>
    <acceptMatch>/rep:report/rep:assessment[1]/rep:accept[1]</acceptMatch>
  </scenario>
  <noScenarioReport>
    <resource><name>Default Report</name><location>resources/default-report.xsl</location></resource>
  </noScenarioReport>
</scenarios>
''')

# Synthetic inputs: the German demo invoice (standard rate) and the EU reverse-charge example,
# each plus the fields both formats require.
output = args.output.resolve()
shutil.rmtree(output, ignore_errors=True)
output.mkdir(parents=True)
demo = REPO / 'examples/invoice-languages/de'
resolved = json.loads(run([typstgen, 'prepare-invoice', '--config', str(demo / 'invoice-config.json'), str(demo / 'invoice.json')]).stdout)
inputs = [('standard-rate', resolved['data'], resolved['company'])]
for case, example in [('reverse-charge', 'de-eu-services-draft'), ('intra-community', 'de-eu-goods-draft'), ('export', 'de-export-draft'),
                      ('zero-rate', 'de-zero-rate-draft'), ('exempt', 'de-exempt-draft'), ('domestic-reverse-charge', 'de-domestic-reverse-charge-draft'),
                      ('oss', 'de-eu-b2c-oss-draft')]:
    view = json.loads(run([typstgen, 'validate-document', '--catalog', str(REPO / 'profiles/catalog.json'),
                           str(REPO / 'examples/invoice-profiles' / (example + '.json'))]).stdout)
    inputs.append((case, view['data'], view['company']))

targets = [('xrechnung-3.0', xrechnung_config, 'scenarios.xml'), ('peppol-bis-3.0', peppol_config, 'scenarios-peppol.xml')]
report = {'kosit_validator': pins['kosit_validator'], 'xrechnung_configuration': pins['xrechnung_configuration'],
          'peppol_schematron': pins['peppol_schematron'], 'results': []}


def validate(config, scenarios, xml):
    result = run([java, '--enable-native-access=ALL-UNNAMED', '-jar', str(kosit), '-s', scenarios, '-r', str(config),
                  '-o', str(output), '-p', str(xml)], check=False)
    accepted = re.search(r'Acceptable:\s+1\s+Rejected:\s+0', result.stdout) is not None
    return accepted, result.stdout


for case, data, company in inputs:
    company['electronic_address'] = {'scheme_id': '0204', 'value': '991-12345-67'}
    company.setdefault('contact', {}).update(name='Synthetic Contact', phone='+49 30 0000000')
    data['recipient']['electronic_address'] = {'scheme_id': '0204', 'value': '991-98765-43'}
    data.setdefault('metadata', {})['buyer_reference'] = '991-01234-56'
    (output / (case + '.data.json')).write_text(json.dumps(data, indent=2))
    (output / (case + '.company.json')).write_text(json.dumps(company, indent=2))
    for name, config, scenarios in targets:
        xml = output / (case + '.' + name + '.xml')
        run([typstgen, 'e-invoice', '--company', str(output / (case + '.company.json')), '--format', name, '-o', str(xml),
             str(output / (case + '.data.json'))])
        accepted, _ = validate(config, config / scenarios, xml)
        # Control: without the buyer reference both rule sets must reject the file.
        broken = output / (case + '.' + name + '.control.xml')
        text = xml.read_text()
        stripped = re.sub(r'\s*<cbc:BuyerReference>.*?</cbc:BuyerReference>', '', text)
        if stripped == text:
            sys.exit(f'{case} {name}: control could not remove the buyer reference')
        broken.write_text(stripped)
        control_rejected = not validate(config, config / scenarios, broken)[0]
        report['results'].append({'case': case, 'format': name, 'accepted': accepted, 'control_rejected': control_rejected})
        print(f"{case} {name}: {'accepted' if accepted else 'REJECTED'}; control without buyer reference {'rejected' if control_rejected else 'WRONGLY ACCEPTED'}")

(output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
print(f'Report and files: {output}')
sys.exit(0 if all(r['accepted'] and r['control_rejected'] for r in report['results']) else 1)
