#import "@local/business-templates:0.4.1": invoice

#invoice(
  data: json("invoice.json"),
  company: json("/data/company.json"),
)
