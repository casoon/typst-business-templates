#import "@local/business-templates:0.2.0": invoice

#invoice(
  data: json("invoice.json"),
  company: json("/data/company.json"),
)
