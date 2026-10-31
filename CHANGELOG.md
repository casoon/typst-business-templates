# Changelog

All notable changes to the `business-templates` Typst package are documented here.
Package versions follow Semantic Versioning independently of the discontinued docgen crate.
The unchanged [docgen release history](https://casoon.github.io/typst-business-templates/docs/reference/docgen-changelog/)
is archived separately.

## [Unreleased]

### Added
- **Invoices:** XRechnung 3.0 and Peppol BIS Billing 3.0 files (UBL 2.1) from the same invoice data via
  `typstgen e-invoice`, checked against the canonical values and validated with Mustang 2.26.0.
  Details: [E-invoice files](https://casoon.github.io/typst-business-templates/docs/guides/invoice-profiles/#e-invoice-files-xrechnung-and-peppol).
- **Testing:** `scripts/validate-einvoice.py` validates XRechnung and Peppol files on demand with the pinned KoSIT validator, the official XRechnung configuration and the Peppol BIS Billing 3.0.21 Schematron, including a control that must be rejected.
  Details: [Official rule sets](https://casoon.github.io/typst-business-templates/docs/guides/invoice-profiles/#official-rule-sets-on-demand).
- **Invoices:** `xrechnung-3.0` and `peppol-bis-3.0` are selectable outputs of the released DE profiles; `validate-document` reports the fields each format needs before the file is written (typstgen 0.6.1).
  Details: [E-invoice files](https://casoon.github.io/typst-business-templates/docs/guides/invoice-profiles/#e-invoice-files-xrechnung-and-peppol).
- **Invoices:** Draft profiles for the 0% rate on photovoltaic systems (`de-zero-rate-section-12-3`), § 4 exemptions (`de-exempt-section-4`), domestic reverse charge (`de-domestic-reverse-charge`), EU B2C under the Union scheme (`de-eu-b2c-oss`) and EU small businesses (`de-eu-small-business`), with examples and CII/UBL validation where the structured file is supported.
  Details: [Further drafts](https://casoon.github.io/typst-business-templates/docs/guides/invoice-profiles/#further-drafts-0-rate-exemptions-13b-oss-eu-small-business).
- **Invoices:** Draft profiles `de-eu-goods-b2b` (intra-Community supply, category K) and `de-third-country-export` (export, category G) with prerequisites, statutory notes, examples and CII/UBL validation; `IntraCommunity` and `Export` VAT codes, `delivery_country_code`, `delivery_city` and `delivery_postal_code` in the invoice schema (typstgen 0.6.2).
  Details: [EU goods and export](https://casoon.github.io/typst-business-templates/docs/guides/invoice-profiles/#eu-goods-and-export-drafts).
- **Invoices:** Draft profile `de-eu-services-b2b` for German services to business customers in other EU member states (reverse charge, category AE), with prerequisites, statutory note check, CII/UBL validation and an example.
  Details: [EU service profile](https://casoon.github.io/typst-business-templates/docs/guides/invoice-profiles/#eu-service-to-a-business-customer-draft).

### Changed
- **Documentation:** README, start page, FAQ and the invoice guides state that the invoice and tax-case profiles are templates not reviewed by a tax adviser, describe the use cases, and list every invoice case with its state (released or draft); the start page table is generated from the profile catalog and a check keeps README, guide and start page in step.
- **Invoices:** Reverse-charge and intra-Community invoices print the recipient's VAT ID, as § 14a UStG requires. Other invoices are unchanged.
- **Tooling:** typstgen 0.6.2 is the single pinned compiler version. It is the published crate, so
  the separate source build for invoice configuration and profile tools is gone: install it with
  `cargo install typstgen --version 0.6.2 --locked`. CI, `scripts/test.sh` and the demo builder use it.
- **Installation:** `scripts/install-package.sh` copies the package into Typst's local package
  directory; README and installation guide describe setup in three steps.
- **Metadata:** Year-only prose `created_at` labels remain visible and no longer imply a fabricated PDF calendar date. Details: [migration](https://casoon.github.io/typst-business-templates/docs/guides/migration/#document-identity).
- **Documentation:** Useful questions from the retired landing page are consolidated into an
  updated FAQ, with the historical practice article linked from the migration guide.
- **Pages:** GitHub Pages is the single project homepage; the redundant custom-domain link
  is removed from the header and metadata.
- **Pages:** theme 0.11.1; the start page now carries a release teaser and an FAQ.

## [0.2.0] - 2026-10-26

### Breaking
- **docgen and the Rust crate are discontinued.** The repository is now the Typst package
  `business-templates` 0.2.0 in `templates/`, compiled with
  [typstgen](https://github.com/casoon/typstgen). `cli/`, `src/`, the install script, the release
  binaries and the `sys.inputs` adapters for docgen are removed. Client and project management,
  numbering and `--encrypt` are not carried over.
- **Diagrams** come from [chartlet](https://github.com/casoon/chartlet) instead of docgen's layout
  code: the examples in `examples/diagrams/` are chartlet specs, rendered as SVG. The `diagram`
  template is removed; the mind map uses chartlet's radial tree and the quadrant a scatter plot with
  named quadrants (chartlet 0.21).
- `locale/` moved into the package (`templates/locale/`).

### Added
- **Examples:** All eight invoice language demos include a shared fictional SVG logo.
- **Invoices:** Configurable US Letter, US dollar/date formatting and separately calculated
  sales-tax components, with eight committed language and US demos plus editable inputs.
- **Invoices:** A reusable `invoice-config.json` controls named taxes, required fields, notes,
  currency and presentation through typstgen's shared invoice preparation API.
- **Testing:** `scripts/test.sh` builds the coordinated tools in an isolated cache and retains
  synthetic package/invoice PDFs, canonical inputs and external validation reports for manual review.
- **Invoices:** Shared DE/international rendering with independent language and number formatting,
  versioned DE standard/§ 19 preview profiles, a French B2B draft and coordinated typstgen contracts.
- **Validation:** Canonical PDF/CII integration checks with optional pinned Mustang and veraPDF
  validation; unsupported national cases and structured adapters have explicit capability states.
- **Publications:** Compact A4 `publication` and landscape `brochure` frames, with printable fields,
  choices, notices, phases, tables, priorities, cards and numbered steps; synthetic multipage examples.
- **Credentials:** `mask: true` replaces nonempty password fields before rendering and adds a
  translated notice; PDF extraction checks verify that synthetic passwords are absent.
- **Task lists:** Optional phases and caller-defined role legends supplement the existing `assignee`
  field with visible responsibility labels.
- **Typst package:** `typst.toml` and `lib.typ`; accounting templates are functions
  (`invoice(data:, company:)` …), running-text documents take named parameters and a body
- Language from `company.json`: the running-text templates and credentials load the labels for
  `company.language` when no `locale` is passed (before, they fell back to English labels)
- **Totals check:** invoice, offer, credit note and order confirmation stop the build when an item
  total, the subtotal, the VAT or the total does not add up, to the cent
- **§ 19 UStG note:** invoice and credit note print `default_terms.vat_note` from `company.json`
  when `vat_exempt` is set; the old README promised this, but no template did it
- **PDF metadata:** accounting documents set the document number as title, the company as author
  and the document date, which PDF/A-3 needs for ZUGFeRD e-invoices
- **JSON schemas** for every accounting document and `company.json` in `schema/`; the example files
  reference them with `$schema`
- **Examples** for every template, compiled with typstgen, including a ZUGFeRD invoice, a task list,
  a handout and an architecture diagram in the documentation
- **From casoon-data:** the letter takes its text as Typst content (headings, lists, tables), free
  address `lines`, a `final` paragraph kept with the closing and a page header from page 2; a
  recipient's company is not printed twice when it repeats the name; the offer prints the company
  above the contact person, its project reference, and "Gesamtbetrag (netto)" without VAT; units
  `tag`, `monat`, `jahr` take the plural for quantities other than 1
- **Task list tags** are shown again below each task (removed in 0.6.10)
- `scripts/check.sh` and a CI workflow on pull requests: compiles all examples and diagrams,
  builds the e-invoices, validates the JSON and compares the locale keys

### Changed
- **Package:** Version 0.2.0 aligns the manifest, local imports, example package path and website;
  the first standalone template release uses the `templates-v0.2.0` tag.
- **Pages:** A practical MCP workflow and setup guide explain AI-assisted checking, previews
  and PDF generation; the entry path covers other documents and clarifies invoice language scope.
- **Pages:** The homepage, README and documentation explain typstgen as the separate
  compiler project, with links to its repository and compatible installation instructions.
- **Pages:** The hero explains deterministic JSON/Typst document generation with a responsive
  Chartlet workflow; multilingual invoices remain a concrete application below.
- **Pages:** English audience-focused copy, direct PDF/setup links and a shorter example workflow
  make the document templates easier to explore before installing the tooling.
- **Documentation:** README, installation and capability reference distinguish published tooling
  from coordinated development features; Pages includes language/US invoices and publications.
- **Diagrams:** rendered with chartlet 0.21 instead of 0.19. The checked-in SVGs of the
  architecture, flow and swimlane examples gained a fuller description for screen readers, naming
  the most connected node, loops and bottlenecks; the drawings themselves are unchanged.
- **Tooling:** the pinned versions of typstgen and chartlet live in `tool-versions.json`, read by
  the check workflow and by the start page, instead of being written out in each place.

- **Locales:** Partial dictionaries recursively overlay the selected language catalog; null inherits,
  empty strings suppress labels, and incompatible known types fail with a field path.
- **Metadata:** Running-text documents keep the human title, author, assigned number and explicit
  date in PDF metadata without inventing missing creation dates.
- **Releases:** Documented independent Typst package tags, pinned installation, legacy migration and
  family-by-family integration; historical crate tags retain their meaning.
- **Contributors:** The existing check command also verifies locale contracts, password masking,
  document identity, PDF/UA compilation and tagged publication tables with synthetic data.

### Fixed
- **Invoices:** Unit prices retain their canonical decimal precision in the PDF, matching the CII
  unit price instead of silently rounding it to EUR cents.
- **Invoices:** Optional null logos and omitted house numbers work in the profile examples and
  both address layouts, matching the existing data schema.
- **Templates checked against casoon-data**, the production user of the old template copy: the
  title pages of concept, documentation and protocol look as before the refactoring of January
  2026 again (own page without header and footer, bold labels with colon, outlined tags, 24 pt
  title); accounting documents no longer fail without `language` in `company.json` (default `de`);
  the totals check accepts `totals.discount_total`
- **Logo with the package:** `company.logo` may be image bytes; a path pointed into the package
- **Task list** ignored a `company` passed to it (colours, logo, language)
- **Reminder** failed on a numeric or missing `reminder_level` and on a fee given as string;
  **credit note** failed on a salutation without introduction
- **Example documents that did not compile:** the it-consultant order confirmation, time sheet
  and SLA used wrong field names or unescaped `#`/`@`; the contract template referenced an
  undefined `status`; the SLA template built party names as content; the title page failed on
  `tags: none`
- **Delivery note printed Typst code:** the address block call was missing its `#`
- **Optional fields:** the order confirmation no longer requires `order_number` or `terms`, and
  document footers leave out the status line when no status is set
- **Letter example:** the subject was outside `metadata`, where the template does not read it
- **Project page:** the caption under the hero invoice made the page wider than a phone screen;
  it now names the example folder and takes the typstgen version from `tool-versions.json`
