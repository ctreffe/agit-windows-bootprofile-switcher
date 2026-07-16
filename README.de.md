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
> Das Collaboration Model dokumentiert Engineering-Praktiken, KI-unterstützte Entwicklungsworkflows und Repository-Konventionen, die in diesem Projekt verwendet werden.
>
> Das in diesem Projekt verwendete Modell ist in [ChatGPT.md](ChatGPT.md) dokumentiert.

> [!NOTE]
> **Projektstatus**
>
> BootProfile Switcher hat den Architektur-Meilenstein (`v0.2.0`), den Boot Profile Detection Proof of Concept (`v0.3.0`), den Boot-Profile-Detection-Meilenstein (`v0.4.0`), den Profile-Engine-Meilenstein (`v0.5.0`), den Module-System-Meilenstein (`v0.6.0`), den Configuration-Meilenstein (`v0.7.0`), den Integration-Meilenstein (`v0.8.0`), den Validation-Meilenstein (`v0.9.0`), den Initial-Stable-Release-Meilenstein (`v1.0.0`), den Network-Isolation-Meilenstein (`v1.1.0`), den Meilenstein Configuration Format v2 (`v1.2.0`), den Meilenstein Boot Menu From Configuration (`v1.3.0`), den Meilenstein Service and Startup Control Discovery (`v1.4.0`), den Meilenstein Service Control for Windows Search (`v1.5.0`), den Meilenstein Startup and User-Application Control (`v1.6.0`) und den Meilenstein Machine-Wide Runtime and Deployment (`v1.7.0`) abgeschlossen.
>
> Der Meilenstein `v1.7.0 - Machine-Wide Runtime and Deployment` ist abgeschlossen. Dieser Release bietet eine MDT-kompatible lokale ProgramData-Runtime, unbeaufsichtigte Deployment- und Removal-Einstiegspunkte, explizite Bootmenüverwaltung, restore-fähiges Multi-User-Cleanup und validierten LocalSystem-Betrieb.
>
> Der aktive Roadmap-Meilenstein ist `v1.8.0 - Policy and Vendor Control Foundation`. Er verbindet die Ermittlung unterstützter Steuerflächen mit Entscheidungsdokumentation, Modul- und Konfigurationsdesign, einer reversiblen Windows-Policy-Implementierung bei bestätigter stabiler Schnittstelle sowie Deployment-/Restore-Validierung. Siehe [Projekt-Roadmap](docs/roadmap.md).

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

Der Uninstall-Wrapper stellt bei Bedarf die gespeicherte normale
Adapter-Baseline wieder her und entfernt danach den Startup-Hook und den
verwalteten Demo-Boot-Eintrag. Wenn bei der Installation eine vorherige
ProgramData-Profilkonfiguration gesichert wurde, wird sie wiederhergestellt.

## Schnellstart: Startup-and-User-Application-Control-Demo

Das Startup-and-User-Application-Control-Modul hat ein eigenes Demo-Setup:

```text
install-startup-user-application-control-demo.cmd
```

Dieses Setup installiert einen verwalteten Bootmenue-Eintrag mit dem Namen
`App Startup Control`, installiert eine passende maschinenweite
Profilkonfiguration und installiert den Startup Hook sowie den User-Logon-Hook.
Runtime-Skripte und Module werden nach
`%ProgramData%\BootProfileSwitcher\runtime` kopiert, damit die Hook-Ausfuehrung
nicht vom Profil des installierenden Benutzers abhaengt.
Das Demo-Profil nutzt reales Apply/Restore fuer allowlist-basierte
Startup-Flaechen von Teams, OneDrive, ownCloud und Microsoft Office sowie den
AnyDesk-Support-Dienst und Microsoft 365 Copilot:

1. normaler Start kann eine gelernte Startup-Baseline wiederherstellen
2. `App Startup Control`-Start deaktiviert die konfigurierten
   Startup-Registry-Werte, Scheduled Tasks und den AnyDesk-Dienst
3. User-Logon wartet kurz auf verzoegerte Autostarts und behandelt danach
   per-user Startup-Eintraege und konfigurierte Prozess-Stopps,
   einschliesslich Microsoft 365 Copilot und AnyDesk
4. ein spaeterer normaler Start oder der Demo-Uninstall stellt die gelernte
   Baseline wieder her

Die Demo kann entfernt werden mit:

```text
uninstall-startup-user-application-control-demo.cmd
```

Der erste Uninstall-Lauf stellt Maschinen-Baselines wieder her, entfernt den
Startup-Hook und den verwalteten Boot-Eintrag und plant die Wiederherstellung
der HKCU-Baseline betroffener Benutzer über den beibehaltenen User-Logon-Hook.
Nachdem alle betroffenen Benutzer angemeldet waren und ihre Completion-Nachweise
geprüft wurden, entfernt ein Aufruf des PowerShell-Uninstallers mit
`-FinalizeUserRestore` den verbleibenden User-Logon-Hook. Eine zuvor gesicherte
ProgramData-Profilkonfiguration wird wiederhergestellt, ohne den ausstehenden
benutzerspezifischen Restore ungültig zu machen.

Der User-Logon-Hook wird ohne Konsolenfenster ueber den Windows Script Host
gestartet. Sein Runtime-Skript sollte im normalen Betrieb nicht manuell aus
einer interaktiven Konsole gestartet werden.

Jedes produktive Modul sollte, soweit praktikabel, eine kleine installierbare
Demo bereitstellen. Die Demo sollte das beabsichtigte Modulverhalten zeigen,
ohne manuelle Konfigurationsänderungen vorauszusetzen.

## Schnellstart: Config-Driven-Boot-Menu-Demo

Die Bootmenü-Demo für Konfigurationsformat v2 installiert eine v2-Konfiguration,
erzeugt verwaltete Bootmenü-Einträge aus dieser Konfiguration und installiert
den Startup Hook:

```text
install-config-driven-boot-menu-demo.cmd
```

Die Demo erzeugt drei verwaltete Einträge mit den Namen `Network Isolation`,
`Experiment Local` und `Maintenance`. Zusätzlich blendet sie den
standardmäßigen Windows-Boot-Eintrag aus der Bootmenü-Anzeige aus, um das
begrenzte Verhalten von `bootMenu.defaultEntry.hide` zu demonstrieren. Der
Default-Eintrag wird nicht gelöscht, und der Demo-Uninstall stellt ihn über den
gespeicherten Bootmenü-State wieder her:

```text
uninstall-config-driven-boot-menu-demo.cmd
```

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

- `install-startup-user-application-control-demo.cmd` installiert die Startup-and-User-Application-Control-Moduldemo mit einem verwalteten Bootprofil `App Startup Control`.
- `uninstall-startup-user-application-control-demo.cmd` startet die restore-fähige Entfernung der Startup-and-User-Application-Control-Moduldemo und behält den User-Logon-Hook für ausstehende benutzerspezifische Restores bei.

- `install-demo.cmd` installiert das v1.0.0-Foundation-Demo-Setup in der erwarteten Reihenfolge und fordert bei Bedarf erhöhte Rechte an.
- `uninstall-demo.cmd` entfernt Startup-Hook, verwaltete Bootmenü-Einträge und temporären Demo-Marker, lässt die ProgramData-Konfiguration aber unverändert.
- `install-network-isolation-demo.cmd` installiert die Network-Isolation-Moduldemo mit einem verwalteten Bootprofil `Network Isolation`.
- `uninstall-network-isolation-demo.cmd` entfernt die Network-Isolation-Moduldemo und stellt die vorherige ProgramData-Profilkonfiguration wieder her, wenn ein Backup vorhanden ist.
- `install-config-driven-boot-menu-demo.cmd` installiert die Bootmenü-Demo für Konfigurationsformat v2 mit mehreren benannten verwalteten Profilen.
- `uninstall-config-driven-boot-menu-demo.cmd` entfernt die config-driven Bootmenü-Demo und stellt die vorherige ProgramData-Profilkonfiguration wieder her, wenn ein Backup vorhanden ist.
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
- `scripts/Install-ConfigDrivenBootMenuDemo.ps1` installiert die config-driven Bootmenü-Demo.
- `scripts/Uninstall-ConfigDrivenBootMenuDemo.ps1` entfernt die config-driven Bootmenü-Demo.
- `scripts/Uninstall-StartupUserApplicationControlDemo.ps1` führt die zweistufige Entfernung der Startup-and-User-Application-Control-Demo aus; `-FinalizeUserRestore` entfernt den beibehaltenen User-Logon-Hook nach Prüfung der Completion-Nachweise.
- `scripts/Install-BootProfileConfiguration.ps1` validiert und installiert eine Profilkonfigurationsdatei an den standardmäßigen maschinenweiten Konfigurationspfad.
- `scripts/Install-BootProfileSwitcherDeployment.ps1` ist der nicht-interaktive MDT-kompatible Deployment-Einstieg für lokale Runtime, Konfiguration, Hooks und die explizite Installation verwalteter Bootmenü-Einträge.
- `scripts/Uninstall-BootProfileSwitcherDeployment.ps1` ist der nicht-interaktive MDT-kompatible Removal-Einstieg für explizit ausgewählte Hooks und verwaltete Bootmenü-Einträge; Runtime, Konfiguration und Modul-Lifecycle-State bleiben erhalten.
- `scripts/Restore-BootProfileSwitcherMachineBaselines.ps1` stellt maschinenweite Lifecycle-Baselines vor dem Entfernen wieder her; per-user HKCU-Baselines bleiben eine Aufgabe des User-Logon-Kontexts.
- `scripts/Start-BootProfileSwitcherUserBaselineRestore.ps1` plant die einmalige Wiederherstellung per-user Baselines über den beibehaltenen User-Logon-Hook.
- `scripts/Test-BootProfileConfiguration.ps1` validiert eine Profil-Konfigurationsdatei, ohne Änderungen anzuwenden.
- `scripts/Test-BootProfileConfigurationFixtures.ps1` validiert die enthaltenen bekannten gültigen und ungültigen Konfigurations-Fixtures.
- `scripts/Inspect-ServiceStartupControlTargets.ps1` fuehrt eine rein lesende Discovery fuer Service-, Autostart- und User-Application-Control im v1.4.0-Meilenstein aus.

Der standardmäßige maschinenweite Konfigurationspfad ist:

```text
%ProgramData%\BootProfileSwitcher\config\profiles.json
```

Das validierte Beispiel für Konfigurationsformat v2 liegt hier:

```text
config/profiles.v2.example.json
```

Die Demo-Konfiguration des Network-Isolation-Moduls liegt in:

```text
config/demos/network-isolation.json
```

Die Demo-Konfiguration für das config-driven Bootmenü liegt in:

```text
config/demos/config-driven-boot-menu.json
```

Konfiguration steuert jetzt den Modul-Dispatch. Wenn die standardmäßige `profiles.json` fehlt, ungültig ist oder die aufgelöste Profil-ID nicht enthält, führt das Bootprofil keine Aktion aus. Die Engine meldet den Grund in ihrer strukturierten Ausgabe, und der Startup Hook protokolliert Konfigurationsstatus, Validierungsfehler und Dispatch-Skip-Grund in `logs/startup-profile.log`. Eigene Skriptpfade werden strukturell vom Konfigurationsformat akzeptiert, aber noch nicht ausgeführt.

Konfigurationsformat v2 ist in
[docs/configuration-format-v2.de.md](docs/configuration-format-v2.de.md)
dokumentiert. Der aktuelle Runtime-Pfad nutzt weiterhin die installierte
Konfiguration und den bestehenden Startup-Ablauf. Die Bootmenü-Installation kann
v2 jetzt direkt aus der maschinenweiten Konfiguration oder über einen
ausdrücklichen `-ConfigPath`-Override lesen.

Network Isolation ist ausführlich in
[docs/modules/network-isolation.de.md](docs/modules/network-isolation.de.md)
dokumentiert.

Service Control ist in
[docs/modules/service-control.md](docs/modules/service-control.md)
dokumentiert. Die aktuelle Implementierung unterstuetzt Dry-run sowie
kontrolliertes Apply/Restore fuer `WSearch` und das logische Ziel `anydesk`.

Die Planung fuer Startup and User-Application Control ist in
[docs/modules/startup-user-application-control.md](docs/modules/startup-user-application-control.md)
dokumentiert. Das v1.6.0-Design adressiert Teams, OneDrive, ownCloud,
Microsoft Office, Microsoft 365 Copilot und AnyDesk ueber ein gemeinsames
Control-Surface-Modell mit applikationsbezogenen Capability Notes.
Die aktuelle Implementierung unterstuetzt Dry-run-Planung sowie kontrolliertes
Apply/Restore fuer allowlist-basierte Startup-Registry-Werte und Scheduled
Tasks. Prozesse koennen reine Inspektion bleiben oder nach User-Logon gestoppt
werden, wenn die Konfiguration `processes.action = "stop"` setzt.

Bekannte Module im aktuellen Repository:

- `validation-log`
- `network-isolation`
- `service-control` allowlist-basiertes Windows-Service-Control-Modul
- `startup-user-application-control` Startup- und User-Application-Control-Modul
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
1.7.0 Machine-Wide Runtime and Deployment
```

## Roadmap

Der aktive Meilenstein ist:

```text
v1.8.0 Policy and Vendor Control Foundation
```

Er umfasst die Capability Discovery für Windows Update und Bitdefender,
dauerhafte Entscheidungen zu Steuerflächen, allowlist-basiertes Policy-Design,
mindestens einen unterstützten reversiblen Windows-Policy-Pfad bei bestätigter
Schnittstelle sowie unbeaufsichtigte Lifecycle-Validierung. Spätere
Meilensteine behandeln Network-Isolation-Hardening, Windows-Search-Scope-Control
und Operational Readiness.

Ziele, Validierungserwartungen und Nicht-Ziele stehen in
[docs/roadmap.md](docs/roadmap.md).

## Validierung

Die aktuelle Validierung für maschinenweites Deployment und Cleanup ist hier dokumentiert:

```text
docs/deployment/mdt-deployment.md
```

Die Konfigurations-Regressions-Fixtures werden ausgeführt mit:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-BootProfileConfigurationFixtures.ps1
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
- [docs/roadmap.md](docs/roadmap.md) – aktive Meilensteinziele, Validierungserwartungen und weitere Roadmap
- [docs/architecture.md](docs/architecture.md) – konzeptionelle Systemarchitektur
- [docs/decisions/PDR-0001-roadmap-after-v1.7.md](docs/decisions/PDR-0001-roadmap-after-v1.7.md) – Entscheidung zum Roadmap-Zuschnitt nach v1.7.0
- [docs/deployment/mdt-deployment.md](docs/deployment/mdt-deployment.md) – technisches MDT-kompatibles Deployment-Modell
- [docs/deployment/mdt-administrator-guide.de.md](docs/deployment/mdt-administrator-guide.de.md) – Praxisanleitung für MDT-Administratoren: Bereitstellung, Update und Entfernung
- [docs/configuration-format-v2.md](docs/configuration-format-v2.md) – englische Dokumentation zu Konfigurationsformat v2
- [docs/configuration-format-v2.de.md](docs/configuration-format-v2.de.md) – deutsche Dokumentation zu Konfigurationsformat v2
- [docs/discovery/service-startup-control.md](docs/discovery/service-startup-control.md) – Discovery-Scope und Inventarisierungsworkflow fuer Service and Startup Control
- [docs/discovery/service-startup-control-findings.md](docs/discovery/service-startup-control-findings.md) – Discovery-Ergebnisse und erste Modulempfehlung fuer Service and Startup Control
- [docs/discovery/startup-user-application-control-findings.md](docs/discovery/startup-user-application-control-findings.md) – Discovery-Ergebnisse fuer Startup and User-Application Control
- [docs/modules/service-control.md](docs/modules/service-control.md) – Design des Service-Control-Moduls
- [docs/modules/startup-user-application-control.md](docs/modules/startup-user-application-control.md) – Design fuer Startup and User-Application Control
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
- [docs/decisions/ADR-0005-configuration-format-v2.md](docs/decisions/ADR-0005-configuration-format-v2.md) – Architekturentscheidung zu Konfigurationsformat v2
- [docs/decisions/ADR-0006-configuration-driven-boot-menu.md](docs/decisions/ADR-0006-configuration-driven-boot-menu.md) – Architekturentscheidung zur konfigurationsgetriebenen Bootmenü-Installation
- [docs/decisions/ADR-0007-service-and-startup-control-modularization.md](docs/decisions/ADR-0007-service-and-startup-control-modularization.md) – Architekturentscheidung zur Modularisierung von Service and Startup Control
- [docs/decisions/ADR-0008-startup-and-user-application-control.md](docs/decisions/ADR-0008-startup-and-user-application-control.md) – Architekturentscheidung zu Startup and User-Application Control
- [docs/decisions/ADR-0009-machine-wide-and-version-resilient-controls.md](docs/decisions/ADR-0009-machine-wide-and-version-resilient-controls.md) – Architekturentscheidung zu maschinenweiten und versionsresilienten Controls
- [LICENSE](LICENSE) – MIT-Lizenz

### Resolver des aktuellen Profils

Nach der Installation des Bootmenüs und einem Start über ein verwaltetes Profil wie `Network Isolation`, `Experiment Local` oder `Maintenance`:

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
