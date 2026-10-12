# Freelance designer – example project

**Lisa Chen Design**, brand identity and packaging design in Hamburg. Kleinunternehmer under
§ 19 UStG, so no VAT is charged. Branding: purple accent (#6C63FF), font Poppins.

How to compile: see [examples/README.md](../README.md).

| Document | Source | Content |
|----------|--------|---------|
| Invoice | `documents/invoices/2025/invoice.json` | Corporate design for BrewBuddy GmbH, 4,700.00 EUR without VAT |
| Offer | `documents/offers/2025/offer.json` | Tea packaging for Bergmann Teemanufaktur, 4,490.00 EUR without VAT |
| Credentials | `documents/credentials/2025/credentials.json` | Website, FTP and design file access |
| Concept | `documents/concepts/2025/concept.typ` | Brand concept for the premium tea line |
| Documentation | `documents/documentation/2025/documentation.typ` | Brand guidelines for BrewBuddy |

## Kleinunternehmer

- Every invoice item has
  `"vat_rate": { "code": "SmallBusiness", "exemption_reason": "Kleinunternehmer gemäß § 19 UStG", "percentage": "0" }`.
  `SmallBusiness` (or `Exempt`) is the VAT category E of EN 16931, so the invoice also works as a
  ZUGFeRD e-invoice.
- `totals.vat_breakdown` is empty, `totals.vat_total` is 0.
- Invoice and credit note print the note from `company.json`:

```json
"default_terms": {
  "vat_rate": 0,
  "vat_exempt": true,
  "vat_note": "Gemäß §19 UStG wird keine Umsatzsteuer berechnet."
}
```
