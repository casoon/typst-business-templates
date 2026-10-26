// Printable content, not interactive PDF forms. Typography inherits from the
// surrounding document unless company is passed explicitly.
#import "../common/styles.typ": get-accent-color, get-font-preset, load-locale

#let writing-field(label, lines: 3, hint: none, company: none) = {
  assert(type(lines) == int and lines >= 0, message: "writing-field.lines: expected non-negative integer")
  set text(..if company == none { (:) } else { (font: get-font-preset(company).body) })
  block(width: 100%, above: 8pt, below: 8pt)[
    #block(sticky: true)[#strong(label) #if hint != none [#linebreak()#hint]]
    #for _ in range(lines) {
      block(height: 7mm, width: 100%, below: 0pt,
        stroke: (bottom: 0.4pt + gray))
    }
  ]
}

#let check-option(label, checked: false) = block(above: 4pt, below: 4pt)[
  #box(width: 10pt, height: 10pt, baseline: 1pt, stroke: 0.6pt,
    if checked { align(center + horizon)[×] }) #h(4pt)#label
]

#let choice-group(label, options: ()) = {
  block(sticky: true, above: 8pt, strong(label))
  for option in options {
    if type(option) == dictionary {
      check-option(option.label, checked: option.at("checked", default: false))
    } else { check-option(option) }
  }
}

#let notice(body, title: none, company: none, accent: auto) = {
  let accent = if accent == auto { get-accent-color(company) } else { accent }
  set text(..if company == none { (:) } else { (font: get-font-preset(company).body) })
  block(width: 100%, inset: 10pt, above: 8pt, below: 8pt,
    stroke: (left: 2pt + accent))[
    #if title != none { block(sticky: true, strong(title)) }
    #body
  ]
}

#let process-phase(title, duration: none, result: none, participation: none,
  company: none, locale: none, body) = {
  let labels = load-locale(locale, company).publication
  notice(title: title, company: company)[
    #body
    #for (label, value) in ((labels.duration, duration), (labels.result, result), (labels.participation, participation)) {
      if value != none and value != "" { block[#strong(label): #value] }
    }
  ]
}

#let quiet-table(headers: (), rows: (), columns: auto) = {
  assert(headers.len() > 0, message: "quiet-table.headers: expected explicit header cells")
  for row in rows { assert(row.len() == headers.len(), message: "quiet-table.rows: cell count must match headers") }
  table(columns: if columns == auto { headers.len() } else { columns },
    inset: 6pt, stroke: (bottom: 0.4pt + gray, rest: none),
    table.header(..headers.map(strong)), ..rows.flatten(),
  )
}

#let priority-tag(level, label: none, company: none, locale: none) = {
  let labels = load-locale(locale, company).publication
  assert(level in ("required", "recommended", "optional"), message: "priority-tag.level: unknown priority")
  box(inset: (x: 6pt, y: 3pt), stroke: 0.5pt + get-accent-color(company),
    strong(if label == none { labels.at(level) } else { label }))
}

#let content-card(title, body, company: none) = notice(title: title, company: company, body)
#let numbered-step(number, title, body, company: none) = process-phase(
  str(number) + ". " + title, company: company, body,
)
