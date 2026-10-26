// Entry point of the Typst package `business-templates`.
//
// #import "@local/business-templates:0.1.0": invoice
// #invoice(data: json("RE-2026-001.json"), company: json("company.json"))
//
// Accounting documents take `data` as described by the JSON schemas in schema/ and
// `company` in the shape of company.json. The other documents are functions
// with named parameters and the document body as content.

// Accounting documents (data: dictionary from JSON, company: dictionary)
#import "invoice/default.typ": invoice
#import "offer/default.typ": offer
#import "credit-note/default.typ": credit-note
#import "reminder/default.typ": reminder
#import "delivery-note/default.typ": delivery-note
#import "order-confirmation/default.typ": order-confirmation
#import "quotation-request/default.typ": quotation-request
#import "time-sheet/default.typ": time-sheet
#import "letter/default.typ": letter
#import "credentials/default.typ": credentials

// Documents with named parameters and a content body
#import "concept/default.typ": concept
#import "contract/default.typ": contract
#import "documentation/default.typ": documentation
#import "proposal/default.typ": proposal
#import "protocol/default.typ": protocol
#import "sla/default.typ": sla
#import "specification/default.typ": specification
#import "task-list/default.typ": task-list
#import "handout/default.typ": handout, aufgabe, hinweis, wichtig, kriterium, antwortfeld, textblock

// Compact publications and printable form/checklist components
#import "publication/default.typ": publication, brochure
#import "publication/components.typ": writing-field, check-option, choice-group, notice, process-phase, quiet-table, priority-tag, content-card, numbered-step

// Resolve labels for caller-composed printable components.
#import "common/styles.typ": load-locale
