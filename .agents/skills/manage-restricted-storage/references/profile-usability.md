# Required workflow usability

Use during selected protection-profile setup, after the active scope is
confirmed. Reuse current evidence for the same device, runtime, profile and
route. Ordinary task entry does not run this procedure.

## Select and qualify the needed operations

Derive a short capability list from the project's actual work: authenticated
Git read/fetch/push when used, selected runtimes, required rendering formats and
local previews. Use invented inputs and existing tools. Respect the local domain
contract. Record PASS, FAIL, NOT_TESTED or NOT_APPLICABLE for each operation, its
context and evidence. Preserve failed attempts. Ask only for missing authority;
the setup invocation does not itself authorize credentials or remote writes.

Qualify the original operation in the intended Desktop chat. A successful shell,
network request, SSH handshake or read does not establish fetch/push. An external
CLI test is component evidence. For approved remote write trials, use one absent temporary
ref at an already published commit, verify it independently, delete only that
owned ref with an expected-value guard, and verify absence. Preserve main, HEAD,
index and profile bytes. Consider hooks/workflows before any remote test.

Keep setup pending while a required capability is failed or untested. An explicit
maintainer decision may exclude it. A ready adapter and a selected profile are
separate from accepted operation. Retain recoverable previous settings and exact
owned artifacts; on failure restore only the owned delta without removing denies.
Mark affected evidence stale after relevant runtime/profile/route changes.

Use the existing ignored `RESTRICTED_STORAGE.local.md` for one compact table:
operation and required/excluded status; device/runtime/profile/route; result
and evidence; adapter/original settings/recovery pointer; missing authority
and next step. Never include credentials or protected-source details.

## Windows Git compatibility

Retain the complete accepted invocation under
[GIT_TRANSPORT.md](../../../../GIT_TRANSPORT.md), including the command
launcher as well as authentication. Link the existing local capability
table and approved bindings instead of duplicating them. Qualify required
local metadata operations (staging, commit and tag as applicable) separately
from transport, with their own exact authority and result verification.
The remote-only trial above preserves HEAD/index; it cannot qualify those
local writes. An authorized real workflow can supply their acceptance.

If MSYS reports `NtCreateDirectoryObject` / `0xC0000022`, compare the fixed shell
startup separately from networking and authentication. Read-deny profiles can
retain AppContainer containment after approval; a skill or allow rule is not an
escape identity. Direct Credential Manager can separately fail to access its
Windows credential store. Do not disable protection to make the test pass.

For an authorized GitHub project whose local credential policy permits it,
prepare a native OpenSSH adapter from
[the source asset](../assets/native_git_ssh.cs). Replace the single
`__APPROVED_OWNER__/__APPROVED_REPOSITORY__.git` literal with the verified origin's
owner/repository; accept only ASCII letters, digits, hyphen, underscore and dot
in each component, excluding `.` and `..`. Review the generated source and compile
with the installed Windows C# compiler into an ignored, approved local deployment
directory. Do not install a compiler silently. The executable path used by
`core.sshCommand` must contain no spaces or shell metacharacters; otherwise this
route needs a separately qualified invocation method.

The adapter accepts only that repository's upload-pack/receive-pack at GitHub,
uses the native Windows OpenSSH executable, and forwards binary streams with
per-chunk flushing. It stays in the caller's sandbox. Its directory must contain
`id_ed25519` and `known_hosts`. Pin the host key from GitHub's official current
fingerprint documentation; never learn trust from an unauthenticated scan alone.
Reject unexpected host, repository, command and options; verify missing-setup
failure before deployment. Retain source/binary hashes and recovery state locally.

Prepare a concrete repository-specific credential/configuration proposal. Reuse
existing suitable approved authentication where possible. A new unattended,
passwordless deploy key is a durable credential requiring explicit project
approval, minimum required repository permissions and a revocation plan. Never
print or version the key. Ignore status is not a confidentiality boundary.
Preserve the original values of `remote.origin.url`, `core.sshCommand` and
`ssh.variant`; change only those approved local keys. Use the exact SSH origin,
adapter executable and `ssh` variant, then qualify the actual read/fetch/write
workflow. On failure restore those values, revoke only the newly owned key and
remove only owned deployment files. Do not change global Git/SSH or services.

This route does not cover LFS, submodules, commit signing, other hosts or devices.
Never import this credential arrangement into a project with operator-only
credentials. Such a project needs its own compliant transport design and
acceptance; leave credentialed capability pending until then.

## Native tool cache compatibility

For LuaLaTeX's `no writeable cache path` failure, use an approved ignored writable
project cache and set `TEXMFVAR` and `TEXMFCACHE` only in the render child process.
Do not widen home/global write access or install TeX packages as a workaround.
Retry the same invented render with automatic package installation disabled.
Cache files inherit the sensitivity of their inputs; this procedure qualifies
only the explicitly approved non-sensitive render. Other runtimes need their
own exact error, bounded correction and original-operation acceptance.

## Sources and scope

The native Git route and local TeX-cache correction were qualified on Windows
in November 2026. Recheck the installed runtime rather than assuming all versions
behave alike. Local process profiles do not qualify connectors, browser, MCP,
computer-use or cloud isolation.

- [GitHub SSH host fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
- [GitHub deploy keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys)
- [TeX Live cache variables](https://www.tug.org/texlive/doc/texlive-en/texlive-en.html)
- [Codex Windows Git issue](https://github.com/openai/codex/issues/54449)
