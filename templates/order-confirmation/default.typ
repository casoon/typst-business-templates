// Order Confirmation Template (Auftragsbestätigung) - CASOON Layout
// Confirmation of received orders

// Load data from JSON input
#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": format_german_date, format_money
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, order-confirmation-metadata
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

// Logo and metadata
#accounting-header(
  company: company,
  metadata_content: order-confirmation-metadata(
    confirmation_number: data.metadata.confirmation_number,
    confirmation_date: data.metadata.confirmation_date,
    order_number: data.metadata.order_number,
    expected_delivery: if "expected_delivery" in data.metadata { data.metadata.expected_delivery } else { none },
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

  #text(weight: "bold", size: 12pt)[Auftragsbestätigung]

  #v(8pt)

  #if "salutation" in data and data.salutation != none [
    #data.salutation.greeting\
    #v(3pt)
    #if "introduction" in data.salutation [
      #data.salutation.introduction
    ]
  ] else [
    Sehr geehrte Damen und Herren,\
    #v(3pt)
    vielen Dank für Ihre Bestellung. Hiermit bestätigen wir den Auftrag wie folgt:
  ]

  #v(8pt)
]

// Items table
#block[
  #set text(size: 8pt, font: "Helvetica")

  #grid(
    columns: (35pt, 200pt, 50pt, 50pt, 80pt, 90pt),
    align: (center, left, center, center, right, right),
    row-gutter: 8pt,

    text(weight: "bold")[Pos.],
    text(weight: "bold")[Artikel / Beschreibung],
    text(weight: "bold")[Menge],
    text(weight: "bold")[Einh.],
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
      columns: (35pt, 200pt, 50pt, 50pt, 80pt, 90pt),
      align: (center, left, center, center, right, right),
      row-gutter: 5pt,

      [#item.position],
      [
        #if "article_number" in item and item.article_number != none [
          #text(weight: "bold")[Art.-Nr.: #item.article_number]\
        ]
        #item.description
      ],
      [#item.quantity],
      [#format-unit(item.unit)],
      [#format_money(item.unit_price.amount) EUR],
      [#text(weight: "bold")[#format_money(item.total.amount) EUR]],
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

#v(10pt)

// Terms and closing
#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(justify: true)

  #if "payment_terms" in data.terms and data.terms.payment_terms != none [
    *Zahlungsbedingungen:* #data.terms.payment_terms

    #v(8pt)
  ]

  #if "delivery_terms" in data.terms and data.terms.delivery_terms != none [
    *Lieferbedingungen:* #data.terms.delivery_terms

    #v(8pt)
  ]

  #if "custom_text" in data and data.custom_text != none [
    #data.custom_text

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
