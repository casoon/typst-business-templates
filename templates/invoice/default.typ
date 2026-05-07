// Invoice Template (Rechnung) - CASOON Layout
// Based on casoon-documents simple.typ template

#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": format_german_date, format_money
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, invoice-metadata
#import "../common/unit-formatter.typ": format-unit
#import "../common/totals-summary.typ": invoice-totals

// Load data from JSON input
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
  metadata_content: invoice-metadata(
    invoice_number: data.metadata.invoice_number,
    invoice_date: data.metadata.invoice_date,
    customer_number: if "customer_number" in data.metadata { data.metadata.customer_number } else { none },
    performance_period: if "performance_period" in data.metadata { data.metadata.performance_period } else { none },
    due_date: if "due_date" in data.metadata { data.metadata.due_date } else { none },
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

  #text(weight: "bold")[Rechnung]

  #v(3pt)

  #if "project_reference" in data.metadata and data.metadata.project_reference != none [
    Projekt: #data.metadata.project_reference
    #v(3pt)
  ]

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
// ITEMS TABLE SECTION (7-column layout)
// ============================================================================

// Table header
#block[
  #set text(size: 8pt, font: "Helvetica")

  #grid(
    columns: (35pt, 170pt, 45pt, 45pt, 45pt, 70pt, 70pt),
    align: (center, left, center, center, center, right, right),
    row-gutter: 8pt,

    text(weight: "bold")[Pos.],
    text(weight: "bold")[Bezeichnung],
    text(weight: "bold")[Menge],
    text(weight: "bold")[Einh.],
    text(weight: "bold")[MwSt.],
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
      columns: (35pt, 170pt, 45pt, 45pt, 45pt, 70pt, 70pt),
      align: (center, left, center, center, center, right, right),
      row-gutter: 5pt,

      [#item.position],
      [#item.description],
      [#item.quantity],
      format-unit(item.unit),
      [#item.vat_rate.percentage%],
      [#format_money(item.unit_price.amount)],
      [#text(weight: "bold")[#format_money(item.total.amount)]],
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
  vat_breakdown: data.totals.vat_breakdown,
  total: data.totals.total,
)

#v(5pt)

// ============================================================================
// CLOSING SECTION
// ============================================================================

#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(leading: 0.65em)

  Zahlbar ohne Abzug bis zum #format_german_date(data.payment.due_date).

  #v(8pt)

  Gelieferte Waren bleiben bis zur vollständigen Bezahlung unser Eigentum.

  #v(12pt)

  Mit freundlichen Grüßen

  #v(20pt)

  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner
  ] else [
    #company.name
  ]
]
