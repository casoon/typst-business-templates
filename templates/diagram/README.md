# Diagram Template

Generiert Diagramm-PDFs aus einer JSON-Konvention mit automatischem Layout.

Unterstützte Modi:

- `tree` / `hierarchical`
- `flow` / `layered`
- `mindmap` / `radial`
- `timeline`
- `swimlane`
- `quadrant`
- `roadmap`

Beispiel:

```bash
docgen compile diagram.json
```

Die Layout-Berechnung passiert intern im Projekt. Das Typst-Template rendert nur
das vorberechnete Modell.
