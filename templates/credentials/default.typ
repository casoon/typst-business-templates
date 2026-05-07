// Accounts/Credentials Document Template (Zugangsdaten)
// Based on casoon-documents structure

#import "../common/styles.typ": *
#import "../common/title-page.typ": standard-title-page

// Load data from JSON input (only if available)
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

// Load company and locale from sys.inputs (passed by docgen CLI)
// Only when in JSON workflow (data != none)
#let company = if data != none and "company" in sys.inputs {
  let c = json(sys.inputs.company)
  // Load logo image if logo path is specified
  if "logo" in c and c.logo != none {
    let logo-width = if "logo_width" in c { eval(c.logo_width) } else { 150pt }
    c.insert("_logo_image", image("/" + c.logo, width: logo-width))
  }
  c
} else {
  (:)
}

#let locale = if data != none and "locale" in sys.inputs {
  json(sys.inputs.locale)
} else {
  (common: (:), credentials: (:))
}

// Get branding from company data
#let accent-color = get-accent-color(company)
#let fonts = get-font-preset(company)

// Locale helpers with fallbacks
#let l-confidential = if "credentials" in locale and "confidential" in locale.credentials { locale.credentials.confidential } else { "CONFIDENTIAL" }
#let l-page = if "common" in locale and "page" in locale.common { locale.common.page } else { "Page" }
#let l-project = if "common" in locale and "project" in locale.common { locale.common.project } else { "Project" }
#let l-client = if "common" in locale and "client" in locale.common { locale.common.client } else { "Client" }
#let l-date = if "common" in locale and "date" in locale.common { locale.common.date } else { "Date" }
#let l-title = if "credentials" in locale and "title" in locale.credentials { locale.credentials.title } else { "Credentials" }
#let l-confidential-notice = if "credentials" in locale and "confidential_notice" in locale.credentials { locale.credentials.confidential_notice } else { "This document contains confidential information." }
#let l-technical = if "credentials" in locale and "technical_settings" in locale.credentials { locale.credentials.technical_settings } else { "Technical Settings" }
#let l-ports = if "credentials" in locale and "ports_protocols" in locale.credentials { locale.credentials.ports_protocols } else { "Ports & Protocols" }
#let l-port = if "credentials" in locale and "port" in locale.credentials { locale.credentials.port } else { "Port" }
#let l-protocol = if "credentials" in locale and "protocol" in locale.credentials { locale.credentials.protocol } else { "Protocol" }
#let l-description = if "credentials" in locale and "description" in locale.credentials { locale.credentials.description } else { "Description" }
#let l-username = if "credentials" in locale and "username" in locale.credentials { locale.credentials.username } else { "Username" }
#let l-password = if "credentials" in locale and "password" in locale.credentials { locale.credentials.password } else { "Password" }
#let l-type = if "credentials" in locale and "type" in locale.credentials { locale.credentials.type } else { "Type" }
#let l-notes = if "credentials" in locale and "notes" in locale.credentials { locale.credentials.notes } else { "Notes" }
#let l-security = if "credentials" in locale and "security_notices" in locale.credentials { locale.credentials.security_notices } else { "Security Notices" }
#let l-hint1 = if "credentials" in locale and "security_hint_1" in locale.credentials { locale.credentials.security_hint_1 } else { "Store this document securely." }
#let l-hint2 = if "credentials" in locale and "security_hint_2" in locale.credentials { locale.credentials.security_hint_2 } else { "Do not share with unauthorized persons." }
#let l-hint3 = if "credentials" in locale and "security_hint_3" in locale.credentials { locale.credentials.security_hint_3 } else { "Change passwords regularly." }
#let l-hint4 = if "credentials" in locale and "security_hint_4" in locale.credentials { locale.credentials.security_hint_4 } else { "Use a password manager." }
#let l-hint5 = if "credentials" in locale and "security_hint_5" in locale.credentials { locale.credentials.security_hint_5 } else { "Delete this document after use." }

// Note: Credentials template is CLI-only (requires JSON data via docgen)
// If data is none, the template will fail gracefully when accessing data.metadata

#set page(
  paper: "a4",
  margin: (left: 2.5cm, right: 2cm, top: 2.5cm, bottom: 2.5cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: size-small)
      #grid(
        columns: (1fr, 1fr),
        align: (left, right),
        [#text(fill: accent-color, weight: "bold")[#upper(l-confidential)]],
        [#data.metadata.document_number]
      )
      #v(0.2em)
      #line(length: 100%, stroke: border-thin + accent-color)
    ]
  },
  footer: context {
    if counter(page).get().first() > 1 [
      #line(length: 100%, stroke: border-thin)
      #v(0.2em)
      #set text(size: size-small)
      #grid(
        columns: (1fr, auto, 1fr),
        align: (left, center, right),
        [#data.metadata.client_name],
        [#l-page #counter(page).display()],
        [#data.metadata.created_at.date]
      )
    ]
  }
)

#set text(font: fonts.body, size: size-medium, lang: get-language(company))
#set par(justify: true, leading: 0.65em)

// Heading styles
#show heading.where(level: 1): it => {
  v(25pt)
  block(sticky: true, width: 100%)[
    #text(size: size-xxlarge, weight: "bold", fill: accent-color)[#it.body]
  ]
  v(12pt)
}

#show heading.where(level: 2): it => {
  v(18pt)
  block(sticky: true, width: 100%)[
    #text(size: size-xlarge, weight: "bold")[#it.body]
  ]
  v(8pt)
}

// ============================================================================
// TITLE PAGE
// ============================================================================

// Build metadata dictionary
#let meta = (
  (l-project, data.metadata.project_name),
  (l-client, data.metadata.client_name),
  (l-date, data.metadata.created_at.date),
)

// Security warning box (credentials-specific custom content)
#let security-box = align(center)[
  #box(
    stroke: 1.5pt + accent-color,
    radius: 6pt,
    inset: 1em,
    width: 70%,
  )[
    #align(center)[
      #text(size: size-medium, fill: accent-color, weight: "bold")[
        #upper(l-confidential)
      ]
      #v(0.3em)
      #text(size: size-small, fill: color-text-light)[
        #l-confidential-notice
      ]
    ]
  ]
]

// Render standard title page with credentials-specific customization
#standard-title-page(
  company: company,
  title: data.metadata.title,
  subtitle: none,
  document-type: l-title,
  document-number: data.metadata.document_number,
  accent-color: accent-color,
  metadata: meta,
  custom-content: security-box,
)

// Tags as outlined pills
#if "tags" in data.metadata and data.metadata.tags.len() > 0 [
  #align(center)[
    #for tag in data.metadata.tags [
      #pill(tag)
      #h(8pt)
    ]
  ]
  #v(30pt)
]

// Email
#align(center)[
  #set text(size: size-small, fill: color-text-light)
  #if "contact" in company and "email" in company.contact [#company.contact.email]
]

#v(40pt)

#pagebreak()

// ============================================================================
// CONTENT
// ============================================================================

// Services and credentials
#for (index, service) in data.services.enumerate() [
  #if index > 0 [
    #v(2em)
    #line(length: 100%, stroke: border-thin + color-border)
  ]

  = #service.name

  #if "description" in service and service.description != none [
    #service.description
    #v(0.5em)
  ]

  #if "url" in service and service.url != none [
    *URL:* #link(service.url)[#service.url]
    #v(0.5em)
  ]

  // Technical settings
  #if "technical" in service and service.technical.len() > 0 [
    == #l-technical

    #block(
      fill: color-background,
      inset: 1em,
      radius: 4pt,
      width: 100%,
    )[
      #table(
        columns: (auto, 1fr),
        stroke: none,
        inset: 0.4em,
        ..service.technical.map(setting => (
          [*#setting.key:*],
          [#raw(str(setting.value))]
        )).flatten()
      )
    ]
    #v(0.5em)
  ]

  // Ports
  #if "ports" in service and service.ports.len() > 0 [
    == #l-ports

    #table(
      columns: (auto, auto, auto),
      inset: 0.6em,
      stroke: border-thin + color-border,
      fill: (x, y) => if y == 0 { color-background } else { none },
      [*#l-port*], [*#l-protocol*], [*#l-description*],
      ..service.ports.map(port => (
        [#port.port],
        [#port.protocol],
        [#if "description" in port [#port.description] else [-]]
      )).flatten()
    )
    #v(0.5em)
  ]

  // Credentials
  #if "credentials" in service and service.credentials.len() > 0 [
    == #l-title

    #for cred in service.credentials [
      #block(
        stroke: border-normal + color-border,
        inset: 1em,
        radius: 4pt,
        width: 100%,
      )[
        #if "description" in cred and cred.description != none [
          #text(weight: "bold", size: size-medium)[#cred.description]
          #v(0.5em)
        ]

        #table(
          columns: (auto, 1fr),
          stroke: none,
          inset: 0.3em,

          [*#l-username:*], [#raw(cred.username)],
          [*#l-password:*], [#raw(cred.password)],

          ..if "credential_type" in cred and cred.credential_type != none {
            ([*#l-type:*], [#cred.credential_type])
          } else {
            ()
          },
        )
      ]
      #v(0.8em)
    ]
  ]

  // Notes
  #if "notes" in service and service.notes != none [
    == #l-notes
    #service.notes
  ]
]

// ============================================================================
// SECURITY NOTICE
// ============================================================================

#v(2em)
#line(length: 100%, stroke: border-thin + color-border)
#v(1em)

#align(center)[
  #box(
    stroke: border-normal + accent-color,
    radius: 6pt,
    inset: 1.2em,
    width: 90%,
  )[
    #text(size: size-normal, weight: "bold", fill: accent-color)[#l-security]
    #v(0.5em)
    #set text(size: size-small)
    #align(left)[
      - #l-hint1
      - #l-hint2
      - #l-hint3
      - #l-hint4
      - #l-hint5
    ]
  ]
]
