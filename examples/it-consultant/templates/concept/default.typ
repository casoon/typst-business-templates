// Concept/Design Document Template (Konzept)
// Based on casoon-documents structure
// Supports both JSON input and direct .typ content files
//
// USAGE: The `company` and `locale` parameters must be passed by the document:
//   #let company = json("/data/company.json")
//   #let locale = json("/locale/de.json")
//   #show: concept.with(company: company, locale: locale, ...)

#import "../common/styles.typ": *

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
  body
) = {
  // Use passed company/locale or empty defaults
  let company = if company != none { company } else { (:) }
  let locale = if locale != none { locale } else { (common: (:), concept: (:)) }
  
  // Get branding from company data
  let accent-color = get-accent-color(company)
  let primary-color = get-primary-color(company)
  let fonts = get-font-preset(company)

  set page(
    paper: "a4",
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 100pt),

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

    footer: context [
      #let l-document = if "common" in locale and "document" in locale.common { locale.common.document } else { "Document" }
      #let l-page = if "common" in locale and "page" in locale.common { locale.common.page } else { "Page" }
      #let l-created = if "common" in locale and "created" in locale.common { locale.common.created } else { "Created" }
      #let l-status = if "common" in locale and "status" in locale.common { locale.common.status } else { "Status" }
      
      #line(length: 100%, stroke: border-thin)
      #v(5pt)
      #set text(size: size-xs)
      #grid(
        columns: (125pt, 125pt, 125pt, 125pt),
        column-gutter: 0pt,

        // Column 1: Company Info
        [
          #if "name" in company [#strong[#company.name] #linebreak()]
          #if "address" in company [
            #if "street" in company.address [#company.address.street ]
            #if "house_number" in company.address [#company.address.house_number]
            #linebreak()
            #if "postal_code" in company.address [#company.address.postal_code ]
            #if "city" in company.address [#company.address.city]
          ]
        ],

        // Column 2: Contact
        [
          #if "contact" in company [
            #if "phone" in company.contact [Tel.: #company.contact.phone #linebreak()]
            #if "email" in company.contact [Email: #company.contact.email #linebreak()]
            #if "website" in company.contact [Web: #company.contact.website]
          ]
        ],

        // Column 3: Document Info
        [
          #strong[#l-document:] #linebreak()
          #document_number #linebreak()
          #l-page #counter(page).display()
        ],

        // Column 4: Date
        [
          #strong[#l-created:] #linebreak()
          #if created_at != none [#created_at] #linebreak()
          #l-status: #status
        ],
      )
    ]
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
  // TITLE PAGE (centered layout like casoon-documents)
  // ============================================================================

  page(
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 50pt),
    header: none,
    footer: none,
  )[
    #align(center)[
      #v(50pt)

      // Locale labels with fallbacks
      #let l-concept = if "concept" in locale and "title" in locale.concept { locale.concept.title } else { "Concept" }
      #let l-project = if "common" in locale and "project" in locale.common { locale.common.project } else { "Project" }
      #let l-client = if "common" in locale and "client" in locale.common { locale.common.client } else { "Client" }
      #let l-version = if "common" in locale and "version" in locale.common { locale.common.version } else { "Version" }
      #let l-status = if "common" in locale and "status" in locale.common { locale.common.status } else { "Status" }
      #let l-created = if "common" in locale and "created" in locale.common { locale.common.created } else { "Created" }
      #let l-authors = if "common" in locale and "authors" in locale.common { locale.common.authors } else { "Authors" }

      // Logo
      #if "logo" in company and company.logo != none [
        #let logo-width = if "logo_width" in company { eval(company.logo_width) } else { 150pt }
        #image("/" + company.logo, width: logo-width)
        #v(30pt)
      ]

      // Title
      #text(size: 24pt, weight: "bold")[#title]

      #v(20pt)

      // Document type and number
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[#upper(l-concept)]
      #text(size: size-xlarge, fill: color-text-light)[ · #document_number]

      #v(30pt)

      // Metadata grid
      #grid(
        columns: (auto, auto),
        column-gutter: 20pt,
        row-gutter: 14pt,
        align: (right, left),

        [*#l-project:*], [#project_name],
        [*#l-client:*], [#client_name],
        [*#l-version:*], [#version],
        [*#l-status:*], [#text(fill: accent-color, weight: "bold")[#upper(status)]],
        ..if created_at != none {
          ([*#l-created:*], [#created_at])
        } else { () },
        ..if authors.len() > 0 {
          ([*#l-authors:*], [#authors.join(", ")])
        } else { () },
      )

      #v(1fr)

      // Tags
      #if tags.len() > 0 [
        #for tag in tags [
          #pill(tag)
          #h(8pt)
        ]
        #v(40pt)
      ]
    ]
  ]

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

// Load company and locale from sys.inputs (passed by docgen)
#let _company = if "company" in sys.inputs {
  json(sys.inputs.company)
} else {
  none
}

#let _locale = if "locale" in sys.inputs {
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
  } else if "content" in data {
    eval(data.content, mode: "markup")
  } else {
    []
  }
  
  concept(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    client_name: data.metadata.client_name,
    project_name: data.metadata.project_name,
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
