---
title: Quickstart
description: Set up a project folder, enter your company data and compile a first invoice — as a plain PDF and as a ZUGFeRD e-invoice.
order: 2
---

This assumes typstgen and the package are [installed](../installation/).

## Configured invoice path

For editable taxes, automatic totals, seven invoice languages or US Letter/USD, start with
the coordinated compiler from the installation guide. The repository's language demos are
ready to open in the [showcase](../../../showcase/). From `examples/invoice-languages/`:

```sh
typstgen prepare-invoice --config en-US/invoice-config.json en-US/invoice.json > en-US/resolved.json
typstgen compile invoice.typ --input resolved=en-US/resolved.json -o en-US/invoice.pdf
```

Change the language folder to use another demo. The configuration chooses taxes and
presentation; the input supplies company, recipient and positions. The shared wrapper also
loads the fictional SVG logo. See [Invoice configuration](../../guides/invoice-configuration/)
for the input contract and VAT/sales-tax boundaries.

## Existing JSON with supplied totals

The following workflow remains compatible with published typstgen 0.5.0. Here the caller
supplies totals; the template checks them. Configured invoice preparation can calculate these
values before rendering instead.

## 1. Project layout

```
my-business/
├── typstgen.toml
├── data/
│   └── company.json
└── invoices/
    ├── RE-2026-001.json
    └── RE-2026-001.typ
```

## 2. typstgen.toml

```toml
# This folder is the root for absolute paths such as /data/company.json.
template_paths = ["."]
# Only needed if the package is not in the Typst package directory.
# package_path = "/path/to/packages"
font_paths = ["fonts"]
```

Paths in `typstgen.toml` are relative to the working directory, so run typstgen from the project
folder.

## 3. Company data

`data/company.json` holds everything that is the same on every document: name, address, contact,
tax data, bank account, language and branding. [Branding and languages](../../guides/branding/)
lists all fields.

```json
{
  "$schema": "https://casoon.github.io/typst-business-templates/schema/company.schema.json",
  "name": "Muster IT GmbH",
  "language": "de",
  "business_owner": "Anna Muster",
  "address": { "street": "Hauptstraße", "house_number": "1", "postal_code": "10115", "city": "Berlin", "country": "Deutschland" },
  "contact": { "phone": "+49 30 1234567", "email": "info@muster-it.de", "website": "www.muster-it.de" },
  "tax_id": "27/123/45678",
  "vat_id": "DE123456789",
  "bank_account": { "bank_name": "Musterbank", "account_holder": "Muster IT GmbH", "iban": "DE89 3704 0044 0532 0130 00", "bic": "COBADEFFXXX" },
  "branding": { "accent_color": "#E94B3C", "primary_color": "#2c3e50", "font_preset": "inter" }
}
```

The `$schema` line gives you completion and validation in editors that support JSON Schema
(VS Code, JetBrains IDEs). The templates ignore it.

## 4. The invoice data

`invoices/RE-2026-001.json`:

```json
{
  "$schema": "https://casoon.github.io/typst-business-templates/schema/invoice.schema.json",
  "metadata": {
    "invoice_number": "RE-2026-001",
    "invoice_date": "2026-03-02",
    "due_date": "2026-03-16",
    "performance_period": "02/2026"
  },
  "recipient": {
    "company": "Beispiel AG",
    "name": "Max Beispiel",
    "address": { "street": "Marktplatz", "house_number": "5", "postal_code": "50667", "city": "Köln", "country": "Deutschland" }
  },
  "items": [
    {
      "position": 1, "description": "Beratung", "quantity": "3", "unit": "Tage",
      "unit_price": { "amount": "800" }, "total": { "amount": "2400" },
      "vat_rate": { "code": "Standard", "percentage": "19" }
    },
    {
      "position": 2, "description": "Einrichtung Server", "quantity": "1", "unit": "Pauschal",
      "unit_price": { "amount": "500" }, "total": { "amount": "500" },
      "vat_rate": { "code": "Standard", "percentage": "19" }
    }
  ],
  "totals": {
    "subtotal": { "amount": "2900" },
    "vat_breakdown": [
      { "rate": { "code": "Standard", "percentage": "19" }, "base": { "amount": "2900" }, "amount": { "amount": "551" } }
    ],
    "vat_total": { "amount": "551" },
    "total": { "amount": "3451" }
  },
  "payment": {
    "payment_terms": "Zahlbar innerhalb von 14 Tagen ohne Abzug",
    "due_date": "2026-03-16"
  }
}
```

The template prints these numbers; it does not compute them. It does check them: if a line total,
the subtotal, the VAT or the total does not add up, the build stops with the offending field.

## 5. The Typst file

`invoices/RE-2026-001.typ` passes both files to the template:

```typst
#import "@local/business-templates:0.2.0": invoice

#invoice(
  data: json("RE-2026-001.json"),
  company: json("/data/company.json"),
)
```

`json("RE-2026-001.json")` is relative to the `.typ` file; `/data/company.json` is relative to the
project folder.

## 6. Compile

```sh
typstgen compile invoices/RE-2026-001.typ
# → invoices/RE-2026-001.pdf
```

The PDF lands next to its source; `-o` writes it elsewhere. Its metadata carries the invoice
number as title, the company name as author and the invoice date as date.

## 7. As an e-invoice

The same files produce a ZUGFeRD / Factur-X invoice, a PDF/A-3 with the invoice data embedded as
`factur-x.xml` (EN 16931):

```sh
typstgen compile invoices/RE-2026-001.typ \
  --zugferd invoices/RE-2026-001.json --company data/company.json \
  --pdf-standard a-3b
```

The template sets the invoice date as document date, which PDF/A-3 needs, so no
`--creation-timestamp` is required. Field mapping, VAT codes and validation are covered in the
[typstgen e-invoice guide](https://casoon.github.io/typstgen/docs/guides/e-invoices/).

## Try the examples

The repository has three complete example projects — an IT consultancy with every document type,
a web agency and a freelance designer without VAT (Kleinunternehmer, § 19 UStG):

```sh
git clone https://github.com/casoon/typst-business-templates.git
cd typst-business-templates/examples/it-consultant
typstgen compile documents/invoices/2025/invoice.typ
```

Their `typstgen.toml` points `package_path` at the repository, so they work without installing the
package. Next: [accounting documents](../../guides/json-documents/) and
[documents written in Typst](../../guides/typst-documents/).
