// Credit Note Template (Gutschrift) - CASOON Layout
// Based on invoice template - for refunds and corrections

// Load data from JSON input
#import "../common/formatting.typ": format_german_date, format_money
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, credit-note-metadata
#import "../common/footers.typ": accounting-footer
#import "../common/unit-formatter.typ": format-unit
#import "../common/totals-summary.typ": invoice-totals
#let data = json(sys.inputs.data)

// Load company data
#let company = json("/data/company.json")

#let show-footer = if "metadata" in data and "show_footer" in data.metadata { data.metadata.show_footer } else { true }

#set page(
  paper: "a4",
  margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),

  footer: if show-footer { accounting-footer(company: company) }
)

#set text(font: "Helvetica", size: 10pt, lang: company.language)

// Logo and metadata header
#accounting-header(
  company: company,
  metadata_content: credit-note-metadata(
    credit_note_number: data.metadata.credit_note_number,
    date: data.metadata.date,
    invoice_reference: if "invoice_reference" in data.metadata { data.metadata.invoice_reference } else { none },
  )
)

// Recipient address - DIN 5008
#din5008-address-block(
  company: company,
  recipient: data.recipient,
)

// Title and intro
#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold")[Gutschrift]

  #v(3pt)

  #if "reason" in data.metadata and data.metadata.reason != none [
    Grund: #data.metadata.reason
    #v(3pt)
  ]

  #if "salutation" in data and data.salutation != none [
    #data.salutation.greeting\
    #v(3pt)
    #if "introduction" in data.salutation [
      #data.salutation.introduction
    ]
  ]

  #v(3pt)
]

// Items table
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
      [#format-unit(item.unit)],
      [#item.vat_rate.percentage%],
      [#format_money(item.unit_price.amount)],
      [#text(weight: "bold")[#format_money(item.total.amount)]],
    )

    #v(5pt)
  ]
]

#v(5pt)
#line(length: 100%, stroke: 0.5pt)
#v(5pt)

// Totals
#invoice-totals(
  subtotal: data.totals.subtotal,
  vat_breakdown: data.totals.vat_breakdown,
  total: data.totals.total,
)

#v(5pt)

// Closing
#block[
  #set text(size: 10pt, font: "Helvetica")

  Der Gutschriftsbetrag wird Ihrem Konto gutgeschrieben.

  #v(12pt)

  Mit freundlichen Grüßen

  #v(20pt)

  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner
  ] else [
    #company.name
  ]
]
