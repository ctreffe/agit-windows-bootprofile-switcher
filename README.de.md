# BootProfile Switcher

![Lizenz](https://img.shields.io/github/license/ctreffe/agit-windows-bootprofile-switcher)
![Release](https://img.shields.io/github/v/tag/ctreffe/agit-windows-bootprofile-switcher)
![Letzter Commit](https://img.shields.io/github/last-commit/ctreffe/agit-windows-bootprofile-switcher)

[English documentation](README.md)

> [!NOTE]
> **Projektstatus**
>
> BootProfile Switcher hat den Architektur-Meilenstein (`v0.2.0`) abgeschlossen.
>
> Der aktuelle Entwicklungsschwerpunkt ist `v0.3.0 – Boot Profile Detection Proof of Concept`. A1 hat das Erstellen und Entfernen zweier Windows-Boot-Manager-Einträge, `Mode A` und `Mode B`, validiert.

## Überblick

BootProfile Switcher ist eine konfigurierbare Windows-Bootprofil-Engine, die modulare Systemprofile vor der Benutzeranmeldung anwendet.

Das Projekt soll Windows-Systeme unterstützen, die mehrere Betriebsprofile mit einer einzigen Windows-Installation benötigen. Ein Benutzer wählt beim Systemstart ein Bootprofil aus. BootProfile Switcher wendet anschließend die zugehörige Systemkonfiguration an, bevor die interaktive Anmeldung beginnt.

Der erste Anwendungsfall ist ein Windows-Rechner, der entweder im Normalbetrieb oder in einem Experimentalprofil mit eingeschränkter beziehungsweise deaktivierter Netzwerkkonnektivität starten kann. Die Architektur ist bewusst generisch angelegt, damit später weitere Profile und Komponenten ergänzt werden können.

## Projektziele

BootProfile Switcher soll Folgendes ermöglichen:

- Profilauswahl während des Systemstarts
- eine gemeinsame Windows-Installation
- Systemkonfiguration vor der Benutzeranmeldung
- modulare Profilverwaltung
- skriptfähige Installation und Entfernung
- Kompatibilität mit Gruppenrichtlinien-basierten Deployment-Umgebungen
- nachvollziehbares Logging und Diagnosefähigkeit
- reversible Infrastrukturänderungen

## Nicht-Ziele

BootProfile Switcher soll ausdrücklich nicht Folgendes bereitstellen:

- mehrere Windows-Installationen
- eine Desktop-Anwendung für Endbenutzer
- einen Ersatz für Windows-Deployment-Werkzeuge
- versteckte oder undokumentierte Systemänderungen
- irreversible Konfigurationsänderungen

## Engineering-Ansatz

Dieses Projekt folgt dem AGIT Collaboration Model in [ChatGPT.md](ChatGPT.md).

Das Projekt wird nach folgenden Prinzipien entwickelt:

- Architektur vor Implementierung
- von Windows unterstützte Mechanismen vor eigenen Umgehungslösungen
- Konfiguration statt Hardcoding
- modularer Aufbau
- Wartbarkeit vor kurzfristiger Bequemlichkeit
- Semantic Versioning
- aussagekräftige Changelog-Einträge
- repository-ready Änderungssätze

## Versionierung

BootProfile Switcher verwendet Semantic Versioning.

Der zuletzt abgeschlossene Projektmeilenstein ist:

```text
0.2.0 Architecture
```

Versionstags sollen ein führendes `v` verwenden, zum Beispiel:

```text
v0.2.0
```

Versionstags und GitHub Releases werden bewusst erstellt. Nicht jeder Versionstag benötigt einen GitHub Release.

## Dokumentation

Zentrale Projektdokumente:

- [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) – aktueller Projektstand und nächster Entwicklungsschwerpunkt
- [README.md](README.md) – primäre englische Projektdokumentation
- [README.de.md](README.de.md) – deutsche Projektdokumentation
- [CHANGELOG.md](CHANGELOG.md) – Versionshistorie
- [ChatGPT.md](ChatGPT.md) – AGIT Collaboration Model
- [PHILOSOPHY.md](PHILOSOPHY.md) – Projektphilosophie
- [docs/architecture.md](docs/architecture.md) – konzeptionelle Systemarchitektur
- [docs/poc/a1-boot-menu.md](docs/poc/a1-boot-menu.md) – A1 Boot Menu Proof of Concept
- [docs/decisions/ADR-0001-overall-architecture.md](docs/decisions/ADR-0001-overall-architecture.md) – erste Architekturentscheidung
- [LICENSE](LICENSE) – MIT-Lizenz

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz.
