# BootProfile Switcher Roadmap

## Roadmap Principles

BootProfile Switcher has completed the platform-building phase through v1.7.0.
The runtime, configuration model, lifecycle modules and unattended deployment
path are now mature enough for broader milestones that combine discovery,
design, implementation and validation.

Each milestone should still progress through small validated working commits.
The milestone boundary describes a meaningful user or operator capability, not
an individual script or research question.

## v1.8.0 - Policy and Vendor Control Foundation

### Objective

Establish a supported, reversible control foundation for Windows policy-backed
behavior and vendor-managed endpoint software. Windows Update and Bitdefender
are the first target domains.

### Intended Deliverables

- Perform read-only discovery of Windows Update policy and management surfaces
  and Bitdefender enterprise or vendor-supported control surfaces.
- Record a capability and risk matrix that distinguishes supported policy,
  vendor integration, diagnostic-only findings and unsupported direct control.
- Create or update the appropriate decision record for policy ownership,
  baseline storage, restore behavior and vendor boundaries.
- Define the configuration and module contract for allow-listed policy control.
- Implement at least one supported, reversible Windows policy path when
  discovery confirms a stable control surface.
- Integrate validation, configuration fixtures, logging, deployment and
  baseline restoration with the existing machine-wide runtime.
- Provide an example configuration or documented demonstration path.
- Document a concrete Bitdefender integration path when a supported enterprise
  interface is available, or record a validated negative result and operator
  guidance when it is not.

### Validation

- Read-only discovery must not stop services, disable security software or
  change update behavior.
- Implemented policy control must support dry-run, apply and restore.
- Baselines must be learned before modification and restored through the
  existing deployment cleanup lifecycle.
- Configuration validation must reject unknown policies, values and vendor
  targets.
- The complete path must be validated through the installed ProgramData runtime
  and an unattended deployment context.

### Non-Goals

- Do not force-stop Windows Update service groups.
- Do not bypass Windows self-healing, security controls or Bitdefender tamper
  protection.
- Do not automate consumer UI interactions as a production control surface.
- Do not claim Bitdefender control without a documented supported interface.

## v1.9.0 - Network Isolation Hardening

Strengthen the existing Network Isolation module for managed environments.
Evaluate policy-backed enforcement, firewall ownership, adapter and network UI
restrictions, device-management boundaries and resistance to user-session
re-enablement. Preserve explicit restore behavior and distinguish network
adapter isolation from full Bluetooth or device isolation.

## v1.10.0 - Search and Resource Scope Control

Refine Windows Search beyond service-level control when supported. Investigate
per-drive or path-level indexing scope, document Windows-supported management
surfaces and implement reversible allow-listed behavior only where baseline and
restore semantics are reliable.

## v1.11.0 - Operational Readiness

Consolidate production operations around status, diagnostics, drift detection,
upgrade compatibility and validation reporting. The target is a predictable
administrator workflow for determining what is installed, what profile state
is active, which baselines are owned and whether cleanup is safe.

## Later Candidates

- Full Bluetooth or device isolation as a separate module.
- Configuration inheritance or reusable module-setting defaults.
- Controlled custom-script execution with explicit trust and logging rules.
- Additional supported Windows policy or vendor integrations discovered during
  operational use.

The roadmap may change when validation produces new architectural knowledge,
but changes should be deliberate and reflected here and in
`PROJECT_CONTEXT.md`.
