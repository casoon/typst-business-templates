---
title: Invoice profiles and agent workflow
description: Separate country rules, tax cases, language, layout and output, with explicit validation boundaries.
order: 7
---

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
| Other listed cases | unsupported | True zero, other exemptions, reverse charge, EU goods/services, exports, B2C/OSS, cross-border small business | none |

`pdf-preview` is a rendering output. It is not a statement that issuing a plain PDF satisfies an
applicable electronic invoicing obligation. The existing Factur-X pipeline remains available
separately and is checked with canonical data and external validators below. Versioned XRechnung
3.0.2/UBL 2.1 and Peppol BIS Billing 3.0.21/UBL 2.1 adapter specifications are in the catalog;
they are explicitly **not implemented** and cannot be selected as released outputs. Peppol
transport and French approved-platform transmission are not supplied.

The DE profiles cover supply dates in the reviewed interval 2025-01-01 through 2026-12-31;
the FR draft starts 2026-09-01. These are bounded package review windows, not statutory expiry
dates. Recheck sources and version the profile before extending a window or releasing a case.

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

## Complete synthetic agent flow

Profile tools require the coordinated **unreleased typstgen profiles build**, not the published
0.5.0 binary. The base package examples remain checked with published typstgen 0.5.0. Use the
revision `aad498243e13011906e66ec4bbf3874d33734035` recorded in `tool-versions.json` for the profile workflow; no crate publication or
external release is implied.

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

Build the coordinated CLI from the typstgen checkout at that revision with `cargo build --locked`.
Once the branch is available remotely, `cargo install --git https://github.com/casoon/typstgen
--rev aad498243e13011906e66ec4bbf3874d33734035 --locked` selects exactly that source revision.
The CLI still identifies its package version as 0.5.0; the Git revision distinguishes this
unreleased feature build from the published crate. Do not install the published 0.5.0 crate
and expect profile commands to exist.

CLI equivalent, from `examples/invoice-profiles/`, with the coordinated binary on PATH:

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

The script builds the exact coordinated typstgen revision and pinned chartlet version, creates
an isolated Python environment and verifies the pinned Mustang checksum before executing it.
All downloaded/built tools stay under `.cache/test-tools/`; build directories are separated by
Git revision to prevent reuse of older binaries with the same crate version. Global installations
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
python scripts/check-profiles.py --typstgen /absolute/path/to/coordinated/typstgen \
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

Archive source inputs, selection, catalog/rule versions, confirmed facts and evidence references,
text overrides, package/tooling commits, fonts/assets, creation timestamp, typstgen build manifest
and external reports. No number reservation, booking, payment tracking or document delivery is
performed. XRechnung/Peppol adapters require their specific address/reference/payment/unit
fields and validator artifacts before they can move from specification to released capability.
