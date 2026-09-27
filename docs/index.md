---
title: Overview
description: What typst-business-templates contains, how the CLI and the library differ, and how this documentation is organised.
order: 0
---

typst-business-templates is a set of [Typst](https://typst.app/) templates for business
documents — invoices, offers, credit notes, reminders, letters, credentials, concepts,
documentation, diagrams and more — plus two ways to fill them with data:

- **`docgen`**, a command-line tool. You keep your documents as JSON files (or write them directly
  in Typst), and `docgen` compiles them to PDF with your company data, branding and language.
- **`typst-business-templates`**, a Rust library on
  [crates.io](https://crates.io/crates/typst-business-templates). Templates, locales and fonts are
  embedded in the crate and Typst runs in-process, so an application can produce the same PDFs
  without any external tool.

## What it covers

- 20 document templates in two layouts: an accounting layout with a DIN 5008 address block and a
  four-column company footer, and a document layout with a title page. See
  [Document types](reference/document-types/).
- Labels in seven languages (`de`, `en`, `es`, `fr`, `it`, `nl`, `pt`), selected by `language`
  in `company.json`.
- Branding from `company.json`: accent and primary colour, logo and one of ten font presets.
- Diagrams from JSON without coordinates: flow, tree, mindmap, architecture, timeline, swimlane,
  quadrant and roadmap layouts.
- Project-local templates: standard templates are extracted into `.docgen/templates/` and kept in
  sync with the `docgen` version; forks in `templates/` stay as you left them.

## Where it stops

| docgen does | docgen does not |
| --- | --- |
| Compile JSON or `.typ` files to PDF | Calculate totals or VAT for you — the JSON carries the numbers |
| Keep clients, projects and counters in plain JSON files | Send documents, track payments or book anything |
| Password-protect a PDF with `--encrypt` (via `qpdf`) | Produce e-invoices (ZUGFeRD / XRechnung) |

## How the docs are organised

- **Getting started**: [install](getting-started/installation/) `docgen` and create a
  [first document](getting-started/quickstart/).
- **Guides**: [JSON documents](guides/json-documents/), [documents written in
  Typst](guides/typst-documents/), [diagrams](guides/diagrams/) and
  [branding and languages](guides/branding/).
- **Reference**: [CLI commands](reference/cli/), [document types](reference/document-types/) and
  the [Rust library](reference/library/). Item-level API documentation lives on
  [docs.rs](https://docs.rs/typst-business-templates).

Every document in the [showcase](../showcase/) was compiled by `docgen` from the example file
shown next to it. A product overview is at
[typst-business-templates.casoon.de](https://typst-business-templates.casoon.de).

## Project notes

The files `PROJECT.md`, `ROADMAP.md`, `SIMPLIFICATION-PLAN.md`, `REVIEW-2026-01.md` and
`DATABASE.md` in this folder are internal planning notes (partly in German, partly outdated) and
are not part of this site. They remain in the
[repository](https://github.com/casoon/typst-business-templates/tree/main/docs).
