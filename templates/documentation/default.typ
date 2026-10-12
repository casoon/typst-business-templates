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
  let locale = load-locale(locale, company)
  
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
