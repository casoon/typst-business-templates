// Handout Utility Components
// Import this in content files: #import "/.../handout/components.typ": *

#import "../common/styles.typ": *

// Task box with colored number circle
#let aufgabe(nummer, punkte: none, cat-color: rgb("#3b6df2"), body) = {
  block(
    width: 100%,
    inset: (x: 18pt, y: 14pt),
    radius: 8pt,
    fill: white,
    stroke: 0.75pt + rgb("#e2e8f0"),
    above: 14pt,
  )[
    #grid(
      columns: (36pt, 1fr, auto),
      column-gutter: 10pt,
      align: (center + top, left, right + top),
      block(
        width: 36pt,
        height: 36pt,
        radius: 18pt,
        fill: cat-color,
        inset: 0pt,
      )[
        #set align(center + horizon)
        #text(size: 14pt, fill: white, weight: "bold")[#nummer]
      ],
      body,
      if punkte != none {
        block(
          inset: (x: 8pt, y: 4pt),
          radius: 10pt,
          fill: rgb("#f1f5f9"),
          stroke: 0.5pt + rgb("#cbd5e1"),
        )[
          #text(size: size-small, fill: rgb("#475569"), weight: "medium")[#punkte P.]
        ]
      },
    )
  ]
}

// Hint/tip box
#let hinweis(body) = block(
  width: 100%,
  inset: (x: 18pt, y: 12pt),
  radius: 8pt,
  fill: rgb("#fffbeb"),
  stroke: 0.75pt + rgb("#fde68a"),
  above: 10pt,
)[
  #grid(
    columns: (24pt, 1fr),
    column-gutter: 8pt,
    align: (center + top, left),
    text(size: 16pt)[💭],
    [
      #text(size: size-small, weight: "bold", fill: rgb("#92400e"))[Tipp]
      #v(2pt)
      #text(size: size-small)[#body]
    ],
  )
]

// Important info box
#let wichtig(body) = block(
  width: 100%,
  inset: (x: 18pt, y: 12pt),
  radius: 8pt,
  fill: rgb("#fef2f2"),
  stroke: 0.75pt + rgb("#fecaca"),
  above: 10pt,
)[
  #grid(
    columns: (24pt, 1fr),
    column-gutter: 8pt,
    align: (center + top, left),
    text(size: 16pt)[⚠️],
    [
      #text(size: size-small, weight: "bold", fill: rgb("#991b1b"))[Wichtig]
      #v(2pt)
      #text(size: size-small)[#body]
    ],
  )
]

// Answer space with optional lines
#let antwortfeld(hoehe: 80pt, linien: false) = block(
  width: 100%,
  height: hoehe,
  radius: 6pt,
  fill: rgb("#fafafa"),
  stroke: 0.5pt + rgb("#e2e8f0"),
  inset: 10pt,
  above: 8pt,
)[
  #if linien {
    let line-count = int(hoehe / 20pt)
    for i in range(line-count) {
      v(14pt)
      line(length: 100%, stroke: 0.25pt + rgb("#e2e8f0"))
    }
  }
]

// Quote/text block for reading exercises
#let textblock(quelle: none, body) = block(
  width: 100%,
  inset: (x: 18pt, y: 14pt),
  radius: 8pt,
  fill: rgb("#f8fafc"),
  stroke: (left: 3pt + rgb("#94a3b8"), rest: 0.5pt + rgb("#e2e8f0")),
  above: 10pt,
)[
  #set text(size: size-normal)
  #body
  #if quelle != none [
    #v(6pt)
    #text(size: size-small, style: "italic", fill: rgb("#64748b"))[— #quelle]
  ]
]

// Criteria row for assessment rubrics
#let kriterium(name, beschreibung, gewicht: none) = {
  grid(
    columns: if gewicht != none { (2fr, 4fr, auto) } else { (2fr, 5fr) },
    column-gutter: 8pt,
    row-gutter: 0pt,
    text(weight: "bold", size: size-small)[#name],
    text(size: size-small)[#beschreibung],
    if gewicht != none { text(size: size-small, fill: color-text-light)[#gewicht] },
  )
  v(4pt)
  line(length: 100%, stroke: 0.25pt + color-border)
  v(4pt)
}
