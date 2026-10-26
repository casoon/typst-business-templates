---
title: Package
description: The business-templates Typst package — import, exported functions and their parameters, JSON schemas and the typstgen.toml keys a project uses.
order: 1
---

| | |
| --- | --- |
| Name | `business-templates` |
| Version | `0.2.0` |
| Entry point | `templates/lib.typ` |
| Compiler | Typst 0.15 or later |
| License | MIT |

```typst
#import "@local/business-templates:0.2.0": invoice, concept
```

The package is installed locally, see [Installation](../../getting-started/installation/#the-package).

## Accounting functions

```typst
invoice(data: none, company: none, profile: none, locale: none)
offer(data: none, company: none)
credit-note(data: none, company: none)
reminder(data: none, company: none)
delivery-note(data: none, company: none)
order-confirmation(data: none, company: none)
quotation-request(data: none, company: none)
time-sheet(data: none, company: none)
letter(data: none, company: none, [body])
credentials(data: none, company: (:), locale: none, mask: false)
```

| Parameter | Type | Content |
| --- | --- | --- |
| `data` | dictionary | the document, usually `json("…")`; shape per [schema](#json-schemas) |
| `company` | dictionary | `company.json`; `company.logo` may be replaced by image bytes |
| `locale` | dictionary | `invoice`/`credentials`: partial overrides over the selected package catalog |
| body | content | `letter` only, optional: the letter text with headings, lists and tables, after `data.content` |

`company.language` defaults to `de`. `invoice`, `offer`, `credit-note` and
`order-confirmation` panic if the totals in `data` do not add up
([details](../../guides/json-documents/#totals-check)). All set the PDF title
(document number) and author (company name); all except `time-sheet` set the PDF date to the
document date.

## Running-text functions

Used as a show rule (`#show: concept.with(…)`); the last positional parameter `body` is the rest of
the document. Every function also takes:

| Parameter | Default | Content |
| --- | --- | --- |
| `company` | `none` | `company.json` |
| `locale` | `none` | labels; default from `company.language` |
| `logo` | `none` | logo as content; overrides `company.logo` (not on `task-list`) |
| `show-title-page`, `show-footer` | `true` | not on `handout` |

Template-specific parameters, with defaults:

| Function | Parameters |
| --- | --- |
| `concept` | `title`, `document_number`, `client_name`, `project_name`, `version: "1.0"`, `status: "Entwurf"`, `tags: ()`, `created_at`, `authors: ()`, `show_toc: true` |
| `documentation` | `title`, `document_number`, `subject`, `client_name`, `project_name`, `doc_type: "Dokumentation"`, `version: "1.0"`, `status: "Entwurf"`, `tags: ()`, `authors: ()`, `created_at`, `show_toc: true` |
| `contract` | `title`, `document_number`, `contract_type: "Dienstleistungsvertrag"`, `parties: ()`, `effective_date`, `termination_date`, `created_at`, `status`, `show_toc: true` |
| `protocol` | `title`, `document_number`, `meeting_date`, `meeting_time`, `location`, `participants: ()`, `absent: ()`, `moderator`, `note_taker`, `created_at`, `show_toc: false` |
| `specification` | `title`, `document_number`, `subject`, `client_name`, `project_name`, `version: "1.0"`, `status: "Entwurf"`, `tags: ()`, `authors: ()`, `created_at`, `last_updated`, `show_toc: true` |
| `proposal` | `title`, `document_number`, `client_name`, `project_name`, `budget`, `timeline`, `version: "1.0"`, `status: "Angebot"`, `tags: ()`, `created_at`, `valid_until`, `authors: ()`, `show_toc: true` |
| `sla` | `title`, `document_number`, `service_provider`, `customer`, `effective_date`, `termination_date`, `review_period`, `version: "1.0"`, `status: "Aktiv"`, `created_at`, `show_toc: true` |
| `task-list` | `title: "Aufgabenliste"`, `subtitle`, `project`, `client`, `document-number`, `created` (today), `tasks: ()`, `categories: ()`, `roles: ()`, `notes` |
| `handout` | `title`, `handout-type: "Aufgabenblatt"`, `category`, `subject`, `target-group: "Oberstufe"`, `ai-context`, `competencies: ()`, `duration`, `materials: ()`, `version: "1.0"` |

Parameters without a default shown default to `none`. Dates are strings and printed as given.

`task-list` is usually called directly with an empty body (`#task-list(…)[]`). A task is a
dictionary with `title` and optionally `status` (`todo`, `in-progress`, `done`, `blocked`),
`priority` (`high`, `medium`, `low`), `due`, `assignee`, `tags`, `description`, `depends-on`,
`condition`, `phase` and `subtasks`; a category has `name`, optional `description` and `tasks`.

## Handout helpers

```typst
aufgabe(nummer, punkte: none, cat-color: rgb("#3b6df2"), body)
hinweis(body)
wichtig(body)
antwortfeld(hoehe: 80pt, linien: false)
textblock(quelle: none, body)
kriterium(name, beschreibung, gewicht: none)
```

See [Handout](../../guides/typst-documents/#handout).

## JSON schemas

JSON Schema draft 2020-12, in
[`schema/`](https://github.com/casoon/typst-business-templates/tree/main/schema) and published at
`https://casoon.github.io/typst-business-templates/schema/<name>.schema.json`:

| Schema | Describes |
| --- | --- |
| [`company`](https://casoon.github.io/typst-business-templates/schema/company.schema.json) | `company.json` |
| [`invoice`](https://casoon.github.io/typst-business-templates/schema/invoice.schema.json) | `data` of `invoice` (also read by typstgen for ZUGFeRD) |
| [`offer`](https://casoon.github.io/typst-business-templates/schema/offer.schema.json) | `data` of `offer` |
| [`credit-note`](https://casoon.github.io/typst-business-templates/schema/credit-note.schema.json) | `data` of `credit-note` |
| [`reminder`](https://casoon.github.io/typst-business-templates/schema/reminder.schema.json) | `data` of `reminder` |
| [`delivery-note`](https://casoon.github.io/typst-business-templates/schema/delivery-note.schema.json) | `data` of `delivery-note` |
| [`order-confirmation`](https://casoon.github.io/typst-business-templates/schema/order-confirmation.schema.json) | `data` of `order-confirmation` |
| [`quotation-request`](https://casoon.github.io/typst-business-templates/schema/quotation-request.schema.json) | `data` of `quotation-request` |
| [`time-sheet`](https://casoon.github.io/typst-business-templates/schema/time-sheet.schema.json) | `data` of `time-sheet` |
| [`letter`](https://casoon.github.io/typst-business-templates/schema/letter.schema.json) | `data` of `letter` |
| [`credentials`](https://casoon.github.io/typst-business-templates/schema/credentials.schema.json) | `data` of `credentials` |
| [`common`](https://casoon.github.io/typst-business-templates/schema/common.schema.json) | shared definitions: `date`, `decimal`, `money`, `vat_rate`, `address`, `recipient`, `bank_account` |
| [`invoice-config`](https://casoon.github.io/typst-business-templates/schema/invoice-config.schema.json) | tax model, named taxes/components, required fields, notes and presentation |
| [`document-profiles`](https://casoon.github.io/typst-business-templates/schema/document-profiles.schema.json) | optional versioned rule catalog |
| [`document-request`](https://casoon.github.io/typst-business-templates/schema/document-request.schema.json) | explicit profile selection, invoice data and confirmed facts |

Every field carries a description, including which fields the templates do not render and which
only typstgen reads. A JSON file names its schema with `"$schema"` for editor support; the
templates ignore that key.

## typstgen.toml

The keys a project typically sets ([full reference](https://casoon.github.io/typstgen/docs/reference/configuration/)):

| Key | Example | Purpose |
| --- | --- | --- |
| `template_paths` | `["."]` | the project folder becomes the root for absolute paths such as `/data/company.json` |
| `package_path` | `"../../packages"` | folder containing `local/business-templates/0.2.0`, if the package is not in the Typst package directory |
| `font_paths` | `["fonts"]` | folders with the preset fonts |

Paths are relative to the working directory, so run typstgen from the project folder.

## Locales

`templates/locale/` contains `de`, `en`, `es`, `fr`, `it`, `nl` and `pt`, all with the same keys.
A custom `locale:` dictionary recursively overlays the catalog selected by the document/company
language. Missing/null labels inherit; empty strings suppress labels. Known type conflicts and
unsupported languages fail. `load-locale(locale, company, language: none)` is exported for
caller-composed components. See [Migration](../../guides/migration/#partial-translations).

## Publication functions and components

`publication` and `brochure` accept a content body with the compact frame and identity
parameters. The package exports printable fields, choices, notices, phases, tables, priorities,
cards and numbered steps. See [Publications](../../guides/publications/) for signatures,
page dimensions, PDF structure and overflow limits.

## Metadata and credentials

Running-text title/author/number/date mapping and the `credentials(mask: true)` password-field
contract are described in [Migration](../../guides/migration/). Masking does not redact free text.
Task responsibility reuses `assignee`; optional `phase` and a `roles: ((name: ..., description:
...),)` legend are visible text. Empty phase/assignee values add no column or label.

## Invoice profiles

The rendering selection separates language, format locale, currency, DIN/international layout
and A4/US Letter. The user-owned configuration chooses VAT categories or additive sales-tax
components; canonical calculation and optional rule-catalog resolution belong to typstgen.
See [Invoice configuration](../../guides/invoice-configuration/) and
[Capabilities and limits](../project-status/).
See [Invoice profiles](../../guides/invoice-profiles/) for the versioned contracts and release states.
