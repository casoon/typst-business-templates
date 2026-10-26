---
title: Branding and languages
description: Company data, colours, logo, font presets and the seven languages, all set in company.json.
order: 4
---

Every template takes the company as `company:`, usually `json("/data/company.json")`. The schema
is [`company.schema.json`](https://casoon.github.io/typst-business-templates/schema/company.schema.json);
`name`, `language`, `address` and `contact` are required.

Language support depends on the template. Invoices have translated labels in all seven
supported languages. Other accounting templates still contain German labels and DIN-specific
formats; choosing `company.language` alone does not translate those labels. Running-text
templates use their documented locale options. Supply your own body text in the desired language.

```json
{
  "$schema": "https://casoon.github.io/typst-business-templates/schema/company.schema.json",
  "name": "TechVision Consulting",
  "language": "de",
  "business_owner": "Dr. Michael Hoffmann",
  "address": { "street": "Friedrichstraße", "house_number": "123", "postal_code": "10117", "city": "Berlin", "country": "Deutschland" },
  "contact": { "phone": "+49 30 12345678", "email": "info@techvision-consulting.de", "website": "www.techvision-consulting.de" },
  "tax_id": "27/456/12345",
  "vat_id": "DE345678901",
  "bank_account": { "bank_name": "Deutsche Bank", "account_holder": "TechVision Consulting GmbH", "iban": "DE89 1007 0024 0123 4567 89", "bic": "DEUTDEDB101" },
  "branding": { "accent_color": "#00B894", "primary_color": "#2D3436", "font_preset": "source-sans" },
  "default_terms": { "vat_exempt": false }
}
```

## Letterhead and footer

The accounting documents put the company into the letterhead, the return address line above the
recipient (DIN 5008) and a four-column footer:

| Column | Fields |
| --- | --- |
| 1 | `name`, `business_owner`, `address` |
| 2 | `contact.phone`, `contact.email`, `contact.website` |
| 3 | `business_owner`, `vat_id` |
| 4 | `bank_account`: `bank_name`, `account_holder`, `iban`, `bic` |

`metadata.show_footer: false` in a document's JSON hides it. The running-text documents have their own
footer with company name and address, contact, document number and page, and version or creation
date; `show-footer: false` turns it off.

For e-invoices typstgen reads `name`, `address`, `contact.email`, `vat_id`, `tax_id` and
`bank_account` from the same file.

`default_terms.vat_exempt` and `vat_note` print a VAT exemption note on invoices and credit notes,
see [Kleinunternehmer](../json-documents/#kleinunternehmer--19-ustg).

## Colours and fonts

`branding` applies to the running-text documents (concept, contract, documentation, proposal,
protocol, SLA, specification, task list, handout) and to the credentials sheet. The other
accounting documents keep a fixed layout in Helvetica.

| Key | Default | Used for |
| --- | --- | --- |
| `accent_color` | `#E94B3C` | accent colour (header, rules, highlights) |
| `primary_color` | `#2c3e50` | primary colour (titles, headings) |
| `font_preset` | `default` | body, heading and monospace font |

### Font presets

| Preset | Body and headings | Monospace |
| --- | --- | --- |
| `inter` | Inter | JetBrains Mono |
| `roboto` | Roboto | Roboto Mono |
| `open-sans` | Open Sans | Source Code Pro |
| `lato` | Lato | Fira Code |
| `montserrat` | Montserrat | Fira Code |
| `source-sans` | Source Sans 3 | Source Code Pro |
| `poppins` | Poppins | JetBrains Mono |
| `raleway` | Raleway | Fira Code |
| `nunito` | Nunito | JetBrains Mono |
| `work-sans` | Work Sans | Fira Code |
| `default` | Helvetica | Courier New |

Unknown names fall back to `default`. The font files are in the repository's
[`fonts/`](https://github.com/casoon/typst-business-templates/tree/main/fonts) folder; add the
folder you copy them to to `font_paths` in `typstgen.toml`. A missing font produces a warning and
a fallback font, not an error.

## Logo

Inside a template the logo is loaded with Typst's `image()`. When the templates are imported as a
package, a path would be resolved inside the package, so pass the image bytes instead:

```typst
#let company = json("/data/company.json")
#company.insert("logo", read("/data/logo.png", encoding: none))

#invoice(data: json("RE-2026-001.json"), company: company)
```

A path in `company.json` (`"logo": "data/logo.png"`, from the project root) only works when the
templates are copied into the project. The running-text templates also take `logo:` as content,
for example `logo: image("/data/logo.png", width: 4cm)`, which takes precedence over
`company.logo`.

The logo is 150pt wide; `logo_width` (a Typst length such as `"3cm"`) changes that for the concept
and the task list. Without a logo, the accounting documents show a grey placeholder box where the
logo goes.

## Languages

`language` sets the text language (hyphenation, quotes) of every document and selects the labels
from `templates/locale/<language>.json`:

| Code | Language |
| --- | --- |
| `de` | German |
| `en` | English |
| `es` | Spanish |
| `fr` | French |
| `it` | Italian |
| `nl` | Dutch |
| `pt` | Portuguese |

Translated labels — title page, table of contents, page numbers, headers — appear in the
running-text documents, invoices and the credentials sheet. To change individual labels, pass your own
dictionary in the shape of
[`de.json`](https://github.com/casoon/typst-business-templates/blob/main/templates/locale/de.json):

```typst
#show: concept.with(
  title: "Konzept",
  company: json("/data/company.json"),
  locale: json("/data/locale-de.json"),
)
```

Invoices select language independently of tax treatment, layout, currency and formatting through
[invoice configuration](../invoice-configuration/). Position descriptions and supplied notes
remain caller-authored text. The [showcase](../../../showcase/) includes all seven invoice languages.

The other accounting documents (offer, credit note, reminder, delivery note, order
confirmation, quotation request, time sheet, letter) print German labels whatever the language,
and the handout has German labels too. The text you write yourself is never translated.
