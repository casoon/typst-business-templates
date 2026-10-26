// Specification Template (Spezifikation/Pflichtenheft) - Document Layout
// Technical and functional requirements documentation
// Based on documentation structure with enhanced code support

#import "../common/styles.typ": *
#import "../common/formatting.typ": prose-metadata
#import "../common/footers.typ": document-footer
#import "../common/title-page.typ": document-title-page

// Document function
#let specification(
  title: none,
  document_number: none,
  subject: none,
  client_name: none,
  project_name: none,
  version: "1.0",
  status: "Entwurf",
  tags: (),
  authors: (),
  created_at: none,
  last_updated: none,
  show_toc: true,
  company: none,
  locale: none,
  logo: none,
  show-title-page: true,
  show-footer: true,
  body
) = {
  let company = if company != none { company } else { (:) }
  set document(..prose-metadata(company, title, document_number, created_at, authors: authors))
  let locale = load-locale(locale, company)
  
  let accent-color = get-accent-color(company)
  let primary-color = get-primary-color(company)
  let fonts = get-font-preset(company)

  set page(
    paper: "a4",
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),

    header: context [
      #if counter(page).get().first() > 1 [
        #set text(size: size-small)
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          [#document_number],
          [#if subject != none [#subject] else [#title]],
          [Version #version]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: if show-footer { document-footer(
      company: company,
      locale: locale,
      document_number: document_number,
      status: status,
      version: version,
      last_updated: last_updated,
    ) } else { none }
  )

  set text(font: fonts.body, size: size-medium, lang: get-language(company))
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  // Enhanced code block styling
  show raw.where(block: true): it => {
    set text(size: size-small, font: fonts.mono)
    block(
      fill: color-background,
      inset: 1em,
      radius: 3pt,
      width: 100%,
      stroke: border-thin + color-border,
      it
    )
  }

  // Inline code styling
  show raw.where(block: false): it => {
    box(
      fill: color-background,
      inset: (x: 3pt, y: 0pt),
      radius: 2pt,
      text(size: size-small, font: fonts.mono, it)
    )
  }

  // Heading styles
  show heading.where(level: 1): it => {
    v(25pt)
    text(size: size-xxlarge, weight: "bold", fill: accent-color)[#it]
    v(12pt)
  }

  show heading.where(level: 2): it => {
    v(18pt)
    text(size: size-xlarge, weight: "bold")[#it]
    v(8pt)
  }

  show heading.where(level: 3): it => {
    v(12pt)
    text(size: size-large, weight: "bold")[#it]
    v(6pt)
  }

  // Requirements boxes (can be used via custom markup)
  // Example: #requirement[REQ-001][High][User login must support OAuth2]
  let requirement(id, priority, content) = {
    block(
      fill: if priority == "High" { rgb("#fff3cd") } else if priority == "Medium" { rgb("#d1ecf1") } else { rgb("#f8f9fa") },
      stroke: border-normal + if priority == "High" { rgb("#ffc107") } else if priority == "Medium" { rgb("#17a2b8") } else { color-border },
      radius: 4pt,
      inset: 1em,
      width: 100%,
    )[
      #grid(
        columns: (80pt, 60pt, 1fr),
        align: (left, left, left),
        column-gutter: 10pt,
        [#text(weight: "bold", font: fonts.mono)[#id]],
        [#text(weight: "bold", fill: if priority == "High" { rgb("#856404") } else if priority == "Medium" { rgb("#0c5460") } else { color-text })[#priority]],
        [#content]
      )
    ]
  }

  // Links
  show link: it => text(fill: rgb("#0066cc"), it)

  // Tables
  set table(
    stroke: border-thin + color-border,
    fill: (x, y) => if y == 0 { color-background }
  )

  // ============================================================================
  // TITLE PAGE
  // ============================================================================

  // Extract locale labels
  let spec-label = if "specification" in locale and locale.specification != none and "document_type" in locale.specification {
    locale.specification.document_type
  } else {
    "SPEZIFIKATION"
  }

  // Build metadata dictionary
  let metadata-dict = (:)
  if project_name != none {
    metadata-dict.insert("Projekt", project_name)
  }
  if client_name != none {
    metadata-dict.insert("Auftraggeber", client_name)
  }
  metadata-dict.insert("Version", version)
  metadata-dict.insert("Status", text(fill: accent-color, weight: "bold")[#upper(status)])
  if subject != none {
    metadata-dict.insert("Betreff", subject)
  }
  if created_at != none {
    metadata-dict.insert("Erstellt", created_at)
  }
  if last_updated != none {
    metadata-dict.insert("Aktualisiert", last_updated)
  }
  if authors.len() > 0 {
    metadata-dict.insert("Autoren", authors.join(", "))
  }

  if show-title-page {
    page(
      margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 50pt),
      header: none,
      footer: none,
    )[
      #document-title-page(
        company: company,
        logo: logo,
        title: title,
        document-type: spec-label,
        document-number: document_number,
        accent-color: accent-color,
        metadata: metadata-dict,
        tags: tags,
      )
    ]

    pagebreak()
  }

  // ============================================================================
  // REVISION HISTORY (optional)
  // ============================================================================

  // Can be added via content

  // ============================================================================
  // TABLE OF CONTENTS
  // ============================================================================

  if show_toc {
    [
      #outline(
        title: [
          #set text(size: size-xxlarge, weight: "bold")
          Inhaltsverzeichnis
        ],
        indent: 1em,
        depth: 3,
      )

      #pagebreak()
    ]
  }

  // ============================================================================
  // MAIN CONTENT
  // ============================================================================

  body
}
