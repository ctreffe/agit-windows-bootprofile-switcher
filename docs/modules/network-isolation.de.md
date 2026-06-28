# Network-Isolation-Modul

## Zweck

`network-isolation` ist das erste produktionsorientierte Lifecycle-Modul im BootProfile Switcher.

Es kann ausgewählte Netzwerkadapter-Kategorien für isolierende Bootprofile deaktivieren und die zuletzt gelernte normale Adapter-Baseline wiederherstellen, wenn das System wieder ohne aktive Isolation startet.

Das Modul ist für Szenarien gedacht, in denen eine Windows-Installation weiter nutzbar bleiben soll, während bestimmte Bootprofile mit eingeschränkter Netzwerkkonnektivität laufen.

## Was Das Modul Steuert

Das Modul unterstützt diese Adapter-Kategorien:

- `ethernet`
- `wifi`
- `cellular`
- `bluetoothNetwork`

Bluetooth-Unterstützung meint Bluetooth-Netzwerkadapter wie Bluetooth-PAN-Einträge. Das Modul deaktiviert kein Bluetooth-Radio und keinen USB-Bluetooth-Adapter als Gerät. Vollständige Bluetooth-Device-Isolation gehört in ein späteres eigenes Modul oder Hardening-Milestone.

Das Modul zielt standardmäßig auf Hardware-Netzwerkinterfaces. VPN-, Tunnel-, Loopback- und virtuelle Adapter werden in dieser ersten Implementierung protokolliert und übersprungen. Bluetooth-Netzwerkadapter sind eine explizite Opt-in-Ausnahme, weil Windows sie als Nicht-Hardware-Interfaces melden kann.

## Sicherheitsgrenze

Network Isolation in v1.1.0 ist Adapter-Level-Isolation.

Sie soll verhindern, dass normale Nutzer:innen deaktivierte Zieladapter einfach weiterverwenden. Sie ist keine vollständige Sicherheitsgrenze gegen lokale Administrator:innen, privilegierte Management-Tools oder spätere manuelle Rekonfiguration.

Zukünftiges Hardening sollte prüfen:

- Gruppenrichtlinien
- Einschränkungen der Netzwerk-UI
- Geräteverwaltungs-Kontrollen
- Dienststeuerung
- Firewall-Erzwingung

Das Modul sollte nur mit dieser Grenze im Hinterkopf eingesetzt werden.

## Konfiguration

Die Policy wird global unter `moduleSettings` konfiguriert. Ein Profil aktiviert Isolation, indem es `network-isolation` in seiner `modules`-Liste aufführt.

```json
{
  "schemaVersion": 1,
  "moduleSettings": {
    "network-isolation": {
      "dryRun": true,
      "disable": {
        "ethernet": true,
        "wifi": true,
        "cellular": false,
        "bluetoothNetwork": false
      },
      "exclude": {
        "macAddresses": [],
        "interfaceDescriptions": [],
        "interfaceAliases": []
      }
    }
  },
  "profiles": [
    {
      "name": "BootProfile Switcher - Mode A",
      "mode": "A",
      "modules": [
        "network-isolation"
      ],
      "scripts": []
    }
  ]
}
```

`dryRun` sollte erst auf `false` gesetzt werden, nachdem die protokollierten Adapterentscheidungen auf dem Zielsystem geprüft wurden.

## Profil-Overrides

Profile können Network-Isolation-Einstellungen in ihrem eigenen `moduleSettings`-Abschnitt überschreiben.

`dryRun` und einzelne `disable`-Flags überschreiben den globalen Wert, wenn sie vorhanden sind.

`exclude`-Werte werden addiert. Dadurch bleiben globale Management-Ausnahmen geschützt, während Profile eigene Ausnahmen ergänzen können.

```json
{
  "name": "BootProfile Switcher - Mode A",
  "mode": "A",
  "modules": [
    "network-isolation"
  ],
  "moduleSettings": {
    "network-isolation": {
      "disable": {
        "wifi": false
      },
      "exclude": {
        "interfaceAliases": [
          "Management LAN"
        ]
      }
    }
  },
  "scripts": []
}
```

## Ausnahmen

Adapter können ausgeschlossen werden per:

- MAC-Adresse
- Interface Description
- Interface Alias

MAC-Adressen eignen sich für stabile Ausnahmen auf einzelnen Geräten.

Interface Descriptions eignen sich, um Hardwaremodelle über ähnliche Geräte hinweg zu erkennen.

Interface Aliases eignen sich, wenn Administrator:innen gezielt vorhersehbare Namen per Deployment oder Gruppenrichtlinie vergeben.

## Lifecycle Und Baseline

Das Modul speichert die normale Adapter-Baseline und Metadaten zum letzten Lauf in:

```text
%ProgramData%\BootProfileSwitcher\state\network-isolation-state.json
```

Der Lifecycle ist:

1. Wenn der vorherige Lauf nicht isolierend war, darf der aktuelle Adapter-Snapshot zur neuen normalen Baseline werden.
2. Wenn das aktuelle Profil isolierend ist, werden die konfigurierten Adapter-Kategorien deaktiviert.
3. Wenn der vorherige Lauf isolierend war und der aktuelle Start nicht isoliert, wird die gespeicherte Baseline wiederhergestellt, statt den durch Isolation entstandenen Zustand zu lernen.

Dadurch können administrative Änderungen während normaler, nicht-isolierender Nutzung automatisch zur neuen Baseline werden.

Restore-Entscheidungen verwenden den administrativen Adapterstatus. Das ist wichtig, weil durch `Disable-NetAdapter` deaktivierte Adapter von Windows mit Laufzeitstatus `Not Present` gemeldet werden können, während der administrative Zustand weiterhin zeigt, dass sie wieder aktiviert werden können.

## Logging

Der Startup-Hook schreibt das Gesamtergebnis nach:

```text
logs/startup-profile.log
```

Modulaktionen werden hier protokolliert:

```text
logs/module-actions.log
```

Die Logs zeigen, ob die Konfiguration gültig war, ob ein Profil erkannt wurde, welche Module liefen, welche Adapterentscheidungen getroffen wurden und ob ein Dispatch-Pfad übersprungen wurde.

## Demo

Das Modul enthält ein eigenes Demo-Setup:

```text
install-network-isolation-demo.cmd
```

Die Demo installiert einen verwalteten Bootmenü-Eintrag mit dem Namen `Network Isolation`, eine passende maschinenweite Profilkonfiguration und den Startup-Hook.

Das Demo-Profil deaktiviert Ethernet-, WLAN-, Cellular- und Bluetooth-PAN-Netzwerkadapter. Es demonstriert den vollständigen Lifecycle:

1. normaler Start lernt die aktuelle Adapter-Baseline
2. `Network Isolation`-Start deaktiviert die konfigurierten Netzwerkpfade
3. normaler Start stellt die gelernte Baseline wieder her

Die Demo kann entfernt werden mit:

```text
uninstall-network-isolation-demo.cmd
```

Wenn bei der Installation eine vorherige ProgramData-Profilkonfiguration gesichert wurde, stellt der Uninstall-Wrapper sie wieder her.

Die Demo-Konfiguration liegt hier:

```text
config/demos/network-isolation.json
```

## Validierung

Die Repository-Fixtures können so validiert werden:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-BootProfileConfigurationFixtures.ps1 -AsJson
```

Die Demo-Konfiguration kann so validiert werden:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-BootProfileConfiguration.ps1 -ConfigPath .\config\demos\network-isolation.json -AsJson
```

## Bekannte Grenzen

- Das Modul deaktiviert keine Bluetooth-Radios und keine USB-Bluetooth-Adapter als Geräte.
- Das Modul verwaltet aktuell keine VPN-, Tunnel-, Loopback- oder virtuellen Adapter.
- Adapter-Level-Isolation ist keine vollständige Sicherheitsgrenze gegen lokale Administrator:innen.
- Stärkere Enterprise-Erzwingung gehört in ein zukünftiges Hardening-Milestone.
