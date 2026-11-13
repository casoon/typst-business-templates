#import "@local/business-templates:0.4.1": letter

#letter(
  data: json("letter-001.json"),
  company: json("/data/company.json"),
)
