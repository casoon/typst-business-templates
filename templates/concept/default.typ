// Concept/Design Document Template (Konzept)
// Based on casoon-documents structure
//
// USAGE (Package Import):
//   #import "@local/business-templates:0.1.0": concept
//   #let company = json("/data/company.json")
//   #show: concept.with(
//     title: "My Concept",
//     company: company,
//     logo: image("/data/logo.png"),  // optional, overrides company.logo
//   )

#import "../common/styles.typ": *
#import "../common/formatting.typ": prose-metadata
#import "../common/title-page.typ": document-title-page

// Document function for flexible use
#let concept(
  title: none,
  document_number: none,
  client_name: none,
  project_name: none,
  version: "1.0",
  status: "Entwurf",
  tags: (),
  created_at: none,
  authors: (),
  show_toc: true,
  company: none,
  locale: none,
  logo: none,
  show-title-page: true,
  show-footer: true,
  body
) = {
  // Use passed company/locale or empty defaults
  let company = if company != none { 
    // Pre-load logo image if logo path is specified (for package-import mode)
    if "logo" in company and company.logo != none and "_logo_image" not in company {
      let logo-width = if "logo_width" in company { eval(company.logo_width) } else { 150pt }
      company.insert("_logo_image", image(logo-source(company.logo), width: logo-width))
    }
    company
  } else { 
    (:) 
  }
  set document(..prose-metadata(company, title, document_number, created_at, authors: authors))
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
          [#title],
          [Version #version]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: if show-footer { context {
      if counter(page).get().first() > 1 [
        #line(length: 100%, stroke: border-thin)
        #v(0.2em)
        #set text(size: size-small)
        #let l-page = if "common" in locale and "page" in locale.common { locale.common.page } else { "Page" }
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          [#client_name],
          [#l-page #counter(page).display()],
          [#created_at]
        )
      ]
    } } else { none }
  )

  set text(font: fonts.body, size: size-medium, lang: get-language(company))
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  // Heading styles
  show heading.where(level: 1): it => {
    v(20pt)
    text(size: size-xxlarge, weight: "bold", fill: accent-color)[#it]
    v(10pt)
  }

  show heading.where(level: 2): it => {
    v(15pt)
    text(size: size-xlarge, weight: "bold")[#it]
    v(8pt)
  }

  show heading.where(level: 3): it => {
    v(10pt)
    text(size: size-large, weight: "bold")[#it]
    v(5pt)
  }

  // ============================================================================
  // TITLE PAGE
  // ============================================================================

  // Locale labels with fallbacks
  let l-concept = if "concept" in locale and "title" in locale.concept { locale.concept.title } else { "Concept" }
  let l-project = if "common" in locale and "project" in locale.common { locale.common.project } else { "Project" }
  let l-client = if "common" in locale and "client" in locale.common { locale.common.client } else { "Client" }
  let l-version = if "common" in locale and "version" in locale.common { locale.common.version } else { "Version" }
  let l-status = if "common" in locale and "status" in locale.common { locale.common.status } else { "Status" }
  let l-created = if "common" in locale and "created" in locale.common { locale.common.created } else { "Created" }
  let l-authors = if "common" in locale and "authors" in locale.common { locale.common.authors } else { "Authors" }

  // Build metadata dictionary
  let meta = (
    (l-project, project_name),
    (l-client, client_name),
    (l-version, version),
    (l-status, text(fill: accent-color, weight: "bold")[#upper(status)]),
  )
  
  if created_at != none {
    meta.push((l-created, created_at))
  }
  
  if authors.len() > 0 {
    meta.push((l-authors, authors.join(", ")))
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
        document-type: l-concept,
        document-number: document_number,
        accent-color: accent-color,
        metadata: meta,
        tags: tags,
      )
    ]

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
