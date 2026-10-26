# Typst Business Templates

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Deterministic business PDFs from JSON data and reusable Typst templates.**

Keep structured content and company data in JSON, and define the document layout in Typst.
With the same data, templates, fonts, assets, compiler and timestamp,
[typstgen](https://github.com/casoon/typstgen) reproduces the document build. The sources can
be versioned and reviewed alongside your project.

`business-templates` provides 21 templates for invoices, offers, letters, contracts,
credentials, compact publications, printable forms and landscape brochures.
[chartlet](https://github.com/casoon/chartlet) supplies diagrams when needed.

**[Documentation](https://casoon.github.io/typst-business-templates/)** ·
**[Capabilities and limits](docs/reference/project-status.md)** ·
**[Demo gallery](examples/invoice-languages/README.md)**

## See what you can make

Eight committed PDFs cover German, English, French, Spanish, Italian, Dutch and
Portuguese, plus an English US variant. Each has editable invoice data and configuration;
all use one shared template and a fictional SVG logo.

- [German invoice](examples/invoice-languages/de/invoice.pdf): A4, EUR, German labels.
- [US invoice](examples/invoice-languages/en-US/invoice.pdf): Letter, USD, US dates and separate
  state/local tax components.
- [All eight demos and rebuild instructions](examples/invoice-languages/README.md).

The businesses, accounts and tax rates in these examples are fictional. A language demo is
not a reviewed national tax preset.

## Configure an invoice

Copy [`invoice-config.json`](invoice-config.json) into your project. It declares named tax
rates or sales-tax components, required input fields, notes, language, number/date format,
currency, paper and layout. Each item selects a tax key; omitted totals are calculated by
`typstgen prepare-invoice`. Supplied totals are checked against the same decimal model.

The returned data drives the PDF and, for VAT invoices, the existing CII/Factur-X adapter.
Sales-tax invoices produce PDF and component data. Selecting a country or language does not
infer applicable tax rules or transmission requirements.

[Configuration guide](docs/guides/invoice-configuration.md) ·
[Optional reviewed profiles](docs/guides/invoice-profiles.md)

## Installation and development status

The Typst package is **0.1.0 development source**, installed locally as
`@local/business-templates:0.1.0`. Pin a repository commit; there is no published Typst package
release or Universe upload yet.

Configured invoices and profile tools require the **coordinated typstgen source revision** in
[`tool-versions.json`](tool-versions.json). Installing the published typstgen 0.5.0 does not
provide these commands. The [installation guide](docs/getting-started/installation.md)
distinguishes both toolchains and shows the pinned installation.

Existing plain-template examples remain compatible with published typstgen 0.5.0:

```sh
cargo install typstgen --version 0.5.0 --locked
git clone https://github.com/casoon/typst-business-templates
cd typst-business-templates/examples/it-consultant
typstgen compile documents/invoices/2025/invoice.typ
```

## Beyond invoices

- [Accounting documents](docs/guides/json-documents.md): offers, credit notes, reminders,
  delivery notes, order confirmations, requests, time sheets and letters.
- [Documents in Typst](docs/guides/typst-documents.md): concepts, contracts, documentation,
  proposals, protocols, specifications and tasks.
- [Publications](docs/guides/publications.md): compact A4 guides, intake forms, printable
  components and landscape brochures.
- [Branding and languages](docs/guides/branding.md): company data, logo, fonts and partial
  translation overrides. Credentials can mask password fields.
- [Diagrams](docs/guides/diagrams.md): chartlet SVGs embedded in documents.
- [Package reference](docs/reference/package.md): exports, JSON schemas and configuration.

The full [example projects](examples/README.md) demonstrate both JSON-driven and Typst-authored
documents. [Migration](docs/guides/migration.md) describes existing consumers; a real consumer
migration remains a separate integration step.

## Checks

```sh
./scripts/test.sh
```

The script builds pinned tools in a project-local cache, runs package/profile checks and
external VAT invoice validation, rebuilds all eight language demos and retains PDFs/reports
under `output/test/`. It needs Cargo, Python 3, Java and veraPDF. See the
[acceptance workflow](docs/guides/invoice-profiles.md#local-acceptance-test) for prerequisites.
`./scripts/check.sh` is the compatibility check for an already installed compiler.

The hero workflow is defined in `site/diagrams/document-build.json`. Regenerate its light/dark
and wide/narrow Chartlet SVGs with `python3 site/scripts/render-workflow.py`.

## Earlier docgen versions

The old `docgen` CLI and Rust crate are discontinued. Client/project management, numbering
and encryption are not part of this Typst package. Historical tags retain their meaning;
see [versions and release preparation](docs/reference/releases.md).

Created by [casoon.de](https://www.casoon.de). MIT: [LICENSE](LICENSE).
Fonts in [`fonts/`](fonts/) have their own open licenses.
