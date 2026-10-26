// Totals Summary Component
// Reusable right-aligned totals/summary blocks for accounting documents

#import "formatting.typ": format_money

/// Renders a right-aligned totals summary for invoices
///
/// Parameters:
/// - subtotal: Subtotal amount
/// - vat_breakdown: Array of VAT entries with rate and amount
/// - total: Total amount including VAT
/// - locale: Optional locale dictionary for labels
/// - net: the document is net (offer); without VAT rows the total reads "Gesamtbetrag (netto)"
///
/// Example:
/// ```typst
/// #invoice-totals(
///   subtotal: (amount: 1000),
///   vat_breakdown: ((rate: (percentage: 19), amount: (amount: 190))),
///   total: (amount: 1190)
/// )
/// ```
#let invoice-totals(
  subtotal: none,
  vat_breakdown: (),
  total: none,
  locale: none,
  net: false,
) = {
  // Locale strings with fallbacks
  let l-subtotal = if locale != none and "common" in locale and "subtotal" in locale.common {
    locale.common.subtotal
  } else {
    "Nettobetrag"
  }
  
  let l-vat = if locale != none and "common" in locale and "vat" in locale.common {
    locale.common.vat
  } else {
    "MwSt."
  }
  
  let l-total = if locale != none and "common" in locale and "total_amount" in locale.common {
    locale.common.total_amount
  } else {
    "Gesamtbetrag"
  }
  
  align(right)[
    #set text(size: 10pt, font: "Helvetica")
    
    // Without VAT (e.g. Kleinunternehmer) only the total is shown
    #{
      let rows = ()
      
      // Subtotal
      if vat_breakdown.len() > 0 {
        rows.push(([#l-subtotal:], [#format_money(subtotal.amount) EUR]))
      }
      
      // VAT breakdown
      for vat in vat_breakdown {
        // rate is (percentage: 19) or a plain number
        let pct = if type(vat.rate) == dictionary { vat.rate.percentage } else { vat.rate }
        rows.push(([#l-vat (#pct%):], [#format_money(vat.amount.amount) EUR]))
      }
      
      // Total; without VAT rows an offer's total is net
      let label = if net and vat_breakdown.len() == 0 { l-total + " (netto)" } else { l-total }
      rows.push((
        [#text(weight: "bold", size: 11pt)[#label:]],
        [#text(weight: "bold", size: 11pt)[#format_money(total.amount) EUR]]
      ))
      
      grid(
        columns: if vat_breakdown.len() == 0 { (120pt, 100pt) } else { (100pt, 80pt) },
        align: (right, right),
        row-gutter: 10pt,
        ..rows.flatten()
      )
    }
  ]
}

/// Renders a simple totals summary (without VAT)
///
/// Parameters:
/// - items: Array of (label, value) tuples
/// - total_label: Label for total row (default: "Gesamt")
/// - total_value: Total value
/// - bold_total: Whether to bold the total row (default: true)
///
/// Example:
/// ```typst
/// #simple-totals(
///   items: (
///     ("Zwischensumme", "1.000,00 EUR"),
///     ("Rabatt (-10%)", "-100,00 EUR"),
///   ),
///   total_label: "Gesamt",
///   total_value: "900,00 EUR"
/// )
/// ```
#let simple-totals(
  items: (),
  total_label: "Gesamt",
  total_value: none,
  bold_total: true,
) = {
  align(right)[
    #set text(size: 10pt, font: "Helvetica")
    
    #let rows = ()
    
    // Regular items
    for item in items [
      #rows.push(item)
    ]
    
    // Total row
    if total_value != none [
      #if bold_total [
        #rows.push((
          [#text(weight: "bold", size: 11pt)[#total_label:]],
          [#text(weight: "bold", size: 11pt)[#total_value]]
        ))
      ] else [
        #rows.push(([#total_label:], [#total_value]))
      ]
    ]
    
    #grid(
      columns: (100pt, 80pt),
      align: (right, right),
      row-gutter: 10pt,
      ..rows.flatten()
    )
  ]
}

/// Renders time sheet totals summary
///
/// Parameters:
/// - total_hours: Total hours worked
/// - hourly_rate: Optional hourly rate
/// - total_amount: Optional total amount
/// - locale: Optional locale dictionary
///
/// Example:
/// ```typst
/// #timesheet-totals(
///   total_hours: 40.5,
///   hourly_rate: 75.00,
///   total_amount: 3037.50
/// )
/// ```
#let timesheet-totals(
  total_hours: none,
  hourly_rate: none,
  total_amount: none,
  locale: none,
) = {
  let l-total-hours = if locale != none and "time_sheet" in locale and "total_hours" in locale.time_sheet {
    locale.time_sheet.total_hours
  } else {
    "Gesamtstunden"
  }
  
  let l-hourly-rate = if locale != none and "time_sheet" in locale and "hourly_rate" in locale.time_sheet {
    locale.time_sheet.hourly_rate
  } else {
    "Stundensatz"
  }
  
  let l-total = if locale != none and "common" in locale and "total_amount" in locale.common {
    locale.common.total_amount
  } else {
    "Gesamtbetrag"
  }
  
  align(right)[
    #set text(size: 10pt, font: "Helvetica")
    
    #let rows = ()
    
    // Total hours
    if total_hours != none [
      #rows.push(([#l-total-hours:], [#total_hours h]))
    ]
    
    // Hourly rate
    if hourly_rate != none [
      #rows.push(([#l-hourly-rate:], [#format_money(hourly_rate) EUR/h]))
    ]
    
    // Total amount
    if total_amount != none [
      #rows.push((
        [#text(weight: "bold", size: 11pt)[#l-total:]],
        [#text(weight: "bold", size: 11pt)[#format_money(total_amount) EUR]]
      ))
    ]
    
    #grid(
      columns: (100pt, 80pt),
      align: (right, right),
      row-gutter: 10pt,
      ..rows.flatten()
    )
  ]
}

/// The VAT exemption note from company.default_terms (e.g. § 19 UStG for a Kleinunternehmer),
/// or none if the company charges VAT.
#let vat-exemption-note(company) = {
  let terms = company.at("default_terms", default: (:))
  if terms.at("vat_exempt", default: false) { terms.at("vat_note", default: none) }
}

// An amount from JSON ("1400", 1400 or (amount: "1400", currency: "EUR")) as decimal, or none.
#let _decimal(value) = {
  let v = if type(value) == dictionary { value.at("amount", default: none) } else { value }
  if v == none or str(v).match(regex("^-?\d+(\.\d+)?$")) == none { none } else { decimal(str(v)) }
}

/// Stops the build if the totals in `data` do not add up: each item's total against
/// quantity × unit price, the subtotal against the item totals, the VAT total against the VAT
/// breakdown and the total against subtotal minus discount_total plus VAT. Amounts are compared
/// to the cent; fields that are missing are not checked.
#let check-totals(data) = {
  let round2(x) = calc.round(x, digits: 2)
  let problems = ()
  let items = data.at("items", default: ())
  let item-totals = ()
  for (i, item) in items.enumerate() {
    let quantity = _decimal(item.at("quantity", default: none))
    let price = _decimal(item.at("unit_price", default: none))
    let total = _decimal(item.at("total", default: none))
    if total != none { item-totals.push(total) }
    if quantity != none and price != none and total != none and round2(quantity * price) != round2(total) {
      problems.push("items[" + str(i) + "]: total " + str(total) + " ≠ quantity × unit price = " + str(round2(quantity * price)))
    }
  }
  let totals = data.at("totals", default: (:))
  let subtotal = _decimal(totals.at("subtotal", default: none))
  if subtotal != none and items.len() > 0 and item-totals.len() == items.len() {
    let sum = item-totals.sum()
    if round2(sum) != round2(subtotal) {
      problems.push("totals.subtotal: " + str(subtotal) + " ≠ sum of item totals = " + str(round2(sum)))
    }
  }
  let sales-tax = data.at("tax_model", default: "vat") == "sales-tax"
  let breakdown = totals.at(if sales-tax { "tax_breakdown" } else { "vat_breakdown" }, default: ()).map(group => _decimal(group.at("amount", default: none)))
  let vat-total = _decimal(totals.at(if sales-tax { "tax_total" } else { "vat_total" }, default: none))
  if vat-total == none and breakdown.len() > 0 and none not in breakdown { vat-total = breakdown.sum() }
  if vat-total != none and breakdown.len() > 0 and none not in breakdown and round2(breakdown.sum()) != round2(vat-total) {
    problems.push("totals.vat_total: " + str(vat-total) + " ≠ sum of vat_breakdown = " + str(round2(breakdown.sum())))
  }
  let discount = _decimal(totals.at("discount_total", default: none))
  let total = _decimal(totals.at("total", default: none))
  if total != none and subtotal != none {
    let expected = subtotal
    if discount != none { expected -= discount }
    if vat-total != none { expected += vat-total }
    if round2(expected) != round2(total) {
      let terms = "subtotal" + if discount != none { " − discount" } else { "" } + " + VAT"
      problems.push("totals.total: " + str(total) + " ≠ " + terms + " = " + str(round2(expected)))
    }
  }
  if problems.len() > 0 { panic("totals do not add up:\n" + problems.join("\n")) }
}
