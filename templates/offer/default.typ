// Offer Template (Angebot) - CASOON Layout
// Based on invoice template layout

#import "../common/formatting.typ": format_german_date, format_money
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, offer-metadata
#import "../common/footers.typ": accounting-footer
#import "../common/unit-formatter.typ": format-unit
#import "../common/totals-summary.typ": invoice-totals

// Load data from input parameter
#let data = json(sys.inputs.data)

// Load company data
#let company = json("/data/company.json")

#let show-footer = if "metadata" in data and "show_footer" in data.metadata { data.metadata.show_footer } else { true }

#set page(
  paper: "a4",
  margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),
  footer: if show-footer { accounting-footer(company: company) }
)

#set text(
  font: "Helvetica",
  size: 10pt,
  lang: company.language
)

// ============================================================================
// HEADER SECTION
// ============================================================================

#accounting-header(
  company: company,
  metadata_content: offer-metadata(
    offer_number: data.metadata.offer_number,
    offer_date: data.metadata.offer_date,
    valid_until: if "valid_until" in data.metadata { data.metadata.valid_until } else { none },
    customer_number: if "customer_number" in data.metadata { data.metadata.customer_number } else { none },
  )
)

// ============================================================================
// RECIPIENT ADDRESS (DIN 5008 position at y=160)
// ============================================================================

#din5008-address-block(
  company: company,
  recipient: data.recipient,
)

// ============================================================================
// SALUTATION SECTION
// ============================================================================

#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold")[Angebot]

  #v(3pt)

  #if "salutation" in data and data.salutation != none [
    #data.salutation.greeting\
    #v(3pt)
    #if "introduction" in data.salutation and data.salutation.introduction != none [
      #data.salutation.introduction
    ]
  ]

  #v(3pt)
]

// ============================================================================
// ITEMS TABLE SECTION
// ============================================================================

// Table header
#block[
  #set text(size: 8pt, font: "Helvetica")

  #grid(
    columns: (35pt, 225pt, 45pt, 45pt, 80pt, 90pt),
    align: (center, left, center, center, right, right),
    row-gutter: 8pt,

    text(weight: "bold")[Pos.],
    text(weight: "bold")[Bezeichnung],
    text(weight: "bold")[Menge],
    text(weight: "bold")[Einh.],
    text(weight: "bold")[Einzelpreis],
    text(weight: "bold")[Summe],
  )

  #v(5pt)
  #line(length: 100%, stroke: 0.5pt)
  #v(5pt)
]

// Table rows
#for item in data.items [
  #block[
    #set text(size: 8pt, font: "Helvetica")

    #grid(
      columns: (35pt, 225pt, 45pt, 45pt, 80pt, 90pt),
      align: (center, left, center, center, right, right),
      row-gutter: 5pt,

      [#item.position],
      [
        #text(weight: "bold")[#item.title]\
        #item.description
      ],
      [#item.quantity],
      [#format-unit(item.unit)],
      [#format_money(item.unit_price.amount) EUR],
      [#text(weight: "bold")[#format_money(item.total.amount) EUR]],
    )

    // Sub-items as continuous text spanning all columns, aligned with description
    #if "sub_items" in item and item.sub_items.len() > 0 [
      #v(2pt)
      #pad(left: 35pt)[
        #block[
          #set text(size: 7pt, font: "Helvetica")
          #set par(leading: 0.5em)
          #for (i, sub_item) in item.sub_items.enumerate() [
            #let cleaned = if sub_item.starts-with("- ") {
              sub_item.slice(2)
            } else {
              sub_item
            }
            #if i > 0 [ • ]
            #cleaned
          ]
        ]
      ]
    ]

    #v(5pt)
  ]
]

#v(5pt)

// Table footer line
#line(length: 100%, stroke: 0.5pt)

#v(5pt)

// Totals section (right-aligned)
#invoice-totals(
  subtotal: data.totals.subtotal,
  vat_breakdown: if "vat_breakdown" in data.totals { data.totals.vat_breakdown } else { () },
  total: data.totals.total,
)

#v(5pt)

// ============================================================================
// CLOSING SECTION
// ============================================================================

#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(leading: 0.65em)

  #data.terms.validity

  #v(8pt)

  #if "payment_terms" in data.terms and data.terms.payment_terms != none [
    *Zahlungsbedingungen:* #data.terms.payment_terms

    #v(8pt)
  ]

  #if "delivery_terms" in data.terms and data.terms.delivery_terms != none [
    *Lieferbedingungen:* #data.terms.delivery_terms

    #v(8pt)
  ]

  Mit freundlichen Grüßen

  #v(20pt)

  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner
  ] else [
    #company.name
  ]
]

// ============================================================================
// AGB - NEW PAGE
// ============================================================================

#if "additional_terms" in data.terms and data.terms.additional_terms != none [
  #pagebreak()

  #set text(size: 10pt, font: "Helvetica")

  #v(20pt)

  #text(size: 14pt, weight: "bold")[Allgemeine Geschäftsbedingungen]

  #v(15pt)

  #set text(size: 9pt)
  #set par(leading: 0.8em, justify: true)

  #for (i, term) in data.terms.additional_terms.enumerate() [
    #grid(
      columns: (20pt, 1fr),
      column-gutter: 8pt,
      align: (left, left),
      [#(i + 1).], [#term]
    )
    #v(8pt)
  ]
]
