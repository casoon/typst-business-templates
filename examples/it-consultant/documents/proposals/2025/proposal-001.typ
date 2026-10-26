#import "@local/business-templates:0.2.0": proposal

#show: proposal.with(
  title: "Cloud Migration - Infrastructure Modernisierung",
  document_number: "PRO-2025-001",
  client_name: "TechVision GmbH",
  project_name: "Cloud Migration AWS",
  budget: "45.000 - 65.000 EUR",
  timeline: "3-4 Monate (Q1-Q2 2025)",
  version: "1.0",
  status: "Angebot",
  tags: ("Cloud", "AWS", "Migration", "Infrastructure"),
  created_at: "2025-01-22",
  valid_until: "2025-02-28",
  authors: ("Max Mustermann",),
  show_toc: true,
  company: json("/data/company.json"),
)

= Executive Summary

TechVision GmbH plant die Migration ihrer On-Premise Infrastruktur in die AWS Cloud. Dieser Vorschlag beschreibt einen strukturierten Migrations-Ansatz, der Ausfallzeiten minimiert und gleichzeitig moderne Cloud-Native Praktiken implementiert.

*Kernziele:*
- 99,9% Verfügbarkeit der Systeme
- 30% Kostenreduktion bei Infrastruktur
- Automatisiertes Deployment und Skalierung
- Verbesserte Disaster Recovery (RTO < 1h, RPO < 15min)

= Ausgangssituation

== Aktuelle Infrastruktur

*Server:*
- 3x Physische Server (Dell PowerEdge)
- 12x Virtuelle Maschinen (VMware)
- 2x Datenbank-Server (PostgreSQL, MySQL)
- 1x File Server (NAS, 10TB)

*Herausforderungen:*
- Hohe Wartungskosten für Hardware
- Eingeschränkte Skalierbarkeit
- Manuelles Deployment-Prozess
- Keine automatisierten Backups
- Single Point of Failure bei kritischen Systemen

= Lösungsansatz

== Cloud-Architektur (AWS)

*Compute:*
- EC2 Instances (Auto Scaling Groups)
- Container Orchestration mit ECS/Fargate
- Lambda für Serverless Workflows

*Storage:*
- S3 für Object Storage
- EBS für Block Storage
- EFS für Shared File Systems

*Database:*
- RDS für PostgreSQL (Multi-AZ)
- Aurora für MySQL (Read Replicas)
- ElastiCache (Redis) für Caching

*Networking:*
- VPC mit Public/Private Subnets
- Application Load Balancer
- CloudFront CDN
- Route53 für DNS

*Security:*
- IAM Roles & Policies
- Security Groups & NACLs
- AWS WAF für Web Application Firewall
- KMS für Encryption at Rest

*Monitoring:*
- CloudWatch für Logs und Metrics
- CloudTrail für Audit Logs
- X-Ray für Distributed Tracing

== Migrations-Strategie

Wir empfehlen einen hybriden Ansatz:

*Rehost (Lift & Shift):* Für Legacy-Systeme (30%)
- Schnelle Migration ohne Code-Änderungen
- VM Import nach EC2

*Replatform:* Für Datenbanken und Web-Apps (50%)
- Nutzung von Managed Services (RDS, ECS)
- Minimale Code-Anpassungen

*Refactor:* Für kritische Business-Logik (20%)
- Cloud-Native Redesign
- Microservices Architektur
- Serverless Components

= Projektphasen

== Phase 1: Assessment & Planung (2 Wochen)

*Deliverables:*
- Detailliertes Infrastruktur-Inventar
- Dependency Mapping
- Cost Analysis (TCO Vergleich)
- Detaillierter Migrationsplan
- Risk Assessment

*Aufwand:* 40 Stunden

== Phase 2: AWS Setup & Foundation (3 Wochen)

*Aktivitäten:*
- AWS Account Setup (Organizations, Multi-Account Strategy)
- Landing Zone Konfiguration
- VPC und Networking Setup
- IAM Policies und Rollen
- Security Baseline (CIS Benchmarks)
- Monitoring und Logging Setup

*Deliverables:*
- AWS Landing Zone
- Terraform Infrastructure as Code
- Security Hardening Dokumentation
- Monitoring Dashboards

*Aufwand:* 80 Stunden

== Phase 3: Test-Migration (2 Wochen)

*Aktivitäten:*
- Non-Production Systeme migrieren
- Testing und Validation
- Performance Benchmarking
- Disaster Recovery Tests

*Deliverables:*
- Migrationsskripte
- Test-Berichte
- Angepasste Prozesse

*Aufwand:* 60 Stunden

== Phase 4: Production Migration (4 Wochen)

*Aktivitäten:*
- Rolling Migration der Production-Systeme
- Blue-Green Deployment für kritische Apps
- Datenbank-Migration mit minimaler Downtime
- DNS Cutover
- 24/7 Support während Migration

*Deliverables:*
- Vollständig migrierte Production-Umgebung
- Cutover-Dokumentation
- Rollback-Pläne

*Aufwand:* 120 Stunden

== Phase 5: Optimierung & Training (3 Wochen)

*Aktivitäten:*
- Cost Optimization (Reserved Instances, Savings Plans)
- Performance Tuning
- Auto-Scaling Konfiguration
- Team-Training (AWS Fundamentals, Best Practices)
- Dokumentation und Runbooks

*Deliverables:*
- Optimierte Infrastruktur
- Training-Sessions (3x halbtägig)
- Vollständige Dokumentation
- Operations Runbooks

*Aufwand:* 80 Stunden

= Zeitplan

#table(
  columns: (1fr, 1fr, 1fr),
  [*Phase*], [*Dauer*], [*Zeitraum*],
  [1. Assessment], [2 Wochen], [KW 6-7],
  [2. AWS Setup], [3 Wochen], [KW 8-10],
  [3. Test-Migration], [2 Wochen], [KW 11-12],
  [4. Production], [4 Wochen], [KW 13-16],
  [5. Optimierung], [3 Wochen], [KW 17-19]
)

*Gesamtdauer:* 14 Wochen (ca. 3,5 Monate)

= Kostenaufstellung

== Beratungsleistungen

#table(
  columns: (2fr, 1fr, 1fr, 1fr),
  [*Leistung*], [*Stunden*], [*Satz*], [*Summe*],
  [Assessment & Planung], [40h], [95 EUR], [3.800 EUR],
  [AWS Setup], [80h], [95 EUR], [7.600 EUR],
  [Test-Migration], [60h], [95 EUR], [5.700 EUR],
  [Production Migration], [120h], [95 EUR], [11.400 EUR],
  [Optimierung & Training], [80h], [95 EUR], [7.600 EUR],
  [*Summe Beratung*], [*380h*], [], [*36.100 EUR*]
)

== AWS Infrastruktur-Kosten (monatlich, geschätzt)

#table(
  columns: (2fr, 1fr),
  [*Service*], [*Kosten/Monat*],
  [EC2 Instances (t3.large, 5x)], [400 EUR],
  [RDS PostgreSQL (Multi-AZ)], [350 EUR],
  [S3 Storage (2TB)], [50 EUR],
  [Load Balancer], [25 EUR],
  [CloudFront CDN], [80 EUR],
  [Backup & Disaster Recovery], [120 EUR],
  [Monitoring & Logging], [75 EUR],
  [*Summe AWS (monatlich)*], [*~1.100 EUR*]
)

*Hinweis:* Nach Optimierung (Reserved Instances) erwarten wir eine Reduktion auf ca. 750-850 EUR/Monat.

== Gesamtkosten

- *Einmalig (Migration):* 36.100 EUR (netto)
- *Laufend (AWS):* ~1.100 EUR/Monat (erste 3 Monate)
- *Laufend (optimiert):* ~800 EUR/Monat (ab Monat 4)

*ROI:* Bei aktuellen On-Premise Kosten von 2.500 EUR/Monat erreichen Sie Break-Even nach ca. 24 Monaten.

= Risiken & Mitigation

== Risiko 1: Datenverlust während Migration

*Wahrscheinlichkeit:* Niedrig
*Impact:* Kritisch
*Mitigation:*
- Vollständige Backups vor Migration
- Test-Migration zuerst
- Rollback-Plan für jeden Schritt

== Risiko 2: Performance-Probleme nach Migration

*Wahrscheinlichkeit:* Mittel
*Impact:* Hoch
*Mitigation:*
- Ausführliches Performance-Testing
- Right-Sizing der Instances
- Auto-Scaling für Lastspitzen

== Risiko 3: Kosten-Überschreitung

*Wahrscheinlichkeit:* Mittel
*Impact:* Mittel
*Mitigation:*
- AWS Cost Budgets und Alerts
- Wöchentliches Cost Monitoring
- Reserved Instances für vorhersagbare Workloads

= Warum wir?

*Erfahrung:*
- 15+ erfolgreiche Cloud-Migrationen
- AWS Certified Solutions Architect
- 8 Jahre Erfahrung mit AWS

*Methodik:*
- Strukturierter Migrations-Ansatz
- Minimale Ausfallzeiten
- Kontinuierliche Kommunikation

*Support:*
- 3 Monate Post-Migration Support inklusive
- 24/7 Erreichbarkeit während kritischer Phasen
- Wissenstransfer an Ihr Team

= Referenzen

*Projekt 1:* E-Commerce Platform Migration (2024)
- 50+ Server zu AWS
- Zero-Downtime Migration
- 40% Kostenreduktion

*Projekt 2:* Fintech SaaS Migration (2023)
- PCI-DSS Compliance in AWS
- Multi-Region Setup
- 99.99% Uptime seit Migration
