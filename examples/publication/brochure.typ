#import "@local/business-templates:0.2.0": brochure, content-card, numbered-step
#show: brochure.with(title: "A compact project overview", document-type: "Brief", document-number: "BRIEF-2026-001", language: "en", foreground: rgb("#182C39"), background: rgb("#FFFFFF"), accent: rgb("#244B62"))
#content-card("Shared objectives")[Agree on the intended outcome and the people who will review it.]
#numbered-step(1, "Prepare")[Collect the existing material.]
#numbered-step(2, "Review")[Record questions and decide who can answer them.]
#pagebreak()
= Detailed review
#for i in range(1, 8) [
  == Topic #i
  #lorem(45)
]
