// Accounting Header Component
// Reusable header with logo and metadata box for DIN 5008 business documents

#import "formatting.typ": format_german_date

/// Renders a DIN 5008-compliant accounting header with logo and metadata box
///
/// Layout:
/// - Logo: Right-aligned at top (150pt width)
/// - Metadata box: Right-aligned below logo at 80pt offset (195pt width)
/// - Contact info section with "Rückfragen an:"
/// - Document-specific metadata fields
///
/// Parameters:
/// - company: Company data dictionary with name, contact (phone, email), optional logo
/// - metadata_content: Content to display in the metadata box (document-specific fields)
///
/// Example:
/// ```typst
/// #accounting-header(
///   company: company_data,
///   metadata_content: [
///     *Rechnungs-Nr.:* #invoice_number\
///     *Datum:* #date\
///   ]
/// )
/// ```
#let accounting-header(
  company: none,
  metadata_content: none,
) = {
  // Logo (right side at top)
  place(
    right + top,
    dx: 0pt,
    dy: 0pt,
    if company != none and "logo" in company and company.logo != none [
      #image("/" + company.logo, width: 150pt)
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

  // Metadata box (right side, below logo at 80pt offset)
  place(
    right + top,
    dx: 0pt,
    dy: 80pt,
    block(width: 195pt)[
      #set text(size: 8pt)
      #set par(leading: 0.5em)
      #set align(left)

      // Contact info section
      #if company != none [
        #text(weight: "bold")[Rückfragen an:]\
        #company.name\
        #if "phone" in company.contact and company.contact.phone != none [
          #company.contact.phone\
        ]
        #if "email" in company.contact and company.contact.email != none [
          #company.contact.email
        ]
      ]

      #v(5pt)

      // Document metadata
      #set text(size: 10pt)
      #set par(leading: 0.6em)
      #metadata_content
    ]
  )
}

/// Helper function to create metadata content for invoices
///
/// Parameters:
/// - invoice_number: Invoice number (required)
/// - invoice_date: Invoice date object (required)
/// - customer_number: Optional customer number
/// - performance_period: Optional performance period string
/// - due_date: Optional due date object
///
/// Returns: Content block with formatted metadata
#let invoice-metadata(
  invoice_number: none,
  invoice_date: none,
  customer_number: none,
  performance_period: none,
  due_date: none,
) = [
  *Rechnungs-Nr.:* #invoice_number\
  #if customer_number != none [
    *Kunden-Nr.:* #customer_number\
  ]
  *Rechnungsdatum:* #format_german_date(invoice_date)\
  #if performance_period != none [
    *Leistungszeitraum:* #performance_period\
  ]
  #if due_date != none [
    *Fällig am:* #format_german_date(due_date)\
  ]
]

/// Helper function to create metadata content for offers
///
/// Parameters:
/// - offer_number: Offer number (required)
/// - offer_date: Offer date object (required)
/// - valid_until: Optional validity date object
/// - customer_number: Optional customer number
///
/// Returns: Content block with formatted metadata
#let offer-metadata(
  offer_number: none,
  offer_date: none,
  valid_until: none,
  customer_number: none,
) = [
  *Angebots-Nr.:* #offer_number\
  #if customer_number != none [
    *Kunden-Nr.:* #customer_number\
  ]
  *Angebotsdatum:* #format_german_date(offer_date)\
  #if valid_until != none [
    *Gültig bis:* #format_german_date(valid_until)\
  ]
]

/// Helper function to create metadata content for credit notes
///
/// Parameters:
/// - credit_note_number: Credit note number (required)
/// - date: Credit note date object (required)
/// - invoice_reference: Optional reference to original invoice
///
/// Returns: Content block with formatted metadata
#let credit-note-metadata(
  credit_note_number: none,
  date: none,
  invoice_reference: none,
) = [
  *Gutschrift-Nr.:* #credit_note_number\
  #if invoice_reference != none [
    *Bezug Rechnung:* #invoice_reference\
  ]
  *Datum:* #format_german_date(date)\
]

/// Helper function to create metadata content for delivery notes
///
/// Parameters:
/// - delivery_note_number: Delivery note number (required)
/// - delivery_date: Delivery date object (required)
/// - order_reference: Optional order reference
/// - delivery_time: Optional delivery time string
///
/// Returns: Content block with formatted metadata
#let delivery-note-metadata(
  delivery_note_number: none,
  delivery_date: none,
  order_reference: none,
  delivery_time: none,
) = [
  *Lieferschein-Nr.:* #delivery_note_number\
  #if order_reference != none [
    *Bestell-Nr.:* #order_reference\
  ]
  *Lieferdatum:* #format_german_date(delivery_date)\
  #if delivery_time != none [
    *Lieferzeit:* #delivery_time\
  ]
]

/// Helper function to create metadata content for order confirmations
///
/// Parameters:
/// - confirmation_number: Order confirmation number (required)
/// - confirmation_date: Confirmation date object (required)
/// - order_number: Optional customer order number
/// - expected_delivery: Optional expected delivery date object
///
/// Returns: Content block with formatted metadata
#let order-confirmation-metadata(
  confirmation_number: none,
  confirmation_date: none,
  order_number: none,
  expected_delivery: none,
) = [
  *Bestätigungs-Nr.:* #confirmation_number\
  #if order_number != none [
    *Bestellnummer:* #order_number\
  ]
  *Datum:* #format_german_date(confirmation_date)\
  #if expected_delivery != none [
    *Voraussichtl. Lieferung:* #format_german_date(expected_delivery)\
  ]
]

/// Helper function to create metadata content for quotation requests
///
/// Parameters:
/// - request_number: Request number (required)
/// - request_date: Request date object (required)
/// - response_deadline: Optional response deadline date object
///
/// Returns: Content block with formatted metadata
#let quotation-request-metadata(
  request_number: none,
  request_date: none,
  response_deadline: none,
) = [
  *Anfrage-Nr.:* #request_number\
  *Datum:* #format_german_date(request_date)\
  #if response_deadline != none [
    *Antwort erbeten bis:* #format_german_date(response_deadline)\
  ]
]

/// Helper function to create metadata content for reminders
///
/// Parameters:
/// - reminder_number: Reminder number (required)
/// - reminder_date: Reminder date object (required)
/// - reminder_level: Reminder level (e.g., "1. Mahnung", "2. Mahnung")
///
/// Returns: Content block with formatted metadata
#let reminder-metadata(
  reminder_number: none,
  reminder_date: none,
  reminder_level: none,
) = [
  *Mahnungs-Nr.:* #reminder_number\
  #if reminder_level != none [
    *Mahnstufe:* #reminder_level\
  ]
  *Datum:* #format_german_date(reminder_date)\
]

/// Helper function to create metadata content for letters
///
/// Parameters:
/// - letter_date: Letter date object (required)
/// - reference: Optional reference/subject line
///
/// Returns: Content block with formatted metadata
#let letter-metadata(
  letter_date: none,
  reference: none,
) = [
  #if reference != none [
    *Betreff:* #reference\
  ]
  *Datum:* #format_german_date(letter_date)\
]

/// Helper function to create metadata content for time sheets
///
/// Parameters:
/// - timesheet_number: Time sheet number (required)
/// - period_start: Period start date object (required)
/// - period_end: Period end date object (required)
/// - employee: Optional employee name
///
/// Returns: Content block with formatted metadata
#let timesheet-metadata(
  timesheet_number: none,
  period_start: none,
  period_end: none,
  employee: none,
) = [
  *Stundenzettel-Nr.:* #timesheet_number\
  #if employee != none [
    *Mitarbeiter:* #employee\
  ]
  *Zeitraum:* #format_german_date(period_start) - #format_german_date(period_end)\
]
