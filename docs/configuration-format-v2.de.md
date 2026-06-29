# Konfigurationsformat v2

Konfigurationsformat v2 ist die Konfigurationsform fuer die aktuellen strukturellen Meilensteine des BootProfile Switchers.

Es wurde in v1.2.0 als Design- und Validierungsziel eingefuehrt. Ab v1.3.0 kann die Bootmenue-Installation dieses Format direkt lesen.

## Ziele

Konfigurationsformat v2 soll Folgendes unterstuetzen:

- eine variable Anzahl verwalteter Bootprofile
- frei waehlbare Profil-Anzeigenamen
- konfigurationsgetriebene Bootmenue-Erzeugung
- eingeschraenkte Behandlung des Windows-Default-Boot-Eintrags
- profilnahe Moduleinstellungen
- spaetere Produktionsmodule wie Service Control

## Default Entry

Der Windows-Default-Boot-Eintrag ist kein normales BootProfile-Switcher-Profil.

Er ist der Recovery- und Rueckkehrpfad des Systems. Konfigurationsformat v2 modelliert ihn deshalb separat unter `bootMenu.defaultEntry`.

Der Default Entry soll nur eng begrenzte Optionen unterstuetzen:

- `rename`
- `displayName`
- `hide`

Jede Implementierung, die den Default Entry umbenennt oder versteckt, muss genug Baseline-State speichern, um bei der Deinstallation den gewuenschten normalen Systemzustand wiederherzustellen.

## Verwaltete Profile

Verwaltete BootProfile-Switcher-Profile stehen unter `profiles`.

Jedes verwaltete Profil hat:

- `id` als stabile interne Identitaet
- `displayName` fuer nutzerseitige Anzeigenamen
- `bootMenu.enabled` fuer Bootmenue-Erzeugung
- `modules` als Objekt mit ausgewaehlten Modulen und deren Einstellungen
- `scripts` fuer spaetere Custom-Script-Unterstuetzung

Profil-IDs muessen Kleinbuchstaben, Zahlen und einzelne Bindestrich-Trenner
verwenden, zum Beispiel `network-isolation` oder `experiment-local`. Das alte
v1-Feld `mode` ist nicht Teil von v2.

## Moduleinstellungen

Moduleinstellungen stehen direkt am jeweiligen Profil unter `modules`.

Dadurch bleibt jedes Profil lesbar, ohne Einstellungen aus mehreren Stellen
zusammenfuehren zu muessen. Fuer die erwarteten zwei bis drei verwalteten Profile
auf einem Rechner sind explizite profilnahe Moduleinstellungen leichter zu
pruefen als vererbte globale Defaults.

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

Globale Modul-Defaults koennen spaeter erneut geprueft werden, wenn ein echter
Deployment-Bedarf entsteht. Sie sind bewusst nicht Teil von v2.

## Validierungsregeln

Der v2-Validator lehnt absichtlich uneindeutige oder alte Formen ab:

- nicht unterstuetzte Top-Level-Felder
- reine v1-Profilfelder wie `mode` oder `moduleSettings`
- ungueltige Profil-IDs
- doppelte Profil-IDs
- doppelte Anzeigenamen
- leere `modules`-Objekte
- unbekannte Modulnamen
- Script-Eintraege, die keine Strings sind
- Default-Entry-Anzeigenamen, wenn `rename` auf `false` steht

Diese Regeln halten das Format explizit, weil es als Quelle fuer
konfigurationsgetriebene Bootmenue-Erzeugung dient.

## Beispiel

Die v2-Beispielkonfiguration liegt hier:

```text
config/profiles.v2.example.json
```

Der aktuelle Runtime-Pfad verwendet den installierten `profiles.json`-Pfad und den bestehenden Startup-Ablauf. Die Bootmenue-Installation liest v2 standardmaessig von diesem maschinenweiten Pfad oder ueber einen ausdruecklichen `-ConfigPath`-Override fuer Demos, Tests und Migrationen.
