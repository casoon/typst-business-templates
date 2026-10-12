#import "@local/business-templates:0.1.0": concept

#show: concept.with(
  document_number: "KO-2025-001",
  title: "Packaging Design Konzept Premium-Teelinie",
  client_name: "Bergmann Teemanufaktur",
  project_name: "Verpackungsdesign Teelinie",
  version: "1.0",
  status: "draft",
  created_at: "2025-01-10",
  tags: ("Packaging", "Premium", "Tee", "Nachhaltigkeit"),
  show_toc: true,
  company: json("/data/company.json"),
)

= Die Marke Bergmann

Die Bergmann Teemanufaktur steht seit 1952 für handverlesene Tees höchster Qualität. Die neue Premium-Teelinie soll dieses Erbe modern interpretieren und eine jüngere, designaffine Zielgruppe ansprechen.

== Markenwerte

- *Tradition:* Drei Generationen Tee-Expertise
- *Qualität:* Handverlesene Blätter aus kontrolliertem Anbau
- *Nachhaltigkeit:* Bio-zertifiziert, faire Lieferketten
- *Genuss:* Tee als bewusstes Ritual, nicht als Alltags-Getränk

== Zielgruppe

*Primär:* Design-affine Genießer, 28-45 Jahre, urban, gehobenes Einkommen

*Kaufmotivation:*
- Suchen besondere Geschenke
- Schätzen hochwertige Verpackungen
- Achten auf Nachhaltigkeit
- Bereit, für Qualität mehr zu zahlen

= Designkonzept

== Grundidee: "Stille Eleganz"

Das Design verbindet japanische Ästhetik mit hanseatischer Zurückhaltung. Weniger ist mehr – die Qualität des Tees steht im Mittelpunkt.

== Farbkonzept

Jede Teesorte erhält eine eigene Farbwelt, die den Charakter des Tees widerspiegelt:

#table(
  columns: (1fr, 1fr, 2fr),
  [*Sorte*], [*Farbwelt*], [*Assoziation*],
  [Earl Grey Imperial], [Tiefes Blau], [Bergamotte, Eleganz, Abend],
  [Sencha Hikari], [Zartes Grün], [Frische, Morgen, Japan],
  [Darjeeling First Flush], [Warmes Gold], [Sonne, Himalaya, Premium],
  [Rooibos Sunset], [Terrakotta], [Afrika, Wärme, Sonnenuntergang],
  [Pfefferminz Garten], [Mintgrün], [Frische, Kräuter, Natur],
  [Chai Masala], [Zimt-Braun], [Gewürze, Indien, Wärme],
)

== Typografie

*Headline:* Cormorant Garamond – klassische Serifenschrift mit zeitloser Eleganz

*Body:* Lato – klare, moderne Sans-Serif für Lesbarkeit

Die Kombination schafft die Balance zwischen Tradition und Moderne.

== Verpackungsform

=== Teedosen (100g)

- Zylindrische Metalldose, Höhe 12 cm, Ø 8 cm
- Mattschwarze Basis
- Farbiger Banderole-Streifen mit Sortenname
- Prägung des Bergmann-Logos im Deckel
- Innenliegendes Aromasiegel

=== Teebeutel-Box (20 Stück)

- Rechteckige Kartonage, 15 × 8 × 6 cm
- Naturkarton mit farbigem Aufdruck
- Magnetverschluss für Wiederverschließbarkeit
- FSC-zertifiziertes Papier

= Mockups

== Einzelverpackung

```
    ┌─────────────────┐
    │                 │
    │    BERGMANN     │
    │                 │
    │ ████████████████│ ← Farbstreifen
    │                 │
    │  Earl Grey      │
    │  Imperial       │
    │                 │
    │    100g         │
    └─────────────────┘
```

== Geschenkbox (3er-Set)

Die Geschenkbox präsentiert drei Dosen nebeneinander:

- Außen: Mattschwarzer Karton mit Gold-Prägung
- Innen: Schwarzes Seidenpapier
- Banderole mit Sortenübersicht
- Platz für persönliche Grußkarte

= Materialien & Nachhaltigkeit

== Druckspezifikationen

#table(
  columns: (1fr, 2fr),
  [*Element*], [*Material / Verfahren*],
  [Dose], [Weißblech, food-safe Innenlackierung],
  [Banderole], [Naturpapier 120g/m², Offsetdruck],
  [Kartonage], [Graukarton 400g/m², FSC-zertifiziert],
  [Prägung], [Heißfolienprägung Gold (matt)],
  [Siegel], [Biobasierte Folie, kompostierbar],
)

== Umweltaspekte

- Alle Materialien recycelbar oder kompostierbar
- Dosen zur Wiederverwendung konzipiert
- Minimaler Materialeinsatz durch cleveres Design
- Kurze Lieferwege (Druck in Hamburg)

= Zeitplan & Kosten

== Projektphasen

#table(
  columns: (auto, 1fr, auto),
  [*KW*], [*Phase*], [*Deliverables*],
  [3-4], [Konzept & Moodboards], [Dieses Dokument, 2 Richtungen],
  [5-6], [Design-Entwicklung], [Finale Designs aller 6 Sorten],
  [7], [Geschenkbox], [Design Geschenkverpackung],
  [8], [Druckdaten & Freigabe], [Druckfertige Dateien],
)

== Kostenübersicht

#table(
  columns: (2fr, 1fr),
  [*Position*], [*Betrag*],
  [Konzept & Moodboard], [980 EUR],
  [6× Verpackungsdesign], [2.520 EUR],
  [Geschenkbox-Design], [650 EUR],
  [Druckbegleitung], [340 EUR],
  [*Gesamt (netto)*], [*4.490 EUR*],
)

_Gemäß §19 UStG wird keine Umsatzsteuer berechnet._

= Nächste Schritte

1. Feedback zu den vorgeschlagenen Farbwelten
2. Auswahl: Sollen alle 6 Sorten gleichzeitig oder gestaffelt gelauncht werden?
3. Termin für Druckerei-Gespräch vereinbaren
4. Freigabe zur Design-Entwicklung

#v(1cm)

_Ich freue mich auf Ihr Feedback und die weitere Zusammenarbeit!_

#align(right)[Lisa Chen \ hello\@lisachen.design]
