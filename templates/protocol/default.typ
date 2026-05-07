// Protocol Template (Protokoll/Meeting Notes) - Document Layout
// Based on concept/documentation structure

#import "../common/styles.typ": *
#import "../common/footers.typ": minimal-footer
#import "../common/title-page.typ": document-title-page

// Document function
#let protocol(
  title: none,
  document_number: none,
  meeting_date: none,
  meeting_time: none,
  location: none,
  participants: (),
  absent: (),
  moderator: none,
  note_taker: none,
  created_at: none,
  show_toc: false,
  company: none,
  locale: none,
  logo: none,
  show-title-page: true,
  show-footer: true,
  body
) = {
  let company = if company != none { company } else { (:) }
  let locale = if locale != none { locale } else { (common: (:), protocol: (:)) }
  
  let accent-color = get-accent-color(company)
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
          [#if meeting_date != none [#meeting_date]]
        )
        #v(5pt)
        #line(length: 100%, stroke: border-thin)
      ]
    ],

    footer: if show-footer { minimal-footer(
      company: company,
      locale: locale,
      document_number: document_number,
    ) } else { none }
  )

  set text(font: fonts.body, size: size-medium, lang: get-language(company))
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.")

  show heading.where(level: 1): it => {
    v(18pt)
    text(size: size-xlarge, weight: "bold", fill: accent-color)[#it]
    v(8pt)
  }

  show heading.where(level: 2): it => {
    v(12pt)
    text(size: size-large, weight: "bold")[#it]
    v(6pt)
  }

  // ============================================================================
  // TITLE PAGE
  // ============================================================================

  // Build metadata dictionary for the title page
  let title-metadata = (:)
  if meeting_date != none {
    title-metadata.insert("Datum", meeting_date)
  }
  if meeting_time != none {
    title-metadata.insert("Uhrzeit", meeting_time)
  }
  if location != none {
    title-metadata.insert("Ort", location)
  }
  if moderator != none {
    title-metadata.insert("Moderation", moderator)
  }
  if note_taker != none {
    title-metadata.insert("Protokollant", note_taker)
  }

  // Build custom content for participants and absent lists
  let participants-content = {
    if participants.len() > 0 [
      #v(12pt)
      #block(
        inset: (left: 1em),
      )[
        #text(weight: "bold", size: size-normal)[Teilnehmer:]
        #v(0.4em)
        #for participant in participants [
          - #participant
        ]
      ]
      #v(8pt)
    ]

    if absent.len() > 0 [
      #block(
        inset: (left: 1em),
      )[
        #text(weight: "bold", size: size-normal)[Entschuldigt:]
        #v(0.4em)
        #for person in absent [
          - #person
        ]
      ]
      #v(8pt)
    ]
  }

  if show-title-page {
    document-title-page(
      company: company,
      logo: logo,
      title: title,
      document-type: "BESPRECHUNGSPROTOKOLL",
      document-number: document_number,
      accent-color: accent-color,
      metadata: title-metadata,
      tags: none,
      custom-content: participants-content,
    )

    pagebreak()
  }

  // ============================================================================
  // TABLE OF CONTENTS (optional)
  // ============================================================================

  if show_toc {
    [
      #outline(
        title: [
          #set text(size: size-large, weight: "bold")
          Tagesordnung
        ],
        indent: 1em,
        depth: 2,
      )

      #v(15pt)
      #line(length: 100%, stroke: border-thin)
      #v(15pt)
    ]
  }

  // ============================================================================
  // MAIN CONTENT
  // ============================================================================

  body

  // ============================================================================
  // ACTION ITEMS FOOTER (if present in body via custom markup)
  // ============================================================================

  v(20pt)
  line(length: 100%, stroke: border-normal)
  v(10pt)

  text(size: size-small, fill: color-text-light)[
    Protokoll erstellt am #if created_at != none [#created_at]
  ]
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
    eval("[" + data.content + "]", mode: "code")
  } else {
    []
  }
  
  protocol(
    title: data.metadata.title,
    document_number: data.metadata.document_number,
    meeting_date: if "meeting_date" in data.metadata { data.metadata.meeting_date } else { none },
    meeting_time: if "meeting_time" in data.metadata { data.metadata.meeting_time } else { none },
    location: if "location" in data.metadata { data.metadata.location } else { none },
    participants: if "participants" in data.metadata { data.metadata.participants } else { () },
    absent: if "absent" in data.metadata { data.metadata.absent } else { () },
    moderator: if "moderator" in data.metadata { data.metadata.moderator } else { none },
    note_taker: if "note_taker" in data.metadata { data.metadata.note_taker } else { none },
    created_at: created-date,
    show_toc: if "show_toc" in data.metadata { data.metadata.show_toc } else { false },
    company: _company,
    locale: _locale,
    content-body
  )
}
