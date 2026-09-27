// Common Title Page Components
// Reusable title page elements for technical documents
// Based on credentials template structure

#import "styles.typ": *

/// Renders a standard title page with logo, title, subtitle, and metadata grid
///
/// Parameters:
/// - company: Company data (with optional _logo_image or logo path)
/// - title: Main document title (required)
/// - subtitle: Optional subtitle
/// - document-type: Document type label (e.g., "CREDENTIALS", "TASK LIST")
/// - document-number: Optional document number
/// - accent-color: Color for document type and accents
/// - metadata: Dictionary with metadata entries (e.g., (project: "...", client: "...", date: "..."))
/// - custom-content: Optional custom content to insert (default: none)
#let standard-title-page(
  company: none,
  title: none,
  subtitle: none,
  document-type: none,
  document-number: none,
  accent-color: rgb("#2563eb"),
  metadata: (:),
  custom-content: none,
) = {
  v(50pt)
  
  // Logo
  align(center)[
    #if company != none and "_logo_image" in company [
      #company._logo_image
    ] else if company != none and "logo" in company and company.logo != none [
      #image("/" + company.logo, width: 150pt)
    ]
  ]
  
  v(30pt)
  
  // Document title
  if title != none [
    #align(center)[
      #text(size: size-title, weight: "bold")[#title]
    ]
    #v(20pt)
  ]
  
  // Document type and number
  align(center)[
    #if document-type != none [
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[#upper(document-type)]
    ]
    #if document-number != none [
      #text(size: size-xlarge, fill: color-text-light)[
        #if document-type != none [ · ]
        #document-number
      ]
    ]
  ]
  
  if subtitle != none [
    #v(10pt)
    #align(center)[
      #text(size: size-large, fill: color-text-light)[#subtitle]
    ]
  ]
  
  // Metadata grid
  v(30pt)
  
  if metadata.len() > 0 [
    #align(center)[
      #grid(
        columns: (auto, auto),
        row-gutter: 14pt,
        column-gutter: 20pt,
        align: (right, left),
        ..if type(metadata) == array {
          // If metadata is an array of tuples, flatten it directly
          metadata.flatten()
        } else {
          // If metadata is a dictionary, convert to array of tuples
          metadata.pairs().map(((key, value)) => {
            ([*#key:*], [#value])
          }).flatten()
        }
      )
    ]
  ]
  
  // Custom content area (for additional elements)
  if custom-content != none [
    #v(20pt)
    #custom-content
  ]
  
  v(1fr)
}

/// Renders a document title page with tags/pills support
/// Used for technical documents like concepts, documentation, specifications
///
/// Parameters:
/// - company: Company data (with optional _logo_image or logo path)
/// - logo: Optional logo content (takes precedence over company.logo)
/// - title: Main document title (required)
/// - document-type: Document type label (e.g., "CONCEPT", "DOCUMENTATION")
/// - document-number: Optional document number
/// - accent-color: Color for document type and accents
/// - metadata: Dictionary with metadata entries
/// - tags: Array of tag strings to display as pills at bottom (none or empty: no pills)
/// - custom-content: Optional custom content to insert before tags
#let document-title-page(
  company: none,
  logo: none,
  title: none,
  document-type: none,
  document-number: none,
  accent-color: rgb("#2563eb"),
  metadata: (:),
  tags: (),
  custom-content: none,
) = {
  v(50pt)
  
  // Logo (prioritize passed logo parameter)
  align(center)[
    #if logo != none [
      #logo
    ] else if company != none and "_logo_image" in company [
      #company._logo_image
    ] else if company != none and "logo" in company and company.logo != none [
      #image("/" + company.logo, width: 150pt)
    ]
  ]
  
  v(30pt)
  
  // Document title
  if title != none [
    #align(center)[
      #text(size: size-title, weight: "bold")[#title]
    ]
    #v(20pt)
  ]
  
  // Document type and number
  align(center)[
    #if document-type != none [
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[#upper(document-type)]
    ]
    #if document-number != none [
      #text(size: size-xlarge, fill: color-text-light)[
        #if document-type != none [ · ]
        #document-number
      ]
    ]
  ]
  
  v(30pt)
  
  // Metadata grid
  if metadata.len() > 0 [
    #align(center)[
      #grid(
        columns: (auto, auto),
        row-gutter: 14pt,
        column-gutter: 20pt,
        align: (right, left),
        ..if type(metadata) == array {
          // If metadata is an array of tuples, flatten it directly
          metadata.flatten()
        } else {
          // If metadata is a dictionary, convert to array of tuples
          metadata.pairs().map(((key, value)) => {
            ([*#key:*], [#value])
          }).flatten()
        }
      )
    ]
  ]
  
  v(1fr)
  
  // Custom content area (before tags)
  if custom-content != none [
    #custom-content
    #v(20pt)
  ]
  
  // Tags/Pills at bottom
  if tags != none and tags.len() > 0 [
    #align(center)[
      #for tag in tags [
        #box(
          fill: accent-color.lighten(80%),
          inset: (x: 10pt, y: 5pt),
          radius: 12pt,
          text(size: size-xs, fill: accent-color, weight: "bold")[#upper(tag)]
        )
        #h(8pt)
      ]
    ]
    #v(40pt)
  ]
}

/// Renders a parties title page for contracts and SLAs
/// Shows two party boxes with addresses
///
/// Parameters:
/// - company: Company data
/// - logo: Optional logo content (takes precedence over company.logo)
/// - title: Document title
/// - document-type: Document type label (e.g., contract type or "SERVICE LEVEL AGREEMENT")
/// - document-number: Document number
/// - accent-color: Color for document type and accents
/// - party1-label: Label for first party (e.g., "Auftragnehmer", "Dienstleister")
/// - party1-name: Name of first party
/// - party1-address: Address dictionary with street, house_number, postal_code, city
/// - party2-label: Label for second party (e.g., "Auftraggeber", "Kunde")
/// - party2-name: Name of second party
/// - party2-address: Address dictionary
/// - metadata: Additional metadata dictionary for dates etc.
/// - custom-content: Optional custom content
#let parties-title-page(
  company: none,
  logo: none,
  title: none,
  document-type: none,
  document-number: none,
  accent-color: rgb("#2563eb"),
  party1-label: "Party 1",
  party1-name: none,
  party1-address: none,
  party2-label: "Party 2",
  party2-name: none,
  party2-address: none,
  metadata: (:),
  custom-content: none,
) = {
  v(50pt)
  
  // Logo (prioritize passed logo parameter)
  align(center)[
    #if logo != none [
      #logo
    ] else if company != none and "_logo_image" in company [
      #company._logo_image
    ] else if company != none and "logo" in company and company.logo != none [
      #image("/" + company.logo, width: 150pt)
    ]
  ]
  
  v(30pt)
  
  // Document title
  if title != none [
    #align(center)[
      #text(size: size-title, weight: "bold")[#title]
    ]
    #v(20pt)
  ]
  
  // Document type and number
  align(center)[
    #if document-type != none [
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[#upper(document-type)]
    ]
    #if document-number != none [
      #text(size: size-xlarge, fill: color-text-light)[
        #if document-type != none [ · ]
        #document-number
      ]
    ]
  ]
  
  v(30pt)
  
  // Party boxes
  align(center)[
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 20pt,
      
      // Party 1
      block(
        width: 100%,
        stroke: border-normal + accent-color.lighten(40%),
        radius: 4pt,
        inset: 1em,
      )[
        #align(center)[
          #text(size: size-small, fill: accent-color, weight: "bold")[#upper(party1-label)]
        ]
        #v(0.5em)
        #if party1-name != none [
          #text(size: size-medium, weight: "bold")[#party1-name]\
        ]
        #if party1-address != none [
          #v(0.3em)
          #text(size: size-small)[
            #party1-address.street #party1-address.house_number\
            #party1-address.postal_code #party1-address.city
          ]
        ]
      ],
      
      // Party 2
      block(
        width: 100%,
        stroke: border-normal + accent-color.lighten(40%),
        radius: 4pt,
        inset: 1em,
      )[
        #align(center)[
          #text(size: size-small, fill: accent-color, weight: "bold")[#upper(party2-label)]
        ]
        #v(0.5em)
        #if party2-name != none [
          #text(size: size-medium, weight: "bold")[#party2-name]\
        ]
        #if party2-address != none [
          #v(0.3em)
          #text(size: size-small)[
            #party2-address.street #party2-address.house_number\
            #party2-address.postal_code #party2-address.city
          ]
        ]
      ]
    )
  ]
  
  v(30pt)
  
  // Additional metadata
  if metadata.len() > 0 [
    #align(center)[
      #grid(
        columns: (auto, auto),
        row-gutter: 14pt,
        column-gutter: 20pt,
        align: (right, left),
        ..if type(metadata) == array {
          // If metadata is an array of tuples, flatten it directly
          metadata.flatten()
        } else {
          // If metadata is a dictionary, convert to array of tuples
          metadata.pairs().map(((key, value)) => {
            ([*#key:*], [#value])
          }).flatten()
        }
      )
    ]
  ]
  
  // Custom content
  if custom-content != none [
    #v(20pt)
    #custom-content
  ]
  
  v(1fr)
}

/// Renders an enhanced title page for proposals with prominent info box
/// Shows key information in a highlighted box with background
///
/// Parameters:
/// - company: Company data
/// - logo: Optional logo content (takes precedence over company.logo)
/// - title: Document title
/// - document-type: Document type label (e.g., "PROJEKTVORSCHLAG")
/// - document-number: Document number
/// - accent-color: Color for document type and accents
/// - info-box-content: Content to display in the info box (grid or custom content)
/// - tags: Array of tag strings
/// - authors: Optional authors text to display below tags
/// - custom-content: Optional additional custom content
#let enhanced-title-page(
  company: none,
  logo: none,
  title: none,
  document-type: none,
  document-number: none,
  accent-color: rgb("#2563eb"),
  info-box-content: none,
  tags: (),
  authors: none,
  custom-content: none,
) = {
  v(50pt)
  
  // Logo (prioritize passed logo parameter)
  align(center)[
    #if logo != none [
      #logo
    ] else if company != none and "_logo_image" in company [
      #company._logo_image
    ] else if company != none and "logo" in company and company.logo != none [
      #image("/" + company.logo, width: 150pt)
    ]
  ]
  
  v(30pt)
  
  // Document title (larger than standard)
  if title != none [
    #align(center)[
      #text(size: 28pt, weight: "bold")[#title]
    ]
    #v(20pt)
  ]
  
  // Document type and number
  align(center)[
    #if document-type != none [
      #text(size: size-xlarge, fill: accent-color, weight: "bold")[#upper(document-type)]
    ]
    #if document-number != none [
      #text(size: size-xlarge, fill: color-text-light)[
        #if document-type != none [ · ]
        #document-number
      ]
    ]
  ]
  
  v(30pt)
  
  // Enhanced info box
  if info-box-content != none [
    #align(center)[
      #block(
        width: 85%,
        stroke: 1.5pt + accent-color,
        radius: 6pt,
        inset: 1.5em,
        fill: accent-color.lighten(95%),
      )[
        #info-box-content
      ]
    ]
  ]
  
  v(1fr)
  
  // Custom content
  if custom-content != none [
    #custom-content
    #v(20pt)
  ]
  
  // Tags at bottom
  if tags != none and tags.len() > 0 [
    #align(center)[
      #for tag in tags [
        #box(
          fill: accent-color.lighten(80%),
          inset: (x: 10pt, y: 5pt),
          radius: 12pt,
          text(size: size-xs, fill: accent-color, weight: "bold")[#upper(tag)]
        )
        #h(8pt)
      ]
    ]
    #v(15pt)
  ]
  
  // Authors text below tags
  if authors != none [
    #align(center)[
      #text(size: size-small, fill: color-text-light)[#authors]
    ]
    #v(40pt)
  ]
}
