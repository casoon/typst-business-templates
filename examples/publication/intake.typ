#import "@local/business-templates:0.1.0": publication, writing-field, choice-group, priority-tag, process-phase
#show: publication.with(title: "Projektbriefing und Erfassungsbogen", document-type: "Erfassung", document-number: "FORM-2026-001", company: (name: "Beispielbüro", language: "de"))

#priority-tag("required")
#writing-field("Welches konkrete Ergebnis soll das Projekt für die Beteiligten erreichen?", lines: 4, hint: "Bitte ein überprüfbares Ziel nennen.")
#choice-group("Welche Unterlagen liegen bereits vor?", options: ([Projektbeschreibung], [Zeitplanung], (label: [Ansprechpartner benannt], checked: true)))
#writing-field("Ansprechpartner und Vertretung", lines: 3)
#pagebreak()
= Gemeinsamer Ablauf
#process-phase("Abstimmung", result: "Freigegebenes Briefing", participation: "Auftraggeber und Projektleitung")[Die Antworten werden gemeinsam besprochen.]
#for i in range(1, 7) {
  writing-field("Ergänzende Beobachtung " + str(i), lines: 3)
}
