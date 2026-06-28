# BootProfile Switcher

![Lizenz](https://img.shields.io/github/license/ctreffe/agit-windows-bootprofile-switcher)
![Release](https://img.shields.io/github/v/tag/ctreffe/agit-windows-bootprofile-switcher)
![Letzter Commit](https://img.shields.io/github/last-commit/ctreffe/agit-windows-bootprofile-switcher)

[English documentation](README.md)

> [!NOTE]
> **KI-Zusammenarbeit**
>
> Dieses Projekt wird in Zusammenarbeit zwischen dem Repository-Maintainer und einem KI-Assistenten entwickelt.
>
> Das Collaboration Model dokumentiert Engineering-Praktiken, Kollaborations-Workflows und Repository-Konventionen, die in diesem Projekt verwendet werden.
>
> Es wird in [ChatGPT.md](ChatGPT.md) gepflegt.

> [!NOTE]
> **Projektstatus**
>
> BootProfile Switcher hat den Architektur-Meilenstein (`v0.2.0`), den Boot Profile Detection Proof of Concept (`v0.3.0`) und den Boot-Profile-Detection-Meilenstein (`v0.4.0`) abgeschlossen.
>
> Der Meilenstein `v0.4.0 – Boot Profile Detection` ist abgeschlossen. Das Projekt hat jetzt einen dedizierten Resolver, der das gewählte verwaltete Bootprofil identifiziert, strukturierten JSON-State schreibt, normalen nicht verwalteten Windows-Start ohne Fehler behandelt und vom Startup-Hook verwendet wird.

## Überblick

BootProfile Switcher ist eine konfigurierbare Windows-Bootprofil-Engine, die modulare Systemprofile vor der Benutzeranmeldung anwendet.

Das Projekt soll Windows-Systeme unterstützen, die mehrere Betriebsprofile mit einer einzigen Windows-Installation benötigen. Ein Benutzer wählt beim Systemstart ein Bootprofil aus. BootProfile Switcher wendet anschließend die zugehörige Systemkonfiguration an, bevor die interaktive Anmeldung beginnt.

Der erste Anwendungsfall ist ein Windows-Rechner, der entweder im Normalbetrieb oder in einem Experimentalprofil mit eingeschränkter beziehungsweise deaktivierter Netzwerkkonnektivität starten kann. Die Architektur ist bewusst generisch angelegt, damit später weitere Profile und Komponenten ergänzt werden können.

## Schnellstart: A1 Boot Menu PoC

Für den aktuellen Proof of Concept ist der einfachste Weg zum Installieren oder Entfernen der temporären Bootmenü-Einträge die Verwendung der Command-Wrapper im Repository-Stammverzeichnis:

```text
install.cmd
uninstall.cmd
```

Beide Wrapper können per Doppelklick im Windows Explorer gestartet werden. Sie fordern bei Bedarf Administratorrechte über UAC an und rufen anschließend die zugrunde liegenden PowerShell-Skripte mit einer nur für diesen Prozess geltenden Execution-Policy-Umgehung auf.

Die Wrapper verwalten aktuell nur die A1-Proof-of-Concept-Bootmenü-Einträge:

- `BootProfile Switcher - Mode A`
- `BootProfile Switcher - Mode B`

Die eigentliche Implementierung bleibt in `scripts/` sichtbar, damit sie weiterhin explizit geprüft und manuell getestet werden kann.



## Schnellstart: A3 Startup-Hook-PoC

Nach der Installation des A1-Bootmenüs kann der A3-Startup-Hook aus dem
Repository-Stammverzeichnis installiert werden:

```text
install-startup-hook.cmd
```

Der Startup-Hook registriert eine Windows-Aufgabe, die beim Systemstart läuft,
das gewählte Bootprofil über `scripts/Resolve-BootProfile.ps1` auflöst,
das erkannte Bootprofil in folgende Datei schreibt:

```text
logs/startup-profile.log
```

und ab A4 das passende Profilskript ausführt:

```text
profiles/mode-a/startup.ps1
profiles/mode-b/startup.ps1
```

Die Profilskripte sind absichtlich harmlos und schreiben Validierungseinträge nach:

```text
logs/profile-startup-actions.log
```

Der Hook kann wieder entfernt werden mit:

```text
uninstall-startup-hook.cmd
```

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
0.4.0 Boot Profile Detection
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
- [CODEX.md](CODEX.md) – lokale Codex Operating Policy
- [PHILOSOPHY.md](PHILOSOPHY.md) – Projektphilosophie
- [docs/architecture.md](docs/architecture.md) – konzeptionelle Systemarchitektur
- [docs/poc/a1-boot-menu.md](docs/poc/a1-boot-menu.md) – A1 Boot Menu Proof of Concept
- [docs/poc/a2-current-boot-profile.md](docs/poc/a2-current-boot-profile.md) – A2-Erkennung des aktuellen Bootprofils
- [docs/poc/a3-startup-hook.md](docs/poc/a3-startup-hook.md) – A3 Startup-Hook Proof of Concept
- [docs/poc/a4-profile-startup-scripts.md](docs/poc/a4-profile-startup-scripts.md) – A4-Ausführung profilspezifischer Startup-Skripte
- [docs/poc/a5-findings.md](docs/poc/a5-findings.md) – A5 Proof-of-Concept-Ergebnisse
- [docs/decisions/ADR-0001-overall-architecture.md](docs/decisions/ADR-0001-overall-architecture.md) – erste Architekturentscheidung
- [docs/decisions/ADR-0002-boot-profile-detection.md](docs/decisions/ADR-0002-boot-profile-detection.md) – Strategie zur Bootprofil-Erkennung
- [docs/decisions/ADR-0003-boot-profile-resolver-boundary.md](docs/decisions/ADR-0003-boot-profile-resolver-boundary.md) – Grenze des Bootprofil-Resolvers
- [LICENSE](LICENSE) – MIT-Lizenz

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz.

### Resolver des aktuellen Profils

Nach der Installation des Bootmenüs und einem Start über Mode A oder Mode B:

```cmd
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Resolve-BootProfile.ps1
```

Alternativ in einer erhöhten PowerShell:

```powershell
.\scripts\Resolve-BootProfile.ps1
```

Für maschinenlesbare Ausgabe:

```powershell
.\scripts\Resolve-BootProfile.ps1 -AsJson
```
