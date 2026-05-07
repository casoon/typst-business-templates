// Quotation Request Template (Angebotsanfrage) - Accounting Layout
// Request for quotations from suppliers/vendors

// Load data from JSON input
#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": format_german_date
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, quotation-request-metadata
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

// Header with logo and metadata
#accounting-header(
  company: company,
  metadata_content: {
    quotation-request-metadata(
      request_number: data.metadata.request_number,
      request_date: data.metadata.date,
      response_deadline: if "response_deadline" in data.metadata { data.metadata.response_deadline } else { none },
    )
    
    // Add project reference if present
    if "project_reference" in data.metadata and data.metadata.project_reference != none [
      *Projekt:* #data.metadata.project_reference\
    ]
  }
)

// DIN 5008 address block
#din5008-address-block(
  company: company,
  recipient: if "supplier" in data { data.supplier } else { none },
)

// Title and intro
#block[
  #set text(size: 10pt, font: "Helvetica")

  #text(weight: "bold", size: 12pt)[Angebotsanfrage]

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
    wir bitten Sie um ein Angebot für folgende Leistungen/Produkte:
  ]

  #v(8pt)
]

// Items table
#block[
  #set text(size: 8pt, font: "Helvetica")

  #grid(
    columns: (35pt, 250pt, 60pt, 60pt, 100pt),
    align: (center, left, center, center, left),
    row-gutter: 8pt,

    text(weight: "bold")[Pos.],
    text(weight: "bold")[Beschreibung],
    text(weight: "bold")[Menge],
    text(weight: "bold")[Einheit],
    text(weight: "bold")[Spezifikation],
  )

  #v(5pt)
  #line(length: 100%, stroke: 0.5pt)
  #v(5pt)
]

#for item in data.items [
  #block[
    #set text(size: 8pt, font: "Helvetica")

    #grid(
      columns: (35pt, 250pt, 60pt, 60pt, 100pt),
      align: (center, left, center, center, left),
      row-gutter: 5pt,

      [#item.position],
      [
        #text(weight: "bold")[#item.title]\
        #if "description" in item and item.description != none [
          #item.description
        ]
      ],
      [#item.quantity],
      {
        if item.unit == "stueck" [Stk.]
        else if item.unit == "stunde" [Std.]
        else if item.unit == "tag" [Tag]
        else if item.unit == "monat" [Monat]
        else if item.unit == "kg" [kg]
        else if item.unit == "liter" [l]
        else [#item.unit]
      },
      [#if "specification" in item and item.specification != none [#item.specification]],
    )

    // Sub-items or detailed requirements
    #if "requirements" in item and item.requirements.len() > 0 [
      #v(2pt)
      #pad(left: 35pt)[
        #block[
          #set text(size: 7pt, font: "Helvetica")
          #set par(leading: 0.5em)
          #text(weight: "bold")[Anforderungen:]\
          #for req in item.requirements [
            - #req
          ]
        ]
      ]
    ]

    #v(5pt)
  ]
]

#v(5pt)
#line(length: 100%, stroke: 0.5pt)
#v(10pt)

// Requirements and conditions
#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(justify: true)

  #if "delivery_terms" in data.terms and data.terms.delivery_terms != none [
    *Lieferbedingungen:* #data.terms.delivery_terms

    #v(8pt)
  ]

  #if "delivery_deadline" in data.terms and data.terms.delivery_deadline != none [
    *Gewünschter Liefertermin:* #format_german_date(data.terms.delivery_deadline)

    #v(8pt)
  ]

  #if "payment_terms" in data.terms and data.terms.payment_terms != none [
    *Zahlungsbedingungen:* #data.terms.payment_terms

    #v(8pt)
  ]

  #if "quality_requirements" in data.terms and data.terms.quality_requirements != none [
    *Qualitätsanforderungen:* #data.terms.quality_requirements

    #v(8pt)
  ]

  #if "additional_notes" in data and data.additional_notes != none [
    *Weitere Hinweise:*\
    #data.additional_notes

    #v(8pt)
  ]
]

#v(8pt)

// Response requirements
#block[
  #set text(size: 10pt, font: "Helvetica")
  
  #text(weight: "bold")[Ihr Angebot sollte enthalten:]
  
  #v(5pt)
  
  #if "response_requirements" in data and data.response_requirements.len() > 0 [
    #for req in data.response_requirements [
      - #req
    ]
  ] else [
    - Detaillierte Preiskalkulation
    - Lieferzeiten und -konditionen
    - Zahlungsbedingungen
    - Gültigkeitsdauer des Angebots
    - Referenzen (optional)
  ]

  #v(8pt)

  #if "response_deadline" in data.metadata and data.metadata.response_deadline != none [
    Wir bitten um Ihr Angebot bis zum *#format_german_date(data.metadata.response_deadline)*.
  ]
]

#v(12pt)

// Closing
#block[
  #set text(size: 10pt, font: "Helvetica")

  #if "custom_closing" in data and data.custom_closing != none [
    #data.custom_closing
  ] else [
    Für Rückfragen stehen wir Ihnen gerne zur Verfügung.
  ]

  #v(8pt)

  Mit freundlichen Grüßen

  #v(20pt)

  #if "business_owner" in company and company.business_owner != none [
    #company.business_owner
  ] else [
    #company.name
  ]
]

// Attachments
#if "attachments" in data and data.attachments.len() > 0 [
  #v(15pt)
  #text(weight: "bold")[Anlagen:]
  #v(3pt)
  #for attachment in data.attachments [
    - #attachment
  ]
]
