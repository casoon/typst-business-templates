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
import sys
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
    changed = copy.deepcopy(base); changed['data']['payment']['due_date'] = '2026-02-30'; negative_cases.append((changed, 'data.payment.due_date'))
    changed = copy.deepcopy(base); changed['data']['metadata']['due_date'] = '2026-12-31'; negative_cases.append((changed, 'data.metadata.due_date'))
    changed = copy.deepcopy(base); changed['data']['totals']['discount_total'] = {'amount':'10.00','currency':'EUR'}; negative_cases.append((changed, 'data.totals.discount_total'))
    changed = copy.deepcopy(base); changed['company'].pop('name'); negative_cases.append((changed, 'company.name'))
    for request, expected in negative_cases:
        result = validate(request, 'blocked')
        check(expected in json.dumps(result['diagnostics']), 'Missing diagnostic: ' + expected)

    def export(request, name, hybrid=False, legacy=False, configuration=None):
        if configuration is None:
            resolved = validate(request, 'blocked' if legacy else 'ready_for_preview')
        else:
            (root/'invoice-config.json').write_text(json.dumps(configuration))
            (root/'request.json').write_text(json.dumps(request))
            resolved = json.loads(run([binary, 'prepare-invoice', '--config', 'invoice-config.json', 'request.json'], root))
            check(resolved['status']=='ready_for_preview', str(resolved))
        if legacy:
            # Exercise the existing category model, not a released national profile.
            check(resolved['checks']['arithmetic']=='passed','Legacy category model is invalid')
            resolved['data']=request['data']
            resolved['company']=request['company']
        for field in ['data', 'company', 'selection']:
            (root/(field+'.json')).write_text(json.dumps(resolved[field]))
        (root/'invoice.typ').write_text('#import "@local/business-templates:0.1.0": invoice\n#let company = json("company.json")\n#if company.at("logo", default: none) != none { company.insert("logo", read(company.logo, encoding: none)) }\n#invoice(data: json("data.json"), company: company, profile: json("selection.json"))')
        pdf = root/(name+'.pdf')
        command = [binary, 'compile', 'invoice.typ', '-o', str(pdf), '--creation-timestamp', '1792972800']
        if hybrid:
            command += ['--zugferd', 'data.json', '--company', 'company.json', '--pdf-standard', 'a-3b']
        run(command, root)
        if args.artifacts_dir:
            args.artifacts_dir.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(pdf,args.artifacts_dir/pdf.name)
            (args.artifacts_dir/(name+'.request.json')).write_text(json.dumps(request,indent=2)+'\n')
            (args.artifacts_dir/(name+'.resolved.json')).write_text(json.dumps(resolved,indent=2)+'\n')
            if configuration is not None:
                (args.artifacts_dir/(name+'.config.json')).write_text(json.dumps(configuration,indent=2)+'\n')
        reader = PdfReader(pdf)
        text = '\n'.join(p.extract_text() for p in reader.pages)
        check(request['data']['metadata']['invoice_number'] in text, name+': document number lost')
        if resolved['selection']['profile_id'] == 'de-small-business':
            check('19 UStG' in text, 'Section 19 note missing')
            check(resolved['normalized']['tax_total'] == '0', 'Small business has nonzero VAT')
        if resolved['selection']['language'] == 'en':
            check('Invoice' in text and 'Payable in full by' in text, name+': English labels missing')
            check('Geschäftsinhaber' not in text and 'Rückfragen' not in text, name+': German default labels remain')
        if name=='de-payment-account-override':
            check(request['data']['payment']['bank_account']['bank_name'] in text,'PDF kept the company default bank name')
        for note in resolved['data'].get('notes',[]):
            check(note in text,name+': configured note missing from PDF')
        if hybrid:
            xml = ET.fromstring(reader.attachments['factur-x.xml'][0])
            ns = {'ram':'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100',
                  'rsm':'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100',
                  'udt':'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100'}
            model=resolved['normalized']
            for note in resolved['data'].get('notes',[]):
                check(note in [n.text for n in xml.findall('rsm:ExchangedDocument/ram:IncludedNote/ram:Content',ns)],name+': configured note missing from XML')
            check(xml.find('rsm:ExchangedDocument/ram:ID',ns).text==model['number'],name+': XML identifier differs')
            check(xml.find('rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString',ns).text==model['issue_date'].replace('-',''),name+': XML issue date differs')
            for tag,party in [('SellerTradeParty','seller'),('BuyerTradeParty','buyer')]:
                node=xml.find('.//ram:ApplicableHeaderTradeAgreement/ram:'+tag,ns)
                check(node.find('ram:Name',ns).text==model[party]['name'],name+': XML party name differs')
                address=node.find('ram:PostalTradeAddress',ns)
                for address_tag,field in [('LineOne','line'),('PostcodeCode','postcode'),('CityName','city'),('CountryID','country')]:
                    check(address.find('ram:'+address_tag,ns).text==model[party]['address'][field],name+': XML address differs')
                check(model[party]['name'] in text,name+': PDF party name missing')
            settlement=xml.find('.//ram:ApplicableHeaderTradeSettlement',ns)
            check(settlement.find('ram:InvoiceCurrencyCode',ns).text==model['currency'],name+': XML currency differs')
            due=settlement.find('ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString',ns)
            check(due is not None and due.text==model['due_date'].replace('-',''),name+': XML due date differs')
            groups=settlement.findall('ram:ApplicableTradeTax',ns)
            check(len(groups)==len(model['breakdown']),name+': VAT group count differs')
            for node,group in zip(groups,model['breakdown']):
                check(node.find('ram:CategoryCode',ns).text==group['tax']['category'],name+': VAT group category differs')
                for tag,amount in [('BasisAmount',group['basis']),('CalculatedAmount',group['amount']),('RateApplicablePercent',group['tax']['rate'])]:
                    check(Decimal(node.find('ram:'+tag,ns).text)==Decimal(amount),name+': VAT group '+tag+' differs')
            if model['payment']:
                iban=settlement.find('.//ram:IBANID',ns)
                check(iban is not None and iban.text==model['payment']['iban'],name+': XML payment account differs')
                check(model['payment']['iban'] in text.replace(' ',''),name+': PDF payment account differs')
            if args.artifacts_dir:
                (args.artifacts_dir/(name+'.factur-x.xml')).write_bytes(reader.attachments['factur-x.xml'][0])
            summation = xml.find('.//ram:SpecifiedTradeSettlementHeaderMonetarySummation', ns)
            for tag, field in [('LineTotalAmount','line_total'),('TaxTotalAmount','tax_total'),('GrandTotalAmount','grand_total')]:
                check(Decimal(summation.find('ram:'+tag,ns).text) == Decimal(resolved['normalized'][field]), name+': XML '+field+' differs from canonical model')
            xml_lines = xml.findall('.//ram:IncludedSupplyChainTradeLineItem', ns)
            check(len(xml_lines) == len(resolved['normalized']['lines']), 'XML line count differs')
            for node,line in zip(xml_lines,resolved['normalized']['lines']):
                amount = node.find('.//ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount',ns)
                check(Decimal(amount.text) == Decimal(line['net_amount']), 'XML line amount differs')
                check(node.find('.//ram:ApplicableTradeTax/ram:CategoryCode',ns).text == line['tax']['category'], 'XML tax category differs')
                check(Decimal(node.find('.//ram:NetPriceProductTradePrice/ram:ChargeAmount',ns).text)==Decimal(line['net_price']),'XML unit price differs')
                if line['net_price']=='0.3333':
                    shown='0.3333' if resolved['selection']['format_locale']=='en-GB' else '0,3333'
                    check(shown in text,name+': PDF rounded the canonical unit price')
            pdf_amounts=[model[f] for f in ['line_total','grand_total']]
            pdf_amounts += [group['amount'] for group in model['breakdown']]
            for amount in pdf_amounts:
                printed = f'{Decimal(amount):.2f}'
                if resolved['selection']['format_locale'] != 'en-GB': printed = printed.replace('.',',')
                check(printed in text, name+': PDF canonical total missing '+printed)
            external = {'fixture':name,'mustang':'not_run','pdfa':'not_run'}
            if args.mustang:
                output = run([args.java,'-jar',str(args.mustang.resolve()),'--action','validate','--source',str(pdf),'--disable-file-logging'],root)
                # The process status alone is insufficient. Read the actual validator report.
                start = output.find('<?xml')
                check(start >= 0, 'Mustang returned no XML report')
                validation = ET.fromstring(output[start:])
                if args.artifacts_dir:
                    (args.artifacts_dir/(name+'.mustang.xml')).write_text(output[start:])
                check(validation.find('summary').attrib['status'] == 'valid', name+': Mustang validation failed')
                check(validation.find('xml/summary').attrib['status'] == 'valid', name+': XML invalid')
                external.update(mustang='passed',mustang_version=validation.find('xml/info/validator').attrib['version'],
                                mustang_sha256=hashlib.sha256(args.mustang.read_bytes()).hexdigest(),
                                notices=[n.text for n in validation.findall('xml/messages/notice')])
            if args.verapdf:
                output = run([args.verapdf,'--format','text',str(pdf)],root)
                check(output.startswith('PASS '),name+': veraPDF did not report PASS')
                if args.artifacts_dir:
                    (args.artifacts_dir/(name+'.verapdf.txt')).write_text(output)
                external['pdfa']='passed'
                external['verapdf_version']=run([args.verapdf,'--version'],root).splitlines()[0]
            report['external_validation'].append(external)
        return resolved['normalized']

    configured_request = json.loads((REPO/'examples/invoice-config/invoice.json').read_text())
    configuration = json.loads((REPO/'invoice-config.json').read_text())
    configuration['notes']=['Configured payment reference: SYNTH-2026-001']
    configured_model = export(configured_request,'configured-invoice-eur',hybrid=True,configuration=configuration)
    check(configured_model['grand_total']=='291.5','Configuration did not calculate mixed VAT totals')
    configuration['presentation'].update(language='en',format_locale='en-GB',currency='GBP',layout='din')
    configuration['taxes']['standard']['rate']='20'
    configuration['taxes']['reduced']['rate']='5'
    configured_model = export(configured_request,'configured-invoice-gbp',hybrid=True,configuration=configuration)
    check(configured_model['grand_total']=='292.5' and configured_model['currency']=='GBP','Configuration changes did not reach the shared model')

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
    fractional = copy.deepcopy(base)
    fractional['data']['items'][0]['quantity']='3'
    fractional['data']['items'][0]['unit_price']['amount']='0.3333'
    fractional['data']['items'][0]['total']['amount']='1.00'
    fractional['data']['totals']={'subtotal':{'amount':'1.00','currency':'EUR'},
        'vat_breakdown':[{'rate':{'code':'Standard','percentage':'19'},'base':{'amount':'1.00','currency':'EUR'},'amount':{'amount':'0.19','currency':'EUR'}}],
        'vat_total':{'amount':'0.19','currency':'EUR'},'total':{'amount':'1.19','currency':'EUR'}}
    for language in ['de','en']:
        fractional['selection'].update(language=language,format_locale='de-DE' if language=='de' else 'en-GB')
        export(fractional,'de-fractional-unit-price-'+language,hybrid=True)
    subcent = copy.deepcopy(base)
    subcent['data']['items'][0]['quantity']='0.5'
    subcent['data']['items'][0]['unit_price']['amount']='0.0099'
    subcent['data']['items'][0]['total']['amount']='0.00'
    subcent['data']['totals']={'subtotal':{'amount':'0.00','currency':'EUR'},
        'vat_breakdown':[{'rate':{'code':'Standard','percentage':'19'},'base':{'amount':'0.00','currency':'EUR'},'amount':{'amount':'0.00','currency':'EUR'}}],
        'vat_total':{'amount':'0.00','currency':'EUR'},'total':{'amount':'0.00','currency':'EUR'}}
    export(subcent,'de-subcent-line-rounding',hybrid=True)
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
    optional = copy.deepcopy(base)
    optional['company']['logo'] = None
    export(optional,'de-null-logo')
    optional['company']['address'].pop('house_number')
    optional['data']['recipient']['address'].pop('house_number')
    for layout in ['din','international']:
        optional['selection']['layout']=layout
        export(optional,'de-no-house-number-'+layout)
    override = copy.deepcopy(base)
    override['data']['payment']['bank_account'].update(bank_name='Synthetic invoice bank',iban='GB82WEST12345698765432',bic='NWBKGB2L')
    export(override,'de-payment-account-override',hybrid=True)
    # Long content and addresses exercise both layouts without changing totals.
    long = copy.deepcopy(base)
    long['data']['recipient']['name'] = 'Synthetic buyer with a long business name and several departments for coordination and review'
    long['data']['items'][0]['description'] = ('Synthetic service description with a lengthy scope and review criteria. ' * 100)
    (root/'logo.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="120" height="30"><rect width="120" height="30" fill="#244B62"/></svg>')
    long['company']['logo']='logo.svg'
    for layout in ['din','international']:
        long['selection']['layout']=layout
        export(long,'de-long-'+layout)

    # The user-facing demos use the same builder and one shared Typst wrapper.
    demo_root = REPO/'examples/invoice-languages'
    generated = root/'language-demos'
    run([sys.executable,str(demo_root/'build.py'),'--typstgen',binary,'--output-dir',str(generated)],root)
    titles={'de':'Rechnung','en':'Invoice','en-US':'Invoice','es':'Factura','fr':'Facture','it':'Fattura','nl':'Factuur','pt':'Fatura'}
    for language,title in titles.items():
        for source in [generated/language/'invoice.pdf',demo_root/language/'invoice.pdf']:
            reader=PdfReader(source)
            text=' '.join(' '.join(page.extract_text().split()) for page in reader.pages)
            check(len(reader.pages)==1,str(source)+': demo should fit on one page')
            check(title in text,str(source)+': translated title missing')
            check('else [' not in text,str(source)+': template code leaked into the invoice')
            width,height=(612,792) if language=='en-US' else (595.28,841.89)
            check(abs(float(reader.pages[0].mediabox.width)-width)<0.1 and abs(float(reader.pages[0].mediabox.height)-height)<0.1,str(source)+': wrong paper size')
            if language=='en-US':
                for value in ['$1,249.50','$2,994.93','10/26/2026','11/25/2026','State tax','Local tax','Sales Tax','Example City, NY 00000','Routing number','Account number']:
                    check(value in text,str(source)+': missing '+value)
                check('VAT' not in text and 'EUR' not in text and 'IBAN' not in text,str(source)+': VAT/European payment labels remain')
            else:
                check(('3358.80' if language=='en' else '3358,80') in text,str(source)+': incorrect demo total')
        if args.artifacts_dir:
            shutil.copyfile(generated/language/'invoice.pdf',args.artifacts_dir/('demo-'+language+'.pdf'))

    report['checks']=['eight committed and rebuilt language/US demos','user-owned invoice configuration','profile resolution','missing facts','eligibility dates and waiver','unsupported outputs',
                      'de/en DIN/international invariant','French fr/en draft invariant','multiple rates',
                      'canonical PDF/XML totals, tax groups, parties, dates, currency and payment','optional logos and house numbers','long content']

if args.report:
    args.report.write_text(json.dumps(report,indent=2)+'\n')
print('ok   invoice profiles, canonical values and PDF/XML integration')
for result in report['external_validation']:
    print(f"     {result['fixture']}: Mustang={result['mustang']}, PDF/A={result['pdfa']}")
