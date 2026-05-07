// Common Typst Styles
// This file contains reusable style definitions for all templates
// Based on casoon-documents styling
//
// NOTE: This file defines DEFAULTS only. Company-specific values (colors, fonts)
// are passed via the `company` parameter in template functions.
// This allows templates to work as Typst packages without filesystem access issues.

// ============================================================================
// FONT PRESETS (Google Fonts)
// ============================================================================
// Available presets: inter, roboto, open-sans, lato, montserrat, 
//                    source-sans, poppins, raleway, nunito, work-sans
//
// Each preset defines: body font, heading font, mono font
// Set in company.json: "branding": { "font_preset": "inter" }

#let font-presets = (
  // Modern, clean sans-serif (default)
  "inter": (
    body: "Inter",
    heading: "Inter",
    mono: "JetBrains Mono",
  ),
  // Google's signature font, very readable
  "roboto": (
    body: "Roboto",
    heading: "Roboto",
    mono: "Roboto Mono",
  ),
  // Humanist sans-serif, friendly appearance
  "open-sans": (
    body: "Open Sans",
    heading: "Open Sans",
    mono: "Source Code Pro",
  ),
  // Elegant, slightly rounded
  "lato": (
    body: "Lato",
    heading: "Lato",
    mono: "Fira Code",
  ),
  // Geometric, modern, great for headings
  "montserrat": (
    body: "Montserrat",
    heading: "Montserrat",
    mono: "Fira Code",
  ),
  // Adobe's open source, professional
  "source-sans": (
    body: "Source Sans 3",
    heading: "Source Sans 3",
    mono: "Source Code Pro",
  ),
  // Geometric, playful yet professional
  "poppins": (
    body: "Poppins",
    heading: "Poppins",
    mono: "JetBrains Mono",
  ),
  // Elegant, sophisticated
  "raleway": (
    body: "Raleway",
    heading: "Raleway",
    mono: "Fira Code",
  ),
  // Rounded, friendly, very readable
  "nunito": (
    body: "Nunito",
    heading: "Nunito",
    mono: "JetBrains Mono",
  ),
  // Clean, neutral, versatile
  "work-sans": (
    body: "Work Sans",
    heading: "Work Sans",
    mono: "Fira Code",
  ),
  // System default (Helvetica-based)
  "default": (
    body: "Helvetica",
    heading: "Helvetica",
    mono: "Courier New",
  ),
)

// Get font preset from company data or use default
// This function is called by templates with the company parameter
#let get-font-preset(company) = {
  if company != none and "branding" in company and "font_preset" in company.branding {
    let preset-name = company.branding.font_preset
    if preset-name in font-presets {
      font-presets.at(preset-name)
    } else {
      font-presets.at("default")
    }
  } else {
    font-presets.at("default")
  }
}

// Default preset (used when no company data available)
#let active-preset = font-presets.at("default")

// ============================================================================
// COLOR PALETTE
// ============================================================================

// Default colors (overridden by company branding in templates)
#let color-primary = rgb("#2c3e50")
#let color-accent = rgb("#E94B3C")

// Helper functions to get colors from company data
#let get-primary-color(company) = {
  if company != none and "branding" in company and "primary_color" in company.branding {
    rgb(company.branding.primary_color)
  } else {
    color-primary
  }
}

#let get-accent-color(company) = {
  if company != none and "branding" in company and "accent_color" in company.branding {
    rgb(company.branding.accent_color)
  } else {
    color-accent
  }
}

#let get-language(company) = {
  if company != none and "language" in company { company.language } else { "de" }
}

#let color-secondary = rgb("#34495e")
#let color-text = rgb("#2c3e50")
#let color-text-light = rgb("#7f8c8d")
#let color-border = rgb("#bdc3c7")
#let color-background = rgb("#f5f5f5")
#let color-white = rgb("#ffffff")
#let color-warning = rgb("#fff8e1")

// ============================================================================
// TYPOGRAPHY
// ============================================================================

// Font families (from active preset)
#let font-body = active-preset.body
#let font-heading = active-preset.heading
#let font-mono = active-preset.mono

#let size-xs = 7pt
#let size-small = 8pt
#let size-normal = 9pt
#let size-medium = 10pt
#let size-large = 11pt
#let size-xlarge = 13pt
#let size-xxlarge = 16pt
#let size-title = 22pt

// Text Styles (as dictionaries for use with set text(..style))
#let text-body = (
  font: font-body,
  size: size-medium,
  fill: color-text,
)

#let text-small = (
  font: font-body,
  size: size-small,
  fill: color-text-light,
)

#let text-heading = (
  font: font-heading,
  size: size-large,
  fill: color-primary,
  weight: "bold",
)

#let text-title = (
  font: font-heading,
  size: size-xxlarge,
  fill: color-primary,
  weight: "bold",
)

#let text-mono = (
  font: font-mono,
  size: size-small,
)

// Layout Spacing
#let spacing-xs = 0.2em
#let spacing-small = 0.3em
#let spacing-normal = 0.5em
#let spacing-medium = 1em
#let spacing-large = 1.5em
#let spacing-xlarge = 2em

// Border Styles
#let border-thin = 0.5pt
#let border-normal = 1pt
#let border-thick = 2pt

// UTILITY: Currency format
#let format-currency(amount, currency: "EUR") = [#amount #currency]

// UTILITY: Pill/tag component
#let pill(content, stroke-color: color-text-light) = box(
  stroke: 0.75pt + stroke-color,
  radius: 10pt,
  inset: (x: 10pt, y: 5pt),
  text(size: size-small, fill: stroke-color)[#content]
)

// UTILITY: Info box
#let info-box(content, fill: color-background) = block(
  fill: fill,
  inset: spacing-medium,
  radius: 4pt,
  width: 100%,
  content
)

// UTILITY: Warning box
#let warning-box(content, accent: color-accent) = block(
  stroke: 1.5pt + accent,
  radius: 6pt,
  inset: spacing-medium,
  width: 100%,
  content
)

// UTILITY: Resolve placeholder in footer line
// Replaces {field} and {field.subfield} with values from company data
#let resolve-placeholder(template, company) = {
  let result = template
  
  // Simple field replacements
  if result.contains("{name}") and "name" in company {
    result = result.replace("{name}", company.name)
  }
  if result.contains("{business_owner}") and "business_owner" in company and company.business_owner != none {
    result = result.replace("{business_owner}", company.business_owner)
  }
  if result.contains("{tax_id}") and "tax_id" in company and company.tax_id != none {
    result = result.replace("{tax_id}", company.tax_id)
  }
  if result.contains("{vat_id}") and "vat_id" in company and company.vat_id != none {
    result = result.replace("{vat_id}", company.vat_id)
  }
  
  // Address fields
  if result.contains("{address.street}") and "address" in company and "street" in company.address {
    result = result.replace("{address.street}", company.address.street)
  }
  if result.contains("{address.house_number}") and "address" in company and "house_number" in company.address {
    result = result.replace("{address.house_number}", company.address.house_number)
  }
  if result.contains("{address.postal_code}") and "address" in company and "postal_code" in company.address {
    result = result.replace("{address.postal_code}", company.address.postal_code)
  }
  if result.contains("{address.city}") and "address" in company and "city" in company.address {
    result = result.replace("{address.city}", company.address.city)
  }
  if result.contains("{address.country}") and "address" in company and "country" in company.address {
    result = result.replace("{address.country}", company.address.country)
  }
  
  // Contact fields
  if result.contains("{contact.phone}") and "contact" in company and "phone" in company.contact {
    result = result.replace("{contact.phone}", company.contact.phone)
  }
  if result.contains("{contact.email}") and "contact" in company and "email" in company.contact {
    result = result.replace("{contact.email}", company.contact.email)
  }
  if result.contains("{contact.website}") and "contact" in company and "website" in company.contact {
    result = result.replace("{contact.website}", company.contact.website)
  }
  
  // Bank account fields
  if result.contains("{bank_account.bank_name}") and "bank_account" in company and "bank_name" in company.bank_account {
    result = result.replace("{bank_account.bank_name}", company.bank_account.bank_name)
  }
  if result.contains("{bank_account.iban}") and "bank_account" in company and "iban" in company.bank_account {
    result = result.replace("{bank_account.iban}", company.bank_account.iban)
  }
  if result.contains("{bank_account.bic}") and "bank_account" in company and "bic" in company.bank_account {
    result = result.replace("{bank_account.bic}", company.bank_account.bic)
  }
  if result.contains("{bank_account.account_holder}") and "bank_account" in company and "account_holder" in company.bank_account {
    result = result.replace("{bank_account.account_holder}", company.bank_account.account_holder)
  }
  
  result
}

// UTILITY: Dynamic footer from company.json
// Automatically adjusts column count (1-4) based on footer configuration
#let company-footer(company, show-line: true) = {
  if "footer" not in company or "columns" not in company.footer {
    return []
  }
  
  let footer-columns = company.footer.columns
  let col-count = footer-columns.len()
  
  if col-count == 0 {
    return []
  }
  
  // Build column content
  let col-content = ()
  for col in footer-columns {
    let lines = ()
    
    // Add title if present
    if "title" in col and col.title != none {
      lines.push(strong[#col.title])
    }
    
    // Add lines with placeholder resolution
    if "lines" in col {
      for line in col.lines {
        let resolved = resolve-placeholder(line, company)
        // Skip lines that still contain unresolved placeholders
        if not resolved.contains("{") {
          lines.push(resolved)
        }
      }
    }
    
    // Join lines with linebreaks
    col-content.push(lines.join(linebreak()))
  }
  
  // Calculate column widths (equal distribution)
  let col-width = 100% / col-count
  let col-widths = range(col-count).map(_ => col-width)
  
  [
    #if show-line [
      #line(length: 100%, stroke: border-thin)
      #v(5pt)
    ]
    #set text(size: size-xs)
    #grid(
      columns: col-widths,
      column-gutter: 8pt,
      ..col-content
    )
  ]
}
