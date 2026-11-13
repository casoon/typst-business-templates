#import "@local/business-templates:0.4.1": order-confirmation

#order-confirmation(
  data: json("order-confirmation-001.json"),
  company: json("/data/company.json"),
)
