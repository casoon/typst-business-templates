// Delivery Note Template (Lieferschein) - CASOON Layout
// Document for tracking goods delivery

// Load data from JSON input
#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": format_german_date
#import "../common/din5008-address.typ": din5008-address-block-with-delivery
#import "../common/accounting-header.typ": accounting-header, delivery-note-metadata
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
  metadata_content: delivery-note-metadata(
    delivery_note_number: data.metadata.delivery_note_number,
    delivery_date: data.metadata.delivery_date,
    order_reference: if "order_reference" in data.metadata { data.metadata.order_reference } else { none },
    delivery_time: if "delivery_time" in data.metadata { data.metadata.delivery_time } else { none },
  )
)

// DIN 5008 address block with delivery address support
din5008-address-block-with-delivery(
  company: company,
  recipient: data.recipient,
  delivery_address: if "delivery_address" in data { data.delivery_address } else { none },
)

// Title
#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold", size: 12pt)[Lieferschein]

  #v(8pt)
]

// Items table
#block[
  #set text(size: 8pt, font: "Helvetica")

  #grid(
    columns: (35pt, 250pt, 60pt, 60pt, 80pt),
    align: (center, left, center, center, left),
    row-gutter: 8pt,

    text(weight: "bold")[Pos.],
    text(weight: "bold")[Artikel / Beschreibung],
    text(weight: "bold")[Menge],
    text(weight: "bold")[Einheit],
    text(weight: "bold")[Bemerkung],
  )

  #v(5pt)
  #line(length: 100%, stroke: 0.5pt)
  #v(5pt)
]

#for item in data.items [
  #block[
    #set text(size: 8pt, font: "Helvetica")

    #grid(
      columns: (35pt, 250pt, 60pt, 60pt, 80pt),
      align: (center, left, center, center, left),
      row-gutter: 5pt,

      [#item.position],
      [
        #if "article_number" in item and item.article_number != none [
          Art.-Nr.: #item.article_number\
        ]
        #item.description
      ],
      [#item.quantity],
      {
        if item.unit == "stueck" [Stk.]
        else if item.unit == "karton" [Ktn.]
        else if item.unit == "palette" [Pal.]
        else if item.unit == "kg" [kg]
        else if item.unit == "meter" [m]
        else [#item.unit]
      },
      [#if "notes" in item and item.notes != none [#item.notes]],
    )

    #v(5pt)
  ]
]

#v(5pt)
#line(length: 100%, stroke: 0.5pt)
#v(10pt)

// Signature section
#block[
  #set text(size: 9pt, font: "Helvetica")

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 20pt,
    row-gutter: 50pt,

    [
      #box(
        width: 100%,
        stroke: (top: 0.5pt),
        inset: (top: 5pt),
      )[
        #align(center)[Ort, Datum, Unterschrift Lieferant]
      ]
    ],

    [
      #box(
        width: 100%,
        stroke: (top: 0.5pt),
        inset: (top: 5pt),
      )[
        #align(center)[Ort, Datum, Unterschrift Empfänger]
      ]
    ],
  )
]

#v(10pt)

// Special notes
#if "special_notes" in data and data.special_notes != none [
  #block[
    #set text(size: 9pt, font: "Helvetica")
    
    #text(weight: "bold")[Hinweise:]\
    #data.special_notes
  ]
]

// Shipping info
#if "shipping_method" in data.metadata and data.metadata.shipping_method != none [
  #v(8pt)
  #block[
    #set text(size: 9pt, font: "Helvetica")
    
    *Versandart:* #data.metadata.shipping_method
    
    #if "tracking_number" in data.metadata and data.metadata.tracking_number != none [
      \ *Sendungsnummer:* #data.metadata.tracking_number
    ]
  ]
]
