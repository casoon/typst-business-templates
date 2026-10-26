#import "@local/business-templates:0.1.0": publication, process-phase, notice, quiet-table
#let company = (name: "Example Studio", language: "en", contact: (email: "hello@example.invalid"), branding: (font_preset: "inter", accent_color: "#244B62"))
#show: publication.with(title: "Project guide: from the first conversation to a documented handover", subtitle: "A synthetic project", document-type: "Guide", document-number: "GUIDE-2026-001", created: "2026-10-26", company: company)

= Preparation
#process-phase("Discovery", duration: "One meeting", result: "Agreed scope", participation: "Project sponsor", company: company)[
  Record the objectives, constraints and people involved before starting the work.
]
#notice(title: "Review gate", company: company)[Confirm the scope with all participants.]
#quiet-table(headers: ([Deliverable], [Review]), rows: (([Brief], [Sponsor]), ([Prototype], [Working group])))
#for i in range(1, 15) [
  == Review #i
  Each review records observations, decisions and the person responsible for the next action.
  #lorem(55)
]
