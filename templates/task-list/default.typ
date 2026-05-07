// Task List / Todo List Template
// Technical document template for task management
// Based on credentials template structure

#import "../common/styles.typ": *
#import "../common/title-page.typ": standard-title-page

// Load data from JSON input (only if available)
#let data = if "data" in sys.inputs {
  json(sys.inputs.data)
} else {
  none
}

// Load company and locale from sys.inputs (passed by docgen CLI)
#let company = if data != none and "company" in sys.inputs {
  let c = json(sys.inputs.company)
  // Load logo image if logo path is specified
  if "logo" in c and c.logo != none {
    let logo-width = if "logo_width" in c { eval(c.logo_width) } else { 150pt }
    c.insert("_logo_image", image("/" + c.logo, width: logo-width))
  }
  c
} else {
  none
}

#let locale = if data != none and "locale" in sys.inputs {
  json(sys.inputs.locale)
} else {
  (common: (:))
}

// Get branding from company data
#let accent-color = get-accent-color(company)
#let fonts = get-font-preset(company)

// Locale helpers with fallbacks
#let l-page = if "common" in locale and "page" in locale.common { locale.common.page } else { "Seite" }
#let l-project = if "common" in locale and "project" in locale.common { locale.common.project } else { "Projekt" }
#let l-client = if "common" in locale and "client" in locale.common { locale.common.client } else { "Kunde" }

// Template function
#let task-list(
  // Document metadata
  title: "Aufgabenliste",
  subtitle: none,
  project: none,
  client: none,
  document-number: none,
  created: datetime.today().display("[day].[month].[year]"),
  
  // Company info (optional, will be overridden by JSON workflow)
  company: company,
  
  // Display options
  show-title-page: true,
  show-footer: true,
  
  // Content
  tasks: (),
  categories: (),
  notes: none,
  
  body
) = {
  
  // Page setup with header/footer
  set page(
    paper: "a4",
    margin: (left: 2.5cm, right: 2cm, top: 2.5cm, bottom: 2.5cm),
    header: context {
      if counter(page).get().first() > 1 [
        #set text(size: size-small)
        #grid(
          columns: (1fr, 1fr),
          align: (left, right),
          [#text(fill: accent-color, weight: "bold")[#upper(title)]],
          [#if document-number != none [#document-number]]
        )
        #v(0.2em)
        #line(length: 100%, stroke: border-thin + accent-color)
      ]
    },
    footer: if show-footer { context {
      if counter(page).get().first() > 1 [
        #line(length: 100%, stroke: border-thin)
        #v(0.2em)
        #set text(size: size-small)
        #grid(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          [#if client != none [#client] else if project != none [#project]],
          [#l-page #counter(page).display()],
          [#created]
        )
      ]
    } }
  )
  
  // Text settings
  set text(
    font: fonts.body,
    size: size-medium,
    lang: get-language(company)
  )
  
  set par(justify: true, leading: 0.65em)
  
  // Heading styles
  show heading.where(level: 1): it => {
    v(25pt)
    block(sticky: true, width: 100%)[
      #text(size: size-xxlarge, weight: "bold", fill: accent-color)[#it.body]
    ]
    v(12pt)
  }
  
  show heading.where(level: 2): it => {
    v(18pt)
    block(sticky: true, width: 100%)[
      #text(size: size-xlarge, weight: "bold")[#it.body]
    ]
    v(8pt)
  }
  
  show heading.where(level: 3): it => {
    v(12pt)
    block(sticky: true, width: 100%)[
      #text(size: size-large, weight: "semibold")[#it.body]
    ]
    v(6pt)
  }
  
  // ============================================================================
  // TITLE PAGE
  // ============================================================================
  
  // Build metadata dictionary
  let meta = (:)
  if project != none { meta.insert(l-project, project) }
  if client != none { meta.insert(l-client, client) }
  meta.insert("Datum", created)
  
  // Render standard title page
  if show-title-page {
    standard-title-page(
      company: company,
      title: title,
      subtitle: subtitle,
      document-type: "Aufgabenliste",
      document-number: document-number,
      accent-color: accent-color,
      metadata: meta,
    )
    
    pagebreak()
  }
  
  // ============================================================================
  // TASK RENDERING FUNCTIONS
  // ============================================================================
  
  // Priority badge
  let priority-badge(level) = {
    let (bg, label) = if level == "high" or level == "hoch" {
      (red.lighten(80%), "HOCH")
    } else if level == "medium" or level == "mittel" {
      (orange.lighten(80%), "MITTEL")
    } else if level == "low" or level == "niedrig" {
      (green.lighten(80%), "NIEDRIG")
    } else {
      (gray.lighten(80%), upper(level))
    }
    
    box(
      fill: bg,
      inset: (x: 6pt, y: 2pt),
      radius: 2pt,
      text(size: size-xs, weight: "bold")[#label]
    )
  }
  
  // Status symbol (simple text-based)
  let status-symbol(status) = {
    if status == "done" or status == "erledigt" {
      text(weight: "bold")[[X]]
    } else if status == "in-progress" or status == "in-arbeit" {
      text(weight: "bold")[[-]]
    } else if status == "blocked" or status == "blockiert" {
      text(weight: "bold")[[!]]
    } else {
      text(weight: "bold")[[ ]]
    }
  }
  
  // Render a single task
  let render-task(task, level: 0) = {
    let indent = level * 1.2em
    
    block(above: 0.4em, below: 0.4em, inset: (left: indent))[
      #grid(
        columns: (auto, 1fr),
        column-gutter: 0.6em,
        align: (left, left),
        
        // Status checkbox
        status-symbol(task.at("status", default: "todo")),
        
        // Task content
        {
          // Title with strikethrough if done
          let title-text = if task.at("status", default: "todo") == "done" or task.at("status", default: "todo") == "erledigt" {
            text(fill: color-text-light)[#strike[#task.title]]
          } else {
            text(weight: "medium")[#task.title]
          }
          
          [#title-text]
          
          // Metadata on same line
          let meta = ()
          
          if "priority" in task and task.priority != none {
            meta.push(priority-badge(task.priority))
          }
          
          if "due" in task and task.due != none {
            meta.push(text(size: size-xs, fill: color-text-light)[Fällig: #task.due])
          }
          
          if "assignee" in task and task.assignee != none {
            meta.push(text(size: size-xs, fill: color-text-light)[#task.assignee])
          }
          
          if meta.len() > 0 [
            #h(0.5em)
            #meta.join(h(0.6em))
          ]
          
          // Description inline after title
          if "description" in task and task.description != none [
            #h(0.5em) -- #h(0.3em)
            #text(size: size-small, fill: color-text-light, style: "italic")[#task.description]
          ]
          
          // Dependencies / Conditions
          if "depends-on" in task and task.depends-on != none [
            #v(0.2em)
            #text(size: size-xs, fill: orange)[
              Abhängig von: #task.depends-on
            ]
          ]
          
          if "condition" in task and task.condition != none [
            #v(0.2em)
            #text(size: size-xs, fill: accent-color, style: "italic")[
              Bedingung: #task.condition
            ]
          ]
        }
      )
      
      // Subtasks
      #if "subtasks" in task and task.subtasks != none {
        for subtask in task.subtasks {
          render-task(subtask, level: level + 1)
        }
      }
    ]
  }
  
  // ============================================================================
  // CONTENT RENDERING
  // ============================================================================
  
  // Render categories
  if categories.len() > 0 {
    for category in categories [
      = #category.name
      
      #if "description" in category and category.description != none [
        #text(size: size-medium, fill: color-text-light)[#category.description]
        #v(0.5em)
      ]
      
      #if "tasks" in category and category.tasks != none {
        for task in category.tasks {
          render-task(task)
        }
      }
      
      #v(1em)
    ]
  }
  
  // Render standalone tasks
  if tasks.len() > 0 {
    if categories.len() > 0 [
      = Weitere Aufgaben
    ]
    
    for task in tasks {
      render-task(task)
    }
  }
  
  // Additional notes section
  if notes != none [
    #pagebreak(weak: true)
    = Notizen
    #notes
  ]
  
  // Custom body content
  body
}

// Export for use in other files
#let tasklist = task-list
