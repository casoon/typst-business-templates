#import "@local/business-templates:0.1.0": task-list

// Einfaches Beispiel für eine Aufgabenliste
#task-list(
  title: "Projekt Aufgabenliste",
  subtitle: "Sprint Planning Q1 2026",
  project: "Website Redesign",
  client: "Acme Corporation",
  document-number: "DOC-2026-001",
  company: json("/data/company.json"),
  
  categories: (
    (
      name: "Hochprioritäts-Aufgaben",
      description: "Kritische Aufgaben mit sofortiger Bearbeitung erforderlich",
      tasks: (
        (
          title: "User Authentication implementieren",
          description: "OAuth 2.0 Integration für sichere Anmeldung",
          status: "in-progress",
          priority: "high",
          due: "31.01.2026",
          assignee: "Max Mustermann",
          tags: ("backend", "security"),
          subtasks: (
            (title: "OAuth Provider konfigurieren", status: "done"),
            (title: "Login-Flow testen", status: "in-progress"),
            (title: "Dokumentation erstellen", status: "todo"),
          )
        ),
        (
          title: "Database Migration durchführen",
          description: "PostgreSQL auf Version 15 aktualisieren",
          status: "blocked",
          priority: "high",
          due: "28.01.2026",
          assignee: "Anna Schmidt",
          tags: ("database", "infrastructure"),
          condition: "Backup muss erfolgreich abgeschlossen sein"
        ),
      )
    ),
    
    (
      name: "Entwicklung",
      tasks: (
        (
          title: "API Endpoints für User-Profile",
          status: "todo",
          priority: "medium",
          due: "05.02.2026",
          assignee: "Max Mustermann",
          tags: ("backend", "api"),
          subtasks: (
            (title: "GET /api/users/:id", status: "todo"),
            (title: "PUT /api/users/:id", status: "todo"),
            (title: "DELETE /api/users/:id", status: "todo"),
          )
        ),
        (
          title: "Frontend Komponenten refactorn",
          description: "React Components in TypeScript konvertieren",
          status: "in-progress",
          priority: "medium",
          due: "10.02.2026",
          assignee: "Lisa Müller",
          tags: ("frontend", "refactoring")
        ),
      )
    ),
    
    (
      name: "Testing und Quality Assurance",
      tasks: (
        (
          title: "Unit Tests für Auth-Modul",
          status: "todo",
          priority: "high",
          due: "03.02.2026",
          assignee: "Tom Weber",
          tags: ("testing", "backend"),
          depends-on: "User Authentication implementieren"
        ),
        (
          title: "E2E Tests mit Playwright",
          status: "todo",
          priority: "low",
          due: "15.02.2026",
          assignee: "Lisa Müller",
          tags: ("testing", "frontend")
        ),
      )
    ),
    
    (
      name: "Dokumentation",
      tasks: (
        (
          title: "API Dokumentation aktualisieren",
          status: "done",
          priority: "medium",
          due: "25.01.2026",
          assignee: "Max Mustermann",
          tags: ("documentation",)
        ),
        (
          title: "User Guide schreiben",
          status: "todo",
          priority: "low",
          due: "20.02.2026",
          assignee: "Anna Schmidt",
          tags: ("documentation",)
        ),
      )
    ),
  ),
  
  tasks: (
    (
      title: "Team Meeting vorbereiten",
      description: "Agenda und Präsentation für Montags-Standup",
      status: "todo",
      priority: "medium",
      due: "29.01.2026"
    ),
    (
      title: "Code Review: Pull Request #42",
      status: "todo",
      priority: "high",
      due: "28.01.2026",
      assignee: "Anna Schmidt",
      tags: ("review",)
    ),
  ),
  
  notes: [
    == Wichtige Hinweise
    
    - Alle High-Priority Tasks müssen bis Ende Januar abgeschlossen sein
    - Wöchentliches Standup jeden Montag 10:00 Uhr
    - Bei blockierten Tasks sofort das Team informieren
    
    == Nächste Schritte
    
    + Sprint Review am 14.02.2026
    + Retrospektive danach
    + Planning für nächsten Sprint
    
    == Abhängigkeiten
    
    Die Database Migration blockiert mehrere Backend-Tasks. Frontend kann parallel entwickelt werden.
    
    == Risiken
    
    - Zeitliche Verzögerung bei OAuth Integration möglich
    - Database Migration erfordert Downtime-Fenster
  ]
)[]
