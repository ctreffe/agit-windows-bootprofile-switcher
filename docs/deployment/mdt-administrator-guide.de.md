# BootProfile Switcher mit MDT bereitstellen

Diese Anleitung beschreibt die unbeaufsichtigte Installation, Aktualisierung,
Prüfung und Entfernung für MDT-Administratoren. Der technische Parametervertrag
steht im [MDT Deployment Model](mdt-deployment.md).

## Voraussetzungen

- Die Task Sequence läuft im Maschinenkontext (`LocalSystem`).
- Das Anwendungspaket enthält `scripts\`, `modules\` und eine geprüfte,
  standortspezifische Konfiguration, zum Beispiel `config\site\profiles.json`.
- Testen Sie zunächst auf einem Pilotgerät. Bootmenü-Änderungen benötigen eine
  eigene Freigabe.

Prüfen Sie die Konfiguration vor dem Rollout:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Test-BootProfileConfiguration.ps1" -ConfigurationPath ".\config\site\profiles.json"
```

Die Runtime liegt nach der Installation unter
`%ProgramData%\BootProfileSwitcher\runtime`; sie benötigt danach keinen Zugriff
auf den MDT-Share. Konfiguration und Aufgaben dürfen keine Zugangsdaten,
UNC-Pfade, Benutzernamen oder SIDs enthalten.

## Standardbereitstellung

Fügen Sie nach dem lokalen Entpacken des Anwendungspakets einen PowerShell-
Schritt in die Task Sequence ein. `%SCRIPTROOT%` verweist in MDT auf das Paket:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTROOT%\scripts\Install-BootProfileSwitcherDeployment.ps1" -SourceRoot "%SCRIPTROOT%" -ConfigurationPath "%SCRIPTROOT%\config\site\profiles.json" -InstallStartupHook -InstallUserLogonHook -Force -AsJson
```

| Option | Wirkung |
| --- | --- |
| `-SourceRoot` | Erforderlicher Pfad zum entpackten Anwendungspaket. |
| `-ConfigurationPath` | Validiert und installiert die Profilkonfiguration. |
| `-InstallStartupHook` | Registriert den Maschinen-Hook für den Systemstart. |
| `-InstallUserLogonHook` | Registriert den Hook im Kontext jedes Benutzers. |
| `-Force` | Erlaubt den Austausch einer abweichenden verwalteten Konfiguration. |
| `-AsJson` | Liefert ein kompaktes Ergebnis für MDT-Logs. |

Der Schritt ist nicht interaktiv. MDT bewertet ausschließlich Exit-Code `0` als
Erfolg.

## Bootmenü bewusst aktivieren

Die Standardbereitstellung verändert BCD nicht. Ergänzen Sie den Befehl nur für
eine freigegebene Bootmenü-Bereitstellung um:

```text
-InstallBootMenu
```

Bereits verwaltete Einträge werden nur mit explizitem Ersatz aktualisiert:

```text
-InstallBootMenu -CleanupExistingBootMenu
```

Andere BCD-Einträge bleiben unberührt. Ein Neustart ist für die Installation
nicht nötig, für die Auswahl eines Bootprofils anschließend jedoch sinnvoll.

## Update und Prüfung

Ein reines Runtime-Update behält Konfiguration und Lifecycle-Zustand bei:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTROOT%\scripts\Install-BootProfileSwitcherDeployment.ps1" -SourceRoot "%SCRIPTROOT%" -AsJson
```

Prüfen Sie danach Runtime, Konfiguration und Logs unter
`%ProgramData%\BootProfileSwitcher` sowie die Aufgaben
`BootProfileSwitcher-StartupHook` und `BootProfileSwitcher-UserLogonHook`.

| Exit-Code | Bedeutung |
| --- | --- |
| `0` | Erfolg oder idempotenter No-Change-Lauf. |
| `1` | Parameter-, Konfigurations- oder Berechtigungsfehler. |
| `2` | Runtime-Kopie fehlgeschlagen. |
| `3` | Fehler in der Aufgabenplanung. |
| `4` | BCD-Operation fehlgeschlagen. |
| `5` | Restore oder Bereinigung fehlgeschlagen. |

Prüfen Sie Aufgaben und BCD im gleichen erhöhten Kontext wie den Deployment-
Schritt; nicht erhöhte Abfragen können unvollständig sein.

## Kontrollierte Entfernung

Löschen Sie keine Dateien manuell. Bei zustandsändernden Modulen:

1. Maschinen-Baselines wiederherstellen:

   ```text
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1" -RestoreMachineBaselines -AsJson
   ```

2. Per-user Wiederherstellung vormerken und den User-Logon-Hook beibehalten:

   ```text
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1" -ScheduleUserBaselineRestore -AsJson
   ```

   Jeder betroffene Benutzer muss sich einmal anmelden. Der Abschluss steht
   unter `%LocalAppData%\BootProfileSwitcher\state\pending-user-baseline-restore.json`.

3. Nach Prüfung aller Completion-Nachweise die tatsächlich installierten
   Komponenten entfernen, beispielsweise:

   ```text
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1" -RemoveStartupHook -RemoveUserLogonHook -RemoveBootMenu -RemoveConfiguration -RemoveMachineState -Force -AsJson
   ```

4. Die Runtime ausschließlich separat entfernen:

   ```text
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\BootProfileSwitcher\runtime\scripts\Uninstall-BootProfileSwitcherDeployment.ps1" -RemoveRuntime -Force -AsJson
   ```

Der externe Worker schreibt danach
`%ProgramData%\BootProfileSwitcher\runtime-removal-result.json`. Erst wenn
dort `succeeded: true` steht und der Runtime-Ordner fehlt, ist die Entfernung
abgeschlossen.

## Betriebshinweise

- Die Hooks verwenden ausschließlich die lokale ProgramData-Runtime.
- Der User-Logon-Hook verarbeitet nur HKCU-Daten des angemeldeten Benutzers.
- Führen Sie Änderungen über Pilotgruppen und mit dokumentiertem Rückbauplan ein.
