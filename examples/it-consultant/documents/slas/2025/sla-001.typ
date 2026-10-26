#import "@local/business-templates:0.2.0": sla

#show: sla.with(
  title: "Service Level Agreement - Cloud Infrastructure Support",
  document_number: "SLA-2025-001",
  service_provider: ("company": "IT-Consulting Max Mustermann", "name": "Max Mustermann", "address": ("street": "Musterstraße", "house_number": "123", "postal_code": "12345", "city": "Musterstadt")),
  customer: ("company": "TechVision GmbH", "name": "Thomas Weber (CTO)", "address": ("street": "Innovation Street", "house_number": "42", "postal_code": "80331", "city": "München")),
  effective_date: "01.03.2025",
  termination_date: "28.02.2026",
  review_period: "Quartalsweise",
  version: "1.0",
  status: "Aktiv",
  created_at: "2025-01-25",
  show_toc: true,
  company: json("/data/company.json"),
)

= Leistungsbeschreibung

== Umfang der Services

Der Service Provider erbringt folgende Leistungen für die AWS Cloud-Infrastruktur des Kunden:

*Monitoring & Alerting:*
- 24/7 Überwachung der Cloud-Infrastruktur
- Proaktive Benachrichtigung bei Incidents
- Performance Monitoring
- Cost Monitoring und Reporting

*Incident Management:*
- Ticket-basiertes Support-System
- Incident Response nach definierten SLAs
- Root Cause Analysis bei kritischen Incidents
- Post-Incident Reports

*Wartung & Updates:*
- Regelmäßige Security Updates
- Patch Management für EC2 Instances
- Datenbank-Wartungsfenster
- Infrastructure-as-Code Updates

*Beratung & Optimierung:*
- Monatliche Optimierungs-Reviews
- Cost Optimization Empfehlungen
- Architecture Reviews
- Best Practice Guidance

= Service Level Objectives (SLOs)

== Verfügbarkeit

#table(
  columns: (2fr, 1fr, 2fr),
  [*Service*], [*SLO*], [*Messung*],
  [Production Web Apps], [99.9%], [Uptime pro Monat],
  [API Services], [99.95%], [Uptime pro Monat],
  [Datenbank (RDS)], [99.95%], [Uptime pro Monat],
  [Object Storage (S3)], [99.99%], [Availability per AWS SLA]
)

*Geplante Wartungsfenster:*
- Jeden 1. Sonntag im Monat, 02:00-06:00 Uhr
- Vorankündigung: Mindestens 7 Tage
- Werden nicht auf SLO-Berechnung angerechnet

== Response & Resolution Times

#table(
  columns: (1fr, 2fr, 1fr, 1fr),
  [*Priority*], [*Definition*], [*Response*], [*Resolution*],
  [P1 - Critical], [Production down, Datenverlust], [15 min], [4 Stunden],
  [P2 - High], [Major Feature nicht verfügbar], [1 Stunde], [8 Stunden],
  [P3 - Medium], [Minor Feature beeinträchtigt], [4 Stunden], [2 Werktage],
  [P4 - Low], [Fragen, Feature Requests], [1 Werktag], [5 Werktage]
)

*Response Time:* Zeit bis zur ersten Reaktion auf ein Ticket
*Resolution Time:* Zeit bis zur vollständigen Behebung

== Performance

*API Response Time:*
- p50 (Median): < 100ms
- p95: < 250ms
- p99: < 500ms

*Web Application Load Time:*
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3.5s

*Database Query Performance:*
- 95% aller Queries: < 100ms
- Komplexe Reports: < 2s

= Support-Modell

== Support-Zeiten

*Standard Support:*
- Montag - Freitag: 09:00 - 18:00 Uhr (MEZ)
- Telefon, Email, Ticket-System

*Emergency Support (P1):*
- 24/7 verfügbar
- Hotline: +49 123 456789
- Automatische Eskalation nach 15 Minuten

== Kontakt-Kanäle

*Ticket-System:* https://support.it-consulting.de
*Email:* support\@it-consulting.de
*Telefon:* +49 123 456789 (Werktags 9-18 Uhr)
*Emergency Hotline:* +49 123 456700 (24/7 für P1)
*Slack Channel:* \#techvision-support (Business Hours)

== Eskalationspfad

*Level 1:* Support Engineer (Tickets P2-P4)
*Level 2:* Senior Engineer (Tickets P1, eskalierte P2)
*Level 3:* Lead Architect (Komplexe Architektur-Fragen)
*Management:* Max Mustermann (Eskalation bei SLA-Verletzung)

= Monitoring & Reporting

== Metriken

*Infrastructure Metrics:*
- CPU, Memory, Disk Utilization
- Network Traffic und Bandwidth
- Error Rates und HTTP Status Codes
- Database Connections und Slow Queries

*Business Metrics:*
- Application Response Times
- User Sessions und Active Users
- Transaction Volumes
- Error Rates nach Feature

== Reporting

*Monatliche Reports:*
- SLA Compliance Report
- Incident Summary
- Performance Trends
- Cost Report und Optimierungen
- Kapazitäts-Planung

*Quartalsweise Reviews:*
- Business Review Meeting
- Architecture Review
- SLA Review und Anpassung
- Roadmap Planning

= Verantwortlichkeiten

== Service Provider Verantwortlichkeiten

*Infrastruktur:*
- AWS Account Management
- Security Groups und IAM Policies
- Backup und Disaster Recovery
- Patch Management

*Monitoring:*
- 24/7 Infrastructure Monitoring
- Alert Configuration
- Incident Response

*Dokumentation:*
- Infrastructure-as-Code (Terraform)
- Runbooks und Playbooks
- Architecture Diagrams
- Change Management Logs

== Kunden-Verantwortlichkeiten

*Application:*
- Application Code und Deployments
- Application-Level Monitoring
- Business Logic und Features

*Daten:*
- Data Quality und Validation
- Backup-Retention Policy
- GDPR Compliance der Daten

*Kommunikation:*
- Rechtzeitige Meldung von Änderungen
- Teilnahme an Quarterly Reviews
- Feedback zu Services

= Change Management

== Standard Changes

*Definition:* Vorab genehmigte, risikoarme Änderungen

*Beispiele:*
- Security Patches
- Auto-Scaling Anpassungen
- Log-Rotation Konfiguration

*Prozess:*
- Keine separate Genehmigung erforderlich
- Automatische Benachrichtigung nach Durchführung

== Normal Changes

*Definition:* Planbare Änderungen mit mittlerem Risiko

*Beispiele:*
- Instance Type Änderungen
- Neue Security Groups
- Database Version Upgrades

*Prozess:*
- Change Request im Ticket-System
- Genehmigung durch Kunden (48h vor Umsetzung)
- Dokumentierter Rollback-Plan
- Durchführung im Wartungsfenster

== Emergency Changes

*Definition:* Ungeplante Änderungen zur Behebung kritischer Issues

*Beispiele:*
- Security Incident Response
- Kritische Performance-Fixes
- Service Restoration

*Prozess:*
- Sofortige Umsetzung möglich
- Nachträgliche Dokumentation
- Post-Change Review innerhalb 24h

= SLA-Gutschriften

== Verfügbarkeits-SLA Verletzungen

#table(
  columns: (1fr, 1fr),
  [*Verfügbarkeit*], [*Gutschrift*],
  [< 99.9% aber ≥ 99.0%], [10% der monatlichen Gebühr],
  [< 99.0% aber ≥ 95.0%], [25% der monatlichen Gebühr],
  [< 95.0%], [50% der monatlichen Gebühr]
)

== Response Time SLA Verletzungen

Bei wiederholten Verletzungen (3+ im Monat):
- Zusätzliche 10% Gutschrift pro Vorfall
- Verpflichtender Process Improvement Plan

*Ausnahmen (keine Gutschriften):*
- Geplante Wartungsfenster
- Force Majeure (AWS Outages)
- Probleme durch Kunden-verursachte Änderungen
- DDoS-Angriffe (außerhalb der Kontrolle)

= Security & Compliance

== Security Maßnahmen

*Zugriffskontrolle:*
- Multi-Factor Authentication (MFA) für alle Accounts
- Principle of Least Privilege
- Regelmäßige Access Reviews

*Verschlüsselung:*
- Encryption at Rest (AES-256)
- Encryption in Transit (TLS 1.3)
- Key Management mit AWS KMS

*Monitoring:*
- Security Monitoring mit GuardDuty
- Config Rules für Compliance
- CloudTrail Audit Logs

== Compliance

*Standards:*
- ISO 27001 Practices
- CIS AWS Foundations Benchmark
- GDPR Compliance

*Audits:*
- Vierteljährliche Security Reviews
- Penetration Tests (jährlich)
- Compliance Reports auf Anfrage

= Vertragskonditionen

== Laufzeit und Kündigung

*Laufzeit:* 12 Monate (01.03.2025 - 28.02.2026)

*Verlängerung:* Automatisch um weitere 12 Monate, sofern nicht 3 Monate vor Ablauf gekündigt

*Kündigung:* Schriftlich mit 3 Monaten Frist zum Monatsende

== Preisgestaltung

*Monatliche Pauschale:* 2.500 EUR (netto)

*Inkludiert:*
- 40 Stunden Support pro Monat
- Monitoring & Alerting
- Monatliche Reports
- Quartalsweise Reviews

*Zusatzleistungen:*
- Weitere Support-Stunden: 95 EUR/h
- Notfall-Support außerhalb Geschäftszeiten: 150 EUR/h
- On-Site Support: Nach Aufwand + Reisekosten

== SLA Review

*Quarterly Business Reviews:*
- Review der SLA-Metriken
- Anpassung der Objectives bei Bedarf
- Feedback und Verbesserungsvorschläge
- Roadmap-Planung

*Jährliche Vertrags-Review:*
- Umfassende Service-Bewertung
- Preisanpassungen
- Scope-Änderungen
- Verlängerungs-Verhandlungen
