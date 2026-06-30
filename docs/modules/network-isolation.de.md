# Network-Isolation-Modul

## Zweck

`network-isolation` ist das erste produktionsorientierte Lifecycle-Modul im BootProfile Switcher.

Es kann ausgewaehlte Netzwerkadapter-Kategorien fuer isolierende Bootprofile deaktivieren und die zuletzt gelernte normale Adapter-Baseline wiederherstellen, wenn das System wieder ohne aktive Isolation startet.

Das Modul ist fuer Szenarien gedacht, in denen eine Windows-Installation weiter nutzbar bleiben soll, waehrend bestimmte Bootprofile mit eingeschraenkter Netzwerkkonnektivitaet laufen.

## Was Das Modul Steuert

Das Modul unterstuetzt diese Adapter-Kategorien:

- `ethernet`
- `wifi`
- `cellular`
- `bluetoothNetwork`

Bluetooth-Unterstuetzung meint Bluetooth-Netzwerkadapter wie Bluetooth-PAN-Eintraege. Das Modul deaktiviert kein Bluetooth-Radio und keinen USB-Bluetooth-Adapter als Geraet. Vollstaendige Bluetooth-Device-Isolation gehoert in ein spaeteres eigenes Modul oder Hardening-Milestone.

Das Modul zielt standardmaessig auf Hardware-Netzwerkinterfaces. VPN-, Tunnel-, Loopback- und virtuelle Adapter werden in dieser ersten Implementierung protokolliert und uebersprungen. Bluetooth-Netzwerkadapter sind eine explizite Opt-in-Ausnahme, weil Windows sie als Nicht-Hardware-Interfaces melden kann.

## Sicherheitsgrenze

Network Isolation ist Adapter-Level-Isolation.

Sie soll verhindern, dass normale Nutzer:innen deaktivierte Zieladapter einfach weiterverwenden. Sie ist keine vollstaendige Sicherheitsgrenze gegen lokale Administrator:innen, privilegierte Management-Tools oder spaetere manuelle Rekonfiguration.

Zukuenftiges Hardening sollte pruefen:

- Gruppenrichtlinien
- Einschraenkungen der Netzwerk-UI
- Geraeteverwaltungs-Kontrollen
- Dienststeuerung
- Firewall-Erzwingung

Das Modul sollte nur mit dieser Grenze im Hinterkopf eingesetzt werden.

## Konfiguration

BootProfile Switcher nutzt Configuration Format v2. Jedes Profil definiert seine Modul-Einstellungen direkt unter `profiles[].modules`.

Ein Profil aktiviert Network Isolation, indem es ein `network-isolation`-Objekt in seinem `modules`-Objekt enthaelt:

```json
{
  "schemaVersion": 2,
  "bootMenu": {
    "timeoutSeconds": 10,
    "sourceEntry": "{default}",
    "defaultEntry": {
      "rename": false,
      "displayName": null,
      "hide": false
    }
  },
  "profiles": [
    {
      "id": "network-isolation",
      "displayName": "Network Isolation",
      "bootMenu": {
        "enabled": true
      },
      "modules": {
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
      "scripts": []
    }
  ]
}
```

`dryRun` sollte erst auf `false` gesetzt werden, nachdem die protokollierten Adapterentscheidungen auf dem Zielsystem geprueft wurden.

## Profilbezogene Einstellungen

Network-Isolation-Einstellungen sind in v2 bewusst profilbezogen. Das haelt kleine Deployments lesbar: Zwei oder drei Bootprofile koennen jeweils ihre eigene Netzwerk-Policy deklarieren, ohne globale Defaults.

Unterschiedliche Profile koennen unterschiedliche Adapter-Kategorien deaktivieren oder unterschiedliche Ausnahmen verwenden. Ein Profil kann zum Beispiel nur WLAN deaktivieren, waehrend ein anderes Ethernet, WLAN, Cellular und Bluetooth-PAN-Netzwerkadapter deaktiviert.

## Ausnahmen

Adapter koennen ausgeschlossen werden per:

- MAC-Adresse
- Interface Description
- Interface Alias

MAC-Adressen eignen sich fuer stabile Ausnahmen auf einzelnen Geraeten.

Interface Descriptions eignen sich, um Hardwaremodelle ueber aehnliche Geraete hinweg zu erkennen.

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

Dadurch koennen administrative Aenderungen waehrend normaler, nicht-isolierender Nutzung automatisch zur neuen Baseline werden.

Restore-Entscheidungen verwenden den administrativen Adapterstatus. Das ist wichtig, weil durch `Disable-NetAdapter` deaktivierte Adapter von Windows mit Laufzeitstatus `Not Present` gemeldet werden koennen, waehrend der administrative Zustand weiterhin zeigt, dass sie wieder aktiviert werden koennen.

## Logging

Der Startup-Hook schreibt das Gesamtergebnis nach:

```text
logs/startup-profile.log
```

Modulaktionen werden hier protokolliert:

```text
logs/module-actions.log
```

Die Logs zeigen, ob die Konfiguration gueltig war, ob ein Profil erkannt wurde, welche Module liefen, welche Adapterentscheidungen getroffen wurden und ob ein Dispatch-Pfad uebersprungen wurde.

## Demo

Das Modul enthaelt ein eigenes Demo-Setup:

```text
install-network-isolation-demo.cmd
```

Die Demo installiert einen verwalteten Bootmenue-Eintrag mit dem Namen `Network Isolation`, eine passende maschinenweite Profilkonfiguration und den Startup-Hook.

Das Demo-Profil deaktiviert Ethernet-, WLAN-, Cellular- und Bluetooth-PAN-Netzwerkadapter. Es demonstriert den vollstaendigen Lifecycle:

1. normaler Start lernt die aktuelle Adapter-Baseline
2. `Network Isolation`-Start deaktiviert die konfigurierten Netzwerkpfade
3. normaler Start stellt die gelernte Baseline wieder her

Die Demo kann entfernt werden mit:

```text
uninstall-network-isolation-demo.cmd
```

Beim Entfernen fuehrt der Demo-Uninstaller den Network-Isolation-Lifecycle
einmal im nicht-isolierenden Modus aus, bevor Startup Hook und Demo-Konfiguration
entfernt werden. Dadurch wird die gespeicherte normale Adapter-Baseline auch
dann wiederhergestellt, wenn zuletzt das Bootprofil `Network Isolation`
ausgewaehlt war.

Wenn bei der Installation eine vorherige ProgramData-Profilkonfiguration gesichert wurde, stellt der Uninstall-Wrapper sie wieder her.

Die Demo-Konfiguration liegt hier:

```text
config/demos/network-isolation.json
```

## Validierung

Die Repository-Fixtures koennen so validiert werden:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-BootProfileConfigurationFixtures.ps1 -AsJson
```

Die Demo-Konfiguration kann so validiert werden:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-BootProfileConfiguration.ps1 -ConfigPath .\config\demos\network-isolation.json -AsJson
```

## Bekannte Grenzen

- Das Modul deaktiviert keine Bluetooth-Radios und keine USB-Bluetooth-Adapter als Geraete.
- Das Modul verwaltet aktuell keine VPN-, Tunnel-, Loopback- oder virtuellen Adapter.
- Adapter-Level-Isolation ist keine vollstaendige Sicherheitsgrenze gegen lokale Administrator:innen.
- Staerkere Enterprise-Erzwingung gehoert in ein zukuenftiges Hardening-Milestone.
