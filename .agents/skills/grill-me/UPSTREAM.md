# Upstream Provenance

- Source: https://github.com/mattpocock/skills/tree/6654f6b60cd9d5be8b54c6fafe44346dabeb3b76/skills/productivity/grill-me
- Commit: `6654f6b60cd9d5be8b54c6fafe44346dabeb3b76`
- License: MIT; see `LICENSE` in this directory.
- Local adaptation: remove only the unsupported `disable-model-invocation`
  frontmatter field from `SKILL.md` for Codex compatibility; the router body
  and pinned upstream baseline are unchanged. The separate `agents/openai.yaml`
  retains `policy.allow_implicit_invocation: false` under the Templateverse
  collaboration contract (Governance TVDR-0052).
