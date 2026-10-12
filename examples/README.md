# Examples

Example projects that use the Typst package `business-templates` with
[typstgen](https://github.com/casoon/typstgen).

| Directory | Business | Documents |
|-----------|----------|-----------|
| [digitalagentur/](digitalagentur/) | Web agency (Cologne) | Invoice, offer, credentials, concept, documentation |
| [freelance-designer/](freelance-designer/) | Graphic designer, Kleinunternehmer without VAT (Hamburg) | Invoice, offer, credentials, concept, documentation |
| [it-consultant/](it-consultant/) | IT consulting (Berlin) | All document types |
| `diagram-*/` | Diagram layouts | One diagram each |

## Compile

Each project has its own `typstgen.toml`, so run typstgen inside the project folder. The PDF is
written next to its source.

```bash
cd examples/it-consultant
typstgen compile documents/invoices/2025/invoice.typ
```

All documents of a project:

```bash
find documents -name '*.typ' -exec typstgen compile {} \;
```

## E-invoice (ZUGFeRD / Factur-X)

typstgen embeds the invoice data as `factur-x.xml` (EN 16931), built from the same JSON the
template renders. PDF/A-3 needs a document date, hence `--creation-timestamp`:

```bash
cd examples/it-consultant
typstgen compile documents/invoices/2025/invoice.typ \
  --zugferd documents/invoices/2025/invoice.json --company data/company.json \
  --pdf-standard a-3b --creation-timestamp "$(date +%s)"
```

See the [typstgen e-invoice guide](https://casoon.github.io/typstgen/docs/guides/e-invoices/) for the field mapping and
VAT codes.

## Project layout

```
it-consultant/
├── typstgen.toml        # project folder = root for /data/…, package path, fonts
├── data/
│   └── company.json     # company data, branding and language for every document
└── documents/
    ├── invoices/2025/
    │   ├── invoice.json # the invoice data
    │   └── invoice.typ  # loads the JSON and calls the template
    └── concepts/2025/
        └── concept.typ  # written in Typst directly
```

Accounting documents (invoice, offer, credit note, reminder, delivery note, order confirmation,
quotation request, time sheet, letter, credentials) keep their data in JSON, and a short `.typ`
file passes it to the template:

```typst
#import "@local/business-templates:0.1.0": invoice

#invoice(
  data: json("invoice.json"),
  company: json("/data/company.json"),
)
```

Running text (concept, documentation, contract, proposal, protocol, SLA, specification) is written
in Typst with the template as a show rule:

```typst
#import "@local/business-templates:0.1.0": concept

#show: concept.with(
  title: "IT-Security Konzept",
  document_number: "KO-2025-003",
  company: json("/data/company.json"),
)

= Ausgangssituation
…
```

Labels come in the language set in `company.json` (`"language": "de"`). A logo is passed as image
bytes, because a path inside the package would point into the package:

```typst
#let company = json("/data/company.json")
#company.insert("logo", read("/data/logo.png", encoding: none))
```

## Use an example for your own business

Copy a project folder, set `package_path` and `font_paths` in its `typstgen.toml` to your
locations, and edit `data/company.json`.
