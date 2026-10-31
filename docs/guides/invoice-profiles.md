---
title: Invoice profiles and agent workflow
description: Separate country rules, tax cases, language, layout and output, with explicit validation boundaries.
order: 7
---

> **Templates, not tax advice.** The invoice and tax-case profiles are templates. No tax adviser or
> accountant has reviewed them, and they may need adjusting to your situation and country. Have them
> checked before you issue real invoices. Examples use fictional companies, accounts and rates.

## Supported combinations

The versioned source is `profiles/catalog.json`, validated by
`schema/document-profiles.schema.json`. Each profile declares its country, tax case, languages,
format locales, currencies, layouts, outputs, sources, review date and effective review window.
`released` means the listed bounded combination; it does not mean unrestricted country support.

| Profile | State | Scope | Output |
| --- | --- | --- | --- |
| `de-standard@1` | released | Domestic DE B2B, confirmed ordinary/reduced rate applicability, 19%/7%, no special sectors or territories | PDF preview |
| `de-small-business@1` | released | Domestic DE B2B, explicitly confirmed § 19 eligibility interval and no waiver, 0 VAT/category E | PDF preview |
| `fr-domestic-standard@1-draft` | draft, explicit opt-in | Mainland FR domestic B2B ordinary services at 20%, bounded prerequisites below | PDF preview |
| `de-eu-services-b2b@1-draft` | draft, explicit opt-in | German supplier, other service to a business customer in another EU member state (general place-of-supply rule, § 3a Abs. 2 UStG), tax owed by the recipient: category AE at 0%, bounded prerequisites below | PDF preview |
| `de-eu-goods-b2b@1-draft` | draft, explicit opt-in | German supplier, goods to a business customer registered for VAT in another EU member state (tax-exempt intra-Community supply, § 4 Nr. 1 Buchst. b, § 6a UStG): category K at 0% | PDF preview |
| `de-third-country-export@1-draft` | draft, explicit opt-in | German supplier, goods exported to a third country by the supplier or a foreign buyer (§ 4 Nr. 1 Buchst. a, § 6 UStG): category G at 0% | PDF preview |
| `de-zero-rate-section-12-3@1-draft` | draft, explicit opt-in | Domestic supply or installation of photovoltaic systems at 0% (§ 12 Abs. 3 UStG): category Z | PDF preview |
| `de-exempt-section-4@1-draft` | draft, explicit opt-in | Domestic supply exempt under a named § 4 UStG provision (not Nr. 1, not § 19): category E | PDF preview |
| `de-domestic-reverse-charge@1-draft` | draft, explicit opt-in | Domestic supply where the recipient owes the tax (§ 13b Abs. 2 UStG): category AE | PDF preview |
| `de-eu-b2c-oss@1-draft` | draft, explicit opt-in | Supply to a consumer in another EU member state taxed there under the Union scheme (§ 18j UStG): category S at the caller-confirmed destination rate | PDF preview |
| `de-eu-small-business@1-draft` | draft, explicit opt-in | German small business using another member state's exemption (§ 19a UStG): category E | PDF preview |
| Other listed cases | unsupported | Everything else, in particular new vehicles, chain and triangular transactions, non-Union OSS schemes, travellers' exports | none |

### EU service to a business customer (draft)

Selecting `de-eu-services-b2b` (with `allow_draft`) requires caller-confirmed facts: the recipient is
an entrepreneur and the service is for its business (`service_for_recipient_business`), its VAT ID has
been confirmed (`recipient_vat_id_confirmed`), no special place-of-supply rule applies
(`no_special_place_of_supply_rule`, i.e. none of § 3a Abs. 3-8, § 3b, § 3e UStG) and the place of
supply is the recipient's member state (`facts.place_of_supply`). The recipient must be in an EU
member state other than Germany and have a VAT ID, the seller needs a VAT ID, every line uses
`ReverseCharge` at 0%, and each line's `exemption_reason` carries the statutory wording
"Steuerschuldnerschaft des Leistungsempfängers" (§ 14a Abs. 1 UStG; an English line can add a
translation). The invoice template prints the recipient's VAT ID for reverse-charge invoices because
§ 14a requires both IDs. Not checked: the invoice deadline (15th of the following month), whether the
VAT ID confirmation is current, goods, B2C and the recipient's national rules. Sources: § 3a and
§ 14a UStG, checked 2026-10-31. This is a bounded preview for a documented case, not tax advice.

`pdf-preview` is a rendering output. It is not a statement that issuing a plain PDF satisfies an
applicable electronic invoicing obligation. The existing Factur-X pipeline remains available
separately and is checked with canonical data and external validators below. Versioned XRechnung
3.0.2/UBL 2.1 and Peppol BIS Billing 3.0.21/UBL 2.1 are catalog outputs (`xrechnung-3.0`,
`peppol-bis-3.0`) of the released DE profiles, selectable with typstgen 0.6.2 or later. Selecting
one makes `validate-document` report the extra fields the format needs; the XML itself is written
by `typstgen e-invoice --format xrechnung-3.0|peppol-bis-3.0` from the same invoice data, see
[E-invoice files](#e-invoice-files-xrechnung-and-peppol). The FR draft offers only the preview.
Peppol transport and French approved-platform transmission are not supplied.

The DE profiles cover supply dates in the reviewed interval 2025-01-01 through 2026-12-31;
the FR draft starts 2026-09-01. These are bounded package review windows, not statutory expiry
dates. Recheck sources and version the profile before extending a window or releasing a case.


### EU goods and export (drafts)

Both drafts need caller-confirmed facts and keep the evidence as references; the proof itself
(accounting evidence, shipping or export confirmation) is not checked.

- **`de-eu-goods-b2b`:** goods dispatched to another member state
  (`goods_dispatched_to_member_state`), recipient VAT ID confirmed (`recipient_vat_id_confirmed`),
  acquisition taxed in the destination state (`acquisition_taxed_in_destination`) and no excluded
  transaction type (`no_excluded_transaction_type`: new vehicles, chain or triangular transactions,
  consignment stock, distance sales). The recipient sits in an EU member state other than Germany and
  has a VAT ID, the seller needs one, `metadata.delivery_country_code` names an EU member state
  (with `delivery_city` and `delivery_postal_code` if the file is written as XRechnung), every line
  uses `IntraCommunity` at 0% and its `exemption_reason` contains "innergemeinschaftliche Lieferung",
  for example "Steuerfreie innergemeinschaftliche Lieferung (§ 4 Nr. 1 Buchst. b i. V. m. § 6a UStG)".
  The template prints the recipient's VAT ID because § 14a Abs. 3 UStG requires both IDs.
- **`de-third-country-export`:** goods exported to a third country
  (`goods_exported_to_third_country`), transported by the supplier or a foreign buyer
  (`export_transport_by`: `supplier` or `foreign_buyer`) and no excluded transaction type
  (`no_excluded_transaction_type`: travellers' exports, deliveries to the areas of § 1 Abs. 3 UStG,
  processing by agents). Every line uses `Export` at 0% and its `exemption_reason` contains
  "Ausfuhrlieferung", for example "Steuerfreie Ausfuhrlieferung (§ 4 Nr. 1 Buchst. a i. V. m. § 6 UStG)".

Not checked in either case: invoice deadlines, the validity of the confirmation and the destination
rules of the other state. Sources: § 6, § 6a, § 14, § 14a UStG, checked 2026-10-31. These are bounded
previews for documented cases, not tax advice.


### Further drafts: 0% rate, exemptions, § 13b, OSS, EU small business

Each needs caller-confirmed facts, cites its provision on every line (the line's `exemption_reason`
is printed under the description) and previews only; the legal assessment stays with the caller.

- **`de-zero-rate-section-12-3`:** photovoltaic supply or installation (`pv_supply_or_installation`),
  qualifying location (`qualifying_location`) and capacity of at most 30 kWp
  (`capacity_within_30_kwp`). Lines use `Zero` at 0% and cite "§ 12 Abs. 3 UStG". Private buyers are
  allowed (`buyer_type` is `business` or `consumer`).
- **`de-exempt-section-4`:** the exemption provision is confirmed (`exemption_provision_confirmed`) and
  no option to tax is exercised (`no_option_to_tax`). Lines use `Exempt` at 0% and cite "§ 4 Nr. …"
  with the actual number; the cited provision itself is not assessed.
- **`de-domestic-reverse-charge`:** `facts.section_13b_basis` names the provision (`13b_2_2` to
  `13b_2_12`, not the foreign-supplier cases) and `recipient_status_confirmed` covers the recipient's
  status (for construction services, that the recipient itself provides such services). Lines use
  `ReverseCharge` at 0% and carry "Steuerschuldnerschaft des Leistungsempfängers" (§ 14a Abs. 5 UStG);
  both parties need a VAT ID.
- **`de-eu-b2c-oss`:** consumer in another EU member state, Union scheme registration
  (`oss_registered`), destination taxation because the EU-wide threshold of 10,000 euro is exceeded or
  waived (`destination_taxation_applies`; § 3c, § 3a Abs. 5 UStG) and the destination rate
  (`destination_rate_confirmed`). Lines use `Standard` or `Reduced` with the destination rate; rates
  are not looked up.
- **`de-eu-small-business`:** BZSt Kleinunternehmer identification number issued
  (`small_business_id_issued`, number in `company.small_business_id`), EU-wide turnover within 100,000
  euro (`eu_turnover_within_limit`) and the destination state's conditions met
  (`destination_conditions_met`). Lines use `Exempt` at 0% with the destination state's wording. The
  structured file is not supported for this case: typstgen has no mapping from the Kleinunternehmer ID
  to the seller identifier that EN 16931 (BR-CO-26) demands without a VAT ID.

Sources: § 4, § 9, § 12, § 13b, § 14a, § 18j, § 19a, § 3a, § 3c UStG, checked 2026-10-31. Not checked:
deadlines, registrations and reports (OSS returns, quarterly small-business reports), destination-state
invoice rules. These are bounded previews, not tax advice.

## Responsibilities and normalized contract

The package owns the catalog, schema and rendering. Typstgen owns deterministic resolution,
validation, exact-decimal normalization and XML generation. CLI, library and MCP call the same
functions; there is no second country rule engine in the Typst templates.

`schema/document-request.schema.json` describes the validation envelope:

- `selection`: explicit profile ID/version, language, format locale, currency, layout,
  output profile and optional draft opt-in.
- `data`, `company`: the existing invoice/company contracts, retained for compatibility.
- `facts`: independently established case prerequisites and evidence references.

The returned canonical model has ISO calendar dates, ISO country/currency codes, decimal strings,
explicit line tax categories and separate category/rate tax groups. Quantities, prices and rates
use the existing typstgen decimal arithmetic (four fractional digits internally); monetary totals
round half away from zero directly to EUR cents, without an intermediate rounding step. Unit prices retain their canonical decimal precision
in both PDF and CII. Discounts, allowances, charges, partial payments,
advance invoices and other currency precisions are outside these released profile cases.

The returned `data`/`company` rendering view and CII serialization originate from that same
normalized model. It preserves established template fields and replaces numeric values with the
canonical values. Payment account overrides are reflected in both PDF and XML. The template
formats those values; it neither reclassifies tax nor reconstructs XML from PDF text.

Existing `invoice(data:, company:)` calls keep working. Optional `profile:` accepts rendering
choices (`language`, `format_locale`, `currency`, `layout`, `output_profile`) plus the resolved
identity. `company.language` remains the default text language. `locale:` overlays that catalog.
The profile's rule jurisdiction is not inferred from language, country names or recipient location.
DIN and international frames share references, parties, positions, sums and payment content.
DIN is a layout convention, not a universal legal requirement. Verified currency is EUR; mixed
or unsupported currencies fail explicitly. Date/number formatting uses `de-DE`, `en-GB` or
`fr-FR`; translated content does not silently translate customer-provided free text.

## DE prerequisites and legacy adapter

Both DE cases require DE seller/buyer country codes, business-customer status, a confirmed
place of supply and supply kind, explicit supply date and evidence references. A single invoice
cannot establish § 19 eligibility from annual turnover or determine whether a waiver applies.
The caller supplies eligibility, waiver status and the regime's confirmed start/end dates.
The supply date must lie within that interval. The applied case is persisted in
`data.metadata.applied_tax_case`; it is not read from the company's current status later.

The small-business case requires a § 19 note, appropriate per-line exemption reason, zero rates
and `SmallBusiness`/`Kleinunternehmer` categories; contradictory positive tax is blocked. A
transition to regular taxation selects a different explicit case. The legacy `vat_exempt` flag
and generic `Exempt` remain usable outside these case profiles; generic exemption is not
reclassified as § 19. True zero (Z), exemption (E) and reverse charge (AE) remain separate in the
shared model even at 0%; reverse charge still requires the buyer VAT ID. Their complete national
case profiles are not released. An EU buyer alone never grants exemption.

Primary sources reviewed 2026-10-26:
[§ 14 UStG](https://www.gesetze-im-internet.de/ustg_1980/__14.html),
[§ 12 UStG](https://www.gesetze-im-internet.de/ustg_1980/__12.html),
[§ 19 UStG](https://www.gesetze-im-internet.de/ustg_1980/__19.html),
[§ 34a UStDV](https://www.gesetze-im-internet.de/ustdv_1980/__34a.html).
The package's fact requirements and exclusions are implementation choices within this scope;
they do not replace checking the underlying business facts.

## France: extension proof, not electronic issuance

The confirmed second-country target is mainland domestic B2B ordinary services. The draft
reuses the common invoice core and data-driven rule evaluator. It requires party registration
and VAT identifiers, seller legal form/capital, supply date, service classification, seller size,
no VAT-on-debits option, no prior purchase order, and matching billing/delivery addresses.
Payment data includes an early-payment-discount statement, an independently established late
interest clause and the EUR 40 recovery amount. These country-specific fields are printed with
FR/EN labels. The fixture's interest clause is synthetic, not a recommended contractual rate.

The draft demonstrates identical fiscal values in French and English. Receipt obligations and
issuance timing depend on enterprise characteristics; transmission uses an approved platform
where applicable. The catalog records the route and staged dates separately. No platform or
reporting integration is implemented, so the draft is excluded from the released catalog and
requires `allow_draft: true`. Other rates, overseas territories, VAT-on-debits, different delivery
addresses, purchase orders, deposits, other legal forms and other tax cases need separate work.

Reviewed 2026-10-26:
[Mandatory invoice information](https://www.economie.gouv.fr/entreprises/factures-mentions-obligatoires),
[French VAT rates](https://www.douane.gouv.fr/fiche/les-taux-de-tva),
[Electronic invoicing rollout](https://www.economie.gouv.fr/tout-savoir-sur-la-facturation-electronique-pour-les-entreprises),
[Approved platforms](https://www.impots.gouv.fr/facturation-electronique-et-plateformes-agreees).

## Resolution and inheritance

The generic resolver selects the exact `profile_id`/`profile_version` pair. Languages, locales,
currencies, layouts and outputs must be declared capabilities. Unknown IDs, unsupported outputs,
abstract/unsupported profiles, unknown selection fields and unapproved drafts are blocked.

A profile may extend one exact parent. Required fields and sources are unioned; inherited rules
are retained. Replacing a rule ID requires an explicit `replace_rules` declaration. Conflicts,
unknown replacements, duplicate identities and inheritance cycles fail. Domain metadata and
capability arrays use explicit child replacement. Non-EU profiles have no implicit EU parent.
Rule operations are `required`, `equals`, `one_of`, `mapping`, `contains`, `within`; paths use dot
segments and `*` array traversal. Diagnostics include concrete paths, rule IDs and source records.
The schemas check the catalog shape; typstgen does not pretend a skipped JSON Schema run passed.

## Configuring your own invoices

For user-owned tax rates, required fields, notes and presentation, use
[invoice configuration](../invoice-configuration/). It prepares invoices without selecting a
national catalog entry. The catalogs below remain an optional layer for reviewed national rules.

## Complete synthetic agent flow

Profile tools require typstgen 0.6.0 or later (the version in `tool-versions.json`); the
published 0.5.0 binary does not have them.

1. Call `list_document_profiles` with the package catalog. By default it lists only released
   DE combinations; opt into drafts only for a deliberate preview.
2. Select `de-standard@1`, language `en`, format locale `en-GB`, currency `EUR`, layout
   `international`, output `pdf-preview`. The returned country remains DE and the tax case stays
   domestic standard. Do not substitute an FR case just because the recipient speaks French.
3. Ask for missing facts/fields reported by `validate_document`; preserve `not_run` checks.
   Do not invent VAT IDs, eligibility, numbers or evidence references.
4. Write the resolved view and compile the thin wrapper in `examples/invoice-profiles/invoice.typ`.
5. Run the existing `check`/`preview` tools, inspect the PDF, then `compile`. For a hybrid invoice,
   use the same canonical data with the existing ZUGFeRD compile path and external validators.

Install it with `cargo install typstgen --version 0.6.2 --locked`.

CLI equivalent, from `examples/invoice-profiles/`, with typstgen on PATH:

```sh
typstgen list-document-profiles --catalog ../../profiles/catalog.json
typstgen validate-document --catalog ../../profiles/catalog.json de-standard.json > resolved.json
typstgen compile invoice.typ
```

Library calls in `typstgen::profiles` are `list_document_profiles(catalog, include_drafts)`,
`resolve_document_profile(catalog, selection)`, `validate_document(catalog, request)`.
MCP exposes the same names; `catalog` is a workspace-relative file path, `selection`/`request`
are JSON objects. Its workspace path checks also apply to catalogs. No additional MCP server
is needed. Existing `check` remains a compilation check.

Reports expose `resolved`/`blocked` for selection and `ready_for_preview`/`blocked` for validation.
`checks` separates `schema`, `business_rules`, `arithmetic`, `en16931`, `output_profile`, `pdfa`
and `transmission`. Only executed checks pass. A blocked document has no rendering view;
missing prerequisites are actionable diagnostics. A successful preview is not a send/issue action.

## Local acceptance test

From the repository root, run:

```sh
scripts/test.sh
```

Prerequisites are Cargo, Python 3, Java and the veraPDF CLI. On macOS, `brew install openjdk
verapdf` supplies the external runtimes. `JAVA_BIN` and `VERAPDF_BIN` can select explicit
executables. The script prefers a working Java on PATH and recognises Homebrew's JDK location.
An optional positional argument selects a different parent output directory. Each invocation
creates a fresh `run-…/` directory, so a failed run cannot expose an older success report.

The script builds the pinned typstgen and chartlet versions, creates
an isolated Python environment and verifies the pinned Mustang checksum before executing it.
All downloaded/built tools stay under `.cache/test-tools/`; build directories are separated by
version. Global installations
are untouched.

On success, the printed `output/test/run-…/` directory contains:

- `package/`: A4/landscape publications, phased tasks, metadata fixtures, credentials with and
  without masking, long titles, a logo and a dark-page example. Credentials are synthetic.
- `invoices/`: DE de/en × DIN/international, § 19, multiple rates, legacy zero-tax categories,
  FR fr/en draft and long multipage examples; each with its request/resolved data.
- Beside the hybrid PDFs: the embedded Factur-X XML, Mustang XML report and veraPDF result.
- `report.json`: executed checks, external validator versions, checksum, retained notices and
  explicit `not_run` stages. A successful run does not claim transmission or release the FR draft.

Inspect the PDFs after the automated checks. For manual editing, change a synthetic source in
`examples/invoice-profiles/`, not its generated report. Run the profile validation command again
before compiling `invoice.typ`; do not reuse an old resolved view after changing request data.
Existing user projects remain outside this public acceptance suite.

## Reproducible checks and structured output

```sh
python scripts/check-profiles.py --typstgen /absolute/path/to/typstgen \
  --mustang /absolute/path/to/Mustang-CLI-2.26.0.jar \
  --java /absolute/path/to/java --verapdf /absolute/path/to/verapdf \
  --report /tmp/profile-validation.json
```

This checks DE de/en in both layouts, § 19, multiple rates, FR fr/en, missing prerequisites,
regime validity and negative cases. It compares canonical totals and line categories against
embedded CII and extracted PDF totals, and checks identifiers, parties, addresses, dates, currency and payment accounts, validates Factur-X with Mustang 2.26.0 and PDF/A-3b with
veraPDF 1.30.0 when explicitly supplied. The generated report records versions, validator hash
and notices; omitted validators remain `not_run`. Validator pins and adapter states live in
`profiles/validators.json`. Mustang can report additional XRechnung notices while the selected
Factur-X profile passes; these notices are retained, not treated as XRechnung certification.
The pure XRechnung/Peppol files from `typstgen e-invoice` are validated separately, see below.

Archive source inputs, selection, catalog/rule versions, confirmed facts and evidence references,
text overrides, package/tooling commits, fonts/assets, creation timestamp, typstgen build manifest
and external reports. No number reservation, booking, payment tracking or document delivery is
performed.

## E-invoice files: XRechnung and Peppol

`typstgen e-invoice --company company.json --format xrechnung-3.0 invoice.json` (or
`peppol-bis-3.0`) writes UBL 2.1 XML from the same canonical invoice data as the PDF and the CII
path, never from the rendered PDF. It does not send anything; Peppol network transport and national
submission duties remain outside this package.

Both formats need additional fields, which are reported with their JSON path when missing:
`company.electronic_address` and `recipient.electronic_address` (`scheme_id`, `value`),
`metadata.buyer_reference` (XRechnung; Peppol accepts `metadata.order_reference` instead) and, for
XRechnung, `company.contact.name`, `company.contact.phone`, `company.contact.email` and a payment
method (`payment.method_code` or a bank account). With a catalog profile, `validate-document` and the
MCP tool of the same name report these fields (`OUTPUT-REQUIRED`) before the file is written. An
unknown format is an error, not a PDF fallback. The command reports arithmetic and required fields; XML schema, EN 16931, profile and
transmission checks are `not_run` and need an external validator.

`scripts/check-profiles.py` writes both formats for the VAT fixtures, compares payable amount,
currency, invoice number and tax group count with the canonical values and, when `--mustang` is
given, validates the files with Mustang 2.26.0. Mustang applies the EN 16931 and XRechnung 3.0
rules to the XRechnung file but, for Peppol, only the EN 16931 UBL rules.

### Official rule sets, on demand

```sh
python3 scripts/validate-einvoice.py --typstgen "$(command -v typstgen)"
```

The script is not part of CI or `test.sh`. It downloads the pinned tools listed in
`profiles/validators.json` into `.cache/test-tools/einvoice-validators/` (SHA-256 checked),
writes both formats for the synthetic German demo invoice and validates them with the KoSIT
validator 1.6.3: XRechnung with KoSIT's official configuration 3.0.2 (2026-08-31), Peppol with a
scenario assembled by the script from the UBL schema, the CEN rules and the Peppol BIS Billing
3.0.21 Schematron (compiled locally with the ISO Schematron pipeline). A control copy without the
buyer reference must be rejected, so a pass cannot come from a validator that checks nothing.
Report and files land in `output/einvoice/`. Run it again after changing typstgen or a pin.

Result on 2026-10-31 with typstgen 0.6.2: both files accepted, both controls rejected. This
covers the German demo invoice (one standard-rated VAT group), not every tax case; the Peppol
scenario is assembled here and is not an official Peppol validator distribution. Credit notes,
sales-tax invoices and transmission are not covered.
