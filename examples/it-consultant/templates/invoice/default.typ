// Invoice Template (Rechnung) - CASOON Layout
// Based on casoon-documents simple.typ template

// Load data from JSON input
#let data = json(sys.inputs.data)

// Load company data
#let company = json("/data/company.json")

// Helper function to format date as DD.MM.YY
#let format_german_date(date_obj) = {
  let date_str = date_obj.date
  let parts = date_str.split("-")
  if parts.len() == 3 {
    let year = parts.at(0).slice(2, 4)  // Get last 2 digits of year
    let month = parts.at(1)
    let day = parts.at(2)
    day + "." + month + "." + year
  } else {
    date_str
  }
}

// Helper function to format money with 2 decimal places and comma
#let format_money(amount) = {
  let str_amount = str(amount)
  // Check if already has decimal point
  if str_amount.contains(".") {
    let parts = str_amount.split(".")
    let integer_part = parts.at(0)
    let decimal_part = parts.at(1)
    // Pad or truncate to 2 decimals
    if decimal_part.len() == 1 {
      integer_part + "," + decimal_part + "0"
    } else if decimal_part.len() >= 2 {
      integer_part + "," + decimal_part.slice(0, 2)
    } else {
      integer_part + ",00"
    }
  } else {
    str_amount + ",00"
  }
}

#set page(
  paper: "a4",
  margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 122pt),

  footer: context [
    #set text(size: 7pt, font: "Helvetica")

    #place(
      left + bottom,
      dx: 0pt,
      dy: -72pt,
      block(width: 500pt)[
        #grid(
          columns: (125pt, 125pt, 125pt, 125pt),
          column-gutter: 0pt,
          align: (top, top, top, top),

          // Column 1
          [
            #text(weight: "bold")[#company.name]\
            #if "business_owner" in company and company.business_owner != none [
              #company.business_owner\
            ]
            #company.address.street #company.address.house_number\
            #company.address.postal_code #company.address.city
          ],

          // Column 2
          [
            #if "phone" in company.contact and company.contact.phone != none [
              Tel.: #company.contact.phone\
            ]
            #if "email" in company.contact and company.contact.email != none [
              Email: #company.contact.email\
            ]
            #if "website" in company.contact and company.contact.website != none [
              Web: #company.contact.website
            ]
          ],

          // Column 3
          [
            Geschäftsinhaber:\
            #if "business_owner" in company and company.business_owner != none [
              #company.business_owner\
            ]
            USt-IdNr.:\
            #if "vat_id" in company and company.vat_id != none [
              #company.vat_id
            ]
          ],

          // Column 4
          [
            #if "bank_account" in company and company.bank_account != none [
              Bank: #company.bank_account.bank_name\
              Kontoinhaber: #company.bank_account.account_holder\
              IBAN: #company.bank_account.iban\
              BIC/SWIFT-Code: #company.bank_account.bic
            ]
          ],
        )
      ]
    )
  ]
)

#set text(
  font: "Helvetica",
  size: 10pt,
  lang: company.language
)

// ============================================================================
// HEADER SECTION
// ============================================================================

// Logo (right side at x=350, y=50)
#place(
  right + top,
  dx: 0pt,
  dy: 0pt,
  if "logo" in company and company.logo != none [
    #image("/data/" + company.logo, width: 150pt)
  ] else [
    #box(
      width: 150pt,
      height: 50pt,
      stroke: 1pt + luma(200),
      inset: 10pt,
      radius: 4pt,
    )[
      #align(center + horizon)[
        #text(size: 8pt, fill: luma(150))[Logo hinzufügen in\ company.json]
      ]
    ]
  ]
)

// Invoice metadata (right side, below logo at x=350)
#place(
  right + top,
  dx: 0pt,
  dy: 80pt,
  block(width: 195pt)[
    #set text(size: 8pt)
    #set par(leading: 0.5em)
    #set align(left)

    #text(weight: "bold")[Rückfragen an:]\
    #company.name\
    #if "phone" in company.contact and company.contact.phone != none [
      #company.contact.phone\
    ]
    #if "email" in company.contact and company.contact.email != none [
      #company.contact.email
    ]

    #v(5pt)

    #set text(size: 10pt)
    #set par(leading: 0.6em)
    *Rechnungs-Nr.:* #data.metadata.invoice_number\
    #if "customer_number" in data.metadata and data.metadata.customer_number != none [
      *Kunden-Nr.:* #data.metadata.customer_number\
    ]
    *Rechnungsdatum:* #format_german_date(data.metadata.invoice_date)\
    #if "performance_period" in data.metadata and data.metadata.performance_period != none [
      *Leistungszeitraum:* #data.metadata.performance_period\
    ]
  ]
)

// ============================================================================
// RECIPIENT ADDRESS (DIN 5008 position at y=160)
// ============================================================================

// DIN 5008: Recipient address at y=127.5pt (45mm from top)
// Sender line 20pt above recipient address
// Current: top margin 50pt + v(77.5pt) = 127.5pt ≈ 45mm
#v(77.5pt)

// Sender line (small, above recipient) - DIN 5008
#block(height: 20pt)[
  #set text(size: 8pt, font: "Helvetica")
  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
  ] else [
    #company.name · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
  ]
]

// Recipient address - DIN 5008
#block(height: 120pt)[
  #set text(size: 12pt, font: "Helvetica")

  #data.recipient.name\
  #if "company" in data.recipient and data.recipient.company != none and data.recipient.company != data.recipient.name [
    #data.recipient.company\
  ]
  #data.recipient.address.street #data.recipient.address.house_number\
  #data.recipient.address.postal_code #data.recipient.address.city
]

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
      {
        if item.unit == "monat" [Monat]
        else if item.unit == "stunde" [Std.]
        else if item.unit == "stueck" [Stk.]
        else if item.unit == "tag" [Tag]
        else if item.unit == "pauschale" [Psch.]
        else [#item.unit]
      },
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
#align(right)[
  #set text(size: 10pt, font: "Helvetica")

  #if data.totals.vat_breakdown.len() > 0 [
    #grid(
      columns: (100pt, 80pt),
      align: (right, right),
      row-gutter: 10pt,

      [Nettobetrag:], [#format_money(data.totals.subtotal.amount) EUR],
      [MwSt. (#data.totals.vat_breakdown.at(0).rate.percentage%):], [#format_money(data.totals.vat_breakdown.at(0).amount.amount) EUR],
      [#set text(size: 11pt)
       #text(weight: "bold")[Gesamtbetrag:]], [#set text(size: 11pt)
                                  #text(weight: "bold")[#format_money(data.totals.total.amount) EUR]],
    )
  ] else [
    #grid(
      columns: (100pt, 80pt),
      align: (right, right),
      row-gutter: 10pt,

      [#set text(size: 11pt)
       #text(weight: "bold")[Gesamtbetrag:]], [#set text(size: 11pt)
                                  #text(weight: "bold")[#format_money(data.totals.total.amount) EUR]],
    )
  ]
]

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
