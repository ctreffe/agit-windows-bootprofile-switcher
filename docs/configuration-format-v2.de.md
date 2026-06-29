# Konfigurationsformat v2

Konfigurationsformat v2 ist die geplante Konfigurationsform für die nächsten strukturellen Meilensteine des BootProfile Switchers.

Es wird in v1.2.0 als Design- und Validierungsziel eingeführt. Die Runtime-Erzeugung des Bootmenüs aus diesem Format ist für einen späteren Meilenstein geplant.

## Ziele

Konfigurationsformat v2 soll Folgendes unterstützen:

- eine variable Anzahl verwalteter Bootprofile
- frei wählbare Profil-Anzeigenamen
- konfigurationsgetriebene Bootmenü-Erzeugung
- eingeschränkte Behandlung des Windows-Default-Boot-Eintrags
- profilnahe Moduleinstellungen
- spätere Produktionsmodule wie Service Control

## Default Entry

Der Windows-Default-Boot-Eintrag ist kein normales BootProfile-Switcher-Profil.

Er ist der Recovery- und Rückkehrpfad des Systems. Konfigurationsformat v2 modelliert ihn deshalb separat unter `bootMenu.defaultEntry`.

Der Default Entry soll nur eng begrenzte Optionen unterstützen:

- `rename`
- `displayName`
- `hide`

Jede spätere Implementierung, die den Default Entry umbenennt oder versteckt, muss genug Baseline-State speichern, um bei der Deinstallation den gewünschten normalen Systemzustand wiederherzustellen.

## Verwaltete Profile

Verwaltete BootProfile-Switcher-Profile stehen unter `profiles`.

Jedes verwaltete Profil hat:

- `id` als stabile interne Identität
- `displayName` für nutzerseitige Anzeigenamen
- `bootMenu.enabled` für spätere Bootmenü-Erzeugung
- `modules` als Objekt mit ausgewählten Modulen und deren Einstellungen
- `scripts` für spätere Custom-Script-Unterstützung

## Moduleinstellungen

Moduleinstellungen stehen direkt am jeweiligen Profil unter `modules`.

Dadurch bleibt jedes Profil lesbar, ohne Einstellungen aus mehreren Stellen
zusammenführen zu müssen. Für die erwarteten zwei bis drei verwalteten Profile
auf einem Rechner sind explizite profilnahe Moduleinstellungen leichter zu
prüfen als vererbte globale Defaults.

```json
"modules": {
  "network-isolation": {
    "dryRun": true,
    "disable": {
      "ethernet": true,
      "wifi": true,
      "cellular": true,
      "bluetoothNetwork": true
    },
    "exclude": {
      "macAddresses": [],
      "interfaceDescriptions": [],
      "interfaceAliases": []
    }
  },
  "validation-log": {}
}
```

Globale Modul-Defaults können später erneut geprüft werden, wenn ein echter
Deployment-Bedarf entsteht. Sie sind bewusst nicht Teil von v2.

## Beispiel

Die v2-Beispielkonfiguration liegt hier:

```text
config/profiles.v2.example.json
```

Der aktuelle produktive Runtime-Pfad verwendet weiterhin den installierten `profiles.json`-Pfad und den bestehenden Startup-Ablauf. v2 existiert, damit das Konfigurationsmodell validiert werden kann, bevor die Bootmenü-Erzeugung konfigurationsgetrieben wird.
