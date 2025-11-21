---
allowed-tools: Task, Read, Write, TodoWrite
description: Design backend service architecture from PRD with API contracts, data models, security, testing, CI/CD, and observability — no UI
argument-hint: <prd-file-path>
required-agents: orchestrator, system-architect, api-backend-tester, azure-devops-pipelines-expert, azure-monitor-logs-expert, python-backend-dev, csharp-expert
agent-execution-pattern: sequential-then-parallel
minimum-task-calls: 7
---

# Backend Service Design Command

Create a comprehensive backend architecture and delivery plan from a Product Requirements Document (PRD). Focus on APIs, data models, security, testing, CI/CD, and observability. This command intentionally excludes UI.

## Critical Execution Constraints

Orchestrator usage rules:
- Phase 1: ONLY creates folders and an initial MANIFEST.md
- Phase 4: ONLY synthesizes outputs from other agents
- Do NOT ask the orchestrator to spawn agents; YOU coordinate calls

Agent invocation rules:
- Each agent MUST be called with a separate Task tool call
- Run parallelizable agents together in a single message (multiple Task calls)
- Maintain clear separation of responsibilities across agents

Required execution pattern:
```
Phase 1: Task(orchestrator) - Setup only
Phase 2: Task(system-architect) - Core backend architecture
Phase 3: Task(api-backend-tester) + Task(azure-devops-pipelines-expert) + Task(azure-monitor-logs-expert) [+ Task(python-backend-dev|csharp-expert) optional by stack] - Parallel (3–4 calls in 1 message)
Phase 4: Task(orchestrator) - Synthesis
Total Task calls: 7+ (depending on optional language specialist)
```

## Usage Examples

Analyze PRD referenced from `$ARGUMENTS`. It can be a file path or raw text.

```
# Design from PRD file (stack auto)
/design-backend --prd=docs/prd/order-service.md

# Force language stack and database
/design-backend --prd=specs/inventory/prd.md --stack=python --db=postgres

# Custom output location
/design-backend --prd=specs/billing/prd.md --output=.claude/outputs/design/projects/billing
```

Supported flags:
- `--prd` (required): Path to PRD file
- `--stack` (optional): `python` or `csharp` for language-specific sample implementation
- `--db` (optional): Preferred primary datastore (e.g., `postgres`, `sqlserver`, `mongodb`)
- `--output` (optional): Custom output directory

## PRD-Driven Backend Design

From the PRD, produce:
1. API Contracts: OpenAPI 3.1 spec covering endpoints, schemas, and error models
2. Data Models: Entity schemas, relationships, and migration strategy
3. Architecture: Services, modules, integration points, and data flow diagrams
4. Security: AuthN/Z model, secrets management, tenancy, and compliance notes
5. Testing Strategy: Contract, integration, performance, and security tests
6. CI/CD: Build, test, scan, and deploy with environments and approvals
7. Observability: Logging, metrics, tracing, dashboards, and alerting

## Streamlined Deliverables (One file per agent)

Each agent outputs exactly 1 file at a predictable location:

- system-architect: `integration-architecture.md` — service decomposition, data flow, storage, security, scalability, OpenAPI 3.1
- api-backend-tester: `test-specifications.md` — contract/integration/load/security tests with examples
- azure-devops-pipelines-expert: `cicd-pipeline.md` — CI/CD YAML plan with stages and gates
- azure-monitor-logs-expert: `observability-plan.md` — logs/metrics/tracing, KQL queries, dashboards, alerts
- python-backend-dev (optional by `--stack=python`): `python-sample-implementation.md` — minimal service skeleton and patterns
- csharp-expert (optional by `--stack=csharp`): `csharp-implementation.md` — layered architecture scaffold and patterns
- orchestrator (setup + synthesis): `MANIFEST.md` — registry linking all outputs

Output root for a project:
```
.claude/outputs/design/projects/[project-name]/[YYYYMMDD-HHMMSS]/
```
Agent outputs live under:
```
.claude/outputs/design/agents/{agent-name}/[project-name]-[YYYYMMDD-HHMMSS]/
```

## Phase Templates

Determine `[project-name]` from PRD title or domain. Use consistent timestamp.

### Phase 1 — Orchestrator Setup
```
Task(orchestrator):
"Create project root at .claude/outputs/design/projects/[project-name]/[timestamp]/
Initialize MANIFEST.md with PRD path, assumptions, non-goals, and agent outputs registry placeholders.
Do not call other agents."
```

### Phase 2 — System Architect (Backend)
```
Task(system-architect):
"Read PRD at [path]. Produce integration-architecture.md covering:
- Architecture overview and service boundaries (monolith vs service modules vs microservices)
- API surface with a complete OpenAPI 3.1 document (inline in file) and error taxonomy
- Data model diagrams and storage selections (justify), migration/versioning plan
- Security architecture: AuthN/Z, secrets, key management, tenancy, PII handling
- Performance and scalability plan: caching, partitioning, concurrency
- Reliability: retries, idempotency, outbox/inbox, DLQs, SLOs/SLIs
- Deployment topology and environments
Output to .claude/outputs/design/agents/system-architect/[project-name]-[timestamp]/"
```

### Phase 3 — Parallel Specialists

Run these Task calls together in a single message.

```
Task(api-backend-tester):
"Read PRD and integration-architecture. Produce test-specifications.md with:
- Contract tests derived from OpenAPI (request/response, error cases)
- Integration tests (DB, cache, messaging), fixtures and env setup
- Performance/load tests with baseline metrics and thresholds
- Security tests: auth flows, input validation, rate limiting, abuse, common vulns
Include pytest-oriented examples and CI integration notes.
Output to .claude/outputs/design/agents/api-backend-tester/[project-name]-[timestamp]/"

Task(azure-devops-pipelines-expert):
"Read PRD and integration-architecture. Produce cicd-pipeline.md with:
- Multi-stage YAML (Build, Test, Security Scan, Deploy: dev→stage→prod)
- Caching, artifact handling, variable/secret management, approvals
- Quality gates, test reports, and rollback strategy
Output to .claude/outputs/design/agents/azure-devops-pipelines-expert/[project-name]-[timestamp]/"

Task(azure-monitor-logs-expert):
"Read PRD and integration-architecture. Produce observability-plan.md with:
- Logging schema, correlation IDs, and sampling strategy
- Metrics (RED/USE), SLI/SLO definitions, alert thresholds
- Trace propagation strategy across services
- Example KQL queries and dashboard layout
Output to .claude/outputs/design/agents/azure-monitor-logs-expert/[project-name]-[timestamp]/"

# Optional language specialist by --stack
Task(python-backend-dev) [if --stack=python]:
"Produce python-sample-implementation.md with:
- Minimal FastAPI/HTTP service skeleton: health, readiness, version, example endpoint from OpenAPI
- Folder layout, config management, error handling, typing and docstring standards
- Example tests aligning with test-specifications
Output to .claude/outputs/design/agents/python-backend-dev/[project-name]-[timestamp]/"

Task(csharp-expert) [if --stack=csharp]:
"Produce csharp-implementation.md with:
- Layered architecture scaffold (FunctionApp/Api, Application, Domain, Infrastructure)
- Example endpoint/command aligning with OpenAPI and domain model
- Observability hooks (Serilog/App Insights), secrets, config
Output to .claude/outputs/design/agents/csharp-expert/[project-name]-[timestamp]/"
```

### Phase 4 — Orchestrator Synthesis
```
Task(orchestrator):
"Read all agent outputs. Produce a single MANIFEST.md that:
- Registers exact output files and locations
- Summarizes API surface, data stores, environments, and SLOs
- Lists open questions and risks
Do not duplicate agent plans; link to them."
```

## Execution Validation Checklist

- [ ] Task tool called 7+ times (not just once)
- [ ] Orchestrator limited to setup and synthesis only
- [ ] Phase 3 agents invoked in ONE message with parallel Task calls
- [ ] OpenAPI 3.1 spec included in system-architect output
- [ ] Test specs include contract, integration, performance, and security
- [ ] CI/CD plan covers environments, approvals, and rollbacks
- [ ] Observability includes logs, metrics, traces, dashboards, alerts

## Required Pre-Execution Summary

Before executing, output:
```
Execution Plan Summary:
Phase 1: Task(orchestrator) — Setup
Phase 2: Task(system-architect) — Backend architecture + OpenAPI
Phase 3: Task(api-backend-tester) + Task(azure-devops-pipelines-expert) + Task(azure-monitor-logs-expert) [+ language specialist] — Parallel
Phase 4: Task(orchestrator) — Synthesis (MANIFEST)
Total Task calls: 7+
Estimated completion: [time]
```

## Integration with Implementation

Outputs feed directly into backend implementation workflows (e.g., service scaffolding, contract-first generation, CI/CD setup). MANIFEST.md acts as the single registry for implementers and automation.

