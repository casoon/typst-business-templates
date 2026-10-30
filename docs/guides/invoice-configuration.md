---
title: Invoice configuration
description: Configure tax rates, required fields, notes and presentation using one reusable invoice builder.
order: 8
---

Copy `invoice-config.json` from the repository root into your project and adjust it for your
business. The same invoice builder uses the file for any seller or buyer country. No national
catalog entry or country-specific Typst template is needed. Company and customer addresses
remain in the invoice input; language and tax treatment are explicit choices.

This workflow requires typstgen 0.6.0 or later; 0.5.0 does not contain `prepare-invoice`.

## A configuration you own

```json
{
  "version": 1,
  "presentation": {
    "language": "de",
    "format_locale": "de-DE",
    "currency": "EUR",
    "layout": "international"
  },
  "default_tax": "standard",
  "taxes": {
    "standard": { "category": "S", "rate": "19" },
    "reduced": { "category": "S", "rate": "7" }
  },
  "required_fields": [
    "company.address.country_code",
    "data.recipient.address.country_code",
    "data.metadata.delivery_date"
  ],
  "notes": [],
  "display_fields": []
}
```

The supplied rates are editable starting values. Set the applicable rates and requirements
for your transactions. Changing the company address does not select or change a rate.
`schema/invoice-config.schema.json` provides editor validation; typstgen also validates the
configuration when it is read and rejects unknown configuration fields.
For editor support in a separate project, also copy `schema/invoice-config.schema.json`
and keep its relative path, or adjust the configuration's `$schema` reference.

Each line may choose a `tax` key from `taxes`; omitted keys use `default_tax`:

```json
{
  "description": "Consulting",
  "quantity": "2",
  "unit": "stunde",
  "unit_code": "HUR",
  "unit_price": { "amount": "100.00" },
  "tax": "standard"
}
```

The request file contains `company`, `data` and optional `facts`. `data` contains the usual
invoice metadata, recipient, items and payment information. No `selection` is needed.
Line totals and invoice totals may be omitted: the builder calculates them. When supplied,
they must agree with the calculation. Explicit money currencies must match the configuration;
when omitted they use its currency. A conflicting legacy `vat_rate` is rejected.

## Tax categories

Tax keys such as `standard`, `reduced` or `consulting` are yours to name. Each maps to an
explicit category and percentage:

| Category | Meaning | Rate | Additional input |
| --- | --- | --- | --- |
| `S` | Taxable, including standard and reduced rates | Above 0, at most 100 | None |
| `Z` | Zero-rated | 0 | None |
| `E` | Exempt | 0 | `exemption_reason` or `exemption_reason_code` |
| `AE` | Reverse charge | 0 | Buyer's `vat_id`; optional reason/code |

For example, add another key when that treatment applies:

```json
"reverse-charge": {
  "category": "AE",
  "rate": "0",
  "exemption_reason": "Reverse charge"
}
```

Exemption reasons appear on the affected PDF lines and in the CII tax information. `notes`
adds invoice-wide text to both PDF and XML after any invoice-specific `data.notes`.
Configured invoices use these explicit tax notes rather than the legacy company-wide
`default_terms.vat_note` switch. Distinct categories and exemption reasons retain separate
tax groups even when their percentages are equal.

VAT amounts use exact decimal arithmetic with up to four input decimal places. Each line amount
and each tax-group amount rounds half away from zero to two decimal places. This version
uses that fixed accounting convention for every configured currency; it does not perform
currency conversion, cash rounding, gross-price calculation or document allowances.

## Required and displayed information

`required_fields` lists input paths, for example `company.vat_id`,
`data.recipient.registration_number` or `facts.exemption_confirmed`. `*` traverses arrays,
as in `data.items.*.unit_code`. Missing values block preparation with their concrete paths.
Only require fields relevant to your invoices; calculated totals need not be input fields.

To print a custom registration or transaction field, add its path and a label:

```json
"display_fields": [
  {
    "path": "company.registration_number",
    "labels": { "de": "Registernummer", "en": "Registration number" }
  }
]
```

Every display field needs a label for the configured language. It is printed when present;
also list it in `required_fields` if absence should block the invoice. These display fields
are PDF additions; they do not automatically create new structured XML elements.

## Build an invoice

From `examples/invoice-config/`, with typstgen 0.6.0:

```sh
typstgen prepare-invoice --config ../../invoice-config.json invoice.json > resolved.json
typstgen compile invoice.typ -o invoice.pdf
```

The example uses the repository's shared configuration. In your own project, copy the
configuration beside the invoice and use `--config invoice-config.json` instead.
The wrapper renders `resolved.data`, `resolved.company` and `resolved.selection` using
the existing invoice template. The result also contains the exact configuration, normalized
invoice and diagnostics. A blocked result exits unsuccessfully; do not render it.

For a VAT invoice as hybrid Factur-X, write `resolved.data` and `resolved.company` to JSON files and
pass those same files to `compile --zugferd data.json --company company.json --pdf-standard a-3b`.
This keeps the PDF and CII values aligned. External validators remain separate checks.

The Rust API is `typstgen::invoice_config::prepare_invoice(config, request)`. The existing MCP
server exposes `prepare_invoice` with a workspace-relative `config` file path and a `request`
object; the same workspace access rules apply to this configuration file.

## Presentation and scope

Languages are `de`, `en`, `es`, `fr`, `it`, `nl`, `pt`; layouts are `din` and `international`.
The style is independent of seller and buyer countries:

| Format locale | Decimal separator | Date |
| --- | --- | --- |
| `de-DE` | comma | `26.10.26` |
| `en-GB` | dot | `26/10/2026` |
| `en-US` | dot with comma thousands | `10/26/2026` |
| `fr-FR`, `es-ES`, `it-IT`, `pt-PT` | comma | `26/10/2026` |
| `nl-NL` | comma | `26-10-2026` |

`presentation.paper` is `a4` (default) or `us-letter`. `currency_display` is `auto` (default),
`code` or `symbol`; auto uses dollar prefixes for USD with `en-US`, while code retains the
three-letter currency suffix. Explicit symbol currently supports USD. `tax_label` optionally
overrides the invoice tax-column label. Currency follows the two-decimal convention above.

The [invoice showcase](../../../showcase/) contains eight PDFs with
editable inputs and configuration files. It uses one shared invoice wrapper.

This is a configuration format for invoice construction. It does not infer which tax treatment
or national requirements apply: the result records `checks.jurisdiction = "not_assessed"`.
The existing [versioned catalogs](../invoice-profiles/) provide an optional reviewed-rule path.
Configuration does not add output adapters or invoice transmission; XRechnung/Peppol files come from
`typstgen e-invoice` ([E-invoice files](../invoice-profiles/#e-invoice-files-xrechnung-and-peppol)).


## US sales-tax components

Set `tax_model` to `sales-tax` when the invoice uses additive sales-tax components.
Omitting it preserves the existing `vat` behavior. A US presentation can use:

```json
{
  "version": 1,
  "tax_model": "sales-tax",
  "presentation": {
    "language": "en",
    "format_locale": "en-US",
    "currency": "USD",
    "layout": "international",
    "paper": "us-letter"
  },
  "default_tax": "general",
  "taxes": {
    "general": {
      "components": [
        { "id": "state", "label": "State tax", "rate": "5" },
        { "id": "local", "label": "Local tax", "rate": "2" }
      ]
    },
    "untaxed": { "components": [] }
  }
}
```

These rates are illustrative configuration values. Choose the applicable component set per
line using `tax`, or use `default_tax`. Each component applies to the same net basis; there
is no compounding. Its basis sums the rounded net amounts of lines that selected it. Its
amount rounds once, half away from zero to cents. A component ID shared by multiple sets
must have the same label and rate. Untaxed lines use an empty component set.

The result contains separate `tax_components` on each line, a combined line `tax_rate`, and
`totals.tax_total` plus `totals.tax_breakdown` with component ID, label, rate, basis and amount.
Supplied totals must match. Sales-tax input does not use `vat_rate`, `vat_total` or
`vat_breakdown`. The PDF uses Sales Tax labels and displays each component separately.
`company.tax_id` may hold a supplied registration number; the sales-tax builder does not
require a VAT ID or invent a tax-registration requirement.

For US address display use `address.region` for the state; `en-US` prints city, state and
postal code. Bank data may use `routing_number` and `account_number` instead of IBAN/BIC.
The common calculation model still does not infer rates from addresses, determine nexus or
product taxability, convert currencies, calculate gross prices or apply document allowances.

Sales-tax output records `checks.en16931 = "not_applicable"`. Its `data.tax_model` marker
prevents the existing CII adapter from exporting these components as VAT. The existing
VAT/Factur-X workflow continues to use `tax_model: "vat"` or the omitted default.
