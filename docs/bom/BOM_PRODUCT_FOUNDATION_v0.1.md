# Business Operations Manager (BOM): product foundation v0.1

Status: owner-requested product direction and source baseline; **not an implementation claim**.
Date: 2026-11-23. Fork baseline: `be08705f6637435795fa8e40130c67fb40a79f67`.
Product: standalone Business Operations Manager; separately embeddable as a governed JARVIS Workspace module.

## 1. Preserve the functional foundation

This fork retains upstream Paperclip's agent-company control plane: company and agent management, CEO/org structures, tasks, approvals, heartbeats, budgets, plugin/connection infrastructure, PostgreSQL storage, React UI and server. Do **not** bulk-rename `@paperclipai/*` packages, internal database identifiers, persisted keys, CLI names, environment variables, or runtime protocol names to rebrand the application. Separate product-facing branding from internal compatibility contracts through a versioned configurable branding adapter.

Upstream code is not proof that this fork passed a fresh build or real runtime test. At this baseline there were no GitHub Actions runs, commit checks or published releases on this fork. Start with an isolated local test; do not deploy to production or connect business/payment/social accounts before permissions and data boundaries pass.

## 2. One independently distributable product, two integrations

- **Standalone BOM:** one self-hosted install with its own PostgreSQL, independent identity, secrets, provider connections, data ownership, site configuration and release channel. Embedded PostgreSQL is an available local test baseline; external PostgreSQL, including Supabase-hosted PostgreSQL, is optional and requires its own tested deployment configuration.
- **JARVIS module:** an independently versioned adapter exposes BOM screens and backend capabilities through the JARVIS module SDK and a trusted, owner-scoped gateway. JARVIS remains the principal orchestrator for its own accounts, policy, primary/Hybrid model behavior, permissions, theme and releases.
- **Hosted BOM web:** same product modules and APIs, with independently provisioned public HTTPS, authenticated sessions, tenant isolation, server-side secrets and release/rollback. No reliance on an installed desktop JARVIS or public Electron/native IPC.
- **Independent release testing:** modifying BOM must not implicitly update JARVIS; disabling the JARVIS adapter must not prevent standalone BOM use. Shared BOM packages must have no runtime imports from private JARVIS code.

Use a versioned adapter boundary rather than running two competing systems with identical authority over the same user, company or task.

## 3. Unlimited industries through configuration, not an exhaustive hard-coded list

An organization may enable any combination of template packs (subscription/SaaS, creator platform, hospitality/booking, field services, pool care, construction, remediation, retail, professional services, nonprofit, etc.). Packs are defaults, not immutable business types.

A business can create custom entity types (e.g. `Pool`, `Customer`, `Job`, `Claim`), fields, relationships, pipelines, dashboards, metrics, role visibility and workflows. Preserve underlying stable entity/metric IDs when display names change. Moving a label from `Members` to `Pools` does not change the underlying calculation or data source.

### Metric definition contract (proposed, versioned)

```ts
type MetricDefinition = {
  id: string;                     // stable ID; never derived from user label
  companyId: string;              // enforced by backend authorization
  revision: number;
  label: string;                   // user-editable label, not data semantics
  description?: string;
  kind: "count" | "sum" | "average" | "ratio" | "duration" | "currency";
  unit: "count" | "percent" | "seconds" | "currency" | "custom";
  sourceBindingId: string;        // references a consented, scoped data source
  expression: unknown;            // **validated typed AST**, not raw SQL/JS
  timeField: string;
  filters: unknown;               // validated predicates over permitted fields
  ownerRoleIds: string[];
  refreshPolicy: { mode: "manual" | "scheduled" | "event"; intervalMinutes?: number };
  dataQuality: "verified" | "partial" | "stale" | "unavailable";
  createdAt: string;
  updatedAt: string;
};
```

This is a design contract, not an existing TypeScript export. Implementation must replace `unknown` with safe typed expression/filter AST schemas and validated source catalogs before execution.

### Dashboard widget contract (proposed)

A widget references a metric ID/version and stores its own display label override, visualization type, layout/size, time period, comparisons, sorting, color tokens, allowed roles and missing-data behavior. Widgets remain optional, draggable and removable, and can be individually disabled without changing the underlying metric or other users' dashboards. Chart values must be real or explicitly marked fixture data.

### Event-to-outcome funnel

Model discrete events: campaign impression, site visit, call initiated, call answered, lead created, qualified lead, quote, booking, fulfilled job, invoice, payment and refund. Attribute cautiously; source-reported conversions are not automatically collected revenue or proof of profit. Reconcile overlapping events by source IDs and receipt hashes; record freshness, consent and attribution confidence.

## 4. Data ownership and authorization

Define durable `companyId` boundaries for all business profiles, data sources, credentials, dashboards, metrics, executions, audit records and agent actions. Server-side checks and PostgreSQL constraints must verify tenant ownership even if the user edits a UI route. A user's role (owner/admin/analyst/marketer/technician) and an agent's title/authority are separate controls.

Prefer source-bound read-only analytics connectors at first. Credentials live only in a scoped secrets store; no tokens, service keys or cross-company data in the browser, logs, agent prompts or Git. If Supabase is used, enforce tenant-safe RLS and separately review all elevated service functions. External actions require explicit grants, budgets, idempotency, provenance and audit. Production data must not be used in fixtures by default.

## 5. Business intelligence and AI models

BOM users configure their own authorized OpenAI/Claude/Gemini/Grok API or approved local runtime. Provider sign-in, model authorization, tool grants, and spending limits are different entities. In a JARVIS-embedded installation: Hybrid OFF uses the user's selected primary for all supported agent reasoning, with no silent substitution; Hybrid ON routes only within the explicitly approved pool and budgets.

Intelligence stages:
1. Observe source-linked metrics with data freshness and quality markers.
2. Explain changes using evidence, with uncertainty and alternative explanations.
3. Recommend actions ranked by measured impact, projected cost and risk.
4. Prepare drafts and plans requiring review.
5. Execute only narrow allowed operations with per-company/person permissions, receipts, rollback where available and a global pause control.

Model statements must not become authorization to send messages, spend money, alter connected businesses or release code.

## 6. Social and marketing adapters

Use independent adapters and capability detection for Facebook Pages/Instagram professional accounts, X, TikTok, Reddit, Google Analytics, Search Console, advertising accounts, payment providers and call tracking. A connected badge does not prove a given action is allowed. Track provider/API version, grant scope, account identity, quotas, last synchronization, webhook verification and failure state.

Comment reply modes: `draft`, `approval`, `auto_low_risk`. Default to review; allow automatic low-risk replies only for supported provider capabilities and verified brand-policy categories. Escalate billing/privacy, harassment, threats, medical/safety, account problems, and genuine customer complaints to authorized humans. Record original comment ID, drafted text, approval, sent response ID and platform receipt. Avoid duplicate sends, repetitive responses and unreviewed claims.

## 7. Delivery phases and evidence gates

- **B0: fork baseline.** Read source and explicit permissions, prove local startup and isolated company creation; collect actual Node/pnpm/Rust, browser, server and database receipts. Protect upstream behavior and do not assume CI passes.
- **B1: BOM product identity + independent packaging.** Owner-approved branding, portable configuration, install/update and secure remote auth, without internal package renames.
- **B2: company data / metric SDK.** Type-safe registry, custom entities, validated calculated metrics, dashboard layout persistence, tenant denial tests, component-specific loading/offline states.
- **B3: industry templates + analytics connectors.** Content Connect X, Host Connect X, and a pool service fixture with independently meaningful KPIs; real payment/traffic attribution only when sources are connected and authorized.
- **B4: AI analysis and social workflows.** Evidence-linked recommendations; independently authorized provider setup; approval queues, adapter receipts, budgets and rate-limit handling.
- **B5: JARVIS module adapter / standalone cloud releases.** Cross-surface contracts, security isolation, UI visual QA, migrations, recovery and signed/verified release pipelines where applicable.

Each phase needs builds/typechecks, targeted unit/integration tests, real browser screenshots, failure/permission tests and evidence of persisted state before claiming Working. Track Working / Partial / Stub / Broken / Planned / Blocked, not UI-card presence.

## 8. First acceptance examples

- Content Connect X: independently reconcile website registrations vs paying subscriptions vs actual payment/refund records, without leaking private user identity to other companies.
- Host Connect X: independent host/listing/booking pipeline, subscription figures, traffic and marketing sources.
- Pool service: owner renames a card `Customers` to `Active Pools`, selects the actual pool data source and correct counting logic, then adds recurring visits, calls, quote-to-job conversions and advertising cost without enabling subscription metrics.
- Create two unrelated companies and users: verify cross-company reads/writes, agent requests, database access and social-post dispatch are denied.
- Run BOM standalone with no JARVIS service, then load its adapted UI inside JARVIS under the per-user theme and permission contract without changing either company's data.

## 9. Immediate local test

See [WINDOWS_BASELINE_TEST.md](WINDOWS_BASELINE_TEST.md). Do not configure Supabase, advertising services, phone accounts or paid AI providers for the first isolated smoke test. The fork's existing embedded database is sufficient to verify the original control plane, onboarding and UI. No files in this initial foundation PR modify existing runtime behavior.
