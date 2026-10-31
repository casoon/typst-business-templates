---
title: Capabilities and limits
description: Implementation scope, verification evidence and work remaining before wider integration and release.
order: 4
---

## Current assessment

The source tree provides a usable business-document package and a configurable invoice
builder. The common template, explicit tax configuration and thin language demos give it
a practical extension point: presentation changes do not require national template copies.
The remaining work is concentrated in distribution, real consumer integration and additional
reviewed invoice/export cases.

Package `business-templates` 0.2.0 is distributed as the `templates-v0.2.0` source release. Configured invoice preparation and profile
tools use typstgen 0.6.2 (`tool-versions.json`); these commands are
not present in typstgen 0.5.0. See [Installation](../../getting-started/installation/)
and [Versions](../releases/).

## Implementation map

| Area | Implemented in this source tree | Boundary |
| --- | --- | --- |
| Invoice construction | Named taxes, required fields, notes, custom fields and calculated decimal totals | Caller supplies applicable treatment; no legal/taxability inference |
| Presentation | Seven languages, DIN/international, A4/Letter, currency and locale choices, SVG logos | Other accounting templates retain their existing German/DIN interface |
| VAT categories | Taxable/reduced, zero, exempt and reverse charge with distinct groups | Category support alone does not establish a national or cross-border case |
| Sales tax | Explicit additive components with separate bases/rounded amounts, untaxed lines, US dates/USD/account fields | No location-based rates, nexus determination or compounding; PDF/component output |
| Structured invoices | Existing CII/Factur-X VAT path with PDF/XML value checks | XRechnung 3.0 and Peppol BIS 3.0 as UBL files via `typstgen e-invoice` (checked with Mustang and, on demand, the KoSIT validator with the XRechnung and Peppol 3.0.21 rules); transmission is unimplemented; sales-tax output is rejected by CII and UBL |
| Reviewed catalog | Bounded DE standard and § 19 preview cases; FR domestic B2B, DE→EU B2B service (reverse charge), intra-Community supply and export drafts | Drafts are opt-in previews; B2C/OSS, domestic reverse charge, chain transactions and further exemptions remain unsupported |
| Publications | Compact A4 frame, printable forms, cards, phases and landscape brochures | Printable elements are not interactive AcroForms |
| Existing templates | Password masking, partial locale overrides, task phases/roles and prose identity metadata | Masking covers password fields, not arbitrary free text |

All national catalog combinations expose their release state explicitly. An editable
configuration is user-owned input; it is not a reviewed national rule set. The language
demos use fictional companies, registrations, accounts and rates.

## Verification

`scripts/test.sh` uses pinned compiler/chartlet/Python dependencies and a checksummed Mustang
release. It retains PDFs, resolved data, XML and validator reports for manual inspection.

- Existing example projects, schemas, locale keys and package contracts are exercised.
- Configured VAT invoices compare canonical amounts, tax groups, parties, dates, currency
  and accounts across PDF and XML; the acceptance suite runs Mustang and veraPDF explicitly.
- Eight committed and rebuilt language/US PDFs are checked for content, paper and page count.
- typstgen has targeted decimal, configuration, profile, compile and MCP tests, Clippy,
  minimum-Rust and Wasm CI checks, plus a dependency audit.
- Publication checks exercise PDF structure and PDF/UA compilation. They do not constitute
  a comprehensive manual accessibility certification.

Successful fixture validation applies to the tested files. Arbitrary new configuration and
transaction data still need their own applicable checks; unexecuted validators stay `not_run`.

## Issue scope and remaining steps

| Workstream | Source status |
| --- | --- |
| [#12](https://github.com/casoon/typst-business-templates/issues/12), [#15](https://github.com/casoon/typst-business-templates/issues/15) | Shared rendering/data contract and library/CLI/MCP profile flow implemented for the stated combinations |
| [#17–#23](https://github.com/casoon/typst-business-templates/issues/17) | Publication/component, masking, metadata, task, locale and brochure implementations are present and checked |
| [#24](https://github.com/casoon/typst-business-templates/issues/24) | Version namespaces and release strategy documented; publication remains a separate decision |
| [#14](https://github.com/casoon/typst-business-templates/issues/14) | XRechnung 3.0 and Peppol BIS 3.0 UBL files with catalog output selection, Mustang checks and on-demand KoSIT/Peppol rule checks; transmission and credit notes are not implemented |
| [#11](https://github.com/casoon/typst-business-templates/issues/11), [#13](https://github.com/casoon/typst-business-templates/issues/13) | Initial VAT/configuration/Factur-X/UBL milestone present; remaining reviewed tax cases (true zero, other exemptions, § 13b, B2C/OSS, cross-border small business) remain open |
| [#16](https://github.com/casoon/typst-business-templates/issues/16) | FR domestic B2B draft only; no completed national electronic issuance/transmission path |
| [#25](https://github.com/casoon/typst-business-templates/issues/25) | Package compatibility examples and migration guidance present; migrating a consumer repository is outside this repository's scope (closed) |

Before treating this as a released integration, exercise representative documents from the intended consumer, then select
and publish the package/compiler combination. Package tags, registry publication and Typst
Universe are not implied by a documentation or Pages update. Issue closure should follow
the actual acceptance scope rather than equating an umbrella issue with its first milestone.
