#!/usr/bin/env python3
"""Integration checks against an explicitly selected typstgen profiles build.

Example: python scripts/check-profiles.py --typstgen ../typstgen/target/debug/typstgen
Optional external validators are never silently counted as passed.
"""
import argparse
import copy
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import subprocess
import shutil
import tempfile
import xml.etree.ElementTree as ET

from pypdf import PdfReader

REPO = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--typstgen', required=True)
parser.add_argument('--mustang', type=Path)
parser.add_argument('--java', default='java')
parser.add_argument('--verapdf')
parser.add_argument('--report', type=Path)
parser.add_argument('--artifacts-dir', type=Path)
args = parser.parse_args()
binary = str(Path(args.typstgen).resolve()) if '/' in args.typstgen else args.typstgen
report = {'typstgen': binary, 'external_validation': [], 'checks': []}


def check(condition, message):
    if not condition:
        raise AssertionError(message)


def run(command, cwd, expected=True):
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
    check((result.returncode == 0) == expected, f'{command[0]}: unexpected status {result.returncode}: {result.stdout} {result.stderr}')
    return result.stdout


with tempfile.TemporaryDirectory(prefix='invoice-profiles-') as directory:
    root = Path(directory)
    (root/'typstgen.toml').write_text(f'template_paths=["."]\npackage_path={json.dumps(str(REPO/"packages"))}\nfont_paths=[{json.dumps(str(REPO/"fonts"))}]\n')
    catalog = str(REPO/'profiles/catalog.json')

    def validate(request, expected='ready_for_preview'):
        (root/'request.json').write_text(json.dumps(request))
        stdout = run([binary, 'validate-document', '--catalog', catalog, 'request.json'], root, expected != 'blocked')
        result = json.loads(stdout)
        check(result['status'] == expected, f'Unexpected profile result: {result}')
        return result

    listed = json.loads(run([binary, 'list-document-profiles', '--catalog', catalog], root))
    check({p['id'] for p in listed['profiles']} == {'de-standard', 'de-small-business'}, 'Draft/unsupported profile leaked into released catalog')
    check(all(p['country']=='DE' and p['languages']==['de','en'] and p['outputs']==['pdf-preview'] for p in listed['profiles']), 'Listed capabilities lost inherited fields')
    base = json.loads((REPO/'examples/invoice-profiles/de-standard.json').read_text())
    small = json.loads((REPO/'examples/invoice-profiles/de-small-business.json').read_text())
    france = json.loads((REPO/'examples/invoice-profiles/fr-standard-draft.json').read_text())
    negative_cases = []
    changed = copy.deepcopy(base); changed['facts'].pop('rate_applicability_confirmed'); negative_cases.append((changed, 'facts.rate_applicability_confirmed'))
    changed = copy.deepcopy(base); changed['data']['recipient']['address']['country_code'] = 'FR'; negative_cases.append((changed, 'DE-BUYER'))
    changed = copy.deepcopy(base); changed['selection']['output_profile'] = 'xrechnung'; negative_cases.append((changed, 'selection.output_profile'))
    changed = copy.deepcopy(base); changed['selection']['profile_id'] = 'unknown'; negative_cases.append((changed, 'PROFILE-IDENTITY'))
    changed = copy.deepcopy(small); changed['facts']['waived_exemption'] = True; negative_cases.append((changed, 'DE-19-WAIVER'))
    changed = copy.deepcopy(small); changed['facts']['regime_valid_until'] = '2026-10-24'; negative_cases.append((changed, 'DE-19-PERIOD'))
    changed = copy.deepcopy(small); changed['data']['items'][0]['vat_rate']['percentage'] = '19'; negative_cases.append((changed, 'DE-19-RATE'))
    changed = copy.deepcopy(base); changed['data']['metadata']['delivery_date'] = '2024-12-31'; negative_cases.append((changed, 'PROFILE-VALIDITY'))
    changed = copy.deepcopy(france); changed['selection'].pop('allow_draft'); negative_cases.append((changed, 'PROFILE-STATUS'))
    changed = copy.deepcopy(france); changed['data']['recipient'].pop('registration_number'); negative_cases.append((changed, 'data.recipient.registration_number'))
    changed = copy.deepcopy(france); changed['facts']['vat_on_debits'] = True; negative_cases.append((changed, 'FR-DEBITS'))
    for request, expected in negative_cases:
        result = validate(request, 'blocked')
        check(expected in json.dumps(result['diagnostics']), 'Missing diagnostic: ' + expected)

    def export(request, name, hybrid=False, legacy=False):
        resolved = validate(request, 'blocked' if legacy else 'ready_for_preview')
        if legacy:
            # Exercise the existing category model, not a released national profile.
            check(resolved['checks']['arithmetic']=='passed','Legacy category model is invalid')
            resolved['data']=request['data']
            resolved['company']=request['company']
        for field in ['data', 'company', 'selection']:
            (root/(field+'.json')).write_text(json.dumps(resolved[field]))
        (root/'invoice.typ').write_text('#import "@local/business-templates:0.1.0": invoice\n#let company = json("company.json")\n#if "logo" in company { company.insert("logo", read(company.logo, encoding: none)) }\n#invoice(data: json("data.json"), company: company, profile: json("selection.json"))')
        pdf = root/(name+'.pdf')
        command = [binary, 'compile', 'invoice.typ', '-o', str(pdf), '--creation-timestamp', '1792972800']
        if hybrid:
            command += ['--zugferd', 'data.json', '--company', 'company.json', '--pdf-standard', 'a-3b']
        run(command, root)
        if args.artifacts_dir:
            args.artifacts_dir.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(pdf,args.artifacts_dir/pdf.name)
        reader = PdfReader(pdf)
        text = '\n'.join(p.extract_text() for p in reader.pages)
        check(request['data']['metadata']['invoice_number'] in text, name+': document number lost')
        if request['selection']['profile_id'] == 'de-small-business':
            check('19 UStG' in text, 'Section 19 note missing')
            check(resolved['normalized']['tax_total'] == '0', 'Small business has nonzero VAT')
        if request['selection']['language'] == 'en':
            check('Invoice' in text and 'Payable in full by' in text, name+': English labels missing')
            check('Geschäftsinhaber' not in text and 'Rückfragen' not in text, name+': German default labels remain')
        if hybrid:
            xml = ET.fromstring(reader.attachments['factur-x.xml'][0])
            ns = {'ram':'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100'}
            summation = xml.find('.//ram:SpecifiedTradeSettlementHeaderMonetarySummation', ns)
            for tag, field in [('LineTotalAmount','line_total'),('TaxTotalAmount','tax_total'),('GrandTotalAmount','grand_total')]:
                check(Decimal(summation.find('ram:'+tag,ns).text) == Decimal(resolved['normalized'][field]), name+': XML '+field+' differs from canonical model')
            xml_lines = xml.findall('.//ram:IncludedSupplyChainTradeLineItem', ns)
            check(len(xml_lines) == len(resolved['normalized']['lines']), 'XML line count differs')
            for node,line in zip(xml_lines,resolved['normalized']['lines']):
                amount = node.find('.//ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount',ns)
                check(Decimal(amount.text) == Decimal(line['net_amount']), 'XML line amount differs')
                check(node.find('.//ram:ApplicableTradeTax/ram:CategoryCode',ns).text == line['tax']['category'], 'XML tax category differs')
            for amount in [resolved['normalized'][f] for f in ['line_total','tax_total','grand_total']]:
                printed = f'{Decimal(amount):.2f}'
                if request['selection']['format_locale'] != 'en-GB': printed = printed.replace('.',',')
                check(printed in text, name+': PDF canonical total missing '+printed)
            external = {'fixture':name,'mustang':'not_run','pdfa':'not_run'}
            if args.mustang:
                output = run([args.java,'-jar',str(args.mustang.resolve()),'--action','validate','--source',str(pdf),'--disable-file-logging'],root)
                # The process status alone is insufficient. Read the actual validator report.
                start = output.find('<?xml')
                check(start >= 0, 'Mustang returned no XML report')
                validation = ET.fromstring(output[start:])
                check(validation.find('summary').attrib['status'] == 'valid', name+': Mustang validation failed')
                check(validation.find('xml/summary').attrib['status'] == 'valid', name+': XML invalid')
                external.update(mustang='passed',mustang_version=validation.find('xml/info/validator').attrib['version'],
                                mustang_sha256=hashlib.sha256(args.mustang.read_bytes()).hexdigest(),
                                notices=[n.text for n in validation.findall('xml/messages/notice')])
            if args.verapdf:
                output = run([args.verapdf,'--format','text',str(pdf)],root)
                check(output.startswith('PASS '),name+': veraPDF did not report PASS')
                external['pdfa']='passed'
                external['verapdf_version']=run([args.verapdf,'--version'],root).splitlines()[0]
            report['external_validation'].append(external)
        return resolved['normalized']

    reference = None
    for language in ['de','en']:
        for layout in ['din','international']:
            request = copy.deepcopy(base)
            request['selection'].update(language=language,layout=layout,format_locale='de-DE' if language=='de' else 'en-GB')
            normalized = export(request,'de-'+language+'-'+layout,hybrid=True)
            if reference is None: reference = normalized
            check(normalized == reference,'Language/layout changed fiscal data')
    export(small,'de-small-business',hybrid=True)
    french = export(france,'fr-draft')
    france['selection'].update(language='en',format_locale='en-GB')
    check(export(france,'fr-draft-en') == french,'French translation changed fiscal data')
    # Two standard rates with one independent calculation per category/rate.
    mixed = copy.deepcopy(base)
    line = copy.deepcopy(mixed['data']['items'][0]);line.update(position=2,description='Synthetic reduced-rate item')
    line['vat_rate']={'code':'Reduced','percentage':'7'};mixed['data']['items'].append(line)
    totals=mixed['data']['totals'];totals['subtotal']['amount']='400.00';totals['vat_total']['amount']='52.00';totals['total']['amount']='452.00'
    totals['vat_breakdown'].append({'rate':{'code':'Reduced','percentage':'7'},'base':{'amount':'200.00','currency':'EUR'},'amount':{'amount':'14.00','currency':'EUR'}})
    export(mixed,'de-multiple-rates',hybrid=True)
    zero = copy.deepcopy(base)
    zero['data']['items']=[]
    groups=[]
    for index,code in enumerate(['Zero','Exempt','ReverseCharge']):
        line=copy.deepcopy(base['data']['items'][0])
        line.update(position=index+1,quantity='1',description='Synthetic '+code+' item')
        line['unit_price']['amount']='100.00';line['total']['amount']='100.00'
        line['vat_rate']={'code':code,'percentage':'0'}
        if code!='Zero': line['vat_rate']['exemption_reason']='Synthetic '+code+' reason'
        zero['data']['items'].append(line)
        groups.append({'rate':line['vat_rate'].copy(),'base':{'amount':'100.00','currency':'EUR'},'amount':{'amount':'0.00','currency':'EUR'}})
    zero['data']['totals']={'subtotal':{'amount':'300.00','currency':'EUR'},'vat_breakdown':groups,
        'vat_total':{'amount':'0.00','currency':'EUR'},'total':{'amount':'300.00','currency':'EUR'}}
    export(zero,'legacy-zero-categories',hybrid=True,legacy=True)
    # Long content and addresses exercise both layouts without changing totals.
    long = copy.deepcopy(base)
    long['data']['recipient']['name'] = 'Synthetic buyer with a long business name and several departments for coordination and review'
    long['data']['items'][0]['description'] = ('Synthetic service description with a lengthy scope and review criteria. ' * 100)
    (root/'logo.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="120" height="30"><rect width="120" height="30" fill="#244B62"/></svg>')
    long['company']['logo']='logo.svg'
    for layout in ['din','international']:
        long['selection']['layout']=layout
        export(long,'de-long-'+layout)

    report['checks']=['profile resolution','missing facts','eligibility dates and waiver','unsupported outputs',
                      'de/en DIN/international invariant','French fr/en draft invariant','multiple rates',
                      'canonical PDF/XML totals and categories','long content']

if args.report:
    args.report.write_text(json.dumps(report,indent=2)+'\n')
print('ok   invoice profiles, canonical values and PDF/XML integration')
for result in report['external_validation']:
    print(f"     {result['fixture']}: Mustang={result['mustang']}, PDF/A={result['pdfa']}")
