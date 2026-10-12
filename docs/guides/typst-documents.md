---
title: Documents in Typst
description: Write concepts, documentation and other long documents directly in Typst on top of the standard templates, and fork a template to change its layout.
order: 2
---

Long, prose-heavy documents are easier to write in Typst than in JSON. A `.typ` file imports a
template, loads the company data and the locale, and then contains the text:

```typst
#import "/.docgen/templates/concept/default.typ": concept

#let company = json("/data/company.json")
#let locale = json("/locale/de.json")

#show: concept.with(
  title: "Online-Shop Konzept Bio-Hofladen",
  document_number: "KO-2025-002",
  client_name: "Hofbauer's Biohof",
  project_name: "E-Commerce Lösung",
  version: "1.0",
  status: "draft",
  tags: ("E-Commerce", "Shopware", "Bio", "Regional"),
  created_at: "2025-01-15",
  company: company,
  locale: locale,
)

= Ausgangssituation
…
```

This is the beginning of the [concept in the showcase](../../../showcase/concept/). Compile it like
a JSON document:

```sh
docgen compile documents/concepts/2025/concept.typ
```

For `.typ` files `docgen` runs `typst compile --root . --font-path fonts <file>`, so paths
starting with `/` refer to the project root.

## Standard and custom templates

| | Standard templates | Custom templates |
| --- | --- | --- |
| Location | `.docgen/templates/` | `templates/` |
| Updated | on every `docgen compile` / `build`, to match the `docgen` version | never |
| In Git | no (`docgen` adds `.docgen/` to `.gitignore`) | yes |
| Use for | documents with the stock layout | your own branded layout |

Standard templates come out of the `docgen` binary. `docgen template init` extracts them into an
existing project, `docgen template update` does it on demand.

## Forking a template

```sh
docgen template fork invoice --name branded-invoice
```

This copies `.docgen/templates/invoice/` to `templates/branded-invoice/`. Edit
`templates/branded-invoice/default.typ`, commit it, and import it in your documents:

```typst
#import "/templates/branded-invoice/default.typ": invoice
```

A fork is not touched by later `docgen` updates. Changes in the standard template reach it only
if you carry them over yourself. `docgen template list` shows both kinds.

## Using the templates without docgen

The templates are plain Typst. With the repository as project root you can call Typst directly:

```sh
typst compile --root . --font-path fonts templates/invoice/default.typ output/invoice.pdf \
  --input data=/path/to/invoice.json --input company=/path/to/company.json
```
