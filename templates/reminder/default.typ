// Reminder Template (Zahlungserinnerung/Mahnung) - CASOON Layout
// Multi-level payment reminder system

// Load data from JSON input
#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": format_german_date, format_money
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, reminder-metadata
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

// Logo and Metadata
#accounting-header(
  company: company,
  metadata_content: reminder-metadata(
    reminder_number: data.metadata.reminder_number,
    reminder_date: data.metadata.date,
    reminder_level: if "reminder_level" in data.metadata { data.metadata.reminder_level } else { none },
  )
)

// Recipient address - DIN 5008
#din5008-address-block(
  company: company,
  recipient: data.recipient,
)

// Title
#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold", size: 12pt)[
    #if data.metadata.reminder_level == "1" [
      Zahlungserinnerung
    ] else [
      #data.metadata.reminder_level. Mahnung
    ]
  ]

  #v(8pt)

  #if "salutation" in data and data.salutation != none [
    #data.salutation\
  ] else [
    Sehr geehrte Damen und Herren,
  ]

  #v(8pt)

  #if "introduction" in data and data.introduction != none [
    #data.introduction
  ] else [
    trotz Fälligkeit haben wir bisher keinen Zahlungseingang feststellen können. Wir bitten Sie höflich, den folgenden offenen Betrag zu begleichen:
  ]

  #v(8pt)
]

// Outstanding invoices table
#block[
  #set text(size: 9pt, font: "Helvetica")

  #table(
    columns: (80pt, 80pt, 80pt, 80pt, 80pt),
    align: (left, left, left, right, right),
    stroke: 0.5pt,
    inset: 8pt,

    [*Rechnung*], [*Datum*], [*Fällig am*], [*Betrag*], [*Offen*],

    ..data.outstanding_invoices.map(inv => (
      [#inv.invoice_number],
      [#format_german_date(inv.invoice_date)],
      [#format_german_date(inv.due_date)],
      [#format_money(inv.amount.amount) EUR],
      [#format_money(inv.outstanding.amount) EUR],
    )).flatten()
  )
]

#v(10pt)

// Total outstanding
#align(right)[
  #set text(size: 11pt, font: "Helvetica")
  
  #grid(
    columns: (120pt, 100pt),
    align: (right, right),
    row-gutter: 8pt,

    [#text(weight: "bold")[Offener Gesamtbetrag:]], 
    [#text(weight: "bold")[#format_money(data.totals.total_outstanding.amount) EUR]],

    ..if "reminder_fee" in data.totals and data.totals.reminder_fee.amount > 0 {
      (
        [Mahngebühr:],
        [#format_money(data.totals.reminder_fee.amount) EUR],
        [#text(weight: "bold")[Zahlbetrag gesamt:]],
        [#text(weight: "bold")[#format_money(data.totals.total_due.amount) EUR]]
      )
    } else { () }
  )
]

#v(10pt)

// Payment instructions
#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(justify: true)

  #if "payment_deadline" in data.metadata [
    Wir bitten Sie, den offenen Betrag bis zum *#format_german_date(data.metadata.payment_deadline)* auf unser Konto zu überweisen.

    #v(8pt)
  ]

  #if "custom_text" in data and data.custom_text != none [
    #data.custom_text

    #v(8pt)
  ]

  Falls Sie bereits gezahlt haben, betrachten Sie dieses Schreiben bitte als gegenstandslos.

  #v(12pt)

  Mit freundlichen Grüßen

  #v(20pt)

  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner
  ] else [
    #company.name
  ]
]
