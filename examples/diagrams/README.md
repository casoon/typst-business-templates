# Diagrams with chartlet

[chartlet](https://github.com/casoon/chartlet) lays out diagrams and charts from a JSON
specification and writes SVG. Typst embeds the SVG like any image, so a diagram can sit on its
own page or inside a concept, documentation or proposal.

| Spec | chartlet type |
|------|---------------|
| `architecture.json` | `architecture` – components in nested boundaries |
| `flow.json` | `flow` – process with a decision and a loop back |
| `swimlane.json` | `flow` with `lanes` |
| `orgchart.json` | `tree` |
| `mindmap.json` | `tree` with `"layout": "radial"` – the root in the middle, one ring per level |
| `timeline.json` | `timeline` – phases and milestones |
| `roadmap.json` | `timeline` with groups |
| `quadrant.json` | `scatter` with `quadrants` – dividing lines and the four area names |

Build all of them (needs `cargo install chartlet` and typstgen):

```bash
examples/diagrams/build.sh
```

For Typst, render the **print** variant; the screen SVG draws every mark black in Typst:

```bash
chartlet render flow.json --variant print -o flow.svg
```

```typst
#figure(image("flow.svg", width: 100%), caption: [Projektfreigabe])
```

The documentation in [it-consultant](../it-consultant/documents/documentation/2025/) embeds an
architecture diagram this way. The SVGs use Inter from the repository's `fonts/`, which
`typstgen.toml` here adds.
