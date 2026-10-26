#import "@local/business-templates:0.1.0": task-list
#task-list(title: "Project responsibilities", document-number: "TASK-2026-001", created: "2026-10-26", company: (language: "en"), show-title-page: false,
  roles: ((name: "Sponsor", description: "Reviews the scope and accepts the result."), (name: "Project lead", description: "Coordinates reviews and records decisions.")),
  tasks: range(1, 35).map(i => (
    title: "Review " + str(i) + ": confirm the recorded observations and agree on the next action with the responsible people.",
    assignee: if calc.odd(i) { "Sponsor" } else { "Project lead" },
    phase: if i < 15 { "Preparation" } else { "Delivery" },
    priority: "medium", status: "todo",
  )),
)[]
