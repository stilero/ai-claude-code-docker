---
allowed-tools: Task, Read, Write, WebSearch, WebFetch, TodoWrite
description: Design an Angular 20+ feature from Azure DevOps Work Item (MCP fetch) OR user prompt, producing a standalone components spec for angular-expert. Optionally integrate Figma designs using figma-expert.
argument-hint: --work-item=<id> [--figma-url=<figma-url>] OR --prompt="<instructions>" [--figma-url=<figma-url>] [--output=<dir>]
required-agents: orchestrator, angular-expert, figma-expert
agent-execution-pattern: sequential
minimum-task-calls: 3
---

# Design Angular Feature From Work Item or Prompt (+ Optional Figma)

Create a complete **design specification** for an Angular 20+ feature using either:
- **Azure DevOps MCP** to fetch the work item by ID, OR
- **Direct user prompt** with feature instructions

Then have `angular-expert` produce a single file design per your standalone components architecture. Optionally integrate Figma designs using `figma-expert` to extract visual specifications, design tokens, and component details.

## ⚠️ Constraints

- **Two input modes**:
  - **Work Item mode** (`--work-item`): Use Azure DevOps MCP server to read the Work Item:
    - `WorkItems.Read(id)` – fetch title, description, fields, linked items (parents/children/related), attachments (acceptance criteria)
  - **Prompt mode** (`--prompt`): Use user-provided instructions directly
- **Optional Figma Integration**: If `--figma-url` is provided (works with both modes), parse the URL to extract fileKey and nodeId, then use Figma Dev Mode MCP:
  - Figma URL format: `https://www.figma.com/file/{fileKey}/{title}?node-id={nodeId}` or `https://www.figma.com/design/{fileKey}/{title}?node-id={nodeId}`
  - `get_screenshot` – capture visual references
  - `create_design_system_rules` – extract design tokens
  - `get_code` – get CSS/style suggestions
  - `get_metadata` – extract component properties and dimensions
- **Orchestrator role is limited**:
  - **Phase 1**: Setup folders and capture raw ADO payloads
  - **Phase 2a** (if Figma): Delegate to `figma-expert` for design analysis
  - **Phase 2b**: Delegate design to `angular-expert`
  - **Phase 3**: Synthesis and validation
- **Output**: design files for the feature:
  - `.claude/outputs/design/agents/angular-expert/[feature-key]-[timestamp]/angular-feature-design.md`
  - `.claude/outputs/design/agents/figma-expert/[feature-key]-[timestamp]/*` (if Figma params provided)

**Required Execution Pattern (without Figma):**
```bash
Phase 1: Task(orchestrator) - Setup only
Phase 2: Task(angular-expert) - Design spec
Phase 3: Task(orchestrator) - Synthesis
Total Task calls: 3 (minimum)
```

**Required Execution Pattern (with Figma):**
```bash
Phase 1: Task(orchestrator) - Setup only
Phase 2a: Task(figma-expert) - Extract design specs
Phase 2b: Task(angular-expert) - Design spec (using Figma output)
Phase 3: Task(orchestrator) - Synthesis
Total Task calls: 4 (minimum)
```

## Usage

**Work Item mode:**
```bash
# Basic usage with Azure DevOps Work Item only
/design-angular-feature --work-item=12345

# With Figma design integration
/design-angular-feature --work-item=12345 --figma-url="https://www.figma.com/design/abc123xyz/MyProject?node-id=456-789"

# With custom output directory
/design-angular-feature --work-item=987 --output=.claude/outputs/design/custom
```

**Prompt mode:**
```bash
# Basic usage with user prompt
/design-angular-feature --prompt="Create a product catalog feature with search, filters, and shopping cart integration"

# With Figma design integration
/design-angular-feature --prompt="Build a user dashboard with analytics charts and notification center" --figma-url="https://www.figma.com/file/abc123xyz/Dashboard?node-id=456-789"

# With custom output directory
/design-angular-feature --prompt="Implement a settings page with profile management and preferences" --output=.claude/outputs/design/custom
```

## Phase 1 — Orchestrator (Requirements capture + setup)

**You (Claude Code)** call:

**For Work Item mode (`--work-item`):**
```
Task(orchestrator):
"Using Azure DevOps MCP, fetch Work Item by id=$WORK_ITEM, including linked items (parents, children, related) and attachments.
Create folder `.claude/outputs/design/projects/[feature-key]/[timestamp]/`.
Write raw JSON files:
- work-item.json
- linked.json (if any)
- attachments.json (if any)
If --figma-url is provided, parse the URL to extract fileKey and nodeId:
  - URL format: https://www.figma.com/{file|design}/{fileKey}/{title}?node-id={nodeId}
  - Extract fileKey from the URL path (between /file/ or /design/ and the next /)
  - Extract nodeId from the query parameter node-id (replace hyphens with colons, e.g., '456-789' becomes '456:789')
  - Save to figma-params.json:
    {
      \"figmaUrl\": \"$FIGMA_URL\",
      \"fileKey\": \"extracted-file-key\",
      \"nodeId\": \"extracted-node-id\"
    }
Create MANIFEST.md that lists the fetched resources, normalized 'Feature Key' (e.g., WI-12345-<slug>), and note if Figma URL was provided and parsed.
DO NOT perform design."
```

**For Prompt mode (`--prompt`):**
```
Task(orchestrator):
"Using the user-provided prompt: '$PROMPT'
Create folder `.claude/outputs/design/projects/[feature-key]/[timestamp]/`.
Write requirements.md containing the user's instructions.
If --figma-url is provided, parse the URL to extract fileKey and nodeId:
  - URL format: https://www.figma.com/{file|design}/{fileKey}/{title}?node-id={nodeId}
  - Extract fileKey from the URL path (between /file/ or /design/ and the next /)
  - Extract nodeId from the query parameter node-id (replace hyphens with colons, e.g., '456-789' becomes '456:789')
  - Save to figma-params.json:
    {
      \"figmaUrl\": \"$FIGMA_URL\",
      \"fileKey\": \"extracted-file-key\",
      \"nodeId\": \"extracted-node-id\"
    }
Create MANIFEST.md that lists the prompt-based requirements, normalized 'Feature Key' (e.g., PROMPT-[timestamp]-<slug>), and note if Figma URL was provided and parsed.
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

## Phase 2a — figma-expert (Design extraction) [OPTIONAL - Only if Figma params provided]

**You (Claude Code)** call:

```
Task(figma-expert):
"Read MANIFEST.md and figma-params.json from the project folder.
Using the Figma Dev Mode MCP server with the provided fileKey and nodeId:
1. Use get_screenshot to capture visual references of the design
2. Use create_design_system_rules to extract design tokens (colors, typography, spacing, shadows, etc.)
3. Use get_code to get CSS and style suggestions for the components
4. Use get_metadata to extract precise component properties, dimensions, and structure

Create comprehensive design documentation in `.claude/outputs/design/agents/figma-expert/[feature-key]-[timestamp]/`:
- design-system.md - Design tokens extracted from Figma (colors, typography, spacing, shadows, borders)
- components-spec.md - Component specifications with Angular mappings (inputs, outputs, states, variants)
- layouts-spec.md - Layout structure and responsive behavior
- implementation-guide.md - Step-by-step guide for implementing the Figma design in Angular
- assets/ - Save all screenshots captured from Figma

Ensure all specifications are Angular-ready with:
- Standalone component structure
- Signal-based state management patterns
- TypeScript interfaces for props
- Responsive breakpoints and behavior
- Accessibility requirements (ARIA, semantic HTML)
- All measurements and values extracted directly from Figma metadata"
```

## Phase 2b — angular-expert (Design spec)

```
Task(angular-expert):
"Read MANIFEST.md and requirements source (raw ADO JSON for Work Item mode, OR requirements.md for Prompt mode).
If Figma design specs exist (check `.claude/outputs/design/agents/figma-expert/[feature-key]-[timestamp]/`), integrate them into the design:
- Use design-system.md for theming and CSS custom properties
- Reference components-spec.md for component structure and props
- Follow layouts-spec.md for page structure and responsive patterns
- Incorporate implementation-guide.md recommendations

Produce **one** file `angular-feature-design.md` with:
1) Context & goals – distilled from Work Item (and linked items if provided)
2) Component architecture – standalone components, smart vs presentational, routing structure
3) State management – signals, RxJS observables, service state, route params/query handling
4) Forms & validation – typed reactive forms, validators, error handling
5) Services & data layer – HttpClient services, interceptors, error handling, caching strategies
6) Routing & guards – route definitions, guards (canActivate/canDeactivate), resolvers
7) UI/UX patterns – layout, responsive design, accessibility (ARIA, keyboard nav), loading states
8) API integration – endpoints, DTOs/interfaces, request/response handling, auth tokens
9) Security – authentication guards, role-based access, XSS prevention, secure token storage
10) Performance – lazy loading, OnPush change detection, trackBy, virtual scrolling
11) Testing strategy – unit tests (Jasmine/Jest), component tests, service tests, E2E (Cypress/Playwright)
12) Observability – error tracking, analytics events, performance metrics
13) Implementation checklist – actionable todo list (TodoWrite) with estimates
Ensure all code examples use Angular 17-20+ patterns: standalone components, signals where appropriate, typed forms, and inject() function."
```

## Phase 3 — Orchestrator (Synthesis)

```
Task(orchestrator):
"Review angular-expert output and figma-expert output (if present). Verify:
- Requirements (from Work Item OR prompt) are addressed
- All linked items/dependencies noted (if Work Item mode)
- If Figma was used: design system tokens are incorporated, component specs align with Figma designs
- Test coverage aligns with acceptance criteria
- TodoWrite checklist is complete
Create final summary in MANIFEST.md with links to all design files (angular-feature-design.md and Figma specs if applicable)."
```

## Deliverables

**Work Item mode:**
- `.claude/outputs/design/projects/[feature-key]/[timestamp]/MANIFEST.md`
- `.claude/outputs/design/projects/[feature-key]/[timestamp]/raw/*.json` (work-item, linked, attachments)
- `.claude/outputs/design/agents/angular-expert/[feature-key]-[timestamp]/angular-feature-design.md`

**Prompt mode:**
- `.claude/outputs/design/projects/[feature-key]/[timestamp]/MANIFEST.md`
- `.claude/outputs/design/projects/[feature-key]/[timestamp]/requirements.md`
- `.claude/outputs/design/agents/angular-expert/[feature-key]-[timestamp]/angular-feature-design.md`

**Optional (for both modes):**
- `.claude/outputs/design/projects/[feature-key]/[timestamp]/figma-params.json` (if --figma-url provided, contains parsed fileKey and nodeId)
- `.claude/outputs/design/agents/figma-expert/[feature-key]-[timestamp]/design-system.md` (if Figma params provided)
- `.claude/outputs/design/agents/figma-expert/[feature-key]-[timestamp]/components-spec.md` (if Figma params provided)
- `.claude/outputs/design/agents/figma-expert/[feature-key]-[timestamp]/layouts-spec.md` (if Figma params provided)
- `.claude/outputs/design/agents/figma-expert/[feature-key]-[timestamp]/implementation-guide.md` (if Figma params provided)
- `.claude/outputs/design/agents/figma-expert/[feature-key]-[timestamp]/assets/*` (screenshots if Figma params provided)

## Success Criteria

- Requirements accurately reflected (from Work Item OR prompt)
- Figma design specs (if provided) accurately extracted and integrated:
  - Design system tokens match Figma variables
  - Component specs align with Figma components
  - Layout specifications reflect Figma auto-layout
  - All screenshots captured for visual reference
- Standalone components architecture with Angular 20+ patterns
- Test-first acceptance criteria captured
- Security, accessibility, and performance considered
- Clear TodoWrite tasks generated from design
- Routing and state management clearly defined
- Design tokens/theming integrated into Angular implementation plan (if Figma used)
