// Time Sheet Template (Stundenzettel) - Accounting Layout
// For tracking work hours and billable time

// Load data from JSON input
#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": format_german_date
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, timesheet-metadata
#let data = json(sys.inputs.data)

// Load company data
#let company = json("/data/company.json")

// Helper function to format hours
#let format_hours(hours) = {
  let str_hours = str(hours)
  if str_hours.contains(".") {
    let parts = str_hours.split(".")
    let integer_part = parts.at(0)
    let decimal_part = parts.at(1)
    if decimal_part.len() == 1 {
      integer_part + "," + decimal_part + "0"
    } else if decimal_part.len() >= 2 {
      integer_part + "," + decimal_part.slice(0, 2)
    } else {
      integer_part + ",00"
    }
  } else {
    str_hours + ",00"
  }
}

#let show-footer = if "metadata" in data and "show_footer" in data.metadata { data.metadata.show_footer } else { true }

#set page(
  paper: "a4",
  margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),

  footer: if show-footer { accounting-footer(company: company) }
)

#set text(font: "Helvetica", size: 10pt, lang: company.language)

// Header with logo and metadata
#accounting-header(
  company: company,
  metadata_content: timesheet-metadata(
    timesheet_number: data.metadata.timesheet_number,
    period_start: data.metadata.period_start,
    period_end: data.metadata.period_end,
    employee: if "employee" in data.metadata { data.metadata.employee } else { none },
  )
)

// Recipient/Client address - DIN 5008
#din5008-address-block(
  company: company,
  recipient: if "client" in data { data.client } else { none },
)

// Title
#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold", size: 12pt)[Stundenzettel]

  #v(5pt)

  #if "project_name" in data.metadata and data.metadata.project_name != none [
    Projekt: #data.metadata.project_name
    #v(3pt)
  ]
]

// Time entries table
#block[
  #set text(size: 8pt, font: "Helvetica")

  #table(
    columns: (60pt, 200pt, 50pt, 50pt, 50pt),
    align: (left, left, center, center, center),
    stroke: 0.5pt,
    inset: 6pt,

    [*Datum*], [*Tätigkeit*], [*Von*], [*Bis*], [*Stunden*],

    ..data.entries.map(entry => (
      [#format_german_date(entry.date)],
      [#entry.description],
      [#if "time_start" in entry [#entry.time_start] else [—]],
      [#if "time_end" in entry [#entry.time_end] else [—]],
      [#text(weight: "bold")[#format_hours(entry.hours)]],
    )).flatten()
  )
]

#v(10pt)

// Summary
#align(right)[
  #set text(size: 10pt, font: "Helvetica")

  #grid(
    columns: (120pt, 80pt),
    align: (right, center),
    row-gutter: 10pt,

    [Gesamtstunden:], [#text(weight: "bold", size: 11pt)[#format_hours(data.totals.total_hours) h]],

    ..if "billable_hours" in data.totals {
      (
        [Abrechenbare Stunden:],
        [#text(weight: "bold")[#format_hours(data.totals.billable_hours) h]]
      )
    } else { () },

    ..if "non_billable_hours" in data.totals {
      (
        [Nicht abrechenbar:],
        [#format_hours(data.totals.non_billable_hours) h]
      )
    } else { () },
  )
]

#v(15pt)

// Signature section
#block[
  #set text(size: 9pt, font: "Helvetica")

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 30pt,
    row-gutter: 50pt,

    [
      #v(30pt)
      #box(
        width: 100%,
        stroke: (top: 0.5pt),
        inset: (top: 5pt),
      )[
        #align(center)[Ort, Datum, Unterschrift Mitarbeiter]
      ]
    ],

    [
      #v(30pt)
      #box(
        width: 100%,
        stroke: (top: 0.5pt),
        inset: (top: 5pt),
      )[
        #align(center)[Ort, Datum, Unterschrift Auftraggeber]
      ]
    ],
  )
]

#v(10pt)

// Notes
#if "notes" in data and data.notes != none [
  #block[
    #set text(size: 9pt, font: "Helvetica")
    
    #text(weight: "bold")[Bemerkungen:]\
    #v(0.3em)
    #data.notes
  ]
]
