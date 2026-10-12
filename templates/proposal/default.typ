// Proposal Template (Projektvorschlag) - Document Layout
// Creative project proposals and pitch documents
// Based on concept structure with enhanced visual elements

#import "../common/styles.typ": *
#import "../common/footers.typ": document-footer
#import "../common/title-page.typ": enhanced-title-page

// Document function
#let proposal(
  title: none,
  document_number: none,
  client_name: none,
  project_name: none,
  budget: none,
  timeline: none,
  version: "1.0",
  status: "Angebot",
  tags: (),
  created_at: none,
  valid_until: none,
  authors: (),
  show_toc: true,
  company: none,
  locale: none,
  logo: none,
  show-title-page: true,
  show-footer: true,
  body
) = {
  let company = if company != none { company } else { (:) }
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
          [#title],
          [#if valid_until != none [Gültig bis: #valid_until]]
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

  if show-title-page {
    page(
      margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 50pt),
      header: none,
      footer: none,
    )[
      #enhanced-title-page(
        company: company,
        logo: logo,
        title: title,
        document-type: "PROJEKTVORSCHLAG",
        document-number: document_number,
        accent-color: accent-color,
        info-box-content: align(left)[
          #grid(
            columns: (auto, auto),
            column-gutter: 30pt,
            row-gutter: 14pt,
            align: (right, left),

            [*Projekt:*], [#text(size: size-large, weight: "bold")[#project_name]],
            [*Auftraggeber:*], [#client_name],
            ..if budget != none {
              ([*Budget:*], [#text(fill: accent-color, weight: "bold")[#budget]])
            } else { () },
            ..if timeline != none {
              ([*Zeitrahmen:*], [#timeline])
            } else { () },
            [*Version:*], [#version],
            [*Status:*], [#text(fill: accent-color, weight: "bold")[#upper(status)]],
            ..if created_at != none {
              ([*Datum:*], [#created_at])
            } else { () },
            ..if valid_until != none {
              ([*Gültig bis:*], [#valid_until])
            } else { () },
          )
        ],
        tags: tags,
        authors: if authors.len() > 0 { "Erstellt von: " + authors.join(", ") } else { none },
      )
    ]
    
    pagebreak()
  }

  // ============================================================================
  // TABLE OF CONTENTS
  // ============================================================================

  if show_toc {
    [
      #outline(
        title: [
          #set text(size: size-xxlarge, weight: "bold")
          Inhalt
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

  // ============================================================================
  // NEXT STEPS / CALL TO ACTION
  // ============================================================================

  pagebreak()

  v(50pt)

  align(center)[
    #text(size: size-xxlarge, weight: "bold", fill: accent-color)[
      Nächste Schritte
    ]

    #v(30pt)

    #box(
      width: 80%,
      stroke: border-normal + accent-color,
      radius: 6pt,
      inset: 1.5em,
    )[
      #align(left)[
        #set text(size: size-normal)
        
        Wir freuen uns darauf, dieses Projekt mit Ihnen umzusetzen.

        #v(15pt)

        *Kontakt:*\
        #if "contact" in company [
          #if "email" in company.contact [
            Email: #link("mailto:" + company.contact.email)[#company.contact.email]\
          ]
          #if "phone" in company.contact [
            Telefon: #company.contact.phone
          ]
        ]

        #v(15pt)

        #if valid_until != none [
          *Gültigkeit:* Dieses Angebot ist gültig bis #valid_until
        ]
      ]
    ]
  ]

  v(1fr)
}
