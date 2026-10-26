// Shared wrapper for every language and the US variant.
#import "@local/business-templates:0.1.0": invoice
#let resolved = json(sys.inputs.at("resolved", default: "de/resolved.json"))
#assert(resolved.status == "ready_for_preview", message: "Invoice preparation is blocked")
#let company = resolved.company
#if company.at("logo", default: none) != none { company.insert("logo", read(company.logo, encoding: none)) }
#invoice(data: resolved.data, company: company, profile: resolved.selection)
