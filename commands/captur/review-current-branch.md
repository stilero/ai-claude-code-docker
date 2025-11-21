---
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep, GitWrite, TodoWrite, WebSearch, WebFetch
description: Review code changes in the current Git branch versus a base branch (default: main) using the pull-requests-expert agent. Produces a concise review with blockers/high/nits, suggested line comments, and a merge checklist.
argument-hint: [--base=<branch|main>] [--max-diff-kb=<size|1800>] [--gilfoyle] [--uncommitted] [--work-item=<id>] [--output=<dir>]
required-agents: orchestrator, pull-requests-expert
agent-execution-pattern: sequential
minimum-task-calls: 2
---

# Review Current Branch vs Base (pull-requests-expert)

Runs an expert code review on the **current Git branch** compared to a base branch (default `main`), using the **pull-requests-expert** agent. Outputs a self-contained review package and (optionally) prepares line comments that you can paste into a PR.

## Inputs
- `--base` – Base branch name; defaults to `main`
- `--max-diff-kb` – Safety cap on diff size fed to the model (default 1800KB). If exceeded, the orchestrator chunks by file type and size.
- `--gilfoyle` – If set, enables the agent’s sardonic "Gilfoyle" tone
- `--uncommitted` – If set, review only staged + unstaged uncommitted changes (ignores commits vs base)
- `--work-item` – Optional Azure DevOps Work Item ID. If set, orchestrator will fetch Work Item details using DevOps MCP and include context (title, description, acceptance criteria, links) in MANIFEST.md
- `--output` – Custom output directory. Defaults to `.claude/outputs/reviews/pull-requests-expert/[repo]-[branch]-[timestamp]/`

## Phase 0 — Collect Diff & Context (orchestrator)

Task(orchestrator):
"""
- Detect current branch: `git rev-parse --abbrev-ref HEAD`
- Verify base branch exists; if missing locally, `git fetch --all --prune`
- If `--uncommitted`, generate a unified diff of working directory:
  `git diff --unified=3 --minimal`
- Else, generate a diff vs base branch:
  `git diff --unified=3 --minimal origin/${BASE:=main}...HEAD`
- If diff size > --max-diff-kb, split by file groups (.cs, .csproj, .yml/.yaml, .ts/.tsx/.html/.scss, .json, other). Write chunked files.
- Collect changed file list with `git diff --name-status` (or uncommitted version).
- If `--work-item` provided, fetch details from Azure DevOps MCP (WorkItems.Read(id)), including title, description, acceptance criteria, and linked items. Save as `work-item.json`.
- Create output dir `.claude/outputs/reviews/pull-requests-expert/[repo]-[branch]-[timestamp]/`
- Write:
  - `DIFF.patch` (or chunked)
  - `FILES.txt` (name-status)
  - `MANIFEST.md` (repo, branch, base, flags, counts, chunking, warnings, work-item summary if any)
Do NOT perform the review in this phase.
"""

## Phase 1 — Expert Review (pull-requests-expert)

Task(pull-requests-expert):
"""
Read MANIFEST + diff files (and work-item.json if present). Produce ONE markdown file `review.md` with:
1) Snapshot – branch, base, size (files/lines), change type(s), risk level
2) Work Item context (if available) – ID, title, description, acceptance criteria
3) Architecture & Boundaries – Clean architecture checks, DDD layer placement, eventing, multi-tenancy impact (if .NET)
4) Correctness & Reliability – async, cancellation, idempotency, culture/time, error handling
5) Security – secrets, authZ scopes/roles, input validation, token handling
6) Data & EF Core – configurations in Infrastructure, projections/AsNoTracking, migrations (if applicable)
7) Performance – N+1 risks, indexes, allocations, HTTP retries/backoff
8) Frontend/MAUI – Angular/Mobile checks if those files changed
9) CI/CD – pipeline/task changes, coverage, Sonar, approvals/rollback
10) Findings – grouped as **Blockers**, **High**, **Nits**, each with file/line hints if available
11) Suggested Fixes – minimal diffs/snippets that respect layering
12) Merge Checklist – short, actionable list
If `--gilfoyle` was provided, adopt the Gilfoyle tone without sacrificing accuracy.
"""

## Phase 2 — Optional Line Comments & Todos (pull-requests-expert)

Task(pull-requests-expert):
"""
Generate `line-comments.md` containing suggested inline comments with file:line anchors when deducible from the diff. Also generate `todos.md` with a prioritized TODO list.
"""

## Outputs
- `MANIFEST.md` – metadata, inputs, and limits used
- `DIFF.patch` (or chunked files) – exact reviewed diff
- `FILES.txt` – name-status list
- `work-item.json` – if `--work-item` provided
- `review.md` – the main expert review
- `line-comments.md` – pasteable inline comments
- `todos.md` – prioritized follow-up list

## Notes
- This command works without an open PR. It reviews the local branch vs base or uncommitted changes.
- To post to an ADO PR, use a bot step that reads `review.md` and calls ADO Threads API.
- The agent respects repo conventions; ensure .editorconfig, Directory.Build.props, and solution structure are present.

## Usage
```bash
# Review current branch vs main
/review-current-branch

# Review only uncommitted code
/review-current-branch --uncommitted

# Review against develop and include Work Item 12345
/review-current-branch --base=develop --work-item=12345

# Gilfoyle tone and custom output dir
/review-current-branch --gilfoyle --output=.claude/outputs/reviews/custom
```

## Success Criteria
- Concise and actionable `review.md` with clear Blockers/High/Nits
- Suggested line comments that map to changed files
- Merge checklist reflecting tests, migrations, secrets, rollback
- If work-item provided, context included in review
- Honors max diff size and chunking; no tool errors
