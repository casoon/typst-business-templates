---
title: Document types
description: The 20 templates, grouped by layout, with what each one contains.
order: 2
---

Each template is a folder in
[`templates/`](https://github.com/casoon/typst-business-templates/tree/main/templates) with a
`default.typ`. Shared parts — DIN 5008 address block, accounting header, totals, title pages,
footers, date and money formatting — live in `templates/common/`.

## Accounting layout

Letterhead with logo and a metadata box, DIN 5008 address block with return address line, and a
four-column company footer (address, contact, tax data, bank account).

| Template | Document | Contents |
| --- | --- | --- |
| `invoice` | Invoice | Position table with sub-items, VAT breakdown, payment due date |
| `offer` | Offer | Position table, validity date, payment and delivery terms |
| `credit-note` | Credit note | Reference to the original invoice, reason, position table |
| `reminder` | Payment reminder | Dunning level 1–3, table of open invoices, fees, new deadline |
| `delivery-note` | Delivery note | Items with quantities, shipping details, signature fields |
| `order-confirmation` | Order confirmation | Order details, delivery date, reference to the customer order |
| `letter` | Business letter | Subject, your/our reference, body, enclosures |
| `time-sheet` | Time sheet | Daily entries with start and end times, totals, signatures |
| `quotation-request` | Quotation request | Requested items with specifications and requirements |

## Document layout

Title page with title, document number, metadata and tags, then the content. Most have an
optional table of contents.

| Template | Document | Contents |
| --- | --- | --- |
| `concept` | Concept | Project and client, version, status |
| `documentation` | Documentation | Code blocks, numbered headings, version and status |
| `contract` | Contract | Parties, numbered paragraphs (§ 1, § 2 …), signature page |
| `protocol` | Meeting minutes | Participants, agenda, action items |
| `specification` | Specification | Requirement boxes by priority, version history, authors |
| `proposal` | Project proposal | Budget, timeline, validity |
| `sla` | Service level agreement | Version and last update in the footer |
| `task-list` | Task list | Checklists with status, priorities, categories, dependencies, subtasks |

## Special layouts

| Template | Document | Contents |
| --- | --- | --- |
| `credentials` | Credentials | Confidentiality notice, services and access data, technical settings |
| `diagram` | Diagram | Laid out from nodes and edges, see [Diagrams](../../guides/diagrams/) |
| `handout` | Handout | Teacher sheet followed by student material (German labels) |

## Display options

The document-layout templates take `show-title-page` and `show-footer` (both `true` by default).
The accounting templates read `show_footer` from `metadata` in the JSON.

## Which ones you can see

The [showcase](../../../showcase/) has invoice, offer, credit note, reminder, letter, quotation
request, credentials, proposal, specification, concept, documentation and five diagram layouts,
each compiled from the example file shown next to it.
