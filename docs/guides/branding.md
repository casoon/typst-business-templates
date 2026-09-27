---
title: Branding and languages
description: Company data, colours, logo, font presets, number prefixes and the seven document languages, all set in data/company.json.
order: 4
---

Every template reads `data/company.json`. `docgen init` writes a filled-in starting version:

```json
{
  "name": "Your Company",
  "language": "en",
  "address": { "street": "Street", "house_number": "1", "postal_code": "12345", "city": "City", "country": "Country" },
  "contact": { "phone": "+1 234 567890", "email": "info@example.com", "website": "www.example.com" },
  "tax_id": "123/456/78901",
  "vat_id": "XX123456789",
  "business_owner": "Your Name",
  "bank_account": { "bank_name": "Bank", "account_holder": "Your Company", "iban": "XX00 0000 0000 0000 0000 00", "bic": "BANKXXXX" },
  "branding": { "accent_color": "#E94B3C", "primary_color": "#2c3e50", "font_preset": "inter" },
  "numbering": {
    "year_format": "short",
    "prefixes": { "invoice": "RE", "offer": "AN", "credentials": "ZD", "concept": "KO", "documentation": "DOC" }
  },
  "structure": { "organize_by_year": true },
  "default_terms": {
    "hourly_rate": "95.00", "currency": "EUR", "payment_days": 14, "warranty_months": 12, "vat_rate": 19,
    "standard_terms": ["All prices are net plus statutory VAT.", "Payment due within 14 days without deduction."]
  }
}
```

The company block feeds the letterhead, the return address line above the recipient and the
four-column footer with address, contact, tax data and bank account.

## Logo

Add `"logo"` with a path relative to the project root, for example `"logo": "data/logo.png"`.
Without it, the accounting templates show a placeholder box where the logo goes — visible in the
[showcase](../../../showcase/invoice/) invoices, whose example company has no logo.

## Font presets

`branding.font_preset` picks body, heading and monospace fonts:

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

The font files are in the repository's
[`fonts/`](https://github.com/casoon/typst-business-templates/tree/main/fonts) folder. `docgen`
looks for them in `fonts/` of your project; the Rust library has them built in.

## Languages

`language` selects the labels (invoice, due date, VAT, page …) and the CLI messages:

| Code | Language |
| --- | --- |
| `de` | German |
| `en` | English |
| `es` | Spanish |
| `fr` | French |
| `it` | Italian |
| `nl` | Dutch |
| `pt` | Portuguese |

The text you write in your documents is not translated.

## Document numbers

`numbering.prefixes` sets the prefixes, for example `RE-2026-001` for invoices and `AN-2026-001`
for offers. The counters live in `data/counters.json`, next to `data/clients.json` and
`data/projects.json` for the client and project commands in the [CLI reference](../../reference/cli/).
