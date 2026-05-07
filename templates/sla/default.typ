// SLA Template (Service Level Agreement) - Document Layout
// Service level agreements and support contracts
// Based on contract structure with metrics focus

#import "../common/styles.typ": *
#import "../common/footers.typ": document-footer
#import "../common/title-page.typ": parties-title-page

// Document function
#let sla(
  title: none,
  document_number: none,
  service_provider: none,
  customer: none,
  effective_date: none,
  termination_date: none,
  review_period: none,
  version: "1.0",
  status: "Aktiv",
  created_at: none,
  show_toc: true,
  company: none,
  locale: none,
  logo: none,
  show-title-page: true,
  show-footer: true,
  body
) = {
  let company = if company != none { company } else { (:) }
  let locale = if locale != none { locale } else { (common: (:), sla: (:)) }
  
  let accent-color = get-accent-color(company)
  let primary-color = get-primary-color(company)
  let fonts = get-font-preset(company)

  set page(
    paper: "a4",
    margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 80pt),

    header: context [
      #if counter(page).get().first() > 1 [
        #set text(size: size-small)
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          [#document_number],
          [#title],
          [Version #version]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: if show-footer { document-footer(
      company: company,
      locale: locale,
      document_number: document_number,
      status: status,
      version: version,
      last_updated: effective_date,
    ) } else { none }
  )

  set text(font: fonts.body, size: size-medium, lang: get-language(company))
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    v(20pt)
    text(size: size-xxlarge, weight: "bold", fill: accent-color)[#it]
    v(10pt)
  }

  show heading.where(level: 2): it => {
    v(15pt)
    text(size: size-xlarge, weight: "bold")[#it]
    v(8pt)
  }

  show heading.where(level: 3): it => {
    v(10pt)
    text(size: size-large, weight: "bold")[#it]
    v(5pt)
  }

  // Tables for SLA metrics
  set table(
    stroke: border-thin + color-border,
    fill: (x, y) => if y == 0 { color-background }
  )

  // ============================================================================
  // TITLE PAGE
  // ============================================================================

  // Extract locale labels with fallbacks
  let l-service-provider = if "sla" in locale and "service_provider" in locale.sla { 
    locale.sla.service_provider 
  } else { 
    "Service Provider" 
  }
  
  let l-customer = if "sla" in locale and "customer" in locale.sla { 
    locale.sla.customer 
  } else if "common" in locale and "client" in locale.common { 
    locale.common.client 
  } else { 
    "Kunde" 
  }
  
  let l-document-type = if "sla" in locale and "document_type" in locale.sla { 
    locale.sla.document_type 
  } else { 
    "SERVICE LEVEL AGREEMENT" 
  }
  
  let l-version = if "common" in locale and "version" in locale.common { 
    locale.common.version 
  } else { 
    "Version" 
  }
  
  let l-status = if "common" in locale and "status" in locale.common { 
    locale.common.status 
  } else { 
    "Status" 
  }
  
  let l-effective-date = if "sla" in locale and "effective_date" in locale.sla { 
    locale.sla.effective_date 
  } else { 
    "Gültig ab" 
  }
  
  let l-termination-date = if "sla" in locale and "termination_date" in locale.sla { 
    locale.sla.termination_date 
  } else { 
    "Laufzeit bis" 
  }
  
  let l-review-period = if "sla" in locale and "review_period" in locale.sla { 
    locale.sla.review_period 
  } else { 
    "Review-Zyklus" 
  }
  
  let l-created-at = if "common" in locale and "created" in locale.common { 
    locale.common.created 
  } else { 
    "Erstellt am" 
  }

  // Extract party names and addresses
  let party1-name = if service_provider != none and type(service_provider) == dictionary [
    if "company" in service_provider and service_provider.company != none [
      service_provider.company
    ] else if "name" in service_provider [
      service_provider.name
    ] else [
      none
    ]
  ] else if service_provider != none [
    service_provider
  ] else [
    none
  ]
  
  let party1-address = if service_provider != none and type(service_provider) == dictionary and "address" in service_provider [
    service_provider.address
  ] else [
    none
  ]
  
  let party2-name = if customer != none and type(customer) == dictionary [
    if "company" in customer and customer.company != none [
      customer.company
    ] else if "name" in customer [
      customer.name
    ] else [
      none
    ]
  ] else if customer != none [
    customer
  ] else [
    none
  ]
  
  let party2-address = if customer != none and type(customer) == dictionary and "address" in customer [
    customer.address
  ] else [
    none
  ]

  // Build metadata dictionary
  let metadata = (:)
  metadata.insert(l-version, version)
  metadata.insert(l-status, text(fill: accent-color, weight: "bold")[#upper(status)])
  if effective_date != none {
    metadata.insert(l-effective-date, effective_date)
  }
  if termination_date != none {
    metadata.insert(l-termination-date, termination_date)
  }
  if review_period != none {
    metadata.insert(l-review-period, review_period)
  }
  if created_at != none {
    metadata.insert(l-created-at, created_at)
  }

  if show-title-page {
    page(
      margin: (left: 50pt, right: 45pt, top: 50pt, bottom: 50pt),
      header: none,
      footer: none,
    )[
      #parties-title-page(
        company: company,
        logo: logo,
        title: title,
        document-type: l-document-type,
        document-number: document_number,
        accent-color: accent-color,
        party1-label: l-service-provider,
        party1-name: party1-name,
        party1-address: party1-address,
        party2-label: l-customer,
        party2-name: party2-name,
        party2-address: party2-address,
        metadata: metadata,
      )
    ]

    pagebreak()
  }

  // ============================================================================
  // TABLE OF CONTENTS
  // ============================================================================

  if show_toc {
    [
      #outline(
        title: [
          #set text(size: size-xxlarge, weight: "bold")
          Inhaltsverzeichnis
        ],
        indent: 1em,
        depth: 3,
      )

      #pagebreak()
    ]
  }

  // ============================================================================
  // MAIN CONTENT
  // ============================================================================

  body

  // ============================================================================
  // SIGNATURE PAGE
  // ============================================================================

  pagebreak()

  v(1fr)

  text(size: size-large, weight: "bold")[Unterschriften]

  v(30pt)

  grid(
    columns: (1fr, 1fr),
    column-gutter: 30pt,
    row-gutter: 80pt,

    box(
      width: 100%,
      stroke: (top: 0.5pt),
      inset: (top: 8pt),
    )[
      #align(left)[
        Service Provider\
        #v(0.3em)
        #text(size: size-small)[Ort, Datum, Unterschrift]
      ]
    ],

    box(
      width: 100%,
      stroke: (top: 0.5pt),
      inset: (top: 8pt),
    )[
      #align(left)[
        Kunde\
        #v(0.3em)
        #text(size: size-small)[Ort, Datum, Unterschrift]
      ]
    ],
  )

  v(1fr)
}

// JSON workflow
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

#let _company = if data != none and "company" in sys.inputs {
  let c = json(sys.inputs.company)
  if "logo" in c and c.logo != none {
    let logo-width = if "logo_width" in c { eval(c.logo_width) } else { 150pt }
    c.insert("_logo_image", image("/" + c.logo, width: logo-width))
  }
  c
} else {
  none
}

#let _locale = if data != none and "locale" in sys.inputs {
  json(sys.inputs.locale)
} else {
  none
}

#if data != none {
  let created-date = if "created_at" in data.metadata {
    if type(data.metadata.created_at) == dictionary and "date" in data.metadata.created_at {
      data.metadata.created_at.date
    } else {
      data.metadata.created_at
    }
  } else {
    none
  }
  
  let content-body = if "content_file" in data {
    include(data.content_file)
  } else if "content" in data {
    eval(data.content, mode: "markup")
  } else {
    []
  }
  
  sla(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    service_provider: if "service_provider" in data.metadata { data.metadata.service_provider } else { none },
    customer: if "customer" in data.metadata { data.metadata.customer } else { none },
    effective_date: if "effective_date" in data.metadata { data.metadata.effective_date } else { none },
    termination_date: if "termination_date" in data.metadata { data.metadata.termination_date } else { none },
    review_period: if "review_period" in data.metadata { data.metadata.review_period } else { none },
    version: if "version" in data.metadata { data.metadata.version } else { "1.0" },
    status: if "status" in data.metadata { data.metadata.status } else { "Aktiv" },
    created_at: created-date,
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { true },
    company: _company,
    locale: _locale,
    content-body
  )
}
