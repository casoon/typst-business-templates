#import "@local/business-templates:0.1.0": concept

// Company data from the example project
#let company = json("/data/company.json")

#show: concept.with(
  title: "Online-Shop Konzept Bio-Hofladen",
  document_number: "KO-2025-002",
  client_name: "Hofbauer's Biohof",
  project_name: "E-Commerce Lösung",
  version: "1.0",
  status: "draft",
  tags: ("E-Commerce", "Shopware", "Bio", "Regional"),
  created_at: "2025-01-15",
  company: company,
)

= Ausgangssituation

Hofbauer's Biohof ist ein familiengeführter Bio-Bauernhof in Alfter bei Bonn. Seit über 30 Jahren werden hier Gemüse, Obst und Milchprodukte in Bio-Qualität produziert. Der Verkauf erfolgt bisher ausschließlich über den Hofladen vor Ort und auf zwei Wochenmärkten in der Region.

== Herausforderungen

- *Begrenzte Reichweite:* Kunden müssen physisch zum Hofladen oder Markt kommen
- *Saisonale Schwankungen:* Hohe Nachfrage im Sommer, weniger Kunden im Winter
- *Keine Planbarkeit:* Tagesgeschäft erschwert Anbauplanung
- *Verlorene Stammkunden:* Weggezogene Kunden haben keine Bezugsmöglichkeit mehr

== Ziele des Projekts

1. *Regionaler Online-Vertrieb* im Umkreis von 30 km
2. *Abo-Box System* für planbare, wiederkehrende Bestellungen
3. *Erhöhung der Kundenbindung* durch digitalen Kanal
4. *Optimierung der Anbauplanung* durch Vorbestellungen

= Lösungskonzept

== Shopware 6 als Plattform

Wir empfehlen Shopware 6 als E-Commerce-Plattform:

- Open Source mit aktiver Community
- Deutsche Entwicklung, DSGVO-konform
- Flexible Erweiterbarkeit für Abo-Funktionen
- Gute Performance auch bei wachsenden Produktzahlen

== Kernfunktionen

=== Produktkatalog

Der Shop wird folgende Kategorien abbilden:

#table(
  columns: (1fr, 2fr),
  [*Kategorie*], [*Beispiele*],
  [Gemüse], [Kartoffeln, Karotten, Salate, Kohl, Tomaten],
  [Obst], [Äpfel, Birnen, Beeren (saisonal)],
  [Milchprodukte], [Frischmilch, Joghurt, Quark, Käse],
  [Eier], [Bio-Eier (6er, 10er, 30er Packung)],
  [Fleisch], [Rindfleisch, Hähnchen (auf Vorbestellung)],
  [Hofprodukte], [Marmelade, Honig, Apfelsaft],
)

=== Abo-Box System

Das Herzstück des Shops: Wöchentliche oder zweiwöchentliche Lieferung einer Gemüsebox.

*Varianten:*
- *Kleine Box* (2 Personen): 15 EUR/Woche
- *Familien-Box* (4 Personen): 28 EUR/Woche
- *Große Box* (6+ Personen): 42 EUR/Woche

*Besonderheiten:*
- Kunde kann Produkte ausschließen (Allergien, Vorlieben)
- Inhalt variiert saisonal
- Pausieren jederzeit möglich
- Automatische Abbuchung via SEPA-Lastschrift

=== Lieferlogistik

#table(
  columns: (1fr, 1fr, 1fr),
  [*Option*], [*Gebiet*], [*Kosten*],
  [Selbstabholung], [Hofladen], [Kostenlos],
  [Lieferung], [PLZ 53xxx], [4,90 EUR],
  [Lieferung], [PLZ 50xxx, 51xxx], [6,90 EUR],
)

Liefertage: Mittwoch und Samstag

= Technische Umsetzung

== Systemarchitektur

```
┌─────────────────┐     ┌─────────────────┐
│   Shopware 6    │────▶│   PostgreSQL    │
│   (Frontend)    │     │   (Datenbank)   │
└────────┬────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│     Mollie      │     │    Mailjet      │
│   (Zahlungen)   │     │   (E-Mails)     │
└─────────────────┘     └─────────────────┘
```

== Responsive Design

Der Shop wird für alle Endgeräte optimiert:
- Desktop (ab 1200px)
- Tablet (768px - 1199px)
- Smartphone (bis 767px)

Besonderer Fokus auf Mobile, da viele Kunden unterwegs bestellen.

= Zeitplan

#table(
  columns: (auto, 1fr, auto),
  [*Phase*], [*Aufgaben*], [*Dauer*],
  [1], [Konzeption & Design], [2 Wochen],
  [2], [Shop-Entwicklung], [3 Wochen],
  [3], [Produktfotografie & Content], [1 Woche],
  [4], [Testing & Optimierung], [1 Woche],
  [5], [Go-Live & Schulung], [1 Woche],
)

*Geplanter Go-Live:* Anfang April 2025 (vor der Spargelsaison)

= Investitionsübersicht

== Einmalige Kosten

#table(
  columns: (2fr, 1fr),
  [*Position*], [*Betrag*],
  [Shopware 6 Setup & Entwicklung], [4.800 EUR],
  [Produktfotografie], [890 EUR],
  [Zahlungs- & Versandintegration], [1.140 EUR],
  [Schulung & Dokumentation], [450 EUR],
  [*Summe netto*], [*7.280 EUR*],
)

== Laufende Kosten (monatlich)

#table(
  columns: (2fr, 1fr),
  [*Position*], [*Betrag*],
  [Hosting & Wartung], [79 EUR],
  [Zahlungsgebühren (ca. 1,5%)], [variabel],
  [E-Mail-Versand (Mailjet)], [ca. 15 EUR],
)

= Nächste Schritte

1. *Freigabe des Konzepts* durch Frau Hofbauer
2. *Kickoff-Meeting* zur Detailplanung
3. *Bereitstellung* von Logo, Fotos, Produktliste
4. *Start der Entwicklung*

#v(1cm)

_Wir freuen uns auf die Zusammenarbeit und einen erfolgreichen Start in den Online-Handel!_
