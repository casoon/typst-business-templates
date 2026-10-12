# IT-Consultant Examples

Dieses Verzeichnis enthält vollständige Beispiele für alle verfügbaren Dokumenttypen.

## Überblick

Alle Beispiele basieren auf einem realistischen IT-Beratungs-Szenario mit folgenden Projekten:

### Hauptprojekt: API Migration für DataFlow Analytics AG
- **Client**: DataFlow Analytics AG (Dr. Sarah Schmidt, CTO)
- **Projekt**: Migration einer Legacy-API zu modernem REST-API Design
- **Umfang**: User Management, Data Processing, Reporting Endpoints
- **Timeline**: Q1 2025 (14 Wochen)

### Nebenprojekt: Cloud Migration für TechVision GmbH
- **Client**: TechVision GmbH (Thomas Weber, CTO)
- **Projekt**: Migration On-Premise Infrastruktur zu AWS
- **Umfang**: 15 VMs, Datenbanken, File Storage
- **Timeline**: Q1-Q2 2025 (14 Wochen)

## Verfügbare Dokumenttypen

### 📄 Accounting-Layout (Rechnungswesen)

| Typ | Datei | Beschreibung |
|-----|-------|--------------|
| **Invoice** | `invoices/2025/invoice.json` | Rechnungen für erbrachte Leistungen |
| **Offer** | `offers/2025/offer.json` | Angebote für IT-Dienstleistungen |
| **Letter** | `letters/2025/letter-001.json` | Geschäftsbrief (Projektanfrage) |
| **Credit Note** | `credit-notes/2025/credit-note-001.json` | Gutschrift für stornierte Leistungen |
| **Reminder** | `reminders/2025/reminder-001.json` | 1. Mahnung für überfällige Rechnung |
| **Delivery Note** | `delivery-notes/2025/delivery-note-001.json` | Lieferschein für Hardware |
| **Order Confirmation** | `order-confirmations/2025/order-confirmation-001.json` | Auftragsbestätigung API-Projekt |
| **Time Sheet** | `time-sheets/2025/timesheet-001.json` | Stundenzettel mit 71.5h über 2 Wochen |

### 📋 Document-Layout (Projektdokumentation)

| Typ | Datei | Beschreibung |
|-----|-------|--------------|
| **Concept** | `concepts/2025/concept.typ` | Projektkonzepte |
| **Documentation** | `documentation/2025/documentation.typ` | Technische Dokumentation |
| **Contract** | `contracts/2025/contract-001.typ` | Dienstleistungsvertrag (6 Monate) |
| **Protocol** | `protocols/2025/protocol-001.typ` | Kick-off Meeting Protokoll |
| **Specification** | `specifications/2025/specification-001.typ` | API Spezifikation mit OpenAPI |
| **Proposal** | `proposals/2025/proposal-001.typ` | Cloud Migration Projektvorschlag |
| **SLA** | `slas/2025/sla-001.typ` | Service Level Agreement (12 Monate) |
| **Quotation Request** | `quotation-requests/2025/quotation-request-001.json` | Angebotsanfrage für Tools |

### 🔒 Special-Layout

| Typ | Datei | Beschreibung |
|-----|-------|--------------|
| **Credentials** | `credentials/2025/credentials.json` | Zugangsdaten für Systeme |

## Verwendung

Kompilieren: siehe [examples/README.md](../README.md). Jede JSON-Datei hat daneben eine
gleichnamige `.typ`-Datei, die die Daten an das Template übergibt. Konzept, Dokumentation,
Vertrag, Protokoll, Spezifikation, Projektvorschlag und SLA sind direkt in Typst geschrieben.

## Realistische Szenarien

### Szenario 1: Komplettes Projekt-Lifecycle

1. **Proposal** (`proposals/2025/proposal-001.typ`) - Projektvorschlag Cloud Migration
2. **Contract** (`contracts/2025/contract-001.typ`) - Unterschriebener Vertrag
3. **Protocol** (`protocols/2025/protocol-001.typ`) - Kick-off Meeting
4. **Specification** (`specifications/2025/specification-001.typ`) - API-Spezifikation
5. **Time Sheet** (`time-sheets/2025/timesheet-001.json`) - Wöchentliche Zeiterfassung
6. **Order Confirmation** (`order-confirmations/2025/order-confirmation-001.json`) - Auftragsbestätigung
7. **Invoice** (`invoices/2025/invoice.json`) - Monatliche Abrechnung
8. **SLA** (`slas/2025/sla-001.typ`) - Ongoing Support nach Projekt

### Szenario 2: Zahlungs-Workflow

1. **Invoice** - Rechnung versandt
2. **Reminder** (`reminders/2025/reminder-001.json`) - 1. Mahnung nach Zahlungsverzug
3. **Credit Note** (`credit-notes/2025/credit-note-001.json`) - Teilstorno bei Reduzierung

### Szenario 3: Beschaffung

1. **Quotation Request** (`quotation-requests/2025/quotation-request-001.json`) - Anfrage an Supplier
2. **Order Confirmation** - Bestätigung vom Supplier
3. **Delivery Note** (`delivery-notes/2025/delivery-note-001.json`) - Warenlieferung

## Anpassung

Um diese Examples für Ihr Unternehmen anzupassen:

1. **Firmendaten ändern**: `data/company.json` editieren
3. **Texte anpassen**: JSON- und `.typ`-Dateien in `documents/` editieren
4. **Neue Dokumente**: JSON-Datei und `.typ`-Datei kopieren und anpassen

## Tipps

- Alle Beträge sind in EUR (netto)
- Datumsformat: YYYY-MM-DD in JSON
- MwSt.-Satz: 19% (Standard in Deutschland)
- Zahlungsziel: Standard 14 Tage
