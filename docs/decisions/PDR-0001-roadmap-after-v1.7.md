# PDR-0001: Broaden the Roadmap After v1.7.0

Status: Accepted
Date: 2026-07-16

## Context

The early BootProfile Switcher roadmap intentionally separated architecture,
proof-of-concept validation, configuration, individual modules and deployment
into narrow milestones. That reduced uncertainty while the runtime and
lifecycle model were still being established.

After v1.7.0, the project has a validated configuration-driven engine,
reversible lifecycle modules and an unattended machine-wide deployment path.
A discovery-only v1.8.0 would no longer deliver enough operator capability for
a meaningful minor-version milestone.

## Decision

Broaden v1.8.0 from `Policy and Vendor Control Discovery` to
`Policy and Vendor Control Foundation`.

The milestone will combine:

- read-only discovery for Windows Update and Bitdefender;
- a capability and risk classification;
- a durable control-surface decision;
- policy-module and configuration design;
- at least one supported reversible Windows policy implementation when
  discovery confirms a stable interface;
- deployment, baseline-restore and example-path validation;
- a supported Bitdefender integration path or a validated negative result with
  operator guidance.

Later work is separated into substantial capability milestones for Network
Isolation hardening, Search and Resource Scope Control, and Operational
Readiness.

## Rationale

The platform can now support broader vertical milestones without sacrificing
the small-step validation rhythm. The broader scope produces a useful operator
capability while preserving discovery as the safety gate for policy and vendor
control.

## Consequences

- v1.8.0 is no longer complete after inventory and documentation alone.
- Discovery findings must drive an explicit implementation or non-support
  decision.
- Working commits remain small and validated even though the milestone is
  broader.
- The active roadmap is maintained in `docs/roadmap.md`; `PROJECT_CONTEXT.md`
  summarizes only the current state and next step.
- Direct service stopping, tamper-protection bypass and unsupported UI
  automation remain out of scope.

## Alternatives considered

### Keep v1.8.0 discovery-only

Rejected because the project foundation is mature enough to deliver a
validated policy capability in the same milestone.

### Combine all remaining hardening into v1.8.0

Rejected because Windows Update policy, Bitdefender management, Network
Isolation enforcement and Search indexing scope have different ownership,
risk and validation models.

## Follow-up

- Begin v1.8.0 with a read-only support matrix.
- Check whether the implementation decision requires a new ADR for the policy
  module boundary and baseline model.
- Keep `README.md`, `README.de.md`, `PROJECT_CONTEXT.md` and
  `docs/roadmap.md` aligned when the discovery result changes scope.
