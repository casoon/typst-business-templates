// Validate first, saving the returned canonical rendering view as resolved.json.
#import "@local/business-templates:0.1.0": invoice
#let resolved = json("resolved.json")
#assert(resolved.status == "ready_for_preview", message: "Invoice profile validation is blocked")
#let company = resolved.company
#if "logo" in company { company.insert("logo", read(company.logo, encoding: none)) }
#invoice(data: resolved.data, company: company, profile: resolved.selection)
