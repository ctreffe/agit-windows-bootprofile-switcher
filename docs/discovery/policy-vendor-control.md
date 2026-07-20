# Policy and Vendor Control Discovery

## Status

Discovery scope and read-only inventory tooling prepared for v1.8.0. No local
inventory has been collected or approved for Git.

## Objective

The first v1.8.0 step determines which supported control surfaces are available
for Windows Update policy and Bitdefender-managed endpoint software. Discovery
must precede module, configuration and baseline design.

The output will later support a capability and risk matrix with these classes:

- `supported-policy`
- `supported-vendor-integration`
- `diagnostic-only`
- `unsupported-direct-control`
- `not-determined`

Local observations and claims from official Microsoft or Bitdefender material
must be recorded separately. Finding a registry key, service, task or executable
does not prove that changing it is supported.

## Safety Boundaries

Discovery must not:

- change Windows Update policy or update behavior;
- stop, start, disable or reconfigure services;
- modify Scheduled Tasks or registry values;
- invoke update scans or vendor maintenance actions;
- inspect Bitdefender configuration values, credentials, tokens or protected
  data;
- automate a consumer UI or bypass Bitdefender tamper protection;
- infer support from the mere presence of an implementation detail.

Windows Update services are diagnostic context only. They are explicitly not
service-control candidates for this milestone.

## Inventory Script

The read-only entry point is:

```text
scripts/Inspect-PolicyVendorControlTargets.ps1
```

The script writes only to standard output and does not create a report file.
Without `-AsJson`, it prints counts rather than detailed item data:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Inspect-PolicyVendorControlTargets.ps1
```

Detailed structured output is available for local review:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Inspect-PolicyVendorControlTargets.ps1 -AsJson
```

Policy value data is omitted by default because it may contain internal update
server URLs or other environment details. Include it only for a separately
approved local review:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Inspect-PolicyVendorControlTargets.ps1 -AsJson -IncludePolicyValues
```

Windows version, build and PowerShell version are also omitted by default.
`-IncludeEnvironmentMetadata` adds them when they are needed to interpret
support documentation.

The switches affect disclosure only. They do not enable state changes.

## Collected Surfaces

### Windows Update

- metadata for the machine Windows Update Group Policy registry locations;
- metadata for the effective Policy Manager Update location when present;
- state and startup mode of known update-related services as diagnostic context.

Registry value names and types are collected. Value data is included only with
`-IncludePolicyValues`.

### Bitdefender

- matching installed-product names, versions and publishers from machine
  uninstall registration;
- matching service names, display names, state and startup mode;
- matching Scheduled Task names and paths;
- presence of native and WOW6432 Bitdefender registry roots without enumerating
  their values.

Paths, service accounts, uninstall commands and raw vendor configuration are
intentionally omitted. The script does not decide whether a local or centrally
managed control interface is supported.

## Sensitive Output and Artifact Rules

Even read-only output may fingerprint a device or expose internal management
details. Raw output remains local and outside Git by default. Before inspection,
versioning or publication, treat these as separate maintainer decisions:

1. whether the assistant may inspect the raw output;
2. whether a sanitized derivative may be added to Git;
3. whether any artifact may be published externally.

Prefer a manually reviewed support-matrix derivative that removes machine,
user, tenant, domain, internal URL and installation-specific identifiers. An
automated scan is a warning mechanism, not evidence that an artifact is safe.

## Validation Before Local Execution

The repository-side validation for this first step is limited to:

- PowerShell parser validation;
- review that the script contains no state-changing cmdlets or report-file
  output path;
- documentation and local-link checks.

Actual execution is a separate validation step because its output may contain
sensitive environment metadata. Running the count-only view first is the
preferred local sequence.

## Expected Next Result

After an approved local run, create a sanitized findings document and support
matrix. Then verify candidate control surfaces against current official
Microsoft and Bitdefender documentation. Only after that evidence exists should
the project decide the policy-module boundary, configuration contract, baseline
ownership and first reversible Windows policy implementation.
