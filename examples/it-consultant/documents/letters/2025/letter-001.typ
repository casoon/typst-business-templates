#import "@local/business-templates:0.4.0": letter

#letter(
  data: json("letter-001.json"),
  company: json("/data/company.json"),
)
