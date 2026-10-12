#import "@local/business-templates:0.1.0": documentation

// Company data from the example project
#let company = json("/data/company.json")

#show: documentation.with(
  title: "WordPress Benutzerhandbuch",
  subject: "Zimmermann Schreinerei Website",
  document_number: "DOC-2025-002",
  client_name: "Zimmermann Schreinerei GmbH",
  project_name: "Website Relaunch",
  doc_type: "Benutzerhandbuch",
  version: "1.0",
  status: "final",
  created_at: "2025-01-20",
  tags: ("WordPress", "CMS", "Anleitung"),
  authors: ("Pixelwerk Digitalagentur",),
  company: company,
)
= Einführung

Dieses Handbuch erklärt die wichtigsten Funktionen Ihrer neuen WordPress-Website. Sie können damit eigenständig Inhalte pflegen, neue Seiten erstellen und Ihren WooCommerce-Shop verwalten.

== Anmeldung

1. Öffnen Sie `https://www.zimmermann-schreinerei.de/wp-admin`
2. Geben Sie Ihren Benutzernamen und Ihr Passwort ein
3. Klicken Sie auf "Anmelden"

#block(
  fill: luma(240),
  inset: 10pt,
  radius: 4pt,
  [*Tipp:* Speichern Sie die Login-Seite als Lesezeichen in Ihrem Browser.]
)

= Das Dashboard

Nach der Anmeldung sehen Sie das WordPress-Dashboard. Hier finden Sie:

- *Übersicht:* Schnellzugriff und Statistiken
- *Beiträge:* Blog-Artikel und News
- *Seiten:* Statische Seiten (Über uns, Kontakt, etc.)
- *Medien:* Bilder und Dokumente
- *WooCommerce:* Shop-Verwaltung

= Seiten bearbeiten

== Bestehende Seite bearbeiten

1. Gehen Sie zu *Seiten* → *Alle Seiten*
2. Fahren Sie mit der Maus über die gewünschte Seite
3. Klicken Sie auf "Bearbeiten"
4. Nehmen Sie Ihre Änderungen vor
5. Klicken Sie auf *"Aktualisieren"*

== Der Block-Editor

WordPress verwendet den Block-Editor (Gutenberg). Jeder Inhalt ist ein "Block":

#table(
  columns: (1fr, 2fr),
  [*Block-Typ*], [*Verwendung*],
  [Absatz], [Normaler Text],
  [Überschrift], [H2, H3, H4 Überschriften],
  [Bild], [Einzelnes Bild einfügen],
  [Galerie], [Mehrere Bilder als Galerie],
  [Liste], [Aufzählungen und nummerierte Listen],
  [Tabelle], [Tabellarische Daten],
)

=== Neuen Block hinzufügen

1. Klicken Sie auf das *+* Symbol
2. Wählen Sie den gewünschten Block-Typ
3. Füllen Sie den Inhalt aus

= Bilder hochladen

== Bilder in die Mediathek laden

1. Gehen Sie zu *Medien* → *Neu hinzufügen*
2. Ziehen Sie Bilder per Drag & Drop ins Fenster
3. Oder klicken Sie auf "Dateien auswählen"

== Bildgrößen

WordPress erstellt automatisch verschiedene Größen:

- *Thumbnail:* 150 × 150 px
- *Mittel:* 300 × 300 px
- *Groß:* 1024 × 1024 px
- *Vollständig:* Originalgröße

#block(
  fill: rgb("#fff3cd"),
  inset: 10pt,
  radius: 4pt,
  [*Wichtig:* Laden Sie Bilder nicht größer als 2000px hoch. Große Bilder verlangsamen die Website.]
)

= WooCommerce Shop

== Produkte verwalten

=== Neues Produkt anlegen

1. Gehen Sie zu *Produkte* → *Neu hinzufügen*
2. Geben Sie den Produktnamen ein
3. Fügen Sie eine Beschreibung hinzu
4. Setzen Sie den *Preis* im rechten Bereich
5. Laden Sie ein *Produktbild* hoch
6. Wählen Sie eine *Kategorie*
7. Klicken Sie auf *"Veröffentlichen"*

=== Produkt bearbeiten

1. Gehen Sie zu *Produkte* → *Alle Produkte*
2. Klicken Sie auf das Produkt
3. Ändern Sie Preis, Beschreibung oder Bild
4. Klicken Sie auf *"Aktualisieren"*

== Bestellungen

=== Bestellübersicht

Unter *WooCommerce* → *Bestellungen* sehen Sie alle eingegangenen Bestellungen.

*Status-Farben:*
- 🟡 *Wartend:* Zahlung ausstehend
- 🔵 *In Bearbeitung:* Zahlung eingegangen, Versand vorbereiten
- 🟢 *Fertiggestellt:* Versandt und abgeschlossen
- 🔴 *Storniert:* Bestellung abgebrochen

=== Bestellung bearbeiten

1. Klicken Sie auf die Bestellnummer
2. Ändern Sie den Status nach Versand auf "Fertiggestellt"
3. Der Kunde erhält automatisch eine E-Mail

= Referenzprojekte aktualisieren

Ihre Referenzseite zeigt abgeschlossene Projekte. So fügen Sie neue hinzu:

1. Gehen Sie zu *Seiten* → *Referenzen*
2. Klicken Sie auf "Bearbeiten"
3. Scrollen Sie ans Ende der Projektliste
4. Fügen Sie einen neuen *Galerie-Block* hinzu
5. Laden Sie Projektbilder hoch
6. Fügen Sie einen *Absatz-Block* mit der Beschreibung hinzu
7. Klicken Sie auf *"Aktualisieren"*

= Häufige Fragen

== Kann ich etwas kaputt machen?

Nein. WordPress speichert Revisionen. Sie können jederzeit eine frühere Version wiederherstellen.

== Wie ändere ich das Menü?

Gehen Sie zu *Design* → *Menüs*. Hier können Sie Seiten hinzufügen oder entfernen.

== Ich habe mein Passwort vergessen

Klicken Sie auf der Login-Seite auf "Passwort vergessen" und geben Sie Ihre E-Mail ein.

= Support

Bei Fragen oder Problemen erreichen Sie uns:

- *E-Mail:* support\@pixelwerk.de
- *Telefon:* +49 221 98765432
- *Support-Zeiten:* Mo-Fr 9-17 Uhr

#block(
  fill: luma(240),
  inset: 10pt,
  radius: 4pt,
  [Im ersten Monat nach Go-Live ist Support inklusive. Danach bieten wir Wartungsverträge ab 79 EUR/Monat an.]
)
