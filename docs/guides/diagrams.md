---
title: Diagrams
description: Draw architecture, flow, org chart, timeline and other diagrams with chartlet and embed the SVG in any document.
order: 3
---

The package has no diagram template. Diagrams are drawn by
[chartlet](https://casoon.github.io/chartlet/), which lays out a JSON spec without coordinates
and writes SVG. Typst embeds the SVG like any image, so a diagram can sit inside a concept,
documentation or proposal, or on a page of its own.

```sh
cargo install chartlet
```

## 1. Write a spec

```json
{
  "schemaVersion": 1,
  "type": "flow",
  "title": "Projektfreigabe",
  "source": "Von der Anfrage bis zur Auslieferung",
  "flow": {
    "nodes": [
      { "id": "anfrage", "label": "Anfrage", "kind": "start" },
      { "id": "analyse", "label": "Analyse" },
      { "id": "entscheidung", "label": "Freigabe?", "kind": "decision" },
      { "id": "go-live", "label": "Go-Live", "kind": "end" }
    ],
    "edges": [
      { "from": "anfrage", "to": "analyse", "label": "Briefing" },
      { "from": "analyse", "to": "entscheidung" },
      { "from": "entscheidung", "to": "go-live", "label": "Ja" },
      { "from": "entscheidung", "to": "analyse", "label": "Nein", "dash": "dashed" }
    ]
  }
}
```

The chart types and their fields are described in the
[chartlet documentation](https://casoon.github.io/chartlet/).

## 2. Render the print variant

```sh
chartlet render flow.json --variant print -o flow.svg
```

Use `--variant print` for Typst. The default screen SVG is meant for browsers; in Typst every
mark of it comes out black.

## 3. Embed it

```typst
#figure(
  image("flow.svg", width: 100%),
  caption: [Projektfreigabe],
)
```

For a diagram on its own page, size the page to the image:

```typst
#set page(width: auto, height: auto, margin: 12mm)
#image("flow.svg")
```

The SVG text uses Inter. Add the repository's `fonts/` (or your own copy of Inter) to
`font_paths` in `typstgen.toml`, otherwise Typst substitutes another font.

Keep the spec next to the SVG and render again after every change — Typst only sees the SVG.

## Examples

[`examples/diagrams/`](https://github.com/casoon/typst-business-templates/tree/main/examples/diagrams)
has one spec per common business diagram, and `build.sh` there renders and compiles them all:

| Spec | chartlet type |
| --- | --- |
| `architecture.json` | `architecture` — components in nested boundaries |
| `flow.json` | `flow` — process with a decision and a loop back |
| `swimlane.json` | `flow` with `lanes` |
| `orgchart.json` | `tree` |
| `mindmap.json` | `tree` (chartlet has no radial layout) |
| `timeline.json` | `timeline` — phases and milestones |
| `roadmap.json` | `timeline` with groups |
| `quadrant.json` | `scatter` with threshold lines through the middle of both axes |

The documentation of the IT consultancy example
([`documentation.typ`](https://github.com/casoon/typst-business-templates/blob/main/examples/it-consultant/documents/documentation/2025/documentation.typ))
embeds an architecture diagram rendered from `aws-architecture.json` next to it.
