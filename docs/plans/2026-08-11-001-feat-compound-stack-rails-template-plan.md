---
title: Compound Stack Rails Template - Plan
type: feat
date: 2026-08-11
topic: compound-stack-rails-template
artifact_contract: ce-unified-plan/v1
artifact_readiness: requirements-only
product_contract_source: ce-brainstorm
execution: code
---

# Compound Stack Rails Template - Plan

## Goal Capsule

- **Objective:** Build a canonical, runnable Rails starter app that the fleet of Kieran's Rails projects converges on, with agent-executable changelog entries as the upgrade delivery mechanism.
- **Product authority:** Kieran. Stack picks are informed by the pattern survey landing in `docs/patterns/`.
- **Open blockers:** Final stack picks per pattern area await the pattern survey results (Outstanding Questions).

---

## Product Contract

### Summary

A canonical Rails application — Rails + Inertia/React + Kamal + the house libraries — that serves as the template for the fleet. New apps start by cloning it; existing apps converge on it à la carte. Upgrades are delivered by agents that read the template's changelog against a small per-app manifest recording the adopted template version and modules.

### Problem Frame

Sixteen Rails projects share overlapping but drifting stacks: each app re-decides auth, deployment, jobs, serialization, and conventions, and improvements made in one app never reach the others. Keeping them aligned by hand does not scale, and there is no single place where "the current best way I build Rails apps" lives.

### Key Decisions

- **Canonical runnable app over template script or docs-only.** A real, booting app is what upgrade agents diff against and what new apps clone. Script or docs-only variants drift invisibly and offer nothing verifiable.
- **Manifest + agent-executable changelog over per-module upgrade skills.** Each app carries a manifest (template version, modules adopted); agents read changelog entries since that version for those modules and apply them. Entries get promoted into state-detecting skills only when a plain entry proves insufficient.
- **Modular from day one.** Apps adopt pattern areas independently, so the canonical app is structured as independently adoptable modules, not a monolith.
- **Stack picks are survey-driven and now approved.** One opinionated pick per area, from `docs/patterns/SUMMARY.md` ("What compound-stack-rails should adopt"): Ruby 3.4.2, Rails ~> 8.1.3, SQLite + solid_cache/solid_queue/solid_cable, propshaft, npm, Tailwind v4, Kamal ~> 2.12 with ERB-templated env-driven `deploy.yml`; `app/frontend` + vite_rails, React 19 + TypeScript, snake_case pages, base `InertiaController`, SSR wired but off; Rails 8 generator auth (`has_secure_password` + DB-backed Session model, OmniAuth as opt-in linking, no open registration); Solid Queue in Puma; Minitest + fixtures + Vitest; GitHub Actions 3-job skeleton + JS check; `AGENTS.md` real with `CLAUDE.md` symlinked; `ruby_llm ~> 1.16` first-class. `leva` optional add-on; `rails_js_logger` dropped.
- **Riffrec ships built in.** The template includes riffrec feedback capture as a default module, configured to report to a riffrec-dashboard connection via placeholder environment variables — no real credentials or live endpoints in the template.

### Actors

- A1. Kieran — edits the template, writes/approves changelog entries, reviews upgrade PRs.
- A2. Upgrade agent — orchestrated agent pointed at a downstream app; reads the template repo, its changelog, and the app's manifest; lands an upgrade PR.
- A3. Downstream app — any fleet Rails app carrying a template manifest.

### Requirements

**Template repo**

- R1. The template is a runnable Rails app that boots and deploys via Kamal out of the box.
- R2. Every stack area (auth, frontend, jobs, testing, deploy, serialization, house libraries) is an independently adoptable module with its own documentation in the repo.
- R3. The repo carries a changelog whose entries are written as upgrade instructions an agent can execute against a downstream app, not as human release notes.

**Upgrade delivery**

- R4. Each downstream app carries a small manifest recording the template version it is on and which modules it has adopted.
- R5. An upgrade agent, given only the app repo and the template repo, can determine what is owed (changelog entries since the manifest version, filtered to adopted modules), apply them, and bump the manifest.
- R6. Upgrades land as reviewable PRs on the downstream app, not direct pushes.

**Adoption**

- R7. New apps can be created from the template and are born with a complete manifest.
- R8. An existing app can adopt a single module without adopting the rest of the stack.

**Riffrec module**

- R9. The template ships with riffrec feedback capture wired in as a default module, pointing at a riffrec-dashboard connection through placeholder configuration (env vars); no real credentials, API keys, or live endpoints appear anywhere in the template.

### Key Flows

- F1. Template upgrade reaches a downstream app
  - **Trigger:** Kieran changes something in the template and writes a changelog entry.
  - **Actors:** A1, A2, A3
  - **Steps:** Agent is pointed at the app; reads the app's manifest; reads changelog entries newer than the manifest version for adopted modules; applies the instructions; bumps the manifest; opens a PR.
  - **Covers:** R3, R4, R5, R6
- F2. Existing app adopts a module
  - **Trigger:** Kieran decides an app should take on a template module (e.g., the Kamal setup).
  - **Actors:** A1, A2, A3
  - **Steps:** Agent reads the module's documentation in the template; applies it to the app; records the module and current template version in the manifest; opens a PR.
  - **Covers:** R2, R4, R8

### Acceptance Examples

- AE1. **Covers R3, R5, R6.** Given tada carries a manifest with the Kamal module adopted, when Kieran changes the template's Kamal configuration and writes a changelog entry, then an agent pointed at tada lands a mergeable PR applying the change unattended — this is the first-proof gate for the whole system.
- AE2. **Covers R8.** Given an existing app with no manifest, when an agent is asked to adopt one module, then only that module's changes land and the manifest records exactly that module.

### Success Criteria

- AE1 passes on a real app with no human intervention between "changelog entry written" and "PR opened."
- A new app created from the template boots and deploys via Kamal without manual wiring.

### Scope Boundaries

- **Deferred for later:** the reverse promotion loop (patterns flowing from apps back into the template) — starts only after the forward loop has worked once; per-module upgrade skills — promoted from changelog entries as needed, not built up front.
- **Likely excluded:** Cora — it has its own team and momentum; convergence there is opportunistic at best.

### Dependencies / Assumptions

- The pattern survey (running now, output in `docs/patterns/` with a SUMMARY.md ranking) supplies the evidence for stack picks.
- Upgrade agents run through Erf orchestration; the template repo is a registered Erf context.
- Assumption: changelog authoring discipline holds — every template change that affects downstream apps gets an agent-executable entry. This is the system's single point of failure.

### Outstanding Questions

- **Deferred to planning:** manifest format and location; changelog entry format; how the canonical app marks module boundaries; TypeScript version pin (survey shows 5.7–7.0 drift — prefer stable); whether a second Kamal `job` role ships by default (survey: no consensus); Alba/Typelizer typed serialization (parked — 1/8 adoption).
