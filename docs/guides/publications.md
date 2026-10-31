---
title: Publications and printable forms
description: Compact A4 guides, landscape brochures and reusable printed form components.
order: 5
---

## Compact A4 publication

```typst
#import "@local/business-templates:0.2.0": publication, writing-field, choice-group
#show: publication.with(
  title: "Project briefing",
  subtitle: "Preparation for the first meeting",
  document-type: "Briefing",
  document-number: "BRIEF-2026-001",
  created: "2026-10-26",
  language: "en",
  company: (name: "Example Studio", contact: (email: "hello@example.invalid")),
)

= Objectives
#writing-field("What should this project achieve?", lines: 4, hint: "Name an observable outcome.")
#choice-group("Available material", options: ([Brief], [Schedule]))
```

Content starts on the first page. The compact company/type/number header repeats on every page;
the title and subtitle appear once in the body. A footer repeats the company name, email and
current/total page count. Header/footer text is a PDF artifact in Typst. Keep essential
information in the body as well. Titles and content wrap in normal document flow.

`company` uses the existing font preset and accent helpers. `language` overrides
`company.language` for this document; `locale` supplies partial label overrides. Language
selection does not select a country or tax regime. Pass `logo: image(...)` as content, or load
image bytes into `company.logo`. A logo in the repeating header is decorative; meaningful
company identity belongs in body text or metadata. Keep logos to about 9 mm height.

`title`, `subtitle`, `document-type`, `document-number`, `created`, `logo` and `company` may be
omitted. `authors: ()` defaults to the company name for PDF metadata. An omitted `created`
leaves the document date absent. The document number is stored separately from the title in
PDF keywords; see [Migration](../migration/#document-identity).

## Printable components

All helpers are exported from the package. They inherit text styles. Passing `company:` to
helpers that accept it selects its fonts/accent; pass the same company as the frame for a
consistent design. Labels and arbitrary bodies can be ordinary Typst content.

| Function | Parameters |
| --- | --- |
| `writing-field(label, ...)` | `lines: 3` (non-negative integer), `hint: none`, `company: none` |
| `check-option(label, ...)` | `checked: false` |
| `choice-group(label, ...)` | `options: ()`, each a label or `(label: [...], checked: true)` |
| `notice(body, ...)` | `title: none`, `company: none`, `accent: auto` |
| `process-phase(title, body, ...)` | `duration`, `result`, `participation`, `company`, `locale` |
| `quiet-table(...)` | `headers: ()`, `rows: ()`, `columns: auto` |
| `priority-tag(level, ...)` | `level`: `required`, `recommended`, `optional`; `label`, `company`, `locale` |
| `content-card(title, body, ...)` | `company: none` |
| `numbered-step(number, title, body, ...)` | `company: none` |

`process-phase` and `priority-tag` use translated default labels. For example:

```typst
#import "@local/business-templates:0.2.0": process-phase, quiet-table, priority-tag
#priority-tag("required", company: (language: "en"))
#process-phase("Review", duration: "One meeting", result: "Agreed scope",
  participation: "Project sponsor", company: (language: "en"))[
  Record the decisions and the next action.
]
#quiet-table(headers: ([Deliverable], [Reviewer]), rows: (([Brief], [Sponsor]),))
```

Tables require explicit, repeating header cells and matching row lengths. Priorities always
include text. Lines and boxes are printed marks, **not interactive AcroForm fields**. Checked
options are marked with a cross; labels remain normal readable text. No form submission,
keyboard interaction or electronic signature is provided.

## Landscape brochure

`brochure` uses the same parameters and frame as `publication`, with a 297 × 210 mm landscape
A4 default. `publication` defaults to 210 × 297 mm. Both accept explicit `width` and `height`;
there is no automatic slide sizing, content shrinking or poster layout.

```typst
#import "@local/business-templates:0.2.0": brochure, numbered-step
#show: brochure.with(title: "Project overview", language: "en",
  foreground: white, background: rgb("#182C39"), accent: rgb("#C4E6FC"))
#numbered-step(1, "Prepare")[Collect the source material.]
#pagebreak()
= Review
Record the agreed next steps.
```

Background defaults to white and foreground to black. Dark pages require explicit foreground,
background and accent values; colors are not automatically adjusted. The example dark palette
has readable text contrast, but arbitrary caller colors and image content need their own review.
`numbered-step` inherits body text color; pass company data to match component accents.

Content flows onto following pages. For a fixed number of brochure pages, add deliberate
`pagebreak()` calls and shorten overflow rather than expecting automatic scaling. Very tall
logos, oversized unbreakable content, long unbreakable identifiers and excessive header/footer
text can exceed the reserved space. Reduce these or adjust the document content. A publication
is a flowing document rather than a general presentation framework.

## Checks and limits

Run `scripts/check.sh` with typstgen 0.6.2 and Python packages `jsonschema`, `referencing`, `pypdf`.
The package checks compile the A4/landscape examples with `--pdf-standard ua-1`, inspect table
header tags, document identity, reading order samples and continuation pages. Typst marks
repeated headers, footers, lines and shapes as artifacts automatically. The publication heading
show rule preserves the underlying heading elements.

PDF/UA compilation and these structural checks do not constitute a complete accessibility
certification. Review the resulting reading order, contrast, alternative text and content for
each actual document, particularly after adding custom tables, images or complex layouts.
The synthetic examples in `examples/publication/` exercise long titles, optional metadata,
page breaks, phased tasks and extended prose; no customer documents are required.
