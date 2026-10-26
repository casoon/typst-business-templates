// Compact publications start their content on page one. Headers/footers are
// automatically PDF artifacts in Typst; the title is part of the document body.
#import "../common/styles.typ": *
#import "../common/formatting.typ": prose-metadata

#let publication(
  title: none, subtitle: none, document-type: none, document-number: none,
  created: none, authors: (), company: none, language: none, locale: none,
  logo: none, width: 210mm, height: 297mm,
  foreground: black, background: white, accent: auto,
  body,
) = {
  let company = if company == none { (:) } else { company }
  let language = if language == none { get-language(company) } else { language }
  let locale = load-locale(locale, company, language: language)
  let fonts = get-font-preset(company)
  let accent = if accent == auto { get-accent-color(company) } else { accent }
  let mark = if logo != none { logo } else if company.at("logo", default: none) != none {
    image(logo-source(company.logo), height: 9mm)
  }
  set document(..prose-metadata(company, title, document-number, created, authors: authors))
  set text(font: fonts.body, size: 10pt, lang: language, fill: foreground)
  set par(leading: 0.65em)
  set page(
    width: width, height: height, fill: background,
    margin: (x: 18mm, top: 28mm, bottom: 22mm),
    header: [
      #set text(size: 8pt)
      #grid(columns: (1fr, auto), column-gutter: 12pt,
        [#if mark != none { mark } else { company.at("name", default: "") }],
        align(right)[#document-type #if document-type != none and document-number != none [ · ]#document-number],
      )
      #v(3pt)
      #line(length: 100%, stroke: 0.5pt + accent)
    ],
    footer: context [
      #set text(size: 8pt)
      #line(length: 100%, stroke: 0.5pt + foreground)
      #v(3pt)
      #grid(columns: (1fr, auto), column-gutter: 12pt,
        [#company.at("name", default: "") #h(6pt) #company.at("contact", default: (:)).at("email", default: "")],
        [#locale.common.page #counter(page).display("1 / 1", both: true)],
      )
    ],
  )
  show heading: it => text(font: fonts.heading, fill: accent, it)
  if title != none { heading(level: 1, outlined: false, title) }
  if subtitle != none { block(above: 4pt, below: 12pt, subtitle) }
  if created != none { block(below: 12pt)[#locale.common.date: #created] }
  body
}

// Fixed landscape default; custom dimensions use the same publication frame.
#let brochure(width: 297mm, height: 210mm, ..args) = publication(width: width, height: height, ..args)
