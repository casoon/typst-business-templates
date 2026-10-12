// DIN 5008 Address Block Component
// Reusable DIN 5008-compliant address layout for business documents

/// Renders a DIN 5008-compliant address block with sender line and recipient address
///
/// DIN 5008 specifications:
/// - Address window position: 45mm from top (77.5pt)
/// - Sender line: 17.7mm height (20pt), 6pt font size (reduced to 8pt for readability)
/// - Recipient address: 27.3mm height (77.5pt), 10pt font size (increased to 12pt for readability)
///
/// Parameters:
/// - company: Company data dictionary with address and optional business_owner
/// - recipient: Recipient data dictionary with name, optional company, and address
/// - company-first: print recipient.company above recipient.name (offer) instead of below
///
/// Example:
/// ```typst
/// #din5008-address-block(
///   company: (
///     name: "Acme Corp",
///     business_owner: "John Doe",
///     address: (street: "Main St", house_number: "123", postal_code: "12345", city: "Berlin")
///   ),
///   recipient: (
///     name: "Jane Smith",
///     company: "Client Corp",
///     address: (street: "Oak Ave", house_number: "456", postal_code: "54321", city: "Munich")
///   )
/// )
/// ```
#let din5008-address-block(
  company: none,
  recipient: none,
  company-first: false,
) = {
  // DIN 5008 positioning: 45mm from top = 77.5pt
  v(77.5pt)

  // Sender line (return address)
  block(height: 20pt)[
    #set text(size: 8pt, font: "Helvetica")
    #if company != none [
      #if "business_owner" in company and company.business_owner != none [
        #company.business_owner · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
      ] else [
        #company.name · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
      ]
    ]
  ]

  // Recipient address block
  block(height: 120pt)[
    #set text(size: 12pt, font: "Helvetica")
    
    #if recipient != none [
      // The company line is left out when it repeats the name
      #let firm = recipient.at("company", default: none)
      #if firm == recipient.name { firm = none }
      #if company-first and firm != none [
        #firm\
      ]
      #recipient.name\
      #if not company-first and firm != none [
        #firm\
      ]
      #recipient.address.street #recipient.address.house_number\
      #recipient.address.postal_code #recipient.address.city
    ]
  ]
}

/// Renders a DIN 5008 address block with custom delivery address (e.g., for delivery notes)
///
/// Parameters:
/// - company: Company data dictionary
/// - recipient: Billing/primary recipient data
/// - delivery_address: Optional delivery address (overrides recipient address if present)
///
/// Example:
/// ```typst
/// #din5008-address-block-with-delivery(
///   company: company_data,
///   recipient: billing_address,
///   delivery_address: (
///     name: "Warehouse Manager",
///     company: "Client Corp Warehouse",
///     address: (street: "Industrial Rd", house_number: "789", postal_code: "98765", city: "Hamburg")
///   )
/// )
/// ```
#let din5008-address-block-with-delivery(
  company: none,
  recipient: none,
  delivery_address: none,
) = {
  // DIN 5008 positioning
  v(77.5pt)

  // Sender line
  block(height: 20pt)[
    #set text(size: 8pt, font: "Helvetica")
    #if company != none [
      #if "business_owner" in company and company.business_owner != none [
        #company.business_owner · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
      ] else [
        #company.name · #company.address.street #company.address.house_number · #company.address.postal_code #company.address.city
      ]
    ]
  ]

  // Recipient or delivery address block
  block(height: 120pt)[
    #set text(size: 12pt, font: "Helvetica")
    
    // Use delivery address if present, otherwise fallback to recipient
    #if delivery_address != none [
      #if "company" in delivery_address and delivery_address.company != none [
        #delivery_address.company\
      ]
      #if "name" in delivery_address [
        #delivery_address.name\
      ]
      #delivery_address.address.street #delivery_address.address.house_number\
      #delivery_address.address.postal_code #delivery_address.address.city
    ] else if recipient != none [
      #recipient.name\
      #if "company" in recipient and recipient.company != none [
        #recipient.company\
      ]
      #recipient.address.street #recipient.address.house_number\
      #recipient.address.postal_code #recipient.address.city
    ]
  ]
}
