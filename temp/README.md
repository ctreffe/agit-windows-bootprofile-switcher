# Temporary Working Files

Git worktrees are an exception to the intermediate-file rules below: their
container is ignored by the parent checkout, while source commits inside follow
normal repository rules. Exclude worktrees from generic cleanup and do not move
them to materials/ as scratch. See [the worktree contract](../COLLABORATION.md#project-anchor-and-temporary-worktrees).

`temp/` contains disposable intermediate engineering files. All contents
outside `restricted/` are assistant-readable. Everything under `temp/` is
local-only, ignored by Git and must never be versioned.

Use `restricted/` for temporary files that assistants must not enumerate or
read. Temporary files are not cataloged. Promote a durable file to
`materials/`, source, tests, fixtures or configuration as appropriate and
preserve its provenance.
