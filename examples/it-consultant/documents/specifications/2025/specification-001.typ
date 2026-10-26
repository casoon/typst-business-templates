#import "@local/business-templates:0.2.0": specification

#show: specification.with(
  title: "API Migration Spezifikation",
  document_number: "SPEC-2025-001",
  subject: "REST API v2.0 - User Management",
  client_name: "DataFlow Analytics AG",
  project_name: "API Migration Projekt",
  version: "1.2",
  status: "Review",
  tags: ("API", "REST", "Migration", "Backend"),
  authors: ("Max Mustermann", "Anna Fischer"),
  created_at: "2025-01-05",
  last_updated: "2025-01-18",
  show_toc: true,
  company: json("/data/company.json"),
)

= Einleitung

== Zweck des Dokuments

Dieses Dokument spezifiziert die Anforderungen und das Design der neuen REST API v2.0 für das User Management System von DataFlow Analytics AG.

== Zielgruppe

- Backend-Entwickler
- Frontend-Entwickler (API-Konsumenten)
- QA-Team
- DevOps-Team

== Änderungshistorie

#table(
  columns: (60pt, 80pt, 1fr, 1fr),
  [*Version*], [*Datum*], [*Autor*], [*Änderung*],
  [1.0], [05.01.2025], [Max Mustermann], [Initiale Version],
  [1.1], [12.01.2025], [Anna Fischer], [Authentication Endpoints hinzugefügt],
  [1.2], [18.01.2025], [Max Mustermann], [Rate Limiting spezifiziert]
)

= Systemübersicht

== Architektur

Die neue API folgt einer modernen REST-Architektur mit folgenden Komponenten:

- *API Gateway:* NGINX als Reverse Proxy
- *Application Server:* Node.js mit Express.js Framework
- *Database:* PostgreSQL 14
- *Cache:* Redis 7
- *Authentication:* JWT (JSON Web Tokens)

== Technologie-Stack

```javascript
// Package Dependencies
{
  "express": "^4.18.0",
  "jsonwebtoken": "^9.0.0",
  "bcrypt": "^5.1.0",
  "pg": "^8.11.0",
  "redis": "^4.6.0",
  "helmet": "^7.1.0",
  "express-rate-limit": "^7.1.0"
}
```

= Funktionale Anforderungen

== User Management

=== REQ-001: Benutzer erstellen [HIGH]

*Beschreibung:* Das System muss es Administratoren ermöglichen, neue Benutzer anzulegen.

*Endpoint:* `POST /api/v2/users`

*Request Body:*
```json
{
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "user",
  "permissions": ["read", "write"]
}
```

*Response (201):*
```json
{
  "id": "uuid-v4",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "user",
  "createdAt": "2025-01-18T10:30:00Z"
}
```

*Validierung:*
- Email muss gültig und eindeutig sein
- firstName und lastName sind Pflichtfelder (min. 2 Zeichen)
- role muss einem der definierten Rollen entsprechen: `admin`, `user`, `readonly`

=== REQ-002: Benutzer abrufen [HIGH]

*Beschreibung:* Abruf eines einzelnen Benutzers anhand der ID

*Endpoint:* `GET /api/v2/users/{userId}`

*Response (200):*
```json
{
  "id": "uuid-v4",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "user",
  "permissions": ["read", "write"],
  "createdAt": "2025-01-10T10:30:00Z",
  "updatedAt": "2025-01-18T14:20:00Z",
  "lastLogin": "2025-01-18T09:15:00Z"
}
```

=== REQ-003: Benutzer aktualisieren [MEDIUM]

*Endpoint:* `PATCH /api/v2/users/{userId}`

*Request Body (partial update):*
```json
{
  "firstName": "Jane",
  "permissions": ["read", "write", "admin"]
}
```

=== REQ-004: Benutzer löschen [MEDIUM]

*Endpoint:* `DELETE /api/v2/users/{userId}`

*Response (204):* No Content

*Hinweis:* Soft-Delete - Benutzer wird als "deactivated" markiert, nicht physisch gelöscht

=== REQ-005: Benutzerliste abrufen [HIGH]

*Endpoint:* `GET /api/v2/users`

*Query Parameters:*
- `page`: Seitennummer (default: 1)
- `limit`: Einträge pro Seite (default: 20, max: 100)
- `role`: Filter nach Rolle
- `search`: Volltextsuche in Name/Email
- `sort`: Sortierung (z.B. `createdAt:desc`)

*Response (200):*
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 157,
    "pages": 8
  }
}
```

== Authentication & Authorization

=== REQ-010: Login [HIGH]

*Endpoint:* `POST /api/v2/auth/login`

*Request:*
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

*Response (200):*
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "role": "user"
  }
}
```

*Sicherheit:*
- Passwörter werden mit bcrypt (cost factor 12) gehasht
- Rate Limiting: 5 Versuche pro 15 Minuten pro IP
- Account-Sperre nach 10 fehlgeschlagenen Versuchen

=== REQ-011: Token Refresh [HIGH]

*Endpoint:* `POST /api/v2/auth/refresh`

*Request:*
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

=== REQ-012: Logout [MEDIUM]

*Endpoint:* `POST /api/v2/auth/logout`

*Funktion:* Invalidiert das aktuelle Access Token durch Blacklisting in Redis

= Nicht-funktionale Anforderungen

== Performance

- *Response Time:* \< 200ms für 95% aller Requests (p95)
- *Throughput:* Min. 1000 Requests pro Sekunde
- *Concurrent Users:* Bis zu 10.000 gleichzeitige Nutzer

== Sicherheit

- HTTPS-Only (TLS 1.3)
- CORS-Policy konfiguriert
- Helmet.js für Security Headers
- Input Validation & Sanitization
- SQL Injection Prevention (Prepared Statements)
- XSS Protection

== Rate Limiting

```javascript
// Rate Limiting Konfiguration
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 Minuten
  max: 100, // Max 100 Requests pro Window
  message: 'Too many requests from this IP'
});
```

*Spezielle Limits:*
- Login: 5 Requests / 15 Minuten
- User Creation: 10 Requests / Stunde
- Standard: 100 Requests / 15 Minuten

== Monitoring & Logging

- Strukturiertes Logging (JSON-Format)
- Request/Response Logging
- Error Tracking mit Sentry
- Metrics: Prometheus
- Visualization: Grafana Dashboard

= API-Dokumentation

== OpenAPI Specification

Die vollständige API wird mit OpenAPI 3.0 dokumentiert und unter `/api/v2/docs` verfügbar gemacht (Swagger UI).

== Versionierung

- URL-basierte Versionierung: `/api/v2/...`
- Alte Version v1 läuft parallel für 6 Monate
- Deprecation Warnings in Response Headers

= Testing

== Unit Tests

- Code Coverage: Min. 80%
- Framework: Jest
- Alle Business Logic Funktionen

== Integration Tests

- Framework: Supertest
- Alle API Endpoints
- Positive & Negative Test Cases

== Load Tests

- Tool: k6
- Szenarien: 100, 500, 1000 concurrent users
- Ziel: \< 200ms Response Time bei 1000 Users

= Deployment

== Staging

- Automatisches Deployment bei Merge in `develop` Branch
- URL: `https://api-staging.dataflow.com`

== Production

- Blue-Green Deployment Strategie
- URL: `https://api.dataflow.com`
- Rollback-Mechanismus innerhalb 5 Minuten

= Offene Punkte

- [ ] Entscheidung über OAuth2 Integration für externe Clients
- [ ] Finalisierung der GDPR-konformen User-Daten-Export Funktion
- [ ] Definition der Backup & Recovery Strategie
