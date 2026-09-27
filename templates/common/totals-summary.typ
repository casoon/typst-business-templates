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
    
    #if vat_breakdown.len() > 0 [
      #let rows = ()
      
      // Subtotal
      #rows.push(([#l-subtotal:], [#format_money(subtotal.amount) EUR]))
      
      // VAT breakdown
      #for vat in vat_breakdown {
        // rate is (percentage: 19) in JSON documents, a plain number from the Rust types
        let pct = if type(vat.rate) == dictionary { vat.rate.percentage } else { vat.rate }
        rows.push(([#l-vat (#pct%):], [#format_money(vat.amount.amount) EUR]))
      }
      
      // Total
      #rows.push((
        [#text(weight: "bold", size: 11pt)[#l-total:]],
        [#text(weight: "bold", size: 11pt)[#format_money(total.amount) EUR]]
      ))
      
      #grid(
        columns: (100pt, 80pt),
        align: (right, right),
        row-gutter: 10pt,
        ..rows.flatten()
      )
    ]
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
