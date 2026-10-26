---
title: Migration and integration
description: Move from docgen and adopt package features in existing document projects.
order: 6
---

## Version pair

This checkout contains the Typst package `business-templates` **0.2.0**, requiring
Typst **0.15.0** or later and checked with **typstgen 0.5.0** (embedded Typst 0.15). Tool versions
are pinned in `tool-versions.json`. Existing `v0.7.x` tags belong to docgen/the discontinued Rust
crate; they are not Typst package versions. See [Releases](../../reference/releases/).
Use the `templates-v0.2.0` tag or pin its commit alongside the package version:
a symlink to `templates/` changes as the checkout changes.

## From docgen

The German [historical practice article](https://insights.casoon.de/artikel/typst-praxisprojekte-reporting-geschaeftsdokumente/)
describes the earlier document/reporting workflow. It uses docgen; follow this guide for the
current setup and supported commands.

Replace `docgen` with the pinned typstgen tool and install `templates/` as
`local/business-templates/0.2.0`. Replace `sys.inputs` template wrappers with explicit package
calls; use the examples as reference. Typstgen has no replacement for the old client/project
database, number allocation or `--encrypt`. Keep assigned identifiers, content, branding and
secret management in the calling project. Do not regenerate document numbers during migration.
Encrypted source material must be decrypted outside the package and handled by the caller.

Accounting calls still accept `data:` and `company:`. They do not infer a new country or tax
case from language. Keep legacy VAT codes, exemption reasons and financial values until an
explicitly supported profile adapter has been checked against the existing invoice. Compilation
is distinct from fiscal/profile validation and transmission.

## Partial translations

`locale:` now overlays the bundled catalog for `company.language` (default `de`) recursively.
`publication`/`brochure` can select document `language:` explicitly. Complete existing locale
dictionaries remain usable if known branches are dictionaries and known labels are strings.
Only duplicate the labels that actually differ:

```typst
#show: concept.with(
  title: "Briefing", company: (language: "en"),
  locale: (common: (client: "Partner",)),
)
```

Missing keys and `none`/JSON `null` inherit the bundled value. An empty string intentionally
suppresses a label. Unknown custom keys survive unchanged, provided they do not replace known
branches or labels with incompatible types. Known branch/leaf type conflicts fail with their
locale field path. An unsupported language fails explicitly; there is no silent language switch.
Language is only text selection and does not change invoicing rules.

## Credential masking

Pass `mask: true` to `credentials(data:, company:, ...)` to replace each nonempty password with
`********` before rendering. Default `false` preserves the existing output. Missing, null and
empty passwords display an empty value. A translated notice explains the masked view.
Usernames, URLs, technical settings and service notes are unchanged: inspect them before sharing.
The renderer neither embeds the original data nor puts passwords into metadata or attachments.
The source file still contains the original value and must be protected separately.

## Document identity

`concept`, `documentation`, `contract`, `proposal`, `protocol`, `sla`, `specification`, `task-list`
and the publication family set PDF title to the human title, author to the supplied `authors`
where supported (otherwise company name), and keywords to the assigned document number.
Existing public parameter names remain unchanged (`document_number`/`created_at` versus
`document-number`/`created`). The number remains visible on the title page or running frame.
A `task-list` with its title page disabled displays its number from page two as before.

Dates accept an ISO `YYYY-MM-DD` string, a `{date: ...}` dictionary or a German calendar date.
Absent dates are omitted; invalid dates fail. The legacy `task-list.created` default is still
today for compatibility; pass a fixed date or `none` for reproducible documents.
Accounting metadata keeps its existing title/author/date mapping.

PDF keywords provide an additional searchable identifier, not a custom XMP namespace or the
PDF trailer's binary ID. The package does not promise arbitrary PDF/A profiles. Use a compatible
export standard explicitly and validate it externally. For reproducibility use an explicit
`--creation-timestamp`/`SOURCE_DATE_EPOCH`, pin assets/fonts, and archive a typstgen `--manifest`.

## Family-by-family integration

1. Pin package revision and typstgen 0.5.0; compile the old documents and record their text,
   identifiers, financial values and metadata before editing wrappers.
2. Move one guide/intake document to `publication`, then replace only equivalent local field,
   option, notice, phase and table helpers. Keep branding, content and business workflows local.
3. Switch a synthetic credentials document to `mask: true`, extract PDF text, and confirm the
   test password is absent. Inspect every remaining free-text field before using real content.
4. Adopt prose metadata. Compare title, author, keywords and dates to the visible identity.
5. Reuse existing task `assignee` for responsibility, add optional `phase` and a caller-defined
   `roles` legend. Migrate compact landscape content to `brochure` where appropriate.
6. Check invoices separately: compare line amounts, subtotal, categories, rates, VAT and payment
   total. Keep the existing tax treatment and company note. Use the matching external XML/profile
   validator before claiming structured invoice support.
7. Compile long and multipage variants, without and with an optional logo, and inspect every
   page. Remove a local helper only after its replacement has passed these checks.

`scripts/check.sh` compiles all existing example wrappers against the current package/tool pair
and adds synthetic integration checks for locale compatibility, masking, metadata and the new
publication family. These are repository examples, not evidence of a migration in a private
consumer repository. No consumer helpers have been deleted by this package update. Actual
consumer integration and its before/after review require access and a separate commission.

Invoice profiles require the separate coordinated typstgen revision, while base documents remain
compatible with 0.5.0. Follow [Invoice profiles](../invoice-profiles/) before adopting them; preserve
legacy taxation until the explicit case and canonical PDF/XML comparison pass.

A complete repeatable local acceptance run is `scripts/test.sh`; generated review PDFs,
canonical inputs and external reports remain in `output/test/`. See the
[acceptance test](../invoice-profiles/#local-acceptance-test) for prerequisites and scope.
