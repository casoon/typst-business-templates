# Release Process für typst-business-templates

## ⚠️ WICHTIG: Nutze IMMER den GitHub Actions Workflow!

Dieser Workflow baut automatisch für **alle Plattformen** (macOS ARM, Linux ARM/Intel, Windows) und erstellt das Release.

**NIEMALS manuell Binaries bauen und hochladen!**

## Übersicht

Es gibt zwei Repositories:
1. **Haupt-Repo**: `casoon/typst-business-templates` - Code, Templates und GitHub Actions
2. **Homebrew Tap**: `casoon/homebrew-tap` - Homebrew Formula

Der GitHub Actions Workflow (`.github/workflows/release.yml`) automatisiert:
- ✅ Cross-Platform Builds (macOS ARM, Linux ARM + Intel, Windows)
- ✅ Tarball-Erstellung mit korrekten Namen
- ✅ Checksum-Generierung
- ✅ GitHub Release Erstellung
- ✅ Homebrew Tap Benachrichtigung (wenn Token konfiguriert)

## Release-Schritte (EINFACH!)

### 1. Version vorbereiten

```bash
cd /Users/jseidel/GitHub/typst-business-templates

# cli/Cargo.toml aktualisieren
# version = "0.4.x"

# CHANGELOG.md aktualisieren
# [0.4.x] - YYYY-MM-DD
# ### Added / Fixed / Changed
```

### 2. Änderungen committen

```bash
# Alle Änderungen stagen
git add -A

# Commit mit Versionsbump
git commit -m "Bump version to 0.4.x"

# Zu GitHub pushen
git push origin main
```

### 3. Tag erstellen und pushen → Workflow startet automatisch!

```bash
# Tag mit Release Notes erstellen
git tag -a v0.4.x -m "Release v0.4.x: [Titel]

## Fixed
- Fix 1
- Fix 2

## Added
- Feature 1
- Feature 2

## Changed
- Change 1"

# Tag pushen → GitHub Actions Workflow startet automatisch!
git push origin v0.4.x
```

**Das war's!** Der Workflow übernimmt jetzt:
1. Baut für alle Plattformen
2. Erstellt Tarballs/Zips
3. Generiert Checksums
4. Erstellt GitHub Release mit allen Assets

### 4. Workflow-Status prüfen

```bash
# Workflow Status anzeigen
gh run list --workflow=release.yml --limit 1

# Warten bis ✓ erscheint (dauert ~3-5 Minuten)

# Release prüfen
gh release view v0.4.x

# Assets anzeigen
gh release view v0.4.x --json assets --jq '.assets[].name'
```

Erwartete Assets:
- `docgen-aarch64-apple-darwin.tar.gz` (macOS ARM)
- `docgen-aarch64-unknown-linux-gnu.tar.gz` (Linux ARM)
- `docgen-x86_64-unknown-linux-gnu.tar.gz` (Linux Intel)
- `docgen-x86_64-pc-windows-msvc.exe.zip` (Windows)
- `checksums.txt`

### 5. Homebrew Formula aktualisieren

**WICHTIG:** Die Formula muss noch manuell aktualisiert werden (automatische Update ist optional via Token).

```bash
cd /Users/jseidel/GitHub/typst-business-templates

# Checksums aus dem Release holen
gh release view v0.4.x --json assets --jq '.assets[] | select(.name == "checksums.txt") | .url' | xargs curl -sL

# Formula aktualisieren in Formula/docgen.rb:
# 1. version = "0.4.x"
# 2. SHA256 für aarch64-apple-darwin (ARM) eintragen
# 3. SHA256 für x86_64-apple-darwin (Intel) eintragen

# Beispiel aus checksums.txt:
# 5beb03e78e1f286c17d83f72bbba6d80cd18f6a9d7753540c61eefc958159e1a  docgen-aarch64-apple-darwin.tar.gz
# a1b2c3d4e5f6...  docgen-x86_64-apple-darwin.tar.gz

# Formula committen
git add Formula/docgen.rb
git commit -m "Update Formula checksums for v0.4.x"
git push origin main

# Formula ins homebrew-tap kopieren
cp Formula/docgen.rb /opt/homebrew/Library/Taps/casoon/homebrew-tap/Formula/docgen.rb

# Im homebrew-tap committen und pushen
cd /opt/homebrew/Library/Taps/casoon/homebrew-tap
git add Formula/docgen.rb
git commit -m "Update docgen to v0.4.x

- [Änderung 1]
- [Änderung 2]
"
git push origin main
```

### 6. Installation testen

```bash
# Homebrew aktualisieren
brew update

# Upgraden
brew upgrade docgen

# Version prüfen
docgen --version
# Sollte zeigen: docgen 0.4.x

# Funktionalität testen
docgen --help

# Template-Kompilierung testen
cd /Users/jseidel/GitHub/typst-business-templates/examples/it-consultant/documents
docgen compile protocols/2025/protocol-001.json
docgen compile specifications/2025/specification-001.json
```

## Checkliste vor Release

- [ ] Version in `cli/Cargo.toml` aktualisiert
- [ ] `CHANGELOG.md` geschrieben
- [ ] Code committed und gepusht
- [ ] Tag mit Release Notes erstellt
- [ ] **Tag gepusht → GitHub Actions Workflow gestartet**
- [ ] Workflow erfolgreich abgeschlossen (✓)
- [ ] Alle 6 Assets im Release vorhanden
- [ ] Formula mit Checksums aktualisiert
- [ ] Formula ins homebrew-tap kopiert und gepusht
- [ ] Installation über brew getestet
- [ ] Template-Kompilierung getestet

## Warum GitHub Actions?

**Vorteile des Workflows:**
- ✅ **Native Builds** für alle Plattformen (kein Rosetta)
- ✅ **Konsistenz** - gleicher Build-Prozess jedes Mal
- ✅ **Schneller** - paralleles Bauen auf GitHub-Servern
- ✅ **Keine lokalen Builds nötig** - spart Zeit
- ✅ **Reproduzierbar** - jeder Build ist dokumentiert
- ✅ **Checksums automatisch** - keine manuellen Fehler

**Nachteile manueller Builds:**
- ❌ Nur eine Plattform (dein Mac)
- ❌ Fehleranfällig (falsche Dateinamen, fehlende Checksums)
- ❌ Langsamer (manuell Tarballs erstellen, hochladen)
- ❌ Nicht reproduzierbar

## Troubleshooting

### Workflow schlägt fehl

```bash
# Workflow-Log anzeigen
gh run view --log

# Häufige Fehler:
# - Cargo.lock nicht aktualisiert → cargo build lokal laufen lassen
# - Build-Fehler → Code-Probleme beheben
```

### Release existiert bereits

```bash
# Release löschen (wenn fehlerhaft)
gh release delete v0.4.x --yes --cleanup-tag

# Tag neu erstellen und pushen
git tag -a v0.4.x -m "..."
git push origin v0.4.x
```

### Homebrew findet Update nicht

```bash
# Tap-Cache löschen
rm -rf $(brew --cache)/downloads/*docgen*

# Tap neu laden
brew untap casoon/tap
brew tap casoon/tap
brew upgrade docgen
```

### Formula Checksum stimmt nicht

```bash
# Checksums aus Release holen
gh release view v0.4.x --json assets --jq '.assets[] | select(.name == "checksums.txt") | .url' | xargs curl -sL

# Richtige Checksums in Formula eintragen
# Auf macOS:
# - on_arm → aarch64-apple-darwin SHA256
# - on_intel → x86_64-apple-darwin SHA256
```

## Repository-Struktur

```
typst-business-templates/
├── .github/workflows/
│   └── release.yml         # ⭐ GitHub Actions Workflow
├── cli/                    # Rust CLI Code
├── templates/              # Typst Templates
├── Formula/docgen.rb       # Formula (Doku-Kopie)
└── CHANGELOG.md

homebrew-tap/
└── Formula/docgen.rb       # Aktive Formula (hierhin kopieren!)
```

## Wichtige Links

- Haupt-Repo: https://github.com/casoon/typst-business-templates
- Homebrew-Tap: https://github.com/casoon/homebrew-tap
- Releases: https://github.com/casoon/typst-business-templates/releases
- Workflow: https://github.com/casoon/typst-business-templates/actions/workflows/release.yml

## Versionsnummern

Format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking Changes
- **MINOR**: Neue Features (backwards compatible)
- **PATCH**: Bug Fixes

Beispiele:
- 0.4.5 → 0.4.6: Neue Templates (Minor)
- 0.4.6 → 0.4.7: Bug Fixes (Patch)
- 0.4.7 → 0.5.0: Breaking Changes (Minor für 0.x)

---

## ⚠️ WICHTIGSTE REGEL

**IMMER den GitHub Actions Workflow nutzen!**

```bash
# Richtig:
git tag -a v0.4.x -m "Release notes"
git push origin v0.4.x
# → Workflow baut für ALLE Plattformen

# Falsch (NIEMALS):
cargo build --release
tar -czf docgen.tar.gz ...
gh release create ...
# → Nur eine Plattform, fehleranfällig
```
