---
title: Documents in Typst
description: Write concepts, contracts, documentation and other running text directly in Typst with a template as show rule; task lists and handouts.
order: 2
---

Long, prose-heavy documents are easier to write in Typst than in JSON. Nine templates work as a
show rule: `concept`, `contract`, `documentation`, `proposal`, `protocol`, `sla`,
`specification`, `task-list` and `handout`. The metadata goes into named parameters, the rest of
the file is the document.

```typst
#import "@local/business-templates:0.1.0": concept

#show: concept.with(
  title: "IT-Security Konzept Rechtsanwaltskanzlei",
  document_number: "KO-2025-003",
  client_name: "Richter & Partner Rechtsanwälte",
  project_name: "IT-Security Audit & Härtung",
  version: "1.0",
  status: "draft",
  created_at: "2025-01-08",
  tags: ("Security", "DSGVO", "Kanzlei", "Compliance"),
  company: json("/data/company.json"),
)

= Executive Summary

Die IT-Infrastruktur der Kanzlei …
```

```sh
typstgen compile documents/concepts/2025/concept.typ
```

This is the beginning of the IT consultancy's concept in
[`examples/`](https://github.com/casoon/typst-business-templates/tree/main/examples/it-consultant/documents).
Everything after the show rule is plain Typst: headings, tables, lists, `#figure`, images,
[diagrams](../diagrams/), your own functions.

## Common parameters

| Parameter | Default | Effect |
| --- | --- | --- |
| `title`, `document_number` | `none` | title page, page header and footer |
| `version`, `status`, `created_at`, `tags`, `authors` | varies | metadata on the title page (not every template has all of them) |
| `show_toc` | `true` (`protocol`: `false`) | table of contents after the title page |
| `company` | `none` | `company.json`: name, colours, font preset, language, logo |
| `locale` | `none` | a translation dictionary that replaces the one for `company.language` |
| `logo` | `none` | logo as content, e.g. `image("/data/logo.png")`; takes precedence over `company.logo` |
| `show-title-page`, `show-footer` | `true` | turn off the title page or the footer |

Each template adds its own fields — `parties` and `effective_date` for a contract, `participants`
and `meeting_date` for minutes, `budget` and `valid_until` for a proposal. The
[package reference](../../reference/package/) lists all parameters per template.

Fonts and colours come from `branding` in `company.json`, labels (page, version, table of
contents …) from the language; see [Branding and languages](../branding/).

## Task list

`task-list` takes the tasks as data and an optional body. It is called directly rather than as a
show rule; the trailing `[]` is the (empty) body:

```typst
#import "@local/business-templates:0.1.0": task-list

#task-list(
  title: "Projekt Aufgabenliste",
  project: "Website Redesign",
  document-number: "DOC-2026-001",
  company: json("/data/company.json"),
  categories: (
    (
      name: "Entwicklung",
      tasks: (
        (
          title: "User Authentication implementieren",
          status: "in-progress",       // todo, in-progress, done, blocked
          priority: "high",            // high, medium, low
          due: "31.01.2026",
          assignee: "Max Mustermann",
          subtasks: ((title: "OAuth Provider konfigurieren", status: "done"),),
        ),
      ),
    ),
  ),
  notes: [Wöchentliches Standup jeden Montag.],
)[]
```

A task can also carry `description`, `tags`, `depends-on` and `condition`. `tasks:` takes a flat
list without categories. Status and priority also accept the German words (`erledigt`,
`in-arbeit`, `blockiert`, `hoch`, `mittel`, `niedrig`).

## Handout

`handout` produces a teacher sheet (title, target group, duration, competencies, materials,
optional `ai-context`) followed by the student material from the body. Its labels are German.
The package exports helper functions for the body:

| Function | Renders |
| --- | --- |
| `aufgabe(nummer, punkte: none)[…]` | numbered task, optionally with points |
| `hinweis[…]` | hint box |
| `wichtig[…]` | highlighted warning box |
| `antwortfeld(hoehe: 80pt, linien: false)` | empty answer field, optionally ruled |
| `textblock(quelle: none)[…]` | source text with attribution |
| `kriterium(name, beschreibung, gewicht: none)` | row of an assessment rubric |

```typst
#import "@local/business-templates:0.1.0": handout, aufgabe, hinweis, antwortfeld

#show: handout.with(
  title: "Argumente prüfen",
  handout-type: "Aufgabenblatt",
  subject: "Deutsch",
  target-group: "Oberstufe",
  duration: "45 Minuten",
  competencies: ("Argumente erkennen", "Belege bewerten"),
)

#hinweis[Lies den Kommentar zweimal.]

#aufgabe(1, punkte: 4)[
  Nenne die These des Kommentars in einem Satz.
  #antwortfeld(hoehe: 60pt, linien: true)
]
```

The full example is
[`examples/handout/aufgabenblatt.typ`](https://github.com/casoon/typst-business-templates/blob/main/examples/handout/aufgabenblatt.typ).

## Changing a layout

The templates are plain Typst. To change one beyond its parameters, copy
[`templates/`](https://github.com/casoon/typst-business-templates/tree/main/templates) into your
project — the templates need the shared `common/` and `locale/` folders next to them — and import
by path instead of from the package:

```typst
#import "/templates/concept/default.typ": concept
```

A copy does not receive later changes to the package. Inside the project, `company.logo` may also
be a path (see [Logo](../branding/#logo)).
