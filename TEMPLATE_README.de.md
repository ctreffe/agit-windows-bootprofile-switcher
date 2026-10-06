# BootProfile Switcher: Template-Anleitung

> [!NOTE]
> **KI-Zusammenarbeit**
> Diese Anleitung beschreibt angepasste geerbte Workflows und Konventionen.
> Die Projektregeln und Entscheidungen bleiben maßgeblich; das Modell der
> Zusammenarbeit steht in [COLLABORATION.md](COLLABORATION.md).

[English guide](TEMPLATE_README.md) · [Projektübersicht](README.de.md)

## Herkunft und Geltung

Aus AI Dev Template, geprüft gegen Commit `6a2cc69831c99dd68d00fba9063bd404ab0b9df7`. Die Einführung
der Anleitung wurde für dieses bestehende Projekt separat ausgewählt.
[PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) und [TEMPLATE_SYNC.md](TEMPLATE_SYNC.md)
halten die verifizierte Herkunft, Auswahl und Abweichungen fest.
Diese Anleitung ist keine zweite Regelquelle: AGENTS.md, lokale Fachregeln
und akzeptierte Decision Records bestimmen das tatsächliche Vorgehen.
Initialisierung ist abgeschlossen; entfernte Erstellungs-Skills, Template-
Backlogs und Initialisierungsanweisungen werden nicht wieder eingeführt.

## Kernprinzip

Der Maintainer verantwortet Projektrichtung, Architektur und Release-Entscheidungen. Der Assistant kann beim Entwerfen, Implementieren, Testen, Dokumentieren und Prüfen helfen, muss aber die Autorität des Maintainers wahren, Annahmen und Einschränkungen sichtbar machen und darf abgeschlossenen Code, Validierungen, Commits oder Dateien niemals simulieren.

Das Repository ist der maßgebliche Engineering-Zustand. Code und Dokumentation sollen für künftige Maintainer ohne private Chatverläufe verständlich sein, und eine Änderung ist nicht abgeschlossen, nur weil sie einmal funktioniert hat.

## Skills für die Zusammenarbeit

Skills sind abgegrenzte Arbeitsabläufe in `.agents/skills/`.
Sie führen den Agenten durch eine bestimmte Aufgabe und laden dafür die
passenden Repository-Leitlinien. Rufe einen Skill im Chat mit `$skill-name`
auf, zum Beispiel `$review-project`. Die verlinkten Skill-Dateien beschreiben
den vollständigen Ablauf.

- **Agent oder explizit:** Der Agent darf den Skill bei einer passenden
  Aufgabe selbst auswählen; du kannst ihn auch direkt aufrufen.
- **Explizit:** Der Skill braucht einen bewussten Aufruf oder eine
  ausdrückliche Auswahl durch den Maintainer. Ein Vorschlag des Agenten
  aktiviert ihn noch nicht.

Die Auswahl eines Skills erteilt keine zusätzliche Freigabe für geschützte
Git-Aktionen, Installation, externe Übertragung oder Veröffentlichung. Die
lokalen Zugriffs- und Fachregeln gelten für jeden Ablauf.



`reuse-fixes` liest und ergänzt ausschließlich das Fehlerwissen dieses
Repositorys. Der Skill sammelt keine Erfahrungen über Repositories hinweg
und führt kein globales Fehlergedächtnis.
Aktive Lösungen stehen mit 4–8 Zeilen pro Fall in `TROUBLESHOOTING.md`.
## Externe Dateien und Quellen

Lege neu erhaltene Dateien zunächst in `input/intake/` ab, bevor über ihre Verwendung entschieden wird. Dokumentiere sichere Metadaten, Provenienz und Klassifizierung in `input/CATALOG.md`; verwende die ignorierte Datei `input/CATALOG.local.md`, wenn Dateinamen, Pfade oder andere Angaben selbst sensibel sind.

Katalogisiere unveränderte externe Dienste, Datensätze und URLs auch dann, wenn
ihre Inhalte außerhalb des Repositorys bleiben. Nutze stabile öffentliche URLs
direkt und löse logische private oder gerätespezifische Orte über die ignorierte
`input/PATHS.local.md` auf.

- **`input/intake/`** ist der ignorierte Eingangsbereich für noch nicht klassifizierte Dateien. Ihre bloße Anwesenheit erlaubt keinen Zugriff durch den Assistant.
- **`input/restricted/`** ist ignoriert und für Dateien bestimmt, die nur der Maintainer oder ausdrücklich freigegebene lokale Prüfungen lesen dürfen.
- **`input/local/`** ist ignoriert und enthält Dateien, die der Assistant lokal verarbeiten darf, die aber nicht in Git gelangen dürfen.
- **`input/versioned/`** enthält geprüfte externe Dateien, die versioniert werden dürfen. Verschiebe sie in einen projektspezifischen Quellen-, Fixture- oder Konfigurationsordner, wenn dieser ihre dauerhafte Rolle klarer ausdrückt, und bewahre die Provenienz im Katalog.

Assistant-Zugriff, Git-Versionierung und externe Weitergabe sind drei getrennte Entscheidungen. Eine Verschiebung dokumentiert die Klassifizierung, erweitert aber keine Berechtigung. Technisch festgelegte Laufzeitorte wie `.env`, Anwendungs-Logverzeichnisse oder lokale Datenbanken dürfen dort bleiben, wo die Software sie benötigt; ihre Klassifizierung und Ignore-Regeln sollten dennoch dokumentiert werden.

Für große, nicht in Git versionierte Dateien, die auf mehreren Rechnern
verfügbar bleiben müssen, gilt der anbieterneutrale Workflow in
`SYNCHRONIZED_STORAGE.md`. Synchronisierte Dateien
bleiben externer Speicher; Synchronisierung ist weder Git-Versionierung,
Backup, Assistant-Zugriff noch Publikationsfreigabe.

## Temporäre Arbeitsdateien

Verwende `temp/` für wegwerfbare Engineering-Zwischendateien. Alle Inhalte
außerhalb von `temp/restricted/` sind für den Assistant lesbar; dieses
Restricted-Verzeichnis darf weder aufgelistet noch gelesen werden. Sämtliche temporären Inhalte werden
ignoriert, dürfen niemals versioniert werden und werden nicht katalogisiert.
Überführe dauerhafte Dateien bewusst nach `materials/` oder an einen
maßgeblichen Engineering-Ort.

## Projektmaterialien

Dateien in `input/` bleiben inhaltlich unverändert. Ein konvertierter Export,
eine bereinigte Reproduktionsdatei, ein zugeschnittener Screenshot, ein
Diagnoseauszug oder jede andere Inhaltsänderung ist neues Projektmaterial und
kein veränderter Input. `materials/` bewahrt solche Arbeitsdateien auf, solange
sie nützlich bleiben, aber noch keine maßgebliche Quelle, Tests, Fixtures oder
Konfiguration sind.

Jedes katalogisierte Material ist für den Assistant lesbar. Dokumentiere
Provenienz und Erstellung oder Transformation in `materials/CATALOG.md` und
verwende `Based on` mit Input- oder Material-IDs. Speichere Dateien als
**`local`** im ignorierten `materials/local/`, als **`versioned`** in
`materials/versioned/` oder als **`external`** an einem stabilen logischen Ort
im Katalog. Löse externe Orte je Rechner über die ignorierte
`materials/PATHS.local.md` auf, ausgehend von der versionierten Beispieldatei.

Zugriff autorisiert weder Git-Versionierung noch Weitergabe. Überführe Material
erst dann in Source, Tests, Fixtures oder Konfiguration, wenn dieser Ort seine
dauerhafte Engineering-Rolle besser ausdrückt, und bewahre die Provenienz.
Build-Outputs, Caches und wegwerfbare Diagnosedateien gehören nicht nach
`materials/`.

Nicht die Erzeugungsweise, sondern die aktuelle Projektrolle bestimmt den
Ablageort. Bewahre eine erzeugte Datei in `materials/` auf, wenn sie als
dauerhafte Arbeits- oder Quelldatei in weitere Engineering-Schritte eingeht.
Lege sie in `output/` oder einem anderen dokumentierten Deliverable-Ort ab,
wenn sie als Projektergebnis zur Nutzung, Prüfung, Übergabe, Veröffentlichung
oder Auslieferung bestimmt ist. Wegwerfbare Erzeugungszwischenstände bleiben in
`temp/`; Source, Tests, Fixtures und Konfiguration behalten ihre maßgeblichen
Orte.

## Empfohlener Workflow

Entwicklung erfolgt in kleinen, validierten Schleifen:

```text
Intention -> Roadmap -> Implementieren -> Validieren -> Anpassen -> Dokumentieren -> Commit vorbereiten -> Fortsetzen
```

1. Ermittle die aktuelle Repository- und Working-Tree-Baseline.
2. Bestätige den aktiven Roadmap-Schritt und was er nachweisen oder liefern soll.
3. Implementiere eine logische, prüfbare Änderung.
4. Führe relevante Tests, Skripte, Linter, Renderer oder Maintainer-lokale Validierungen aus.
5. Behebe gefundene Probleme, bevor der Schritt als bereit dargestellt wird.
6. Aktualisiere Code-Kommentare, technische Dokumentation und benutzerorientierte Leitlinien, die vom Verhalten betroffen sind.
7. Dokumentiere folgenreiche Architektur-, Projekt- oder Dokumentationsentscheidungen.
8. Bereite einen regulären Arbeits-Commit mit passendem Conventional-Commit-Präfix vor.
9. Schließe einen erfüllten Milestone separat ab, indem Version, Changelog, Projektkontext und validierter Status harmonisiert werden.

Reguläre neue Aufgaben verwenden `start-task`. Rufe `$review-project` für eine
umfassende neutrale Bestandsaufnahme, `$sync-template` für die Übernahme aus
dem Quelltemplate, `$check-consistency` für interne Diagnose und
`$perform-retrospective` für eine separate Bewertung der Zusammenarbeit auf.

## Decision Records

Wähle den Record-Typ nach dem Entscheidungsgegenstand:

- **ADR — Architecture Decision Record:** Architektur, Schnittstellen, Konfigurationsformate, Lebenszyklusverhalten, Deployment, Sicherheitsgrenzen, Behandlung sensibler Inputs, Fixture-Versionierung oder Richtlinien für erzeugte Outputs.
- **PDR — Project Decision Record:** Umfang, Roadmap, Zusammenarbeit, Datenschutz, Repository-Struktur, Release-Modell oder Governance.
- **DDR — Documentation Decision Record:** Benutzerdokumentation, Referenzstruktur, Terminologie, Beispiele, Screenshots oder Dokumentations-QA.

Vorlagen befinden sich in [docs/decisions/](docs/decisions/). Erstelle einen Record, wenn künftige Maintainer Kontext, Begründung und Konsequenzen benötigen; routinemäßige Implementierungsdetails gehören stattdessen in Code, Tests oder gewöhnliche Dokumentation.

## Kontinuierliche Verbesserung

Entwicklungsprojekte sollten bewährte Praktiken bewahren und unnötige Komplexität entfernen. Validierte negative Ergebnisse, wiederkehrende Validierungsprobleme und Wartbarkeitserkenntnisse sind legitimes Projektwissen.

Nutze `$sync-template`, um ein Projekt mit seiner verifizierten Source-Template-Baseline zu vergleichen und ausgewählte Entwicklungen zu übernehmen. Verwende `$check-consistency` getrennt für Widersprüche zwischen Implementierung, Tests, Dokumentation und Roadmap und `$perform-retrospective` für Zusammenarbeit, Engineering-Übergaben, Validierungsstrategie und Arbeitsrhythmus. Ein Befund wird erst dann zum Template-Kandidaten, wenn seine Übertragbarkeit, Wartungskosten und Auswirkungen auf unterschiedliche Entwicklungsprojekte geprüft wurden.

Der Maintainer koordiniert die templateübergreifende Weiterentwicklung in einem privaten Governance-Repository namens `ai-templateverse`. Es dokumentiert gemeinsame Konventionen, bewusste Spezialisierungen und Evidenz aus abgeleiteten Projekten. Das Repository wird bewusst nicht verlinkt, da Template-Nutzer:innen keinen Zugriff darauf benötigen.

Die Governance-Koordination erzeugt keine verborgenen Engineering-Anforderungen. Jede Änderung, die dieses Template betrifft, muss hier durch gepflegte Leitlinien, gegebenenfalls Decision Records, den Changelog und die Release-Historie abgebildet werden. Wiederverwendbare Verbesserungen müssen Code, Tests, Konfiguration und nutzerorientierte Dokumentation aufeinander abgestimmt halten und dürfen nicht eine einzelne Implementierungserfahrung überpassen.


## Git-Befugnisse

Git-Zustände dürfen lesend geprüft werden. Staging erfordert eine konkrete
Anweisung. Jede geschützte Git-Aktion, einschließlich Commit und Push, benötigt
eine eigene explizite, repositorybezogene Freigabe. Die Template-Regel, dass
eine Commit-Freigabe zugleich einen Push umfasst, wurde hier nicht übernommen.
Eine Skill-Ausführung oder lokale Pfadzuordnung erteilt keine weitere Befugnis.

## Vorhandene Workflows und Projektdateien

| Skill | Aufruf |
| --- | --- |
| [check-consistency](.agents/skills/check-consistency/SKILL.md) | Explizit |
| [grill-me](.agents/skills/grill-me/SKILL.md) | Explizit |
| [grilling](.agents/skills/grilling/SKILL.md) | Explizit |
| [handoff-task](.agents/skills/handoff-task/SKILL.md) | Agent oder explizit |
| [perform-retrospective](.agents/skills/perform-retrospective/SKILL.md) | Explizit |
| [record-decision](.agents/skills/record-decision/SKILL.md) | Agent oder explizit |
| [reuse-fixes](.agents/skills/reuse-fixes/SKILL.md) | Agent oder explizit |
| [review-project](.agents/skills/review-project/SKILL.md) | Explizit |
| [start-task](.agents/skills/start-task/SKILL.md) | Agent oder explizit |
| [sync-template](.agents/skills/sync-template/SKILL.md) | Explizit |

- [AGENTS.md](AGENTS.md)
- [COLLABORATION.md](COLLABORATION.md)
- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)
- [TASK_HANDOFF.md](TASK_HANDOFF.md)
- [TEMPLATE_SOURCE.md](TEMPLATE_SOURCE.md)
- [TEMPLATE_SYNC.md](TEMPLATE_SYNC.md)
- [PHILOSOPHY.md](PHILOSOPHY.md)
- [DOCUMENTATION.md](DOCUMENTATION.md)
- [REPOSITORY.md](REPOSITORY.md)
- [VALIDATION.md](VALIDATION.md)
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## Lizenz und Zuschreibung

Die Anleitung beruht auf dem MIT-lizenzierten AI Dev Template.
Die Projektlizenz steht in [LICENSE](LICENSE); vorhandene Zuschreibungen und
Lizenzen der übernommenen Skills bleiben erhalten. Die Synchronisation ändert
keine Lizenz und erteilt keine Veröffentlichungsfreigabe.
