---
title: JSON documents
description: How a JSON document becomes a PDF, how docgen picks the template, and where to find examples for each document type.
order: 1
---

Structured documents — invoices, offers, credit notes, reminders, letters, credentials and the
other types in [Document types](../../reference/document-types/) — are JSON files. `docgen`
hands the file to the matching template together with `data/company.json` and the locale.

## What happens on `docgen compile`

1. The standard templates in `.docgen/templates/` are brought up to the version of `docgen`
   (a version marker and a lock file keep parallel runs safe).
2. The template is chosen: `--template <name>` if given, otherwise from the path.
3. `docgen` runs `typst compile --root . --font-path fonts .docgen/templates/<type>/default.typ`
   with the inputs `data`, `company` and `locale`. Diagrams skip this step and render in-process,
   see [Diagrams](../diagrams/).
4. The PDF lands next to the JSON file, or at the path given with `-o`.

Run `docgen` from the project root: the paths to `data/company.json`, `fonts/` and
`.docgen/templates/` are relative to it.

## How the template is chosen

The path is matched case-insensitively against names in English and German, and against the
number prefix of the file name:

| Path contains | Template |
| --- | --- |
| `invoice`, `rechnung`, `/re-` | `invoice` |
| `offer`, `angebot`, `/an-` | `offer` |
| `letter`, `brief`, `/br-` | `letter` |
| `credit-note`, `gutschrift`, `/gs-` | `credit-note` |
| `reminder`, `mahnung` | `reminder` |
| `delivery-note`, `lieferschein`, `/ls-` | `delivery-note` |
| `order-confirmation`, `auftragsbestätigung`, `/ab-` | `order-confirmation` |
| `time-sheet`, `timesheet`, `stundenzettel`, `/ts-` | `time-sheet` |
| `quotation-request`, `angebotsanfrage`, `/anf-` | `quotation-request` |
| `credential`, `zugang`, `/zd-` | `credentials` |
| `concept`, `konzept`, `/ko-` | `concept` |
| `documentation`, `dokumentation`, `/dok-` | `documentation` |
| `diagram`, `mindmap`, `flowchart`, `organigram` | `diagram` |
| `contract`, `vertrag`, `/vtr-` | `contract` |
| `protocol`, `protokoll`, `/prot-` | `protocol` |
| `specification`, `spezifikation`, `/spec-` | `specification` |
| `proposal`, `vorschlag`, `/pro-` | `proposal` |
| `sla` | `sla` |

The first match wins, in the order of the table. If nothing matches, `invoice` is used — pass
`--template` for anything the path does not name, for example `task-list` or `handout`.
The folders that `docgen init` creates (`documents/invoices/`, `documents/credit-notes/` …) all
match their type.

## Examples per type

The IT consultancy example project has one JSON file per type, in
[`examples/it-consultant/documents/`](https://github.com/casoon/typst-business-templates/tree/main/examples/it-consultant/documents).
Copy the one you need and change the values. Several of them are in the
[showcase](../../../showcase/), each next to the PDF it produces.

The numbers in a document are data: `items`, `totals` and the VAT breakdown are printed as given,
so whatever creates the JSON computes them.

For invoices and credentials, JSON Schemas are in
[`schema/`](https://github.com/casoon/typst-business-templates/tree/main/schema).
`docgen ai-guide` prints a guide with the data formats and workflows, written to be handed to an
AI assistant that drafts documents for you.

## Building many documents

```sh
docgen build                    # every .json and .typ below documents/
docgen build documents/invoices # one folder
docgen build -o pdfs            # other output folder
docgen watch documents/         # rebuild on change, Ctrl+C to stop
```

`build` writes each PDF as `output/<file name>.pdf` and reports how many documents failed.

## Password-protected PDFs

```sh
docgen compile documents/credentials/2026/access.json --encrypt
```

`--encrypt` asks for a password (the input is visible while typing) and encrypts the PDF with
AES-256 through [`qpdf`](https://github.com/qpdf/qpdf), which has to be installed. The defaults
allow printing and forbid copying and modification.
