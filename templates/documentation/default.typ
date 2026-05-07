// Documentation Template (Dokumentation)
// Technical documentation for projects, APIs, systems, etc.
// Based on casoon-documents structure
// Supports both JSON input and direct .typ content files
//
// USAGE (Package Import):
//   #import "@local/docgen-documentation:0.4.2": documentation
//   #let company = json("/data/company.json")
//   #let locale = json("/locale/de.json")
//   #show: documentation.with(
//     title: "My Documentation",
//     company: company,
//     locale: locale,
//     logo: image("/data/logo.png"),  // Logo as image, not path
//   )

#import "../common/styles.typ": *
#import "../common/footers.typ": document-footer
#import "../common/title-page.typ": document-title-page

// Document function for flexible use
#let documentation(
  title: none,
  document_number: none,
  subject: none,
  client_name: none,
  project_name: none,
  doc_type: "Dokumentation",
  version: "1.0",
  status: "Entwurf",
  tags: (),
  authors: (),
  created_at: none,
  show_toc: true,
  company: none,
  locale: none,
  logo: none,
  show-title-page: true,
  show-footer: true,
  body
) = {
  // Use passed company/locale or empty defaults
  let company = if company != none { company } else { (:) }
  let locale = if locale != none { locale } else { (common: (:), documentation: (:)) }
  
  // Get branding from company data
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
      created_at: created_at,
      status: status,
    ) } else { none }
  )

  set text(font: fonts.body, size: size-medium, lang: get-language(company))
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  // Code block styling
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

  // Locale labels with fallbacks
  let l-documentation = if "documentation" in locale and "title" in locale.documentation { locale.documentation.title } else { doc_type }
  let l-project = if "common" in locale and "project" in locale.common { locale.common.project } else { "Project" }
  let l-client = if "common" in locale and "client" in locale.common { locale.common.client } else { "Client" }
  let l-version = if "common" in locale and "version" in locale.common { locale.common.version } else { "Version" }
  let l-status = if "common" in locale and "status" in locale.common { locale.common.status } else { "Status" }
  let l-created = if "common" in locale and "created" in locale.common { locale.common.created } else { "Created" }
  let l-authors = if "common" in locale and "authors" in locale.common { locale.common.authors } else { "Authors" }

  // Build metadata dictionary
  let meta = ()
  
  if project_name != none {
    meta.push((l-project, project_name))
  }
  
  if client_name != none {
    meta.push((l-client, client_name))
  }
  
  meta.push((l-version, version))
  meta.push((l-status, text(fill: accent-color, weight: "bold")[#upper(status)]))
  
  if created_at != none {
    meta.push((l-created, created_at))
  }
  
  if authors.len() > 0 {
    meta.push((l-authors, authors.join(", ")))
  }

  if show-title-page {
    document-title-page(
      company: company,
      logo: logo,
      title: title,
      document-type: l-documentation,
      document-number: document_number,
      accent-color: accent-color,
      metadata: meta,
      tags: tags,
    )

    pagebreak()
  }

  // ============================================================================
  // TABLE OF CONTENTS
  // ============================================================================

  if show_toc {
    let l-toc = if "common" in locale and "table_of_contents" in locale.common { locale.common.table_of_contents } else { "Table of Contents" }
    [
      #outline(
        title: [
          #set text(size: size-xxlarge, weight: "bold")
          #l-toc
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

// For JSON-based usage (via docgen CLI)
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

// Only load company/locale when in JSON workflow (data != none)
// This prevents sys.inputs errors when using package import directly
#let _company = if data != none and "company" in sys.inputs {
  let c = json(sys.inputs.company)
  // Load logo image if logo path is specified
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
  
  let content-body = if "content_file" in data {
    include(data.content_file)
  } else if "content" in data and "markdown" in data.content {
    eval(data.content.markdown, mode: "markup")
  } else {
    []
  }
  
  documentation(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    subject: if "subject" in data.metadata { data.metadata.subject } else { none },
    client_name: if "client_name" in data.metadata { data.metadata.client_name } else { none },
    project_name: if "project_name" in data.metadata { data.metadata.project_name } else { none },
    doc_type: if "doc_type" in data.metadata { data.metadata.doc_type } else { "Dokumentation" },
    version: if "version" in data.metadata { data.metadata.version } else { "1.0" },
    status: if "status" in data.metadata { data.metadata.status } else { "Entwurf" },
    tags: if "tags" in data.metadata { data.metadata.tags } else { () },
    created_at: created-date,
    authors: if "authors" in data.metadata { data.metadata.authors } else { () },
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { true },
    company: _company,
    locale: _locale,
    content-body
  )
}
