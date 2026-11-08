# Coherent commit packages

Use this assessment whenever `commit-changes` or `commit-milestone` is invoked,
before changing staging. Assess each repository independently from its permitted
staged and unstaged changes and selected untracked files.

## Choose the grouping

Group by purpose, behavior or accepted idea. Keep the implementation, relevant
documentation and validation together. Identify dependencies and order packages
so each resulting commit is understandable and internally consistent on top of
its predecessors. File boundaries and line counts are not commit boundaries.
Keep one package when splitting would be artificial, misleading or produce an
invalid intermediate state. Do not rewrite existing history to improve grouping.

Briefly explain the chosen package(s), selected paths or hunks, dependency order
and relevant evidence before staging. For one coherent change, one sentence is
enough; do not impose a fixed number of commits or a separate planning artifact.

Apply existing repository/action-specific authority only where it covers the
whole proposed sequence and selection. A scoped authorization may cover several
packages for that task; it is not standing authority. Honor an explicit single
commit, exact selection and all push/tag exclusions. Ask only for missing
authority or a consequential choice; assessment itself grants no Git action.

## Preserve and verify the selection

Preserve existing staging and unrelated working-tree changes. When independent
changes share a file, stage exact reviewed hunks only where safely separable.
Do not stage the whole file merely for convenience, temporarily remove working
changes, or silently unstage another selection. If the proposed package cannot
coexist with the existing index, resolve that selection with the maintainer
before mutation. A useful combined package is preferable to an unsafe split.

Before each commit, inspect the complete staged diff against the intended
package, including pre-existing staged content and omissions. Assess that
candidate tree with its predecessors, not only the combined working tree:
unstaged changes can hide missing dependencies. Use proportionate source review
or targeted checks for each package; evidence from the full working tree alone
does not validate an intermediate commit. Reuse evidence only for unchanged
governed inputs. Verify each resulting commit and the remaining selection.

Several commits may share one final normal push under the existing upstream
authority. If a package fails, retain completed commits and remaining work,
report partial progress and diagnose the gap; do not reset, rebase, amend or
otherwise rewrite history without separate authority.

## Milestone closure

Assess separable implementation packages before the final milestone closure.
Use ordinary message and targeted-validation rules for those packages. Keep
version, release changelog and completion metadata coherent on the final closure
commit; earlier package documentation must remain true at its own state.
Comprehensive applicable milestone validation must cover the exact completed
candidate tree after all milestone inputs are stable, including closure metadata.
Recheck affected evidence if package preparation changes that tree.

Create only the intended milestone tag at the verified final closure commit,
never at an intermediate package. Packages do not each become a release, and no
empty closure commit is required merely to manufacture an extra package. Retain
the skill's exact branch/tag push, exclusions and historical-backfill rules.

## Domain boundaries

Keep code, dependency/configuration changes and relevant tests coherent. A
later package must not supply a missing prerequisite that makes an earlier
commit fail its applicable engineering checks.
