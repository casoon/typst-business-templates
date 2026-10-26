// Invoice Template (Rechnung) - CASOON Layout
// Based on casoon-documents simple.typ template

#import "../common/styles.typ": get-language, load-locale, logo-source
#import "../common/invoice-profile.typ": invoice-presentation, invoice-money, invoice-price, invoice-date, invoice-party, invoice-reference, invoice-sums, invoice-unit
#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": format_german_date, format_money, document-metadata
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, invoice-metadata
#import "../common/unit-formatter.typ": format-unit
#import "../common/totals-summary.typ": invoice-totals, vat-exemption-note, check-totals

/// Renders the document. `data` is described by schema/invoice.schema.json,
/// `company` that of company.json.
#let invoice(data: none, company: none, profile: none, locale: none) = [
#check-totals(data)
#let choice = invoice-presentation(profile, company, data)
#let texts = load-locale(locale, company, language: choice.language)
#let labels = texts.invoice
#let money = invoice-money.with(format-locale: choice.format_locale)
#let price = invoice-price.with(format-locale: choice.format_locale)
#let date = invoice-date.with(format-locale: choice.format_locale)
#set document(..document-metadata(company, data.metadata.at("invoice_number", default: none), data.metadata.at("invoice_date", default: none)))
#let show-footer = if "metadata" in data and "show_footer" in data.metadata { data.metadata.show_footer } else { true }

#set page(
  paper: "a4",
  margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),

  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 8pt)
      #grid(columns: (1fr, auto), [#data.metadata.invoice_number], [#texts.common.page #counter(page).display("1 / 1", both: true)])
    ]
  },
  footer: if show-footer { accounting-footer(company: company, locale: texts) }
)

#set text(
  font: "Helvetica",
  size: 10pt,
  lang: choice.language
)

// ============================================================================
// HEADER SECTION
// ============================================================================

#if choice.layout == "din" {
  accounting-header(company: company, contact-label: labels.contact, logo-placeholder: none,
    metadata_content: invoice-reference(data, labels, texts.common, date))
  din5008-address-block(company: company, recipient: data.recipient, address-width: 250pt)
} else [
  #if company.at("logo", default: none) != none [
    #image(logo-source(company.logo), width: 100pt, height: 40pt, fit: "contain")
    #v(8pt)
  ]
  #grid(columns: (1fr, 1fr), column-gutter: 20pt,
    [#invoice-party(company)],
    [#invoice-reference(data, labels, texts.common, date)],
  )
  #v(16pt)
  #invoice-party(data.recipient)
  #v(16pt)
]

// ============================================================================
// SALUTATION SECTION
// ============================================================================

#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold")[#labels.title]

  #v(3pt)

  #if "project_reference" in data.metadata and data.metadata.project_reference != none [
    #texts.common.project: #data.metadata.project_reference
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
    columns: (24pt, 1fr, 36pt, 36pt, 36pt, 62pt, 62pt),
    column-gutter: 4pt,
    align: (center, left, center, center, center, right, right),
    row-gutter: 8pt,

    text(weight: "bold")[#labels.position],
    text(weight: "bold")[#labels.description],
    text(weight: "bold")[#labels.quantity],
    text(weight: "bold")[#labels.unit],
    text(weight: "bold")[#labels.vat],
    text(weight: "bold")[#labels.unit_price],
    text(weight: "bold")[#labels.total_price],
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
      columns: (24pt, 1fr, 36pt, 36pt, 36pt, 62pt, 62pt),
    column-gutter: 4pt,
      align: (center, left, center, center, center, right, right),
      row-gutter: 5pt,

      [#item.position],
      [#item.description #if item.vat_rate.at("exemption_reason", default: none) != none [#linebreak()#item.vat_rate.exemption_reason]],
      [#item.quantity],
      invoice-unit(item, labels),
      [#item.vat_rate.percentage%],
      [#price(item.unit_price.amount)],
      [#text(weight: "bold")[#money(item.total.amount)]],
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
#invoice-sums(data, labels, money, choice.currency)

#v(5pt)

// ============================================================================
// CLOSING SECTION
// ============================================================================

#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(leading: 0.65em)

  #let vat-note = if choice.at("profile_id", default: "") == "configured-invoice" { none } else { vat-exemption-note(company) }
  #if vat-note != none [
    #vat-note

    #v(8pt)
  ]

  #for note in data.at("notes", default: ()) [#block(above: 4pt, below: 4pt)[#note]]

  #if data.payment.at("due_date", default: none) != none [
    #labels.payable_by #date(data.payment.due_date).
  ] else if data.payment.at("payment_terms", default: none) != none [
    #data.payment.payment_terms
  ]

  #if "bank_account" in data.payment [
    #v(8pt)
    *#labels.iban:* #data.payment.bank_account.iban
    #if "bic" in data.payment.bank_account [#linebreak()*#labels.bic:* #data.payment.bank_account.bic]
  ]
  #for field in data.at("profile_fields", default: ()) [
    #block(above: 4pt, below: 4pt)[*#field.label:* #field.value]
  ]
  #v(8pt)

  #labels.retention_of_title

  #v(12pt)

  #labels.regards

  #v(20pt)

  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner
  ] else [
    #company.name
  ]
]
]
