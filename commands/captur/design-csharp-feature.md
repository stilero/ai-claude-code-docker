---
allowed-tools: Task, Read, Write, WebSearch, WebFetch, TodoWrite
description: Design a C#/.NET 8 feature from Azure DevOps Work Item (MCP fetch) OR user prompt, producing a DDD/Clean Architecture spec for csharp-expert
argument-hint: --work-item=<id> [--org=<url>] [--project=<name>] [--repo=<name>] [--include-linked] [--output=<dir>] OR --prompt="<instructions>" [--output=<dir>]
required-agents: orchestrator, csharp-expert, maui-expert
agent-execution-pattern: sequential
minimum-task-calls: 3
---

# Design C# Feature From Work Item or Prompt

Create a complete **design specification** for a .NET 8 feature using either:
- **Azure DevOps MCP** to fetch the work item by ID, OR
- **Direct user prompt** with feature instructions

Then have `csharp-expert` produce a single file design per your DDD/Clean Architecture.

## ⚠️ Constraints

- **Two input modes**:
  - **Work Item mode** (`--work-item`): Use Azure DevOps MCP server to read the Work Item:
    - `WorkItems.Read(id)` – fetch title, description, fields
    - Also fetch: linked items (parents/children/related), attachments (acceptance criteria), and PRs if `--include-linked` is provided
  - **Prompt mode** (`--prompt`): Use user-provided instructions directly
- **Orchestrator role is limited**:
  - **Phase 1**: Setup folders and capture requirements (from ADO or prompt)
  - **Phase 2**: Delegate design to `csharp-expert` and optionally `maui-expert` if it's a MAUI application
- **Output**: exactly **one** design file for the feature:
  `.claude/outputs/design/agents/csharp-expert/[feature-key]-[timestamp]/csharp-feature-design.md`

**Required Execution Pattern:**
```bash
Phase 1: Task(orchestrator) - Setup only
Phase 2: Task(csharp-expert) +  Task(maui-expert)
Phase 3: Task(orchestrator) - Synthesis
Total Task calls: 3 (minimum)
```

## Usage

**Work Item mode:**
```bash
/design-csharp-feature --work-item=12345 --org=https://dev.azure.com/yourorg --project=MyProject --repo=smart-supply --include-linked
/design-csharp-feature --work-item=987 --output=.claude/outputs/design/custom
```

**Prompt mode:**
```bash
/design-csharp-feature --prompt="Create a Product management feature with CRUD operations, including validation, caching, and event publishing"
/design-csharp-feature --prompt="Implement an order processing system with payment integration and notification service" --output=.claude/outputs/design/custom
```

## Phase 1 — Orchestrator (Requirements capture + setup)

**You (Claude Code)** call:

**For Work Item mode (`--work-item`):**
```
Task(orchestrator):
"Using Azure DevOps MCP, fetch Work Item by id=$WORK_ITEM. If --include-linked, also fetch linked items (parents, children, related), attachments, and PRs.
Create folder `.claude/outputs/design/projects/[feature-key]/[timestamp]/`.
Write raw JSON files:
- work-item.json
- linked.json (if any)
- attachments.json (if any)
- prs.json (if any)
Create MANIFEST.md that lists the fetched resources and normalized 'Feature Key' (e.g., WI-12345-<slug>).
DO NOT perform design."
```

**For Prompt mode (`--prompt`):**
```
Task(orchestrator):
"Using the user-provided prompt: '$PROMPT'
Create folder `.claude/outputs/design/projects/[feature-key]/[timestamp]/`.
Write requirements.md containing the user's instructions.
Create MANIFEST.md that lists the prompt-based requirements and normalized 'Feature Key' (e.g., PROMPT-[timestamp]-<slug>).
DO NOT perform design."
```

### Requirements Normalization

**Work Item mode:**
- **Feature Key** = `WI-[id]-[kebab-title]`
- Extract: Title, Description, Acceptance Criteria, Business Value, Tags, Effort, Area/Iteration Path
- If acceptance criteria missing: infer from description & attachments, mark assumptions clearly

**Prompt mode:**
- **Feature Key** = `PROMPT-[timestamp]-[kebab-title]` (extract title from prompt)
- Parse prompt for: feature description, requirements, acceptance criteria
- If acceptance criteria not explicit: infer from context, mark assumptions clearly

## Phase 2 — csharp-expert (Design spec)

```
Task(csharp-expert):
"Read MANIFEST.md and requirements source (raw ADO JSON for Work Item mode, OR requirements.md for Prompt mode).
Produce **one** file `csharp-feature-design.md` with:
1) Context & goals – distilled from Work Item (and linked items if provided) OR from user prompt
2) Domain model – aggregates, value objects, invariants (Domain/Features/...)
3) Application slice – Commands/Queries, Validators, Handlers (Application/Features/...)
4) Endpoints – Azure Function or Web API endpoint definitions (FunctionApp/Features/...)
5) Persistence – EF Core entities & configurations (Infrastructure/Data/Features/...), migrations outline
6) Events – domain vs integration events, outbox/inbox, idempotency strategy
7) Security – API key/JWT, scopes/roles, tenancy propagation
8) Observability – logging, correlation/tenant IDs, metrics, failure modes
9) Test plan – unit/integration (Testcontainers), fixtures, acceptance criteria coverage
10) Implementation checklist – actionable todo list (TodoWrite) with estimates
Ensure placement comments in all code examples indicating the layer (FunctionApp / Application / Domain / Infrastructure)."
```

## Deliverables

**Work Item mode:**
- `.claude/outputs/design/projects/[feature-key]/[timestamp]/MANIFEST.md`
- `.claude/outputs/design/projects/[feature-key]/[timestamp]/raw/*.json` (work-item, linked, attachments, prs)
- `.claude/outputs/design/agents/csharp-expert/[feature-key]-[timestamp]/csharp-feature-design.md`

**Prompt mode:**
- `.claude/outputs/design/projects/[feature-key]/[timestamp]/MANIFEST.md`
- `.claude/outputs/design/projects/[feature-key]/[timestamp]/requirements.md`
- `.claude/outputs/design/agents/csharp-expert/[feature-key]-[timestamp]/csharp-feature-design.md`

## Success Criteria

- Requirements accurately reflected (from Work Item OR prompt)
- DDD/clean boundaries respected
- Test-first acceptance criteria captured
- Security and multi-tenancy considered
- Clear TodoWrite tasks generated from design
