// Specification Template (Spezifikation/Pflichtenheft) - Document Layout
// Technical and functional requirements documentation
// Based on documentation structure with enhanced code support

#import "../common/styles.typ": *
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
  let locale = if locale != none { locale } else { (common: (:), specification: (:)) }
  
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

// JSON workflow
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

#let _company = if data != none and "company" in sys.inputs {
  let c = json(sys.inputs.company)
  if "logo" in c and c.logo != none {
    let logo-width = if "logo_width" in c { eval(c.logo_width) } else { 150pt }
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
  let created-date = if "created_at" in data.metadata {
    if type(data.metadata.created_at) == dictionary and "date" in data.metadata.created_at {
      data.metadata.created_at.date
    } else {
      data.metadata.created_at
    }
  } else {
    none
  }

  let updated-date = if "last_updated" in data.metadata {
    if type(data.metadata.last_updated) == dictionary and "date" in data.metadata.last_updated {
      data.metadata.last_updated.date
    } else {
      data.metadata.last_updated
    }
  } else {
    none
  }
  
  let content-body = if "content_file" in data {
    include(data.content_file)
  } else if "content" in data {
    eval("[" + data.content + "]", mode: "code")
  } else {
    []
  }
  
  specification(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    subject: if "subject" in data.metadata { data.metadata.subject } else { none },
    client_name: if "client_name" in data.metadata { data.metadata.client_name } else { none },
    project_name: if "project_name" in data.metadata { data.metadata.project_name } else { none },
    version: if "version" in data.metadata { data.metadata.version } else { "1.0" },
    status: if "status" in data.metadata { data.metadata.status } else { "Entwurf" },
    tags: if "tags" in data.metadata { data.metadata.tags } else { () },
    created_at: created-date,
    last_updated: updated-date,
    authors: if "authors" in data.metadata { data.metadata.authors } else { () },
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { true },
    company: _company,
    locale: _locale,
    content-body
  )
}
