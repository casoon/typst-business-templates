---
title: Quickstart
description: Create a project, set your company data and compile a first invoice.
order: 2
---

## 1. Create a project

```sh
docgen init my-business
cd my-business
```

`init` creates:

```
my-business/
├── data/company.json       # company, bank, branding, numbering, default terms
├── documents/<type>/<year>/ # one folder per document type
├── output/<year>/
├── templates/              # your forked templates
└── .docgen/templates/      # standard templates, kept in sync with docgen
```

## 2. Enter your company data

Edit `data/company.json`: name, address, contact, tax and VAT ID, bank account, `language`,
and the `branding` block. [Branding and languages](../../guides/branding/) lists the options.

## 3. Write a document

Start from the invoice of the IT consultancy example and adjust it:

```sh
curl -fsSL -o documents/invoices/2026/invoice.json \
  https://raw.githubusercontent.com/casoon/typst-business-templates/main/examples/it-consultant/documents/invoices/2025/invoice.json
```

The file holds `metadata` (number, dates, project), `recipient`, `items` with optional
`sub_items`, `totals` with the VAT breakdown, and `payment`. It is the
[invoice in the showcase](../../../showcase/invoice/). [JSON documents](../../guides/json-documents/)
explains the structure and where to find examples for the other types.

## 4. Compile

```sh
docgen compile documents/invoices/2026/invoice.json
# → documents/invoices/2026/invoice.pdf

docgen compile documents/invoices/2026/invoice.json -o output/2026/invoice.pdf
```

`docgen` detects the document type from the path (`invoices/` → `invoice` template). To compile
every document at once, run `docgen build`; `docgen watch` rebuilds on every change.

## Try the examples

The repository contains three complete example projects — a web agency, a freelance designer
without VAT (Kleinunternehmer, § 19 UStG) and an IT consultancy:

```sh
git clone https://github.com/casoon/typst-business-templates.git
cd typst-business-templates/examples/digitalagentur
docgen build
```

The [showcase](../../../showcase/) shows documents from these projects as `docgen` renders them.
