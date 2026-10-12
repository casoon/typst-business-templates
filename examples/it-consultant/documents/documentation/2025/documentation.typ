#import "@local/business-templates:0.1.0": documentation

#show: documentation.with(
  document_number: "DOC-2025-003",
  title: "AWS Architektur-Dokumentation",
  subject: "MedTech Solutions Cloud Infrastructure",
  client_name: "MedTech Solutions AG",
  project_name: "AWS Cloud Migration",
  doc_type: "Architecture Documentation",
  version: "1.0",
  status: "final",
  created_at: "2025-01-22",
  tags: ("AWS", "Architecture", "Cloud", "Infrastructure"),
  authors: ("Dr. Michael Hoffmann", "TechVision Consulting"),
  show_toc: true,
  company: json("/data/company.json"),
)

= Überblick

Diese Dokumentation beschreibt die AWS-Cloud-Architektur der MedTech Solutions AG nach Abschluss der Migration. Sie dient als Referenz für das DevOps-Team und externe Auditoren.

== Architektur-Diagramm

// Erzeugt mit chartlet: chartlet render aws-architecture.json --variant print -o aws-architecture.svg
#figure(
  image("aws-architecture.svg", width: 100%),
  caption: [AWS-Architektur nach der Migration],
)

= Netzwerk

== VPC Konfiguration

#table(
  columns: (1fr, 2fr),
  [*Parameter*], [*Wert*],
  [VPC CIDR], [10.0.0.0/16],
  [Region], [eu-central-1 (Frankfurt)],
  [Availability Zones], [eu-central-1a, eu-central-1b],
  [DNS Hostnames], [Aktiviert],
  [DNS Resolution], [Aktiviert],
)

== Subnets

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  [*Name*], [*CIDR*], [*AZ*], [*Typ*],
  [public-1a], [10.0.1.0/24], [eu-central-1a], [Public],
  [public-1b], [10.0.2.0/24], [eu-central-1b], [Public],
  [private-1a], [10.0.10.0/24], [eu-central-1a], [Private],
  [private-1b], [10.0.20.0/24], [eu-central-1b], [Private],
  [db-1a], [10.0.100.0/24], [eu-central-1a], [Isolated],
  [db-1b], [10.0.200.0/24], [eu-central-1b], [Isolated],
)

== Security Groups

=== ALB Security Group

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  [*Typ*], [*Port*], [*Quelle*], [*Beschreibung*],
  [Inbound], [443], [0.0.0.0/0], [HTTPS von Internet],
  [Inbound], [80], [0.0.0.0/0], [HTTP Redirect],
  [Outbound], [8080], [ECS SG], [Zu ECS Services],
)

=== ECS Security Group

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  [*Typ*], [*Port*], [*Quelle*], [*Beschreibung*],
  [Inbound], [8080], [ALB SG], [Von Load Balancer],
  [Outbound], [5432], [RDS SG], [Zu Datenbank],
  [Outbound], [443], [0.0.0.0/0], [AWS APIs, ECR],
)

= Compute (ECS)

== Cluster Konfiguration

- *Cluster Name:* medtech-prod-cluster
- *Capacity Provider:* FARGATE, FARGATE_SPOT
- *Container Insights:* Aktiviert

== Services

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  [*Service*], [*CPU*], [*Memory*], [*Replicas*],
  [api-gateway], [512], [1024 MB], [2],
  [patient-service], [1024], [2048 MB], [3],
  [billing-service], [512], [1024 MB], [2],
)

== Auto Scaling

- *Metrik:* CPU Utilization
- *Target:* 70%
- *Min Capacity:* 2
- *Max Capacity:* 10
- *Scale-out Cooldown:* 60s
- *Scale-in Cooldown:* 300s

= Datenbank (RDS)

== Konfiguration

#table(
  columns: (1fr, 2fr),
  [*Parameter*], [*Wert*],
  [Engine], [PostgreSQL 15.4],
  [Instance Class], [db.r6g.large],
  [Multi-AZ], [Ja],
  [Storage], [500 GB gp3],
  [IOPS], [3000],
  [Encryption], [AES-256 (AWS KMS)],
  [Backup Retention], [35 Tage],
  [Maintenance Window], [Sun 03:00-04:00 UTC],
)

== Connection Pooling

PgBouncer läuft als Sidecar in jedem ECS Task:

- *Pool Mode:* Transaction
- *Max Connections:* 100
- *Default Pool Size:* 20

= Secrets Management

Alle sensiblen Daten werden in AWS Secrets Manager gespeichert:

#table(
  columns: (1fr, 2fr),
  [*Secret Name*], [*Inhalt*],
  [prod/rds/admin], [Datenbank Admin Credentials],
  [prod/rds/app], [Application User Credentials],
  [prod/api/jwt-secret], [JWT Signing Key],
  [prod/external/stripe], [Stripe API Keys],
)

*Rotation:* Automatische Rotation alle 30 Tage für DB-Credentials.

= CI/CD Pipeline

== Übersicht

```
GitHub Push → GitHub Actions → Build & Test → ECR Push → CodePipeline → ECS Deploy
```

== Stages

1. *Source:* GitHub Repository (main branch)
2. *Build:* Docker Image bauen, Unit Tests
3. *Push:* Image zu ECR pushen
4. *Deploy Staging:* Automatisches Deployment
5. *Integration Tests:* Automatisierte API Tests
6. *Approve:* Manuelle Freigabe
7. *Deploy Production:* Blue/Green Deployment

== Blue/Green Deployment

- *Deployment Controller:* CodeDeploy
- *Traffic Shift:* Linear10PercentEvery1Minute
- *Rollback:* Automatisch bei CloudWatch Alarms

= Monitoring & Alerting

== CloudWatch Dashboards

- *Production Overview:* CPU, Memory, Request Count
- *API Metrics:* Latency, Error Rate, 4xx/5xx
- *RDS Health:* Connections, CPU, Storage

== Alarms

#table(
  columns: (2fr, 1fr, 1fr),
  [*Alarm*], [*Threshold*], [*Action*],
  [API Error Rate > 1%], [5 min], [PagerDuty P2],
  [API Latency p99 > 500ms], [5 min], [PagerDuty P3],
  [RDS CPU > 80%], [15 min], [PagerDuty P3],
  [RDS Connections > 80%], [5 min], [PagerDuty P2],
  [ECS Task Failed], [1 min], [PagerDuty P1],
)

= Disaster Recovery

== RPO / RTO

- *RPO (Recovery Point Objective):* 1 Stunde
- *RTO (Recovery Time Objective):* 4 Stunden

== Backup-Strategie

- *RDS:* Automatische Snapshots (täglich), Transaction Logs (5 min)
- *S3:* Cross-Region Replication nach eu-west-1
- *Secrets:* Replikation nach eu-west-1

== Failover-Prozedur

1. Route 53 Health Check schlägt fehl
2. Automatischer Failover zu Standby (Multi-AZ)
3. PagerDuty Alarm an On-Call Engineer
4. Manuelle Prüfung und Bestätigung

= Kosten

== Monatliche Kosten (geschätzt)

#table(
  columns: (2fr, 1fr),
  [*Service*], [*Kosten/Monat*],
  [ECS Fargate], [~850 EUR],
  [RDS PostgreSQL (Multi-AZ)], [~650 EUR],
  [Application Load Balancer], [~50 EUR],
  [CloudFront], [~100 EUR],
  [S3 + Backups], [~80 EUR],
  [Secrets Manager], [~15 EUR],
  [CloudWatch], [~120 EUR],
  [Data Transfer], [~200 EUR],
  [*Gesamt*], [*~2.065 EUR*],
)

= Kontakt

*TechVision Consulting*\
Dr. Michael Hoffmann\
info\@techvision-consulting.de\
+49 30 12345678
