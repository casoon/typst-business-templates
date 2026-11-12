#import "@local/business-templates:0.4.0": invoice

#invoice(
  data: json("invoice.json"),
  company: json("/data/company.json"),
)
