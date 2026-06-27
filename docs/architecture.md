# System Architecture

## Overview

BootProfile Switcher consists of a small set of independent components.

```text
Windows Boot Manager
        |
Boot Profile Selection
        |
BootProfile Engine
        |
Profile Resolver
        |
Modules
        |
Windows Configuration
```

This document intentionally describes the conceptual architecture only.
Implementation details and design decisions are documented separately in ADRs.
