#import "@local/business-templates:0.1.0": order-confirmation

#order-confirmation(
  data: json("order-confirmation-001.json"),
  company: json("/data/company.json"),
)
