// Rendering choices only. Resolve/validate rule profiles in typstgen; no country
// rule engine or tax-case inference lives in the template package.
#import "styles.typ": get-language, load-locale
#import "formatting.typ": format_money, format_german_date, to-datetime

#let invoice-presentation(profile, company, data) = {
  let defaults = (
    language: get-language(company), format_locale: "de-DE", currency: "EUR",
    layout: "din", output_profile: "pdf-preview",
    paper: "a4", currency_display: "auto",
  )
  let choice = if profile == none { defaults } else { defaults + profile }
  assert(choice.language in ("de", "en", "es", "fr", "it", "nl", "pt"), message: "profile.language: unsupported")
  assert(choice.format_locale in ("de-DE", "en-GB", "en-US", "fr-FR", "es-ES", "it-IT", "nl-NL", "pt-PT"), message: "profile.format_locale: unsupported")
  assert(choice.layout in ("din", "international"), message: "profile.layout: unsupported")
  assert(choice.paper in ("a4", "us-letter"), message: "profile.paper: unsupported")
  assert(choice.currency_display in ("auto", "code", "symbol"), message: "profile.currency_display: unsupported")
  assert(choice.currency_display != "symbol" or choice.currency == "USD", message: "profile.currency_display: explicit symbols currently support USD")
  assert(choice.output_profile == "pdf-preview", message: "profile.output_profile: renderer only supports pdf-preview; request structured output through typstgen")
  assert(choice.currency.matches(regex("^[A-Z]{3}$")).len() == 1, message: "profile.currency: expected a three-letter currency code")
  for item in data.items {
    for money in (item.unit_price, item.total) {
      assert(money.at("currency", default: "EUR") == choice.currency, message: "items: currency differs from profile.currency")
    }
  }
  for key in ("subtotal", "vat_total", "tax_total", "total", "discount_total") {
    if key in data.totals {
      assert(data.totals.at(key).at("currency", default: "EUR") == choice.currency, message: "totals." + key + ": currency differs from profile.currency")
    }
  }
  for group in data.totals.at("vat_breakdown", default: ()) {
    for key in ("base", "amount") {
      if key in group and type(group.at(key)) == dictionary {
        assert(group.at(key).at("currency", default: "EUR") == choice.currency, message: "totals.vat_breakdown: currency differs from profile.currency")
      }
    }
  }
  choice
}

#let invoice-dollar(currency, format-locale, currency-display) = {
  currency == "USD" and (currency-display == "symbol" or (currency-display == "auto" and format-locale == "en-US"))
}

// Unit prices can have more precision than rounded monetary totals. Preserve
// their decimal value so PDF and XML do not show different prices per unit.
#let invoice-price(amount, format-locale: "de-DE", currency: "EUR", currency-display: "auto") = {
  let parts = str(decimal(str(amount))).split(".")
  let fraction = parts.at(1, default: "")
  if fraction.len() < 2 { fraction += "0" * (2 - fraction.len()) }
  let whole = parts.first()
  let negative = whole.starts-with("-")
  if negative { whole = whole.slice(1) }
  if format-locale == "en-US" {
    let groups = ()
    while whole.len() > 3 {
      groups.insert(0, whole.slice(whole.len() - 3))
      whole = whole.slice(0, whole.len() - 3)
    }
    groups.insert(0, whole)
    whole = groups.join(",")
  }
  let sign = if negative { "-" } else { "" }
  let symbol = if invoice-dollar(currency, format-locale, currency-display) { "$" } else { "" }
  sign + symbol + whole + if format-locale in ("en-GB", "en-US") { "." } else { "," } + fraction
}

#let invoice-money(amount, format-locale: "de-DE", currency: "EUR", currency-display: "auto") = {
  invoice-price(calc.round(decimal(str(amount)), digits: 2), format-locale: format-locale,
    currency: currency, currency-display: currency-display)
}

#let invoice-date(value, format-locale: "de-DE") = {
  if format-locale == "de-DE" { format_german_date(value) }
  else if format-locale in ("en-US", "en-GB", "fr-FR", "es-ES", "it-IT", "nl-NL", "pt-PT") {
    let date = to-datetime(value)
    assert(date != auto, message: "invoice date: expected a calendar date")
    date.display(if format-locale == "en-US" { "[month]/[day]/[year]" }
      else if format-locale == "nl-NL" { "[day]-[month]-[year]" }
      else { "[day]/[month]/[year]" })
  }
  else if type(value) == dictionary { value.date } else { value }
}

#let invoice-party(party, format-locale: "de-DE") = [
  #let firm = party.at("company", default: none)
  #if firm != none and firm != party.name [#firm#linebreak()]
  #party.name#linebreak()
  #party.address.street #party.address.at("house_number", default: "")#linebreak()
  #if format-locale == "en-US" [#party.address.city#if party.address.at("region", default: "") != "" [, #party.address.region] #party.address.postal_code] else [#party.address.postal_code #party.address.city]
  #linebreak()
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
  let sales-tax = data.at("tax_model", default: "vat") == "sales-tax"
  let groups = if sales-tax { data.totals.tax_breakdown } else { data.totals.vat_breakdown }
  if groups.len() > 0 { rows.push([#labels.subtotal:]); rows.push([#money(data.totals.subtotal.amount) #currency]) }
  for vat in groups {
    let pct = if type(vat.rate) == dictionary { vat.rate.percentage } else { vat.rate }
    let label = if sales-tax { vat.label } else { labels.vat }
    let amount = if sales-tax { vat.amount } else { vat.amount.amount }
    rows.push([#label (#pct%):]); rows.push([#money(amount) #currency])
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
