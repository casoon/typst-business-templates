---
title: Document types
description: The 19 templates, grouped by layout, with the function to call, how it takes its content and the schema of its data.
order: 2
---

Each template is a folder in
[`templates/`](https://github.com/casoon/typst-business-templates/tree/main/templates) with a
`default.typ`; the function has the same name as the folder and is exported from `lib.typ`.
Shared parts — DIN 5008 address block, accounting header, totals, title pages, footers, date and
money formatting — live in `templates/common/`.

Two calling conventions:

- **data** — `#invoice(data: json("…"), company: json("/data/company.json"))`. The content is a
  JSON file described by the linked schema. See [Accounting documents](../../guides/json-documents/).
- **show rule** — `#show: concept.with(title: …, company: …)` followed by the text. See
  [Documents in Typst](../../guides/typst-documents/).

Schemas are published at `https://casoon.github.io/typst-business-templates/schema/`.

## Accounting layout

Letterhead with logo and a metadata box, DIN 5008 address block with return address line, and a
four-column company footer (address, contact, tax data, bank account). Helvetica, German labels.

| Function | Document | Call | Schema | Contents |
| --- | --- | --- | --- | --- |
| `invoice` | Invoice | data | [invoice](https://casoon.github.io/typst-business-templates/schema/invoice.schema.json) | Position table with sub-items, VAT breakdown, payment due date; totals check; ZUGFeRD with typstgen |
| `offer` | Offer | data | [offer](https://casoon.github.io/typst-business-templates/schema/offer.schema.json) | Position table, validity date, terms; totals check |
| `credit-note` | Credit note | data | [credit-note](https://casoon.github.io/typst-business-templates/schema/credit-note.schema.json) | Reference to the original invoice, reason, position table; totals check |
| `reminder` | Payment reminder | data | [reminder](https://casoon.github.io/typst-business-templates/schema/reminder.schema.json) | Dunning level 1–3, table of open invoices, fees, new deadline |
| `delivery-note` | Delivery note | data | [delivery-note](https://casoon.github.io/typst-business-templates/schema/delivery-note.schema.json) | Items with quantities, delivery address, shipping details, signature fields |
| `order-confirmation` | Order confirmation | data | [order-confirmation](https://casoon.github.io/typst-business-templates/schema/order-confirmation.schema.json) | Order reference, expected delivery, position table; totals check |
| `quotation-request` | Quotation request | data | [quotation-request](https://casoon.github.io/typst-business-templates/schema/quotation-request.schema.json) | Requested items with specifications, requirements, response deadline |
| `time-sheet` | Time sheet | data | [time-sheet](https://casoon.github.io/typst-business-templates/schema/time-sheet.schema.json) | Daily entries with start and end times, hour totals, signatures |
| `letter` | Business letter | data | [letter](https://casoon.github.io/typst-business-templates/schema/letter.schema.json) | Subject, your/our reference, body, enclosures |

## Credentials

| Function | Document | Call | Schema | Contents |
| --- | --- | --- | --- | --- |
| `credentials` | Access data | data, plus `locale:` | [credentials](https://casoon.github.io/typst-business-templates/schema/credentials.schema.json) | Title page, confidentiality notice, one section per service with logins, ports and settings |

The credentials sheet uses the document layout (title page, branding, translated labels) but
takes its content as data.

## Document layout

Title page with logo, title, document number, metadata and tags, then the content. Branding and
labels follow `company.json`. Most have an optional table of contents (`show_toc`).

| Function | Document | Call | Contents |
| --- | --- | --- | --- |
| `concept` | Concept | show rule | Project and client, version, status, authors |
| `documentation` | Documentation | show rule | Subject, document type, code blocks, version and status |
| `contract` | Contract | show rule | Contract type, parties, effective and termination date |
| `protocol` | Meeting minutes | show rule | Date, time, location, participants, moderator, note taker |
| `specification` | Specification | show rule | Version, last update, authors |
| `proposal` | Project proposal | show rule | Budget, timeline, validity |
| `sla` | Service level agreement | show rule | Provider, customer, effective date, review period |
| `task-list` | Task list | function call with `categories:` / `tasks:` | Checklists with status, priorities, due dates, assignees, dependencies, subtasks |

## Handout

| Function | Document | Call | Contents |
| --- | --- | --- | --- |
| `handout` | Teaching handout | show rule | Teacher sheet followed by student material; helpers `aufgabe`, `hinweis`, `wichtig`, `kriterium`, `antwortfeld`, `textblock`; German labels |

## Display options

The document-layout templates take `show-title-page` and `show-footer` (both `true` by default).
The accounting templates read `show_footer` from `metadata` in the JSON.

## Which ones you can see

The [showcase](../../../showcase/) shows a selection, each compiled from the example file shown
next to it. All types have an example in
[`examples/it-consultant/documents/`](https://github.com/casoon/typst-business-templates/tree/main/examples/it-consultant/documents),
except the task list (in `examples/digitalagentur/`) and the handout (in `examples/handout/`).
