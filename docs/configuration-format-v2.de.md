# Konfigurationsformat v2

Konfigurationsformat v2 ist die Konfigurationsform fuer die aktuellen strukturellen Meilensteine des BootProfile Switchers.

Es wurde in v1.2.0 als Design- und Validierungsziel eingefuehrt. Ab v1.3.0 kann die Bootmenue-Installation dieses Format direkt lesen.

Dieses Dokument ist als praktische Anleitung zum Bearbeiten von `profiles.json`
geschrieben. Es erklaert, was die einzelnen Teile der Datei bedeuten, welche
Werte man zuerst sicher aendern kann und wie das Ergebnis vor der Installation
validiert wird.

## Ziele

Konfigurationsformat v2 soll Folgendes unterstuetzen:

- eine variable Anzahl verwalteter Bootprofile
- frei waehlbare Profil-Anzeigenamen
- konfigurationsgetriebene Bootmenue-Erzeugung
- eingeschraenkte Behandlung des Windows-Default-Boot-Eintrags
- profilnahe Moduleinstellungen
- spaetere Produktionsmodule wie Service Control

## Speicherort der Konfiguration

Die standardmaessige maschinenweite Konfigurationsdatei ist:

```text
C:\ProgramData\BootProfileSwitcher\config\profiles.json
```

BootProfile Switcher liest diese Datei waehrend des Startvorgangs. Auch der
Bootmenue-Installer verwendet sie standardmaessig, wenn verwaltete
Boot-Eintraege erzeugt werden.

Fuer Entwicklung, Tests und Demos koennen Skripte ueber `-ConfigPath` eine
andere Datei verwenden. Im Repository sind diese Beispiele wichtig:

- `config/profiles.v2.example.json` ist das allgemeine v2-Beispiel.
- `config/demos/config-driven-boot-menu.json` zeigt mehrere verwaltete Boot-Eintraege.
- `config/demos/network-isolation.json` zeigt den echten Network-Isolation-Lifecycle.

Die installierte ProgramData-Datei sollte nicht blind bearbeitet werden. Besser
ist es, eine Kopie im Repository oder an einem anderen Arbeitsort zu aendern,
zu validieren und anschliessend mit dem Installer-Skript zu installieren.

## Dateistruktur

Eine v2-Konfiguration hat drei oberste Teile:

```json
{
  "schemaVersion": 2,
  "bootMenu": {},
  "profiles": []
}
```

`schemaVersion` muss `2` sein.

`bootMenu` beschreibt globales Windows-Boot-Manager-Verhalten.

`profiles` enthaelt die verwalteten BootProfile-Switcher-Profile, die im
Bootmenue erscheinen und beim Start Module ausfuehren koennen.

Der Windows-Default-Boot-Eintrag steht nicht in `profiles`. Er wird nur ueber
`bootMenu.defaultEntry` behandelt.

## Default Entry

Der Windows-Default-Boot-Eintrag ist kein normales BootProfile-Switcher-Profil.

Er ist der Recovery- und Rueckkehrpfad des Systems. Konfigurationsformat v2 modelliert ihn deshalb separat unter `bootMenu.defaultEntry`.

Der Default Entry soll nur eng begrenzte Optionen unterstuetzen:

- `rename`
- `displayName`
- `hide`

Jede Implementierung, die den Default Entry umbenennt oder versteckt, muss genug Baseline-State speichern, um bei der Deinstallation den gewuenschten normalen Systemzustand wiederherzustellen.

Aktuelle Felder:

- `rename` steuert, ob die Beschreibung des Windows-Default-Boot-Eintrags geaendert wird.
- `displayName` ist der Ersatzname, wenn `rename` auf `true` steht; der Wert muss `null` sein, wenn `rename` auf `false` steht.
- `hide` steuert, ob der Windows-Default-Boot-Eintrag aus der sichtbaren Bootmenue-Reihenfolge entfernt wird.

Fuer vorsichtige erste Tests sollte diese Einstellung beibehalten werden:

```json
"defaultEntry": {
  "rename": false,
  "displayName": null,
  "hide": false
}
```

Die config-driven Bootmenue-Demo verwendet `hide = true`, um zu zeigen, dass der
normale Windows-Eintrag aus der Anzeige ausgeblendet werden kann, ohne ihn zu
loeschen. Die Deinstallation stellt den gespeicherten Default-Entry-Zustand
wieder her.

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

Ein minimales verwaltetes Profil sieht so aus:

```json
{
  "id": "experiment-local",
  "displayName": "Experiment Local",
  "bootMenu": {
    "enabled": true
  },
  "modules": {
    "validation-log": {}
  },
  "scripts": []
}
```

Bedeutung der Felder:

- `id` ist die stabile interne Kennung. Sie sollte kleingeschrieben bleiben und nach einem Deployment nicht leichtfertig umbenannt werden.
- `displayName` ist der Name, den Benutzer im Windows Boot Manager sehen.
- `bootMenu.enabled` entscheidet, ob fuer dieses Profil ein verwalteter Boot-Eintrag erzeugt wird.
- `modules` waehlt aus, was BootProfile Switcher ausfuehrt, wenn dieses Profil erkannt wird.
- `scripts` ist fuer spaetere Custom-Script-Unterstuetzung reserviert. Es muss ein Array sein, aber Custom Scripts werden noch nicht ausgefuehrt.

Wenn `bootMenu.enabled` auf `false` steht, kann das Profil in der Konfiguration
bleiben, aber der Bootmenue-Installer erzeugt keinen Boot-Eintrag dafuer.

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

Aktuell bekannte Module im Repository:

- `validation-log` schreibt harmlose Validierungs-Logeintraege.
- `network-isolation` kann konfigurierte Netzwerkadapter-Kategorien deaktivieren und wiederherstellen.
- `service-control` kann aktuell geplante Service-Control-Aktionen fuer Windows Search / `WSearch` im Dry-run pruefen.
- `startup-user-application-control` validiert und dry-runnt geplante Startup- und User-Application-Control-Einstellungen fuer Teams, OneDrive, ownCloud und Microsoft Office.
- `demo-system-marker` ist ein temporaeres Foundation-Demomodul.

### Network-Isolation-Einstellungen

`network-isolation` ist das erste Modul, das echten Windows-Zustand veraendern
kann. Fuer eine neue Konfiguration sollte zuerst `dryRun = true` verwendet
werden:

```json
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
}
```

Wenn `dryRun` auf `true` steht, protokolliert das Modul, was es tun wuerde,
ohne Adapter zu deaktivieren. Erst nach der Pruefung der Logausgabe auf dem
Zielrechner sollte der Wert auf `false` gesetzt werden.

Das Objekt `disable` waehlt Adapter-Kategorien aus:

- `ethernet` fuer kabelgebundene Netzwerkadapter
- `wifi` fuer WLAN-Adapter
- `cellular` fuer Mobile-Broadband-Adapter
- `bluetoothNetwork` fuer Bluetooth-PAN-Netzwerkadapter

Das Objekt `exclude` nimmt bestimmte Adapter von der Isolation aus. Das ist
sinnvoll, wenn ein Management-Adapter, ein Recovery-Pfad oder eine andere
notwendige Verbindung aktiv bleiben muss.

`bluetoothNetwork` deaktiviert nicht das Bluetooth-Funkmodul und kein
USB-Bluetooth-Geraet. Es betrifft nur Bluetooth-Netzwerkadapter wie Bluetooth
PAN.

### Startup-and-User-Application-Control-Einstellungen

`startup-user-application-control` ist das v1.6.0-Modul fuer
allowlist-basierte Applikations-Startup-Flaechen. Die erste Implementierung
ist rein lesend und protokolliert geplante Aktionen im Dry-run:

```json
"startup-user-application-control": {
  "dryRun": true,
  "applications": [
    {
      "id": "teams",
      "startup": {
        "enabled": false
      },
      "processes": {
        "action": "inspect-only"
      }
    }
  ]
}
```

Unterstuetzte Applikations-IDs sind:

- `teams`
- `onedrive`
- `owncloud`
- `microsoft-office`

`startup.enabled` muss ein Boolean sein. Das erste validierte Prozessverhalten
ist `inspect-only`; das Beenden von User-Prozessen wird vom Validator bewusst
nicht akzeptiert.

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

## Sicherer Bearbeitungsablauf

Beim Aendern einer Konfiguration empfiehlt sich dieser Ablauf:

1. Ein vorhandenes Beispiel kopieren, zum Beispiel `config/profiles.v2.example.json`.
2. Nur ein Profil auf einmal aendern.
3. `network-isolation.dryRun` auf `true` lassen, bis die Logausgabe geprueft wurde.
4. Die Datei validieren:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-BootProfileConfiguration.ps1 -ConfigPath .\config\profiles.v2.example.json -AsJson
```

5. Die validierte Konfiguration installieren:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Install-BootProfileConfiguration.ps1 -SourcePath .\config\profiles.v2.example.json
```

6. Das verwaltete Bootmenue erst installieren oder aktualisieren, wenn die Konfigurationsvalidierung erfolgreich war.

Der Validator prueft Struktur und bekannte Einstellungen. Er beweist nicht,
dass ein Profil fuer einen bestimmten Rechner betrieblich sicher ist.
Adapter-Namen, Exclusions und Dry-Run-Logs sollten geprueft werden, bevor echte
Network-Isolation-Aenderungen aktiviert werden.

## Haeufige Aenderungen

Um ein harmloses Testprofil hinzuzufuegen, kann ein vorhandenes Profil kopiert
und `id`, `displayName` und `modules` angepasst werden:

```json
{
  "id": "maintenance",
  "displayName": "Maintenance",
  "bootMenu": {
    "enabled": true
  },
  "modules": {
    "validation-log": {}
  },
  "scripts": []
}
```

Um ein Profil in der Konfiguration zu behalten, aber nicht im Bootmenue
anzuzeigen, wird gesetzt:

```json
"bootMenu": {
  "enabled": false
}
```

Um Network Isolation zu testen, ohne Adapter zu veraendern, bleibt:

```json
"dryRun": true
```

Um nach erfolgreicher Validierung echte Network-Isolation-Aenderungen zu
erlauben, wird gesetzt:

```json
"dryRun": false
```

`dryRun = false` sollte nur in der dedizierten Network-Isolation-Demo oder in
einer fuer den Zielrechner geprueften Konfiguration verwendet werden.

## Troubleshooting

Wenn die Validierung fehlschlaegt, sollte das `errors`-Array in der JSON-Ausgabe
gelesen werden. Haeufige Ursachen sind doppelte `id`-Werte, doppelte
`displayName`-Werte, ungueltige Profil-IDs, unbekannte Modulnamen oder ein
`displayName` unter `bootMenu.defaultEntry`, obwohl `rename` auf `false` steht.

Wenn ein Profil nicht im Bootmenue erscheint, sollte
`profiles[].bootMenu.enabled` geprueft werden.

Wenn ein Profil im Bootmenue erscheint, aber kein Modul laeuft, sollte geprueft
werden, ob die Profil-ID aus dem Resolver-State zu einer konfigurierten Profil
`id` passt. Ausserdem sollte `logs/startup-profile.log` auf
`dispatchSkippedReason` geprueft werden.

Wenn Network Isolation keine Adapter deaktiviert, sollte geprueft werden, ob
`dryRun` noch auf `true` steht. Die Detailentscheidungen stehen in
`logs/module-actions.log`.

Wenn Network Isolation Adapter unerwartet deaktiviert hat, sollte im
Demo-Szenario `uninstall-network-isolation-demo.cmd` verwendet werden. Wenn der
Lifecycle-State nicht mehr vorhanden ist, muss der Adapterzustand eventuell
manuell in Windows wiederhergestellt werden.

## Beispiel

Die v2-Beispielkonfiguration liegt hier:

```text
config/profiles.v2.example.json
```

Der aktuelle Runtime-Pfad verwendet den installierten `profiles.json`-Pfad und den bestehenden Startup-Ablauf. Die Bootmenue-Installation liest v2 standardmaessig von diesem maschinenweiten Pfad oder ueber einen ausdruecklichen `-ConfigPath`-Override fuer Demos, Tests und Migrationen.
