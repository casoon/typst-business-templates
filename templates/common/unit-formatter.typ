// Unit Formatter
// Reusable unit type translations for German business documents

/// Translates unit codes to German abbreviations
///
/// Parameters:
/// - unit: Unit code string (e.g., "stueck", "stunde", "kg")
///
/// Returns:
/// - German abbreviation or original unit if no translation exists
///
/// Supported units:
/// - stueck → Stk.
/// - stunde → Std.
/// - tag → Tag
/// - monat → Monat, or Monate for a quantity other than 1 (also tag, jahr)
/// - jahr → Jahr
/// - pauschale → Psch.
/// - kg → kg
/// - meter → m
/// - kilometer → km
/// - liter → l
/// - karton → Ktn.
/// - palette → Pal.
///
/// Example:
/// ```typst
/// #format-unit("stueck")   // "Stk."
/// #format-unit("stunde")   // "Std."
/// #format-unit("unknown")  // "unknown"
/// ```
#let format-unit(unit, quantity: 1) = {
  let one = str(quantity).match(regex("^1(\.0*)?$")) != none
  if unit == "stueck" [Stk.]
  else if unit == "stunde" [Std.]
  else if unit == "tag" { if one [Tag] else [Tage] }
  else if unit == "monat" { if one [Monat] else [Monate] }
  else if unit == "jahr" { if one [Jahr] else [Jahre] }
  else if unit == "pauschale" [Psch.]
  else if unit == "kg" [kg]
  else if unit == "meter" [m]
  else if unit == "kilometer" [km]
  else if unit == "liter" [l]
  else if unit == "karton" [Ktn.]
  else if unit == "palette" [Pal.]
  else [#unit]
}

/// Translates unit codes with full German words (for display)
///
/// Parameters:
/// - unit: Unit code string
///
/// Returns:
/// - Full German word or abbreviation
///
/// Example:
/// ```typst
/// #format-unit-full("stueck")   // "Stück"
/// #format-unit-full("stunde")   // "Stunden"
/// ```
#let format-unit-full(unit) = {
  if unit == "stueck" [Stück]
  else if unit == "stunde" [Stunden]
  else if unit == "tag" [Tage]
  else if unit == "monat" [Monate]
  else if unit == "jahr" [Jahre]
  else if unit == "pauschale" [Pauschale]
  else if unit == "kg" [Kilogramm]
  else if unit == "meter" [Meter]
  else if unit == "kilometer" [Kilometer]
  else if unit == "liter" [Liter]
  else if unit == "karton" [Kartons]
  else if unit == "palette" [Paletten]
  else [#unit]
}
