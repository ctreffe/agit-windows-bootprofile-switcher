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
> BootProfile Switcher hat den Architektur-Meilenstein (`v0.2.0`), den Boot Profile Detection Proof of Concept (`v0.3.0`), den Boot-Profile-Detection-Meilenstein (`v0.4.0`), den Profile-Engine-Meilenstein (`v0.5.0`), den Module-System-Meilenstein (`v0.6.0`), den Configuration-Meilenstein (`v0.7.0`), den Integration-Meilenstein (`v0.8.0`), den Validation-Meilenstein (`v0.9.0`), den Initial-Stable-Release-Meilenstein (`v1.0.0`), den Network-Isolation-Meilenstein (`v1.1.0`) und den Meilenstein Configuration Format v2 (`v1.2.0`) abgeschlossen.
>
> Der Meilenstein `v1.2.0 – Configuration Format v2` ist abgeschlossen. Dieser Release ergänzt die validierte v2-Konfigurationsstruktur, profil-lokale Moduleinstellungen, begrenzte Default-Entry-Einstellungen, Validator-Abdeckung, Dokumentation und eine ADR zur Formatentscheidung.

## Überblick

BootProfile Switcher ist eine konfigurierbare Windows-Bootprofil-Engine, die modulare Systemprofile vor der Benutzeranmeldung anwendet.

Das Projekt soll Windows-Systeme unterstützen, die mehrere Betriebsprofile mit einer einzigen Windows-Installation benötigen. Ein Benutzer wählt beim Systemstart ein Bootprofil aus. BootProfile Switcher wendet anschließend die zugehörige Systemkonfiguration an, bevor die interaktive Anmeldung beginnt.

Der erste Anwendungsfall ist ein Windows-Rechner, der entweder im Normalbetrieb oder in einem Experimentalprofil mit eingeschränkter beziehungsweise deaktivierter Netzwerkkonnektivität starten kann. Die Architektur ist bewusst generisch angelegt, damit später weitere Profile und Komponenten ergänzt werden können.

## Schnellstart: Foundation-Demo

Für das v1.0.0-Foundation-Demo-Setup kann der kombinierte Wrapper aus dem
Repository-Stammverzeichnis verwendet werden:

```text
install-demo.cmd
```

Er fordert bei Bedarf Administratorrechte an und führt die
Foundation-Demo-Installationsreihenfolge aus:

1. verwaltete Bootmenü-Einträge installieren
2. validierte Profilkonfiguration installieren
3. Startup-Hook installieren

Das Demo-Setup kann wieder entfernt werden mit:

```text
uninstall-demo.cmd
```

Der Demo-Uninstall entfernt den Startup-Hook, die verwalteten Bootmenü-Einträge
und den temporären Demo-Marker, falls er vorhanden ist. Die
ProgramData-Profilkonfiguration bleibt unverändert, damit eine angepasste
Konfiguration nicht unerwartet gelöscht wird.

## Schnellstart: Network-Isolation-Demo

Das Network-Isolation-Modul hat eine eigene Dokumentation:

- [Dokumentation zum Network-Isolation-Modul](docs/modules/network-isolation.de.md)

Es hat außerdem ein eigenes Demo-Setup:

```text
install-network-isolation-demo.cmd
```

Dieses Setup installiert einen verwalteten Bootmenü-Eintrag mit dem Namen
`Network Isolation`, installiert eine passende maschinenweite
Profilkonfiguration und installiert den Startup-Hook. Im Bootmenü kann dann
zwischen normalem Windows-Start und dem Network-Isolation-Profil gewählt
werden.

Das Demo-Profil deaktiviert Ethernet-, WLAN-, Cellular- und Bluetooth-PAN-
Netzwerkadapter und demonstriert den vollständigen Lifecycle:

1. normaler Start lernt die aktuelle Adapter-Baseline
2. `Network Isolation`-Start deaktiviert die konfigurierten Netzwerkpfade
3. normaler Start stellt die gelernte Baseline wieder her

Die Network-Isolation-Demo kann entfernt werden mit:

```text
uninstall-network-isolation-demo.cmd
```

Der Uninstall-Wrapper entfernt den Startup-Hook und den verwalteten
Demo-Boot-Eintrag. Wenn bei der Installation eine vorherige
ProgramData-Profilkonfiguration gesichert wurde, wird sie wiederhergestellt.

Jedes produktive Modul sollte, soweit praktikabel, eine kleine installierbare
Demo bereitstellen. Die Demo sollte das beabsichtigte Modulverhalten zeigen,
ohne manuelle Konfigurationsänderungen vorauszusetzen.

## Einzelne Setup-Schritte

Für das ursprüngliche Zwei-Profil-Validierungssetup ist der einfachste Weg zum Installieren oder Entfernen der verwalteten Bootmenü-Einträge die Verwendung der Command-Wrapper im Repository-Stammverzeichnis:

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

`validation-log` schreibt Validierungseinträge nach:

```text
logs/module-actions.log
```

`network-isolation` ist das erste produktionsorientierte Lifecycle-Modul. Es
kann konfigurierte Hardware-Netzwerkadapter-Kategorien für isolierende
Bootprofile deaktivieren und nach einer Isolation die zuletzt gelernte normale
Adapter-Baseline wiederherstellen. Einrichtung, Warnungen, Konfigurationsdetails
und Moduldemo sind in der
[Dokumentation zum Network-Isolation-Modul](docs/modules/network-isolation.de.md)
beschrieben.

`demo-system-marker` ist ein temporäres Foundation-Demonstrationsmodul. Es
schreibt das aufgelöste Profil in einen harmlosen maschinenweiten Marker:

```text
C:\ProgramData\BootProfileSwitcher\runtime\demo-current-profile.json
```

Der Demo-Marker zeigt, dass profilspezifische Module eine harmlose Änderung auf
Systemebene anwenden können, ohne das Windows-Verhalten zu verändern. Er bleibt
für die Foundation-Demo verfügbar und kann in einem späteren Cleanup entfernt
werden, wenn die produktiven Moduldemos ihn vollständig ersetzen. Die
Marker-Datei kann gefahrlos gelöscht werden.

Der Hook kann wieder entfernt werden mit:

```text
uninstall-startup-hook.cmd
```

## Aktuelle Befehls- und Konfigurationsreferenz

Aktuelle Command-Wrapper:

- `install-demo.cmd` installiert das v1.0.0-Foundation-Demo-Setup in der erwarteten Reihenfolge und fordert bei Bedarf erhöhte Rechte an.
- `uninstall-demo.cmd` entfernt Startup-Hook, verwaltete Bootmenü-Einträge und temporären Demo-Marker, lässt die ProgramData-Konfiguration aber unverändert.
- `install-network-isolation-demo.cmd` installiert die Network-Isolation-Moduldemo mit einem verwalteten Bootprofil `Network Isolation`.
- `uninstall-network-isolation-demo.cmd` entfernt die Network-Isolation-Moduldemo und stellt die vorherige ProgramData-Profilkonfiguration wieder her, wenn ein Backup vorhanden ist.
- `install.cmd` installiert die verwalteten BootProfile-Switcher-Bootmenü-Einträge und fordert bei Bedarf erhöhte Rechte an.
- `install-configuration.cmd` installiert eine validierte Profilkonfiguration an den standardmäßigen maschinenweiten Konfigurationspfad und fordert bei Bedarf erhöhte Rechte an.
- `uninstall.cmd` entfernt die verwalteten Bootmenü-Einträge und fordert bei Bedarf erhöhte Rechte an.
- `install-startup-hook.cmd` installiert die Startup Scheduled Task.
- `uninstall-startup-hook.cmd` entfernt die Startup Scheduled Task.
- `detect-current-profile.cmd` startet den Helper zur Erkennung des aktuellen Profils.

Aktuelle PowerShell-Einstiegspunkte:

- `scripts/Get-BootProfileMenuStatus.ps1` zeigt den verwalteten Bootmenü-Status und erkannte BootProfile-Switcher-BCD-Einträge an.
- `scripts/Resolve-BootProfile.ps1` löst das gewählte Bootprofil auf und schreibt strukturierten Resolver-State.
- `scripts/Invoke-ProfileEngine.ps1` konsumiert Resolver-State, validiert Konfiguration und ruft nur die Module auf, die im passenden konfigurierten Profil ausgewählt sind.
- `scripts/Install-NetworkIsolationDemo.ps1` installiert Boot-Eintrag, Konfiguration und Startup-Hook für die Network-Isolation-Moduldemo.
- `scripts/Uninstall-NetworkIsolationDemo.ps1` entfernt die Network-Isolation-Moduldemo und stellt bei Bedarf das vorherige Profilkonfigurations-Backup wieder her.
- `scripts/Install-BootProfileConfiguration.ps1` validiert und installiert eine Profilkonfigurationsdatei an den standardmäßigen maschinenweiten Konfigurationspfad.
- `scripts/Test-BootProfileConfiguration.ps1` validiert eine Profil-Konfigurationsdatei, ohne Änderungen anzuwenden.
- `scripts/Test-BootProfileConfigurationFixtures.ps1` validiert die enthaltenen bekannten gültigen und ungültigen Konfigurations-Fixtures.

Der standardmäßige maschinenweite Konfigurationspfad ist:

```text
%ProgramData%\BootProfileSwitcher\config\profiles.json
```

Das Repository enthält das aktuelle Beispiel-Konfigurationsformat in:

```text
config/profiles.example.json
```

Das validierte Beispiel für Konfigurationsformat v2 liegt hier:

```text
config/profiles.v2.example.json
```

Die Demo-Konfiguration des Network-Isolation-Moduls liegt in:

```text
config/demos/network-isolation.json
```

Konfiguration steuert jetzt den Modul-Dispatch. Wenn die standardmäßige `profiles.json` fehlt, ungültig ist oder den aufgelösten Modus nicht enthält, führt das Bootprofil keine Aktion aus. Die Engine meldet den Grund in ihrer strukturierten Ausgabe, und der Startup Hook protokolliert Konfigurationsstatus, Validierungsfehler und Dispatch-Skip-Grund in `logs/startup-profile.log`. Eigene Skriptpfade werden strukturell vom Konfigurationsformat akzeptiert, aber noch nicht ausgeführt.

Konfigurationsformat v2 ist in
[docs/configuration-format-v2.de.md](docs/configuration-format-v2.de.md)
dokumentiert. Der aktuelle Runtime-Pfad nutzt weiterhin die installierte
Konfiguration und den bestehenden Startup-Ablauf; v2 ist bereit, im nächsten
Meilenstein als Quelle für die konfigurationsgetriebene Bootmenü-Erzeugung zu
dienen.

Network Isolation ist ausführlich in
[docs/modules/network-isolation.de.md](docs/modules/network-isolation.de.md)
dokumentiert.

Bekannte Module im aktuellen Release:

- `validation-log`
- `network-isolation`
- `demo-system-marker` temporäres Foundation-Demomodul

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
1.1.0 Network Isolation
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
- [docs/configuration-format-v2.md](docs/configuration-format-v2.md) – englische Dokumentation zu Konfigurationsformat v2
- [docs/configuration-format-v2.de.md](docs/configuration-format-v2.de.md) – deutsche Dokumentation zu Konfigurationsformat v2
- [docs/modules/network-isolation.md](docs/modules/network-isolation.md) – englische Dokumentation des Network-Isolation-Moduls
- [docs/modules/network-isolation.de.md](docs/modules/network-isolation.de.md) – deutsche Dokumentation des Network-Isolation-Moduls
- [docs/poc/a1-boot-menu.md](docs/poc/a1-boot-menu.md) – A1 Boot Menu Proof of Concept
- [docs/poc/a2-current-boot-profile.md](docs/poc/a2-current-boot-profile.md) – A2-Erkennung des aktuellen Bootprofils
- [docs/poc/a3-startup-hook.md](docs/poc/a3-startup-hook.md) – A3 Startup-Hook Proof of Concept
- [docs/poc/a4-profile-startup-scripts.md](docs/poc/a4-profile-startup-scripts.md) – A4-Ausführung profilspezifischer Startup-Skripte
- [docs/poc/a5-findings.md](docs/poc/a5-findings.md) – A5 Proof-of-Concept-Ergebnisse
- [docs/release/v1.0.0-release-scope.md](docs/release/v1.0.0-release-scope.md) – Umfang des initialen stabilen Releases
- [docs/decisions/ADR-0001-overall-architecture.md](docs/decisions/ADR-0001-overall-architecture.md) – erste Architekturentscheidung
- [docs/decisions/ADR-0002-boot-profile-detection.md](docs/decisions/ADR-0002-boot-profile-detection.md) – Strategie zur Bootprofil-Erkennung
- [docs/decisions/ADR-0003-boot-profile-resolver-boundary.md](docs/decisions/ADR-0003-boot-profile-resolver-boundary.md) – Grenze des Bootprofil-Resolvers
- [docs/decisions/ADR-0004-network-isolation-lifecycle-module.md](docs/decisions/ADR-0004-network-isolation-lifecycle-module.md) – Architekturentscheidung zum Network-Isolation-Lifecycle-Modul
- [LICENSE](LICENSE) – MIT-Lizenz

### Resolver des aktuellen Profils

Nach der Installation des Bootmenüs und einem Start über ein verwaltetes Profil wie Mode A, Mode B oder Network Isolation:

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
