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
> BootProfile Switcher hat den Architektur-Meilenstein (`v0.2.0`), den Boot Profile Detection Proof of Concept (`v0.3.0`), den Boot-Profile-Detection-Meilenstein (`v0.4.0`), den Profile-Engine-Meilenstein (`v0.5.0`), den Module-System-Meilenstein (`v0.6.0`), den Configuration-Meilenstein (`v0.7.0`), den Integration-Meilenstein (`v0.8.0`) und den Validation-Meilenstein (`v0.9.0`) abgeschlossen.
>
> Der Meilenstein `v0.9.0 – Validation` ist abgeschlossen. Der konfigurationsgetriebene Runtime-Pfad wurde für Mode A, Mode B, fehlende oder ungültige Konfiguration, normalen Windows-Start und Reinstall-Sicherheit validiert.

## Überblick

BootProfile Switcher ist eine konfigurierbare Windows-Bootprofil-Engine, die modulare Systemprofile vor der Benutzeranmeldung anwendet.

Das Projekt soll Windows-Systeme unterstützen, die mehrere Betriebsprofile mit einer einzigen Windows-Installation benötigen. Ein Benutzer wählt beim Systemstart ein Bootprofil aus. BootProfile Switcher wendet anschließend die zugehörige Systemkonfiguration an, bevor die interaktive Anmeldung beginnt.

Der erste Anwendungsfall ist ein Windows-Rechner, der entweder im Normalbetrieb oder in einem Experimentalprofil mit eingeschränkter beziehungsweise deaktivierter Netzwerkkonnektivität starten kann. Die Architektur ist bewusst generisch angelegt, damit später weitere Profile und Komponenten ergänzt werden können.

## Schnellstart: Bootmenü und Startup-Hook

Für den aktuellen Validierungsstand ist der einfachste Weg zum Installieren oder Entfernen der verwalteten Bootmenü-Einträge die Verwendung der Command-Wrapper im Repository-Stammverzeichnis:

```text
install.cmd
uninstall.cmd
```

Beide Wrapper können per Doppelklick im Windows Explorer gestartet werden. Sie fordern bei Bedarf Administratorrechte über UAC an und rufen anschließend die zugrunde liegenden PowerShell-Skripte mit einer nur für diesen Prozess geltenden Execution-Policy-Umgehung auf.

Die Wrapper verwalten aktuell die BootProfile-Switcher-Bootmenü-Einträge:

- `BootProfile Switcher - Mode A`
- `BootProfile Switcher - Mode B`

Die eigentliche Implementierung bleibt in `scripts/` sichtbar, damit sie weiterhin explizit geprüft und manuell getestet werden kann.

## Schnellstart: Konfiguration und Startup-Hook

Bevor der Startup-Hook konfigurierte Profilaktionen dispatchen kann, muss die
Beispiel-Profilkonfiguration an den maschinenweiten Standardpfad installiert
werden:

```text
install-configuration.cmd
```

Nach der Installation des Bootmenüs kann der Startup-Hook aus dem
Repository-Stammverzeichnis installiert werden:

```text
install-startup-hook.cmd
```

Der Startup-Hook registriert eine Windows-Aufgabe, die beim Systemstart läuft,
das gewählte Bootprofil über `scripts/Resolve-BootProfile.ps1` auflöst,
`scripts/Invoke-ProfileEngine.ps1` aufruft, Module aus dem passenden konfigurierten
Profil dispatcht und das Startup-Ergebnis in folgende Datei schreibt:

```text
logs/startup-profile.log
```

Die aktuellen Module sind bewusst klein gehalten. `validation-log` schreibt
Validierungseinträge nach:

```text
logs/module-actions.log
```

`demo-system-marker` ist ein temporäres Demonstrationsmodul für v1.0.0. Es
schreibt das aufgelöste Profil in einen harmlosen maschinenweiten Marker:

```text
C:\ProgramData\BootProfileSwitcher\runtime\demo-current-profile.json
```

Der Demo-Marker zeigt, dass profilspezifische Module eine echte Änderung auf
Systemebene anwenden können, ohne das Windows-Verhalten zu verändern. Er soll
nach v1.0.0 wieder entfernt werden, sobald produktive Module existieren; die
Marker-Datei kann gefahrlos gelöscht werden.

Der Hook kann wieder entfernt werden mit:

```text
uninstall-startup-hook.cmd
```

## Aktuelle Befehls- und Konfigurationsreferenz

Aktuelle Command-Wrapper:

- `install.cmd` installiert die verwalteten BootProfile-Switcher-Bootmenü-Einträge und fordert bei Bedarf erhöhte Rechte an.
- `install-configuration.cmd` installiert eine validierte Profilkonfiguration an den standardmäßigen maschinenweiten Konfigurationspfad und fordert bei Bedarf erhöhte Rechte an.
- `uninstall.cmd` entfernt die verwalteten Bootmenü-Einträge und fordert bei Bedarf erhöhte Rechte an.
- `install-startup-hook.cmd` installiert die Startup Scheduled Task.
- `uninstall-startup-hook.cmd` entfernt die Startup Scheduled Task.
- `detect-current-profile.cmd` startet den Helper zur Erkennung des aktuellen Profils.

Aktuelle PowerShell-Einstiegspunkte:

- `scripts/Get-BootProfileMenuStatus.ps1` zeigt den verwalteten Bootmenü-Status und erkannte BootProfile-Switcher-BCD-Einträge an.
- `scripts/Resolve-BootProfile.ps1` löst das gewählte Bootprofil auf und schreibt strukturierten Resolver-State.
- `scripts/Invoke-ProfileEngine.ps1` konsumiert Resolver-State, validiert Konfiguration und ruft nur die harmlosen Module auf, die im passenden konfigurierten Profil ausgewählt sind.
- `scripts/Install-BootProfileConfiguration.ps1` validiert und installiert eine Profilkonfigurationsdatei an den standardmäßigen maschinenweiten Konfigurationspfad.
- `scripts/Test-BootProfileConfiguration.ps1` validiert eine Profil-Konfigurationsdatei, ohne Änderungen anzuwenden.
- `scripts/Test-BootProfileConfigurationFixtures.ps1` validiert die enthaltenen bekannten gültigen und ungültigen Konfigurations-Fixtures.

Der standardmäßige maschinenweite Konfigurationspfad ist:

```text
%ProgramData%\BootProfileSwitcher\config\profiles.json
```

Das Repository enthält das aktuelle Beispiel-Schema in:

```text
config/profiles.example.json
```

Konfiguration steuert jetzt den Modul-Dispatch. Wenn die standardmäßige `profiles.json` fehlt, ungültig ist oder den aufgelösten Modus nicht enthält, führt das Bootprofil keine Aktion aus. Die Engine meldet den Grund in ihrer strukturierten Ausgabe, und der Startup Hook protokolliert Konfigurationsstatus, Validierungsfehler und Dispatch-Skip-Grund in `logs/startup-profile.log`. Eigene Skriptpfade werden strukturell vom Schema akzeptiert, aber noch nicht ausgeführt.

Bekannte Module in der aktuellen Entwicklungsversion:

- `validation-log`
- `demo-system-marker` temporäres v1.0.0-Release-Demomodul

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
- Code- und Anwender:innen-Dokumentation, die ohne private Chat-Historie verständlich ist

## Versionierung

BootProfile Switcher verwendet Semantic Versioning.

Der zuletzt abgeschlossene Projektmeilenstein ist:

```text
0.9.0 Validation
```

## Validierung

Der wiederholbare Validierungsumfang für den aktuellen Runtime-Pfad ist hier dokumentiert:

```text
docs/validation/v0.9-validation-checklist.md
```

Der geplante Umfang des initialen stabilen Releases ist hier dokumentiert:

```text
docs/release/v1.0.0-release-scope.md
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
- [docs/release/v1.0.0-release-scope.md](docs/release/v1.0.0-release-scope.md) – Umfang des initialen stabilen Releases
- [docs/decisions/ADR-0001-overall-architecture.md](docs/decisions/ADR-0001-overall-architecture.md) – erste Architekturentscheidung
- [docs/decisions/ADR-0002-boot-profile-detection.md](docs/decisions/ADR-0002-boot-profile-detection.md) – Strategie zur Bootprofil-Erkennung
- [docs/decisions/ADR-0003-boot-profile-resolver-boundary.md](docs/decisions/ADR-0003-boot-profile-resolver-boundary.md) – Grenze des Bootprofil-Resolvers
- [LICENSE](LICENSE) – MIT-Lizenz

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

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz.
