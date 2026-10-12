// Contract Template (Vertrag) - Document Layout
// Based on concept/documentation structure

#import "../common/styles.typ": *
#import "../common/footers.typ": document-footer
#import "../common/title-page.typ": parties-title-page

// Document function
#let contract(
  title: none,
  document_number: none,
  contract_type: "Dienstleistungsvertrag",
  parties: (),
  effective_date: none,
  termination_date: none,
  created_at: none,
  status: none,
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
          [#if effective_date != none [Gültig ab: #effective_date]]
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
  set heading(numbering: "§1.")

  show heading.where(level: 1): it => {
    v(20pt)
    text(size: size-xlarge, weight: "bold", fill: accent-color)[#it]
    v(10pt)
  }

  show heading.where(level: 2): it => {
    v(15pt)
    text(size: size-large, weight: "bold")[#it]
    v(8pt)
  }

  // ============================================================================
  // TITLE PAGE
  // ============================================================================

  if show-title-page {
    page(
      margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 50pt),
      header: none,
      footer: none,
    )[
      #parties-title-page(
        company: company,
        logo: logo,
        title: title,
        document-type: contract_type,
        document-number: document_number,
        accent-color: accent-color,
        party1-label: "Auftragnehmer",
        party1-name: if parties.len() > 0 and "company" in parties.at(0) and parties.at(0).company != none { parties.at(0).company } else if parties.len() > 0 and "name" in parties.at(0) { parties.at(0).name } else { none },
        party1-address: if parties.len() > 0 and "address" in parties.at(0) { parties.at(0).address } else { none },
        party2-label: "Auftraggeber",
        party2-name: if parties.len() > 1 and "company" in parties.at(1) and parties.at(1).company != none { parties.at(1).company } else if parties.len() > 1 and "name" in parties.at(1) { parties.at(1).name } else { none },
        party2-address: if parties.len() > 1 and "address" in parties.at(1) { parties.at(1).address } else { none },
        metadata: {
          let meta = (:)
          if effective_date != none {
            meta.insert("Gültig ab", effective_date)
          }
          if termination_date != none {
            meta.insert("Laufzeit bis", termination_date)
          }
          if created_at != none {
            meta.insert("Erstellt am", created_at)
          }
          meta
        },
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

  // ============================================================================
  // SIGNATURE PAGE
  // ============================================================================

  pagebreak()

  v(1fr)

  text(size: size-large, weight: "bold")[Unterschriften]

  v(30pt)

  grid(
    columns: (1fr, 1fr),
    column-gutter: 30pt,
    row-gutter: 80pt,

    ..parties.map(party => 
      box(
        width: 100%,
        stroke: (top: 0.5pt),
        inset: (top: 8pt),
      )[
        #align(left)[
          #if "company" in party and party.company != none [
            #party.company\
          ]
          #if "name" in party [
            #party.name\
          ]
          #v(0.3em)
          #text(size: size-small)[Ort, Datum, Unterschrift]
        ]
      ]
    ).flatten()
  )

  v(1fr)
}
