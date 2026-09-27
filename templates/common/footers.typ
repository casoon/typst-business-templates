// Common Footer Templates for Business Documents
// Provides reusable footer layouts for different document types

#import "styles.typ": *

// ============================================================================
// STANDARD DOCUMENT FOOTER (4-column layout)
// Used by: documentation, concept, specification, contract
// ============================================================================

#let document-footer(
  company: none,
  locale: none,
  document_number: none,
  created_at: none,
  status: "Draft",
  // Optional for specification/versioned documents
  version: none,
  last_updated: none,
) = {
  // Locale strings with fallbacks
  let l-document = if locale != none and "common" in locale and "document" in locale.common {
    locale.common.document
  } else {
    "Document"
  }
  
  let l-page = if locale != none and "common" in locale and "page" in locale.common {
    locale.common.page
  } else {
    "Page"
  }
  
  let l-created = if locale != none and "common" in locale and "created" in locale.common {
    locale.common.created
  } else {
    "Created"
  }
  
  let l-status = if locale != none and "common" in locale and "status" in locale.common {
    locale.common.status
  } else {
    "Status"
  }
  
  context [
    #line(length: 100%, stroke: border-thin)
    #v(5pt)
    #set text(size: size-xs)
    #grid(
      columns: (125pt, 125pt, 125pt, 125pt),
      column-gutter: 0pt,

      // Column 1: Company Info
      [
        #if company != none and "name" in company [#strong[#company.name] #linebreak()]
        #if company != none and "address" in company [
          #if "street" in company.address [#company.address.street ]
          #if "house_number" in company.address [#company.address.house_number]
          #linebreak()
          #if "postal_code" in company.address [#company.address.postal_code ]
          #if "city" in company.address [#company.address.city]
        ]
      ],

      // Column 2: Contact
      [
        #if company != none and "contact" in company [
          #if "phone" in company.contact [Tel.: #company.contact.phone #linebreak()]
          #if "email" in company.contact [Email: #company.contact.email #linebreak()]
          #if "website" in company.contact [Web: #company.contact.website]
        ]
      ],

      // Column 3: Document Info
      [
        #strong[#l-document:] #linebreak()
        #document_number #linebreak()
        #l-page #counter(page).display()
      ],

      // Column 4: Metadata (supports both created_at and version/last_updated)
      [
        #if version != none [
          // Version-style (for specification, contract, etc.)
          #strong[Version:] #version #linebreak()
          #if status != none [#l-status: #status #linebreak()]
          #if last_updated != none [Aktualisiert: #last_updated]
        ] else [
          // Standard style (for documentation, concept)
          #strong[#l-created:] #linebreak()
          #if created_at != none [#created_at] #linebreak()
          #if status != none [#l-status: #status]
        ]
      ],
    )
  ]
}

// ============================================================================
// MINIMAL FOOTER (3-column layout)
// Used by: protocol (simplified meeting minutes)
// ============================================================================

#let minimal-footer(
  company: none,
  locale: none,
  document_number: none,
) = {
  let l-page = if locale != none and "common" in locale and "page" in locale.common {
    locale.common.page
  } else {
    "Page"
  }
  
  context [
    #line(length: 100%, stroke: border-thin)
    #v(5pt)
    #set text(size: size-xs)
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),

      [#if company != none and "name" in company [#company.name]],
      [#l-page #counter(page).display()],
      [#document_number],
    )
  ]
}

// ============================================================================
// ACCOUNTING FOOTER (4-column business layout)
// Used by: invoice, offer, credit-note, etc.
// ============================================================================

#let accounting-footer(
  company: none,
) = {
  context [
    #set text(size: 7pt, font: "Helvetica")

    #place(
      left + bottom,
      dx: 0pt,
      dy: -10pt,
      block(width: 500pt)[
        #grid(
          columns: (125pt, 125pt, 125pt, 125pt),
          column-gutter: 0pt,
          align: (top, top, top, top),

          // Column 1: Company Contact
          [
            #if company != none and "name" in company [
              #text(weight: "bold")[#company.name]\
            ]
            #if company != none and "business_owner" in company and company.business_owner != none [
              #company.business_owner\
            ]
            #if company != none and "address" in company [
              #company.address.street #company.address.house_number\
              #company.address.postal_code #company.address.city
            ]
          ],

          // Column 2: Contact Details
          [
            #if company != none and "contact" in company [
              #if "phone" in company.contact and company.contact.phone != none [
                Tel.: #company.contact.phone\
              ]
              #if "email" in company.contact and company.contact.email != none [
                Email: #company.contact.email\
              ]
              #if "website" in company.contact and company.contact.website != none [
                Web: #company.contact.website
              ]
            ]
          ],

          // Column 3: Business Info
          [
            Geschäftsinhaber:\
            #if company != none and "business_owner" in company and company.business_owner != none [
              #company.business_owner\
            ]
            USt-IdNr.:\
            #if company != none and "vat_id" in company and company.vat_id != none [
              #company.vat_id
            ]
          ],

          // Column 4: Bank Account
          [
            #if company != none and "bank_account" in company and company.bank_account != none [
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
}
