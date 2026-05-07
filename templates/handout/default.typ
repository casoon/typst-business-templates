// Handout Template (Handreichung für Lehrkräfte)
// Educational handouts for the Upscale learning platform
// Types: Aufgabenblatt, Methodenguide, Bewertungsraster
//
// Structure:
//   Page 1: Lehrerblatt (teacher notes) — remove before copying
//   Page 2+: Schülerblatt (student material) — visually engaging
//
// USAGE (Package Import):
//   #import "@local/docgen-handout:0.4.2": handout
//   #show: handout.with(
//     title: "Argumentationsanalyse im KI-Zeitalter",
//     handout-type: "Aufgabenblatt",
//     category: "Sprache & Kommunikation",
//     target-group: "Oberstufe",
//   )

#import "../common/styles.typ": *

// ============================================================================
// HANDOUT TEMPLATE
// ============================================================================

#let handout(
  title: none,
  handout-type: "Aufgabenblatt",
  category: none,
  subject: none,
  target-group: "Oberstufe",
  ai-context: none,
  competencies: (),
  duration: none,
  materials: (),
  version: "1.0",
  company: none,
  locale: none,
  logo: none,
  body
) = {
  let company = if company != none { company } else { (:) }
  let accent-color = get-accent-color(company)
  let primary-color = get-primary-color(company)
  let fonts = get-font-preset(company)

  // Category colors mapping
  let category-colors = (
    "Sprache & Kommunikation": rgb("#b45309"),
    "Mathematik & Logik": rgb("#0369a1"),
    "Natur & Technik": rgb("#047857"),
    "Mensch & Gesellschaft": rgb("#b42318"),
    "Denken & Wissen": rgb("#4338ca"),
    "Raum, Umwelt & Welt": rgb("#0f766e"),
  )

  let cat-color = if category != none and category in category-colors {
    category-colors.at(category)
  } else {
    accent-color
  }

  let cat-light = cat-color.lighten(92%)
  let cat-mid = cat-color.lighten(80%)

  set text(font: fonts.body, size: size-medium, lang: get-language(company))
  set par(justify: true, leading: 0.65em)

  // Links
  show link: it => text(fill: rgb("#3b6df2"), it)

  // ========================================================================
  // PAGE 1: LEHRERBLATT (teacher notes)
  // ========================================================================

  set page(
    paper: "a4",
    margin: (left: 45pt, right: 45pt, top: 55pt, bottom: 60pt),
    header: none,
    footer: none,
  )

  // Diagonal "LEHRERBLATT" watermark
  place(center + horizon,
    rotate(-35deg,
      text(size: 72pt, fill: cat-color.lighten(85%), weight: "bold", tracking: 8pt)[LEHRERBLATT]
    )
  )

  // Teacher page header bar
  block(
    width: 100%,
    inset: (x: 20pt, y: 14pt),
    radius: (top-left: 6pt, top-right: 6pt),
    fill: cat-color,
  )[
    #text(size: size-small, fill: white, weight: "bold")[LEHRERBLATT — Nicht an Schüler ausgeben]
  ]

  block(
    width: 100%,
    inset: (x: 20pt, y: 16pt),
    radius: (bottom-left: 6pt, bottom-right: 6pt),
    fill: cat-light,
    stroke: (left: 2pt + cat-color, right: 0.5pt + cat-mid, bottom: 0.5pt + cat-mid),
  )[
    #text(size: size-xs, fill: cat-color, weight: "bold", tracking: 2pt)[#upper(handout-type)]
    #v(4pt)
    #text(size: size-title, weight: "bold")[#title]
    #v(6pt)
    #set text(size: size-normal)
    #grid(
      columns: (auto, auto, auto),
      column-gutter: 20pt,
      row-gutter: 4pt,
      [*Fachbereich:* #category],
      [*Zielgruppe:* #target-group],
      if duration != none [*Dauer:* #duration] else [],
    )
  ]

  v(14pt)

  // AI context box
  if ai-context != none {
    block(
      width: 100%,
      inset: (x: 16pt, y: 14pt),
      radius: 6pt,
      fill: rgb("#f0f4ff"),
      stroke: (left: 3pt + rgb("#3b6df2"), rest: 0.5pt + rgb("#c7d7ff")),
    )[
      #text(size: size-normal, weight: "bold", fill: rgb("#3b6df2"))[KI-Kontext]
      #v(6pt)
      #text(size: size-normal)[#ai-context]
    ]
    v(10pt)
  }

  // Two-column layout: Competencies + Materials
  {
    let has-comps = competencies.len() > 0
    let has-mats = materials.len() > 0

    if has-comps and has-mats {
      grid(
        columns: (1fr, 1fr),
        column-gutter: 12pt,
        block(
          width: 100%,
          inset: (x: 14pt, y: 12pt),
          radius: 6pt,
          fill: color-background,
          stroke: 0.5pt + color-border,
        )[
          #text(size: size-small, weight: "bold", fill: cat-color)[Geförderte Kompetenzen]
          #v(6pt)
          #for comp in competencies [
            #grid(
              columns: (14pt, 1fr),
              column-gutter: 4pt,
              text(size: size-small, fill: cat-color)[✓],
              text(size: size-small)[#comp],
            )
            #v(2pt)
          ]
        ],
        block(
          width: 100%,
          inset: (x: 14pt, y: 12pt),
          radius: 6pt,
          fill: color-background,
          stroke: 0.5pt + color-border,
        )[
          #text(size: size-small, weight: "bold", fill: cat-color)[Benötigte Materialien]
          #v(6pt)
          #for mat in materials [
            #grid(
              columns: (14pt, 1fr),
              column-gutter: 4pt,
              text(size: size-small, fill: color-text-light)[•],
              text(size: size-small)[#mat],
            )
            #v(2pt)
          ]
        ],
      )
    } else if has-comps {
      block(
        width: 100%,
        inset: (x: 14pt, y: 12pt),
        radius: 6pt,
        fill: color-background,
        stroke: 0.5pt + color-border,
      )[
        #text(size: size-small, weight: "bold", fill: cat-color)[Geförderte Kompetenzen]
        #v(6pt)
        #for comp in competencies [
          #grid(
            columns: (14pt, 1fr),
            column-gutter: 4pt,
            text(size: size-small, fill: cat-color)[✓],
            text(size: size-small)[#comp],
          )
          #v(2pt)
        ]
      ]
    } else if has-mats {
      block(
        width: 100%,
        inset: (x: 14pt, y: 12pt),
        radius: 6pt,
        fill: color-background,
        stroke: 0.5pt + color-border,
      )[
        #text(size: size-small, weight: "bold", fill: cat-color)[Benötigte Materialien]
        #v(6pt)
        #for mat in materials [
          #grid(
            columns: (14pt, 1fr),
            column-gutter: 4pt,
            text(size: size-small, fill: color-text-light)[•],
            text(size: size-small)[#mat],
          )
          #v(2pt)
        ]
      ]
    }
  }

  v(14pt)

  // Quick reference for teacher
  block(
    width: 100%,
    inset: (x: 16pt, y: 14pt),
    radius: 6pt,
    fill: rgb("#fff8e1"),
    stroke: (left: 3pt + rgb("#f59e0b"), rest: 0.5pt + rgb("#fde68a")),
  )[
    #text(size: size-normal, weight: "bold", fill: rgb("#92400e"))[Einsatzhinweise]
    #v(6pt)
    #set text(size: size-small)
    #grid(
      columns: (14pt, 1fr),
      column-gutter: 4pt,
      row-gutter: 4pt,
      text(fill: rgb("#92400e"))[→],
      [Ab Seite 2 beginnt das Schülermaterial — diese Seite vor dem Kopieren entfernen.],
      text(fill: rgb("#92400e"))[→],
      [Version #version — bei inhaltlichen Änderungen bitte Versionsnummer erhöhen.],
    )
  ]

  pagebreak()

  // ========================================================================
  // PAGE 2+: SCHÜLERBLATT (student material)
  // ========================================================================

  // Switch to student page layout
  set page(
    paper: "a4",
    margin: (left: 40pt, right: 40pt, top: 70pt, bottom: 55pt),

    header: context {
      let pg = counter(page).get().first()
      if pg > 1 [
        // Colored top bar
        #place(top + left, dx: -40pt, dy: -70pt,
          block(width: 100% + 80pt, height: 8pt, fill: cat-color)
        )
        #v(2pt)
        #grid(
          columns: (1fr, auto),
          align: (left, right),
          text(size: size-normal, fill: cat-color, weight: "bold")[#title],
          text(size: size-small, fill: color-text-light)[#handout-type],
        )
        #v(2pt)
        #line(length: 100%, stroke: 0.5pt + cat-mid)
      ]
    },

    footer: context {
      let pg = counter(page).get().first()
      if pg > 1 [
        #line(length: 100%, stroke: 0.25pt + color-border)
        #v(4pt)
        #set text(size: size-xs, fill: color-text-light)
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          [#category #if subject != none [· #subject]],
          [Seite #counter(page).display()],
          [Language Toolbox],
        )
      ]
    },

    background: context {
      let pg = counter(page).get().first()
      if pg > 1 {
        // Subtle decorative corner element
        place(bottom + right, dx: 10pt, dy: 10pt,
          circle(radius: 40pt, fill: cat-color.lighten(95%))
        )
      }
    },
  )

  // Student title block
  block(
    width: 100%,
    inset: 0pt,
    above: 0pt,
  )[
    // Big category-colored title area
    #block(
      width: 100%,
      inset: (x: 24pt, y: 20pt),
      radius: 8pt,
      fill: cat-light,
      stroke: (left: 4pt + cat-color, rest: none),
    )[
      #text(size: size-xs, fill: cat-color, weight: "bold", tracking: 3pt)[#upper(handout-type)]
      #v(6pt)
      #text(size: 20pt, weight: "bold")[#title]
      #v(8pt)
      #grid(
        columns: (auto, auto, auto),
        column-gutter: 16pt,
        if category != none [
          #grid(
            columns: (auto, auto),
            column-gutter: 4pt,
            align: horizon,
            circle(radius: 4pt, fill: cat-color),
            text(size: size-normal)[#category],
          )
        ],
        if duration != none [
          #text(size: size-normal)[⏱ #duration]
        ],
        text(size: size-normal, fill: color-text-light)[#target-group],
      )
    ]
  ]

  v(14pt)

  // Student-facing AI hint (friendly, non-threatening)
  if ai-context != none {
    block(
      width: 100%,
      inset: (x: 18pt, y: 14pt),
      radius: 8pt,
      fill: rgb("#f0f4ff"),
      stroke: 0.75pt + rgb("#c7d7ff"),
    )[
      #grid(
        columns: (28pt, 1fr),
        column-gutter: 8pt,
        align: (center + horizon, left),
        block(
          width: 28pt,
          height: 28pt,
          radius: 14pt,
          fill: rgb("#3b6df2"),
          inset: 0pt,
        )[
          #set align(center + horizon)
          #text(size: 14pt, fill: white)[💡]
        ],
        [
          #text(size: size-normal, weight: "bold", fill: rgb("#1e40af"))[Hinweis zur KI-Nutzung]
          #v(3pt)
          #text(size: size-small)[#ai-context]
        ],
      )
    ]
    v(12pt)
  }

  // Heading styles for student content — more visual
  show heading.where(level: 1): it => {
    v(18pt)
    block(
      width: 100%,
      below: 12pt,
    )[
      #block(
        width: 100%,
        inset: (left: 14pt, y: 8pt),
        radius: 4pt,
        stroke: (left: 3pt + cat-color, rest: none),
        fill: cat-color.lighten(95%),
      )[
        #text(size: size-xxlarge, weight: "bold", fill: cat-color)[#it.body]
      ]
    ]
  }

  show heading.where(level: 2): it => {
    v(14pt)
    block(
      below: 8pt,
    )[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 8pt,
        align: horizon,
        block(width: 3pt, height: 16pt, radius: 1.5pt, fill: cat-color),
        text(size: size-xlarge, weight: "bold")[#it.body],
      )
    ]
  }

  show heading.where(level: 3): it => {
    v(10pt)
    block(
      below: 6pt,
      text(size: size-large, weight: "bold", fill: cat-color.darken(10%))[#it.body]
    )
  }

  // Tables with rounded feel and category color
  set table(
    stroke: 0.5pt + color-border,
    inset: (x: 10pt, y: 8pt),
    fill: (x, y) => if y == 0 { cat-color.lighten(88%) }
  )
  show table: it => block(radius: 4pt, clip: true, it)

  // ========================================================================
  // STUDENT CONTENT
  // ========================================================================

  body
}

// ============================================================================
// UTILITY COMPONENTS (for use in content files)
// ============================================================================

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
      // Colored number circle
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
      // Task body
      body,
      // Points badge
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

// Hint/tip box — friendly for students
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

// Answer space with lines
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

// ============================================================================
// JSON-BASED USAGE (via docgen CLI)
// ============================================================================

#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

#let _company = if data != none and "company" in sys.inputs {
  let c = json(sys.inputs.company)
  if "logo" in c and c.logo != none {
    let logo-width = if "logo_width" in c { eval(c.logo_width) } else { 120pt }
    c.insert("_logo_image", image("/" + c.logo, width: logo-width))
  }
  c
} else {
  none
}

#let _locale = if data != none and "locale" in sys.inputs {
  json(sys.inputs.locale)
} else {
  none
}

#if data != none {
  let content-body = if "content_file" in data {
    include(data.content_file)
  } else if "content" in data and "markdown" in data.content {
    eval(data.content.markdown, mode: "markup")
  } else {
    []
  }

  handout(
    title: data.metadata.title,
    handout-type: if "handout_type" in data.metadata { data.metadata.handout_type } else { "Aufgabenblatt" },
    category: if "category" in data.metadata { data.metadata.category } else { none },
    subject: if "subject" in data.metadata { data.metadata.subject } else { none },
    target-group: if "target_group" in data.metadata { data.metadata.target_group } else { "Oberstufe" },
    ai-context: if "ai_context" in data.metadata { data.metadata.ai_context } else { none },
    competencies: if "competencies" in data.metadata { data.metadata.competencies } else { () },
    duration: if "duration" in data.metadata { data.metadata.duration } else { none },
    materials: if "materials" in data.metadata { data.metadata.materials } else { () },
    version: if "version" in data.metadata { data.metadata.version } else { "1.0" },
    company: _company,
    locale: _locale,
    content-body
  )
}
