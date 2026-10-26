// Shared wrapper for every language and the US variant.
#import "@local/business-templates:0.1.0": invoice
#let resolved = json(sys.inputs.at("resolved", default: "de/resolved.json"))
#assert(resolved.status == "ready_for_preview", message: "Invoice preparation is blocked")
#invoice(data: resolved.data, company: resolved.company, profile: resolved.selection)
