---
title: Overview
description: What the business-templates Typst package contains, which tools it works with, and how this documentation is organised.
order: 0
---

typst-business-templates is the [Typst](https://typst.app/) package `business-templates`: 19
templates for business documents — invoices, offers, credit notes, reminders, letters,
credentials, concepts, contracts, documentation and more. Two tools from the same author go with
it:

- **[typstgen](https://casoon.github.io/typstgen/)** compiles the documents to PDF and, for
  invoices, embeds ZUGFeRD / Factur-X data. Any Typst compiler works for plain PDFs; the examples
  and this documentation use typstgen.
- **[chartlet](https://casoon.github.io/chartlet/)** renders diagrams from a JSON spec to SVG,
  which the documents embed as images.

## What it covers

- Ten accounting documents with a DIN 5008 address block and a four-column company footer. Their
  data lives in JSON files, described by [JSON schemas](reference/package/#json-schemas).
- Nine documents written in Typst, with a title page and optional table of contents.
  See [Document types](reference/document-types/).
- Totals check: invoice, offer, credit note and order confirmation refuse to compile if the
  amounts in the JSON do not add up.
- E-invoices: typstgen turns an invoice into a PDF/A-3 with `factur-x.xml` (EN 16931) from the
  same JSON.
- Company data, colours, logo and one of eleven font presets from `company.json`; labels of the
  running-text documents in seven languages.

## Where it stops

| The package does | The package does not |
| --- | --- |
| Lay out the document from the data you give it | Calculate totals or VAT — the JSON carries the numbers, the templates only check them |
| Stop the build when totals do not add up | Assign document numbers or keep counters, clients or projects |
| Produce a ZUGFeRD invoice together with typstgen | Fully validate it — typstgen's checks are not an EN 16931 validator; use one such as [Mustang](https://www.mustangproject.org/) before sending |
| | Send documents, track payments or book anything |
| | Produce XRechnung or ZUGFeRD credit notes |

## How the docs are organised

- **Getting started**: [install](getting-started/installation/) typstgen and the package, then
  compile a [first invoice](getting-started/quickstart/).
- **Guides**: [accounting documents from JSON](guides/json-documents/),
  [documents written in Typst](guides/typst-documents/), [diagrams with chartlet](guides/diagrams/)
  and [branding and languages](guides/branding/).
- **Reference**: the [package](reference/package/) (functions, parameters, schemas) and the
  [document types](reference/document-types/).

Every document in the [showcase](../showcase/) was compiled from the example file shown next to
it. The example projects are in
[`examples/`](https://github.com/casoon/typst-business-templates/tree/main/examples).

## docgen and the Rust crate

Earlier versions shipped `docgen`, a CLI with project scaffolding, numbering and client
management, and a Rust library crate. Both are discontinued: the templates are now a plain Typst
package, and compiling and e-invoices are done by typstgen.
