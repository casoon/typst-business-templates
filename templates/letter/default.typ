// Letter Template (Geschäftsbrief) - CASOON Layout
// DIN 5008, layout like invoice/offer.
//
// The letter text comes as Typst content (headings, lists, tables), or as
// data.content (a string) for short letters from JSON.
//
//   #import "@local/business-templates:0.1.0": letter
//   #letter(
//     data: (
//       metadata: (date: "2026-10-08", subject: "…", reference_number: "CAS-BRF-2026-001"),
//       recipient: (lines: ("Firma", "Herr Name", "Straße 1", "12345 Ort")),
//       salutation: "Sehr geehrte Damen und Herren,",
//     ),
//     company: json("/data/company.json"),
//   )[ Brieftext ]

#import "../common/styles.typ": get-language, logo-source
#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": to-datetime

// "2026-10-08" or (date: "2026-10-08") -> "08.10.2026"
#let format-letter-date(date) = {
  let date_str = if type(date) == dictionary { date.date } else { str(date) }
  let parts = date_str.split("-")
  if parts.len() == 3 {
    parts.at(2) + "." + parts.at(1) + "." + parts.at(0)
  } else {
    date_str
  }
}

/// Renders the letter. `data` is described by schema/letter.schema.json,
/// `company` that of company.json; the optional body is the letter text.
#let letter(data: none, company: none, ..body) = {
  let meta = data.metadata
  let subject = meta.at("subject", default: none)
  let reference = meta.at("reference_number", default: none)
  let show-footer = meta.at("show_footer", default: true)

  set page(
    paper: "a4",
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),
    header: context {
      if counter(page).get().first() > 1 {
        set text(size: 8pt, font: "Helvetica", fill: luma(90))
        grid(
          columns: (1fr, auto),
          [#if reference != none [#reference · ]#subject],
          [Seite #counter(page).display() von #counter(page).final().first()],
        )
        v(-4pt)
        line(length: 100%, stroke: 0.5pt + luma(180))
      }
    },
    footer: if show-footer { accounting-footer(company: company) },
  )

  set text(font: "Helvetica", size: 10pt, lang: get-language(company))
  set par(justify: true, leading: 0.65em)
  set document(
    title: if subject != none { subject } else if reference != none { reference } else { "Schreiben" },
    author: company.name,
    ..if "date" in meta { (date: to-datetime(meta.date)) },
  )

  show heading.where(level: 1): it => {
    v(10pt)
    text(size: 12pt, weight: "bold", it.body)
    v(4pt)
  }
  show heading.where(level: 2): it => {
    v(8pt)
    text(size: 10.5pt, weight: "bold", it.body)
    v(2pt)
  }
  show table: set text(size: 8.5pt)
  show table: set par(justify: false)

  // ==========================================================================
  // HEADER: logo and metadata on the right
  // ==========================================================================

  place(right + top, dx: 0pt, dy: 0pt,
    if "logo" in company and company.logo != none {
      image(logo-source(company.logo), width: 150pt)
    },
  )

  place(right + top, dx: 0pt, dy: 80pt,
    block(width: 195pt)[
      #set text(size: 8pt)
      #set par(leading: 0.5em, justify: false)
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
      #if reference != none [
        *Unser Zeichen:* #reference\
      ]
      #if "your_reference" in meta and meta.your_reference != none [
        *Ihr Zeichen:* #meta.your_reference\
      ]
      *Datum:* #format-letter-date(meta.date)
    ],
  )

  // ==========================================================================
  // ADDRESS (DIN 5008, 45 mm from the top)
  // ==========================================================================

  v(77.5pt)

  block(height: 20pt)[
    #set text(size: 8pt)
    #if "business_owner" in company and company.business_owner != none [
      #company.business_owner · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
    ] else [
      #company.name · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
    ]
  ]

  block(height: 120pt)[
    #set text(size: 11pt)
    #set par(justify: false)
    #let r = data.recipient
    #if "lines" in r [
      #r.lines.join(linebreak())
    ] else [
      #r.name\
      #if "company" in r and r.company != none and r.company != r.name [
        #r.company\
      ]
      #r.address.street #r.address.house_number\
      #r.address.postal_code #r.address.city
    ]
  ]

  // ==========================================================================
  // SUBJECT, SALUTATION, TEXT, CLOSING
  // ==========================================================================

  if subject != none {
    text(weight: "bold", size: 11pt, subject)
    v(8pt)
  }

  if "salutation" in data and data.salutation != none {
    data.salutation
    v(4pt)
  }

  if "content" in data and data.content != none {
    data.content
  }
  body.pos().join()

  v(12pt)
  // data.final: the last paragraph, kept on one page with the closing and signature
  block(breakable: false)[
    #if "final" in data and data.final != none [
      #data.final
      #v(8pt)
    ]
    #if "closing" in data and data.closing != none [#data.closing] else [Mit freundlichen Grüßen]

    #v(20pt)

    #if "signature_name" in data and data.signature_name != none [
      #data.signature_name
    ] else if "business_owner" in company and company.business_owner != none [
      #company.business_owner
    ] else [
      #company.name
    ]
  ]

  if "attachments" in data and data.attachments != none and data.attachments.len() > 0 {
    v(15pt)
    text(weight: "bold")[Anlagen:]
    v(3pt)
    for attachment in data.attachments [
      - #attachment
    ]
  }
}
