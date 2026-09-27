// Common Formatting Helpers
// Reusable formatting functions for dates, money, and other data types

/// Formats a date object to German DD.MM.YY format
///
/// Parameters:
/// - date_obj: Dictionary with "date" key containing ISO date string (YYYY-MM-DD)
///
/// Returns:
/// - Formatted date string (DD.MM.YY) or original string if parsing fails
///
/// Example:
/// ```typst
/// #format_german_date((date: "2025-01-27"))
/// // Output: 27.01.25
/// ```
#let format_german_date(date_obj) = {
  // Accepts a date object (date: "YYYY-MM-DD") or a plain string, as the Rust types send it
  let date_str = if type(date_obj) == dictionary { date_obj.date } else { str(date_obj) }
  let parts = date_str.split("-")
  if parts.len() == 3 {
    let year = parts.at(0).slice(2, 4)
    let month = parts.at(1)
    let day = parts.at(2)
    day + "." + month + "." + year
  } else {
    date_str
  }
}

/// Formats a monetary amount to German format with comma decimal separator
///
/// Parameters:
/// - amount: Numeric value or string representing money
///
/// Returns:
/// - Formatted string with comma decimal separator and 2 decimal places
///
/// Examples:
/// ```typst
/// #format_money(1234.5)   // "1234,50"
/// #format_money(99)       // "99,00"
/// #format_money(12.345)   // "12,34" (rounded down)
/// ```
#let format_money(amount) = {
  let str_amount = str(amount)
  if str_amount.contains(".") {
    let parts = str_amount.split(".")
    let integer_part = parts.at(0)
    let decimal_part = parts.at(1)
    if decimal_part.len() == 1 {
      integer_part + "," + decimal_part + "0"
    } else if decimal_part.len() >= 2 {
      integer_part + "," + decimal_part.slice(0, 2)
    } else {
      integer_part + ",00"
    }
  } else {
    str_amount + ",00"
  }
}

/// Formats a monetary amount with currency suffix
///
/// Parameters:
/// - amount: Numeric value or string representing money
/// - currency: Currency code (default: "EUR")
///
/// Returns:
/// - Formatted string with currency (e.g., "1.234,50 EUR")
///
/// Example:
/// ```typst
/// #format_money_with_currency(1234.5)
/// // Output: "1234,50 EUR"
/// ```
#let format_money_with_currency(amount, currency: "EUR") = {
  format_money(amount) + " " + currency
}
