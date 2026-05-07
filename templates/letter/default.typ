// Letter Template (Geschäftsbrief) - CASOON Layout
// Based on invoice template layout with DIN 5008 compliance
// Supports both JSON input and direct .typ content files

// Load data from JSON input
#import "../common/footers.typ": accounting-footer
#import "../common/formatting.typ": format_german_date
#import "../common/din5008-address.typ": din5008-address-block
#import "../common/accounting-header.typ": accounting-header, letter-metadata
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
  metadata_content: [
    #if "reference_number" in data.metadata and data.metadata.reference_number != none [
      *Unser Zeichen:* #data.metadata.reference_number\
    ]
    #if "your_reference" in data.metadata and data.metadata.your_reference != none [
      *Ihr Zeichen:* #data.metadata.your_reference\
    ]
    *Datum:* #format_german_date(data.metadata.date)\
  ]
)

// ============================================================================
// RECIPIENT ADDRESS (DIN 5008 position at y=160)
// ============================================================================

#din5008-address-block(
  company: company,
  recipient: data.recipient,
)

// ============================================================================
// SALUTATION AND CONTENT
// ============================================================================

#block[
  #set text(size: 10pt, font: "Helvetica")
  #set par(justify: true, leading: 0.65em)

  #if "subject" in data.metadata and data.metadata.subject != none [
    #text(weight: "bold", size: 11pt)[#data.metadata.subject]
    #v(8pt)
  ]

  #if "salutation" in data and data.salutation != none [
    #data.salutation\
    #v(8pt)
  ]

  // Main content body
  #if "content" in data [
    #data.content
  ]

  #v(12pt)

  // Closing
  #if "closing" in data and data.closing != none [
    #data.closing

    #v(20pt)

    #if "signature_name" in data and data.signature_name != none [
      #data.signature_name
    ] else if "business_owner" in company and company.business_owner != none [
      #company.business_owner
    ] else [
      #company.name
    ]
  ] else [
    Mit freundlichen Grüßen

    #v(20pt)

    #if "business_owner" in company and company.business_owner != none [
      #company.business_owner
    ] else [
      #company.name
    ]
  ]
]

// Attachments section
#if "attachments" in data and data.attachments != none and data.attachments.len() > 0 [
  #v(15pt)
  #text(weight: "bold")[Anlagen:]
  #v(3pt)
  #for attachment in data.attachments [
    - #attachment
  ]
]
