---
title: Overview
description: Configurable invoices, business documents, publications and the boundaries of the current package.
order: 0
---

`business-templates` is a Typst package with 21 document templates. It combines JSON-driven
accounting documents with Typst-authored contracts, concepts, documentation, compact guides,
printable forms and landscape brochures. Company data and content remain ordinary files.

## Choose a workflow

| What you need | Start here |
| --- | --- |
| Editable tax rates, VAT/sales-tax components, required fields, language and paper | [Invoice configuration](guides/invoice-configuration/) |
| A PDF to inspect before installing anything | [Showcase](../showcase/): seven invoice languages, a US variant and other document families |
| Existing invoice JSON with supplied totals | [Quickstart](getting-started/quickstart/) and [accounting documents](guides/json-documents/) |
| Compact A4 guides, intake forms and landscape pages | [Publications](guides/publications/) |
| Long documents authored in Typst | [Documents in Typst](guides/typst-documents/) |
| An AI assistant that checks, previews and compiles your documents | [AI assistants with MCP](guides/ai-agents/) |
| Reviewed, explicitly bounded national rules | [Optional invoice profiles](guides/invoice-profiles/) |

## Roles of the tools

The templates and compiler live in separate repositories. This repository contains the
`business-templates` Typst package, JSON schemas and examples.
[typstgen](https://github.com/casoon/typstgen) is installed separately and provides the CLI,
Rust library and MCP server, with the Typst compiler embedded. Follow the
[setup guide](getting-started/installation/) to select the compatible version.

The Typst package renders the document and checks supplied totals.
[typstgen](https://casoon.github.io/typstgen/) compiles Typst and, since 0.6.0, prepares configured invoices using exact decimal arithmetic. VAT PDFs and CII
XML use the same canonical invoice values. Sales-tax configurations return PDF rendering data
with independent component amounts and are excluded from the CII adapter.
[chartlet](https://casoon.github.io/chartlet/) supplies diagrams as SVG.

Invoices support seven languages, DIN/international layout, A4/US Letter and independent
currency/format choices. Other accounting templates retain their existing German/DIN contract.
Running-text documents and credentials have their documented branding and locale options.

## Package version and boundaries

Package 0.2.0 is distributed as the `templates-v0.2.0` source release for local installation. Checked with typstgen 0.6.1
(`tool-versions.json`), which provides configured invoices, profile tools and e-invoice files.
See [Installation](getting-started/installation/) for setup, and [Capabilities and limits](reference/project-status/) for the implementation map.

The configurable builder does not determine applicable law, rates, taxability, nexus or
national delivery requirements. Transmission (including Peppol network delivery) and additional reviewed
cross-border cases are not implemented. Numbering, accounting, payment tracking and client
management are outside the package. External invoice checks and compilation/accessibility
checks remain separate results.

## Reference and examples

The [common questions](getting-started/faq/) cover local data, MCP, operating systems and
compiler choices.

The [package reference](reference/package/) describes exports, schemas and locale behavior.
[Document types](reference/document-types/) lists all templates.
[Branding](guides/branding/) covers logos, fonts and partial locale overrides;
[Migration](guides/migration/) covers existing projects;
[Versions](reference/releases/) distinguishes this package from discontinued docgen releases.

Every [showcase](../showcase/) entry links to its source configuration or document and full PDF.
