---
allowed-tools: Task, Bash, Read, Write, Edit, MultiEdit, TodoWrite, Glob, Grep, GitWrite
description: Implement an Angular 17-20+ feature from an approved design spec with practical, design-first steps (standalone components). Mirrors the /implement-app workflow.
argument-hint: <design-file-path> [--repo=<path>] [--branch=<name>] [--skip-tests]
required-agents: orchestrator, angular-expert
agent-execution-pattern: sequential
minimum-task-calls: 2
---

# Implement Angular Feature From Design

Production-focused implementation of a previously approved `angular-feature-design.md`. Builds code with **standalone components**, **services**, **guards**, **interceptors**, and **tests**, following the practical workflow from `/implement-app`.

## Inputs

- `<design-file-path>` – Required. Path to `.claude/outputs/design/agents/angular-expert/[feature-key]-[timestamp]/angular-feature-design.md`
- `--repo` – Optional. Repo root (defaults to current working directory)
- `--branch` – Optional. Feature branch name (default `feat/<feature-key>`)
- `--skip-tests` – Optional. If set, postpone running tests (still generate test files)

## Phase 0 — Read Design & Prepare (orchestrator)

Task(orchestrator):
"Read the design file at <design-file-path>. Extract:
- Feature Key (e.g., WI-12345-user-profile)
- Planned components (smart/presentational), services, guards, interceptors, routes
- Models/interfaces, forms, and tests
Create output folder `.claude/outputs/implement/angular-expert/[feature-key]-[timestamp]/` with MANIFEST.md.
If --repo not provided, assume '.' as repo root.
Create a feature branch via GitWrite: feat/<feature-key> (or --branch).
"

## Phase 1 — Repo Assessment & Scaffolding (orchestrator)

- Scan repo structure with `Glob/Grep` to locate Angular project:
  - `src/app/**`, `package.json`, `angular.json`, `tsconfig.json`
- Detect Angular version from `package.json`
- Verify standalone components are supported (Angular 17+)
- Identify existing feature modules or app structure
- Check routing configuration

Create/update MANIFEST with planned file paths and app structure.

## Phase 2 — Models & Interfaces First (angular-expert)

Task(angular-expert):
"Generate TypeScript interfaces and models per design.
- DTOs for API requests/responses
- Domain models
- Form models
- Enums and constants
Place in `src/app/features/<feature-name>/models/` or `src/app/shared/models/`.
Commit: chore(models): add interfaces for <feature-key>."

## Phase 3 — Services & State Management (angular-expert)

Task(angular-expert):
"Generate services per design:
- Data services (HttpClient-based API calls)
- State services (signals or BehaviorSubjects)
- Business logic services
Include:
- Proper dependency injection with inject() function
- Error handling
- Type safety
- Caching strategies if specified
Place in `src/app/features/<feature-name>/services/` or `src/app/core/services/`.
Commit: feat(services): add data and state services for <feature-key>."

## Phase 4 — Components (Presentational First) (angular-expert)

Task(angular-expert):
"Generate presentational (dumb) components per design:
- Standalone components with explicit imports
- Input/Output properties with proper typing
- OnPush change detection
- Accessibility attributes (ARIA, role, etc.)
- Template-driven or reactive forms as designed
Place in `src/app/features/<feature-name>/components/`.
Commit: feat(components): add presentational components for <feature-key>."

## Phase 5 — Smart Components & Routing (angular-expert)

Task(angular-expert):
"Generate smart (container) components and routes:
- Standalone smart components with inject() for services
- Route definitions in routes.ts or routing config
- Route parameters and query param handling
- Lazy loading configuration if specified
- Resolvers if needed
Place smart components in `src/app/features/<feature-name>/pages/` or `containers/`.
Update main routing configuration.
Commit: feat(routing): add smart components and routes for <feature-key>."

## Phase 6 — Guards, Interceptors, and Cross-cutting (angular-expert)

Task(angular-expert):
"Add guards, interceptors, and cross-cutting concerns per design:
- Auth guards (canActivate, canActivate child)
- Form guards (canDeactivate for unsaved changes)
- HTTP interceptors (auth tokens, error handling, logging)
- Validators (custom form validators)
Place in `src/app/core/guards/`, `src/app/core/interceptors/`, `src/app/shared/validators/`.
Register interceptors in app config (provideHttpClient with interceptors).
Commit: feat(guards): add guards and interceptors for <feature-key>."

## Phase 7 — Tests (angular-expert)

Task(angular-expert):
"Add tests per design:
- Component unit tests (.spec.ts files) with TestBed
- Service unit tests with HttpClientTestingModule
- Integration tests for complex flows
- Mock dependencies with jasmine.createSpyObj or jest.fn()
- Test accessibility with axe-core if specified
Follow AAA pattern (Arrange, Act, Assert).
Commit: test: add unit and integration tests for <feature-key>."

## Phase 8 — Build & Validate (orchestrator)

- If not `--skip-tests`, run:
  - `npm install` (or `yarn install` or `pnpm install`)
  - `npm run lint` (or equivalent)
  - `npm run test -- --code-coverage` (or `ng test --code-coverage --watch=false`)
  - `npm run build` (or `ng build`)
- Check for TypeScript errors, linting issues, and test failures
- Update MANIFEST with build/test results
- Record coverage metrics (path in MANIFEST)

## Phase 9 — Observability & Security Touches (angular-expert)

Task(angular-expert):
"Ensure observability and security per design:
- Error tracking integration (if specified, e.g., Sentry, Application Insights)
- Analytics events for key user actions
- Performance monitoring markers
- Secure token storage (sessionStorage/localStorage with encryption if needed)
- XSS prevention (DomSanitizer where necessary)
- Input validation and sanitization
Commit: chore(observability/security): wire tracking and auth for <feature-key>."

## Phase 10 — Finalize & Todos (orchestrator)

- Create a concise `CHANGELOG` entry fragment in output folder
- Produce a `TodoWrite` with deployment/config follow-ups:
  - Environment variables (API endpoints, feature flags)
  - E2E tests (Cypress/Playwright)
  - Accessibility audit
  - Performance testing
  - Documentation updates
- Update MANIFEST with:
  - Final file map
  - Commit SHAs
  - Next steps

## Practical Guidance (from /implement-app philosophy)

- **Design as source of truth** – no scope beyond the design.
- **Functional first** – ship working code; add tests for critical paths.
- **Atomic commits** – small, conventional messages per slice.
- **No secrets** – use environment files; never commit API keys or tokens.
- **Component isolation** – presentational components have no service dependencies.
- **Type safety** – strict TypeScript, no `any` types without justification.
- **Accessibility** – keyboard navigation, ARIA labels, semantic HTML.
- **Performance** – OnPush, trackBy, lazy loading, avoid unnecessary subscriptions.

## Usage Examples

```bash
# Default usage (auto branch)
/implement-angular-feature .claude/outputs/design/agents/angular-expert/WI-12345-user-profile-20250910/angular-feature-design.md

# Custom branch and repo
/implement-angular-feature .claude/outputs/design/agents/angular-expert/WI-9876-dashboard-20250910/angular-feature-design.md --repo=./frontend --branch=feat/WI-9876-dashboard

# Skip tests (fast iteration)
/implement-angular-feature .claude/outputs/design/agents/angular-expert/WI-5555-search-20250910/angular-feature-design.md --skip-tests
```

## Success Criteria

- Code compiles; tests pass (unless --skip-tests)
- Files created exactly as in design; standalone components with proper imports
- TypeScript strict mode passes
- Linting passes
- Accessibility considerations implemented
- Security and observability match design
- MANIFEST and TodoWrite clearly list next actions
