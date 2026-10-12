---
title: Diagrams
description: Describe nodes and edges in JSON and let docgen lay them out as flow, tree, mindmap, architecture, timeline, swimlane, quadrant or roadmap diagram.
order: 3
---

The `diagram` document type turns a JSON description into a one-page PDF. There are no
coordinates in the file: `docgen` computes the layout before the page is rendered, and it needs
no external Typst packages.

```sh
docgen compile examples/diagram-flow/diagram.json -o diagram.pdf
```

Diagrams are the one document type that `docgen` renders with its built-in Typst engine, so they
work without the `typst` binary.

## Structure

```json
{
  "document": { "paper": "presentation-16-9", "margin": "12mm", "background": "#f8fafc" },
  "diagram": {
    "kind": "flow",
    "layout": "layered",
    "title": "Projektfreigabe",
    "subtitle": "Von der Anfrage bis zur Auslieferung"
  },
  "nodes": [
    { "id": "anfrage", "label": "Anfrage", "shape": "rounded",
      "style": { "fill": "#ffffff", "stroke": "#1d4ed8" } },
    { "id": "entscheidung", "label": "Freigabe?", "shape": "diamond" }
  ],
  "edges": [
    { "from": "anfrage", "to": "entscheidung", "label": "Briefing" }
  ]
}
```

| Key | Content |
| --- | --- |
| `document` | `paper` (for example `a4`, `presentation-16-9`), or `width` and `height`; `flipped`, `margin`, `background` |
| `diagram` | `kind`, `layout`, `direction`, `title`, `subtitle`, `theme` |
| `nodes` | `id`, `label`, `shape`, `style` (`fill`, `stroke`, `text`), plus the placement key of the layout: `parent`, `lane`, `phase` or `quadrant` |
| `edges` | `from`, `to`, `label`, `kind`, `style.stroke` |
| `lanes`, `phases` | ordered lane and phase names for swimlane, timeline and roadmap diagrams |

## Layouts

`layout` selects the algorithm; without it, `kind` decides.

| `kind` / `layout` | Nodes are placed |
| --- | --- |
| `tree` / `hierarchical` | by `parent` |
| `flow` / `layered` | in layers along the edges |
| `mindmap` / `radial` | around the root, by `parent` |
| `architecture` | uses the layered layout, along the edges |
| `timeline` | by `phase` |
| `swimlane` | by `lane` |
| `quadrant` | by `quadrant` |
| `roadmap` | by `lane` and `phase` |

Connecting lines come only from `edges`. `parent` places a node in a tree or mindmap but draws
no line, so add an edge for every connection you want to see.

Each layout has an example in
[`examples/`](https://github.com/casoon/typst-business-templates/tree/main/examples), and five of
them are in the [showcase](../../../showcase/diagram-flow/).
