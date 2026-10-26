// Rendering choices only. Resolve/validate rule profiles in typstgen; no country
// rule engine or tax-case inference lives in the template package.
#import "styles.typ": get-language, load-locale
#import "formatting.typ": format_money, format_german_date

#let invoice-presentation(profile, company, data) = {
  let defaults = (
    language: get-language(company), format_locale: "de-DE", currency: "EUR",
    layout: "din", output_profile: "pdf-preview",
  )
  let choice = if profile == none { defaults } else { defaults + profile }
  assert(choice.language in ("de", "en", "es", "fr", "it", "nl", "pt"), message: "profile.language: unsupported")
  assert(choice.format_locale in ("de-DE", "en-GB", "fr-FR"), message: "profile.format_locale: unsupported")
  assert(choice.layout in ("din", "international"), message: "profile.layout: unsupported")
  assert(choice.output_profile == "pdf-preview", message: "profile.output_profile: renderer only supports pdf-preview; request structured output through typstgen")
  assert(choice.currency == "EUR", message: "profile.currency: only EUR is verified")
  for item in data.items {
    for money in (item.unit_price, item.total) {
      assert(money.at("currency", default: "EUR") == choice.currency, message: "items: currency differs from profile.currency")
    }
  }
  for key in ("subtotal", "vat_total", "total", "discount_total") {
    if key in data.totals {
      assert(data.totals.at(key).at("currency", default: "EUR") == choice.currency, message: "totals." + key + ": currency differs from profile.currency")
    }
  }
  for group in data.totals.vat_breakdown {
    for key in ("base", "amount") {
      if key in group and type(group.at(key)) == dictionary {
        assert(group.at(key).at("currency", default: "EUR") == choice.currency, message: "totals.vat_breakdown: currency differs from profile.currency")
      }
    }
  }
  choice
}

#let invoice-money(amount, format-locale: "de-DE") = {
  let value = format_money(calc.round(decimal(str(amount)), digits: 2))
  if format-locale == "en-GB" { value.replace(",", ".") } else { value }
}

// Unit prices can have more precision than rounded monetary totals. Preserve
// their decimal value so PDF and XML do not show different prices per unit.
#let invoice-price(amount, format-locale: "de-DE") = {
  let parts = str(decimal(str(amount))).split(".")
  let fraction = parts.at(1, default: "")
  if fraction.len() < 2 { fraction += "0" * (2 - fraction.len()) }
  parts.first() + if format-locale == "en-GB" { "." } else { "," } + fraction
}

#let invoice-date(value, format-locale: "de-DE") = {
  if format-locale == "de-DE" { format_german_date(value) }
  else if type(value) == dictionary { value.date } else { value }
}

#let invoice-party(party) = [
  #let firm = party.at("company", default: none)
  #if firm != none and firm != party.name [#firm#linebreak()]
  #party.name#linebreak()
  #party.address.street #party.address.at("house_number", default: "")#linebreak()
  #party.address.postal_code #party.address.city#linebreak()
  #party.address.at("country", default: party.address.at("country_code", default: ""))
]

#let invoice-reference(data, labels, common, date) = [
  *#labels.invoice_number:* #data.metadata.invoice_number#linebreak()
  *#labels.invoice_date:* #date(data.metadata.invoice_date)#linebreak()
  #if "customer_number" in data.metadata [*#common.customer_number:* #data.metadata.customer_number#linebreak()]
  #if "performance_period" in data.metadata [*#labels.performance_period:* #data.metadata.performance_period#linebreak()]
  #if "delivery_date" in data.metadata [*#labels.delivery_date:* #date(data.metadata.delivery_date)#linebreak()]
  #if "due_date" in data.metadata [*#labels.due_date:* #date(data.metadata.due_date)]
]

#let invoice-sums(data, labels, money, currency) = {
  let rows = ()
  if data.totals.vat_breakdown.len() > 0 { rows.push([#labels.subtotal:]); rows.push([#money(data.totals.subtotal.amount) #currency]) }
  for vat in data.totals.vat_breakdown {
    let pct = if type(vat.rate) == dictionary { vat.rate.percentage } else { vat.rate }
    rows.push([#labels.vat (#pct%):]); rows.push([#money(vat.amount.amount) #currency])
  }
  rows.push(strong[#labels.total:]); rows.push(strong[#money(data.totals.total.amount) #currency])
  align(right, grid(columns: (auto, auto), column-gutter: 16pt, row-gutter: 8pt, align: right, ..rows))
}

#let invoice-unit(item, labels) = {
  let code = item.at("unit_code", default: "")
  if code in labels.units { labels.units.at(code) }
  else {
    import "unit-formatter.typ": format-unit
    format-unit(item.unit, quantity: item.quantity)
  }
}
