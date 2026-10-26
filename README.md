# Typst Business Templates

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Invoices, offers, contracts and other business documents as a Typst package.**

`business-templates` is a [Typst](https://typst.app/) package with 21 templates for small
businesses: accounting documents with a DIN 5008 address block, and longer documents with a
title page. Compile them with [typstgen](https://github.com/casoon/typstgen), which also turns an
invoice into a ZUGFeRD e-invoice. Diagrams come from [chartlet](https://github.com/casoon/chartlet).

Created by [casoon.de](https://www.casoon.de).

**Website and documentation:** [casoon.github.io/typst-business-templates](https://casoon.github.io/typst-business-templates/)

> **docgen and the Rust crate are discontinued.** Earlier versions shipped the `docgen` CLI and
> the `typst-business-templates` crate. Both are replaced by typstgen, which compiles the same
> templates and JSON files. Client and project management, numbering and `--encrypt` were not
> carried over.

## Quick start

```bash
cargo install typstgen --version 0.5.0 --locked
git clone https://github.com/casoon/typst-business-templates
cd typst-business-templates/examples/it-consultant
typstgen compile documents/invoices/2025/invoice.typ
```

The PDF is written next to its source. Every example project has a `typstgen.toml` that points
to the package in this repository and to the fonts in `fonts/`.

## Use the package in your own project

Copy or link `templates/` into your Typst package directory as
`local/business-templates/0.1.0`, or set `package_path` in your project's `typstgen.toml`:

```toml
# typstgen.toml — run typstgen in the project folder
template_paths = ["."]                                  # project folder = root for /data/…
package_path = "path/to/packages"                       # contains local/business-templates/0.1.0
font_paths = ["path/to/typst-business-templates/fonts"]
```

An invoice is its data in JSON plus a short Typst file:

```typst
// documents/invoices/2026/RE-2026-001.typ
#import "@local/business-templates:0.1.0": invoice

#invoice(
  data: json("RE-2026-001.json"),
  company: json("/data/company.json"),
)
```

A concept, contract or documentation is written in Typst:

```typst
#import "@local/business-templates:0.1.0": concept

#show: concept.with(
  title: "Online-Shop Konzept",
  document_number: "KO-2026-001",
  company: json("/data/company.json"),
)

= Ausgangssituation
…
```

See [migration](docs/guides/migration.md) for existing projects and
[versions and releases](docs/reference/releases.md) for the package/docgen version mapping.
The package in this checkout is unreleased; pin its commit when installing.

## Templates

| Kind | Functions | Arguments |
| --- | --- | --- |
| Accounting | `invoice`, `offer`, `credit-note`, `reminder`, `delivery-note`, `order-confirmation`, `quotation-request`, `time-sheet`, `letter` | `data:` (JSON), `company:` |
| Accounting | `credentials` | `data:`, `company:`, `locale:` |
| Documents | `concept`, `contract`, `documentation`, `proposal`, `protocol`, `sla`, `specification`, `task-list`, `handout`, `publication`, `brochure` | named parameters, `company:`, the body as content |

- **Company data** from `company.json`: address, contact, tax and bank data for the footer, logo.
- **Branding and seven languages** for the running-text documents and credentials: accent and
  primary colour, one of eleven font presets, labels in `de`, `en`, `es`, `fr`, `it`, `nl`, `pt`
  chosen by `language` in `company.json` (`locale:` overrides them). The other accounting
  documents are German, in Helvetica, with a DIN 5008 layout. Invoice language, number format
  and DIN/international layout are independently selectable.
- **Totals are checked.** Invoice, offer, credit note and order confirmation stop the build if an
  item total, the subtotal, the VAT or the total does not add up, to the cent.
- **Kleinunternehmer:** with `default_terms.vat_exempt` in `company.json`, invoice and credit note
  print the § 19 UStG note.
- **PDF metadata:** accounting documents carry the document number as title, the company as
  author and the document date.

A logo in `company.json` is a path, which a package cannot read. Pass the image bytes instead:

```typst
#let company = json("/data/company.json")
#company.insert("logo", read("/data/logo.png", encoding: none))
```

Compact A4 guides, printable form components and landscape brochures are described in
[Publications](docs/guides/publications.md).

## E-invoices (ZUGFeRD / Factur-X)

typstgen embeds the invoice data as `factur-x.xml` (EN 16931), built from the same JSON the
template renders:

```bash
typstgen compile invoice.typ --zugferd invoice.json --company data/company.json --pdf-standard a-3b
```

See the [typstgen e-invoice guide](https://casoon.github.io/typstgen/docs/guides/e-invoices/) for
the field mapping and VAT codes.

## JSON schemas

[`schema/`](schema/) has a JSON schema for every accounting document and for `company.json`.
Reference it from a data file for completion and checks in the editor:

```json
{
  "$schema": "https://casoon.github.io/typst-business-templates/schema/invoice.schema.json",
  "metadata": { "invoice_number": "RE-2026-001", "invoice_date": "2026-01-15" }
}
```

## Diagrams and charts with chartlet

[chartlet](https://github.com/casoon/chartlet) lays out flow charts, trees, timelines,
architecture and sequence diagrams and charts from a JSON spec and writes SVG. Render the print
variant and place it in any document:

```bash
cargo install chartlet
chartlet render architecture.json --variant print -o architecture.svg
```

```typst
#figure(image("architecture.svg", width: 100%), caption: [Plattform-Architektur])
```

[`examples/diagrams/`](examples/diagrams/) has eight specs, and the it-consultant documentation
embeds an architecture diagram.

## Examples

| Folder | Content |
| --- | --- |
| [`examples/it-consultant/`](examples/it-consultant/) | Every accounting document plus concept, contract, documentation, proposal, protocol, SLA, specification |
| [`examples/digitalagentur/`](examples/digitalagentur/) | Invoice, offer, credentials, concept, documentation, task list |
| [`examples/freelance-designer/`](examples/freelance-designer/) | Kleinunternehmer without VAT |
| [`examples/handout/`](examples/handout/) | Worksheet with tasks and answer fields |
| [`examples/diagrams/`](examples/diagrams/) | chartlet specs |

[`examples/README.md`](examples/README.md) explains the project layout.

## Development

For a complete local test with retained PDFs and external validator reports:

```bash
scripts/test.sh
```

This builds the pinned typstgen/chartlet revisions in `.cache/test-tools/`, installs the pinned
Python test dependencies in a local virtual environment and verifies the Mustang download
checksum. It requires Cargo, Python 3, a Java runtime and the veraPDF CLI (on macOS: `brew install
openjdk verapdf`). It runs package and invoice checks and keeps each run in a fresh `output/test/run-…/` directory.
The first run downloads/builds the tools; later runs reuse them. No global tool installation is
replaced. See [the testing workflow](docs/guides/invoice-profiles.md#local-acceptance-test).

The compatibility check with an already installed typstgen is:

```bash
scripts/check.sh
```

compiles every example and diagram, builds the example invoices as ZUGFeRD e-invoices, validates
the example JSON against the schemas and compares the locale keys. It needs typstgen, `pip install
jsonschema referencing pypdf`, and chartlet for the SVG check. CI runs it on every pull request.

## License

MIT, see [LICENSE](LICENSE). The fonts in [`fonts/`](fonts/) have their own open licenses.

Versioned invoice profiles and the coordinated typstgen development workflow are described in
[Invoice profiles](docs/guides/invoice-profiles.md). Only explicitly listed cases/output combinations
are released; France is a preview draft and XRechnung/Peppol adapters are specified but unimplemented.
