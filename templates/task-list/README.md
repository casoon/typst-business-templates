# Task List / Aufgabenliste Template

Professionelles Template für Aufgabenlisten, Todo-Listen und Projektplanung.

## Features

- ✅ **Checklisten** mit Status-Tracking (Todo, In Progress, Done, Blocked)
- 📅 **Datum-basierte Aufgaben** mit Deadlines
- 🎯 **Prioritäten** (Hoch, Mittel, Niedrig)
- 📋 **Kategorien & Strukturierung** für bessere Organisation
- 🔗 **Abhängigkeiten** ("Abhängig von..." / "Wenn-Dann-Logik")
- 👤 **Zuweisungen** (Assignees)
- 🏷️ **Tags** für flexible Filterung
- 📝 **Subtasks** mit hierarchischer Struktur
- 📄 **Notizen-Bereich** für zusätzliche Informationen

## Verwendung

```typst
#import "@local/business-templates:0.1.0": task-list

#task-list(
  title: "Meine Aufgabenliste",
  company: json("/data/company.json"),
  subtitle: "Sprint Planning Q1 2026",
  project: "Website Redesign",
  
  categories: (
    (
      name: "🎯 Hochpriorität",
      tasks: (
        (
          title: "User Authentication implementieren",
          description: "OAuth 2.0 Integration",
          status: "in-progress",
          priority: "high",
          due: "31.01.2026",
          assignee: "Max Mustermann",
          tags: ("backend", "security"),
          subtasks: (
            (title: "OAuth Provider konfigurieren", status: "done"),
            (title: "Login-Flow testen", status: "todo"),
          )
        ),
      )
    ),
  ),
  
  notes: [
    *Wichtige Hinweise:*
    - Alle High-Priority Tasks bis Ende Januar
    - Wöchentliches Standup jeden Montag
  ]
)[]
```

## Beispiele

Siehe:
- [`examples/digitalagentur/documents/task-lists/2025/task-list.typ`](../../examples/digitalagentur/documents/task-lists/2025/task-list.typ)

## Anwendungsfälle

- 📋 **Projektplanung** - Sprint Planning, Roadmaps
- ✅ **Persönliche Todos** - Tägliche/Wöchentliche Aufgaben
- 🎯 **Team-Tasks** - Aufgabenverteilung im Team
- 📊 **Meeting Action Items** - Follow-ups nach Meetings
- 🚀 **Release Checklists** - Deployment-Schritte
- 📝 **Onboarding-Prozesse** - Schritt-für-Schritt Anleitungen

## Tipps

1. **Emojis nutzen** für visuelle Kategorisierung (🎯 🏠 💼 📝 etc.)
2. **Subtasks** für komplexe Aufgaben in kleinere Schritte aufteilen
3. **Tags** konsistent verwenden für einfaches Filtern
4. **Prioritäten** sparsam einsetzen (nicht alles ist "high")
5. **Deadlines** realistisch setzen
6. **Abhängigkeiten** dokumentieren für bessere Planung

## Anpassen

`company` bestimmt Akzentfarbe, Schrift und Sprache (`company.language`), `locale` überschreibt die
Übersetzungen. Für ein eigenes Layout das Template aus `templates/task-list/` in das eigene Projekt
kopieren und dort ändern.
