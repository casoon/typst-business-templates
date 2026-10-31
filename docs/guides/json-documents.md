---
title: Accounting documents
description: Invoices, offers, credit notes and the other accounting documents — data in JSON, a short Typst wrapper, schemas, the totals check, Kleinunternehmer and e-invoices.
order: 1
---

> **Templates, not tax advice.** The invoice and tax-case profiles are templates. No tax adviser or
> accountant has reviewed them, and they may need adjusting to your situation and country. Have them
> checked before you issue real invoices. Examples use fictional companies, accounts and rates.

Ten templates take their content as data: `invoice`, `offer`, `credit-note`, `reminder`,
`delivery-note`, `order-confirmation`, `quotation-request`, `time-sheet`, `letter` and
`credentials`. The data lives in a JSON file; a four-line `.typ` file loads it and calls the
template.

## The wrapper

```typst
#import "@local/business-templates:0.2.0": offer

#offer(
  data: json("AN-2026-007.json"),
  company: json("/data/company.json"),
)
```

Every accounting template has the same two parameters:

| Parameter | Content |
| --- | --- |
| `data` | the document, a dictionary in the shape of the type's [schema](#schemas) |
| `company` | `company.json`, see [Branding and languages](../branding/) |

`invoice` and `credentials` also take partial `locale:` overrides, see [Languages](../branding/#languages).
Invoices additionally accept a rendering `profile:`. For named VAT rates or sales-tax components,
calculated totals, language, currency, paper and layout, use
[invoice configuration](../invoice-configuration/) with typstgen 0.6.2.
The direct wrapper below continues to accept supplied totals, also with typstgen 0.5.0.

Since `data` and `company` are ordinary Typst dictionaries, the wrapper can change them before
passing them on — for example to add the logo as bytes:

```typst
#let company = json("/data/company.json")
#company.insert("logo", read("/data/logo.png", encoding: none))
#invoice(data: json("RE-2026-001.json"), company: company)
```

Compile with `typstgen compile <file>.typ` from the project folder; the PDF lands next to the
source.

## Structure of the data

The JSON describes document content; the reusable Typst template determines its layout.
The same template can render successive data files without copying the layout for each document.

## Deterministic builds

Reproducibility depends on the complete input set: JSON data, template sources, images, font
files, compiler/package versions and build time. Keep those fixed for byte-identical rebuilds.
Use an explicit timestamp when templates read the current date, and pin the compiler and
package revisions rather than relying on whichever versions are installed later.

```sh
typstgen compile document.typ --creation-timestamp 1792972800 --manifest archive.json
typstgen verify archive.json
```

The manifest records the PDF hash, file/font hashes, versions and compile options. Verification
rebuilds the document and checks those inputs and the resulting PDF. See the
[typstgen archiving guide](https://casoon.github.io/typstgen/docs/guides/archiving/) for the
full contract. The template's own document date remains part of its source data.

## Document fields

Most types share this outline (the schema of each type has the details and descriptions of every
field):

| Key | Content |
| --- | --- |
| `metadata` | number, dates, references; `show_footer: false` hides the company footer |
| `recipient` | name, company and `address` for the DIN 5008 address window (`supplier` for quotation requests, `client` for time sheets) |
| `salutation` | `greeting` and `introduction` above the table |
| `items` | positions with `description`, optional `sub_items`, `quantity`, `unit`, `unit_price`, `vat_rate`, `total` |
| `totals` | `subtotal`, `vat_breakdown`, `vat_total`, `total` |
| `payment` | invoice only: `due_date`, `payment_terms`, `bank_account` |

`reminder` lists `outstanding_invoices` instead of items, `time-sheet` has `entries`, and
`credentials` has `metadata` (title-page data) and `services` with access data.

`letter` takes its text as `content` (plain text) or, for headings, lists and tables, as Typst
content after the call; `recipient` may be free `lines` instead of name and address, and `final`
is a last paragraph kept on one page with the closing:

```typst
#letter(
  data: (
    metadata: (date: "2026-10-08", subject: "Bieterfragen", reference_number: "BRF-2026-001"),
    recipient: (lines: ("Muster GmbH", "Herr Max Muster", "Hauptstraße 1", "12345 Musterstadt")),
    salutation: "Sehr geehrte Damen und Herren,",
  ),
  company: json("/data/company.json"),
)[
  = A. Eignung
  …
]
```

A recipient's `company` is left out when it repeats `name`; the offer prints the company above
the name, the other documents below it. Units `tag`, `monat` and `jahr` take the plural
(`Tage`, `Monate`, `Jahre`) for a quantity other than 1.

Value formats, defined in
[`common.schema.json`](https://github.com/casoon/typst-business-templates/blob/main/schema/common.schema.json):

- **Dates** as `"2026-03-02"` or `{ "date": "2026-03-02" }`.
- **Numbers** as JSON numbers or strings with a dot (`"1400"`, `"71.5"`).
- **Amounts** in items and totals as objects: `{ "amount": "1400", "currency": "EUR" }`
  (currency defaults to EUR). The templates read `.amount`, so a plain number is rejected there.
- **VAT rates** as `{ "code": "Standard", "percentage": "19" }`.

The IT consultancy example has one file per type in
[`examples/it-consultant/documents/`](https://github.com/casoon/typst-business-templates/tree/main/examples/it-consultant/documents) —
the quickest start is to copy one and change the values.

## Schemas

Every accounting type and `company.json` has a JSON schema (draft 2020-12) in
[`schema/`](https://github.com/casoon/typst-business-templates/tree/main/schema), published at
`https://casoon.github.io/typst-business-templates/schema/<name>.schema.json`. Reference it from
the file for completion and inline errors in your editor:

```json
{
  "$schema": "https://casoon.github.io/typst-business-templates/schema/offer.schema.json",
  "metadata": { … }
}
```

The examples in the repository use relative paths (`"../../../../../schema/invoice.schema.json"`)
instead. [Document types](../../reference/document-types/) links the schema of each type. To
validate in a script, use any JSON Schema validator; the repository's `scripts/check.sh` does it
with Python's `jsonschema` for every example that names a schema.

## Totals check

Invoice, offer, credit note and order confirmation check the numbers before they render anything.
The build stops if

- an item's `total` differs from `quantity` × `unit_price`,
- `totals.subtotal` differs from the sum of the item totals,
- `totals.vat_total` differs from the sum of `vat_breakdown`,
- `totals.total` differs from subtotal minus `totals.discount_total` (if given) plus VAT,

compared to the cent. All problems are listed at once:

```text
error: panicked with: totals do not add up:
totals.total: 3450 ≠ subtotal + VAT = 3451
```

Fields that are missing are not checked. The templates never compute a number themselves — the
JSON carries every amount, so whatever writes the JSON calculates them.

## Kleinunternehmer (§ 19 UStG)

A company that charges no VAT sets two fields in `company.json`:

```json
"default_terms": {
  "vat_exempt": true,
  "vat_note": "Gemäß § 19 UStG wird keine Umsatzsteuer berechnet."
}
```

Invoice and credit note then print `vat_note` below the totals. The items carry rate 0 with the
code `SmallBusiness` (or `Exempt`) and a reason, which the e-invoice needs:

```json
"vat_rate": { "code": "SmallBusiness", "percentage": "0", "exemption_reason": "Kleinunternehmer gemäß § 19 UStG" }
```

The [freelance designer example](https://github.com/casoon/typst-business-templates/tree/main/examples/freelance-designer)
is set up this way. With an empty `totals.vat_breakdown` the totals block shows only the total.

## PDF metadata

All accounting documents set the PDF title to the document number and the author to the company
name. All of them except `time-sheet`, which has no single date, also set the document date
(invoice date, offer date …) as the PDF date, so the output is reproducible and PDF/A-ready.

## E-invoice (ZUGFeRD / Factur-X)

typstgen builds an EN 16931 `factur-x.xml` from the invoice JSON and `company.json` and embeds it
into a PDF/A-3:

```sh
typstgen compile invoice.typ \
  --zugferd invoice.json --company data/company.json \
  --pdf-standard a-3b
```

No `--creation-timestamp` is needed: the template sets the invoice date as document date.
typstgen recomputes the invoice before writing the XML and fails on mismatches, unknown units or
countries and missing exemption reasons. These checks are not a complete EN 16931 validator;
check the result with an external one before sending. Field mapping, unit codes and VAT
categories are in the
[typstgen e-invoice guide](https://casoon.github.io/typstgen/docs/guides/e-invoices/).

Only invoices are supported — not credit notes. XRechnung and Peppol files are written separately
with `typstgen e-invoice` ([E-invoice files](../invoice-profiles/#e-invoice-files-xrechnung-and-peppol)).
