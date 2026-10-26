#import "@local/business-templates:0.2.0": time-sheet

#time-sheet(
  data: json("timesheet-001.json"),
  company: json("/data/company.json"),
)
