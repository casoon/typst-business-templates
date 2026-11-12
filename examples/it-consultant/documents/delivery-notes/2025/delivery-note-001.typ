#import "@local/business-templates:0.4.0": delivery-note

#delivery-note(
  data: json("delivery-note-001.json"),
  company: json("/data/company.json"),
)
