# Changelog

Human-readable index of the agent-executable entries under
[`docs/changelog/`](docs/changelog/README.md). Each entry is written as upgrade
instructions an agent applies to a downstream app — see the README there for the
filter+apply algorithm.

## 0.2.3

- **0.2.3-001** · _fix_ · deploy, frontend — [Deploy hardening from the first tenant](docs/changelog/0.2.3-001-deploy-hardening-from-first-tenant.md).
  Dockerfile ships .ruby-version + Node for the Vite build; optional remote
  builder; KAMAL_IMAGE and fresh-clone credentials documented.

## 0.2.2

- **0.2.2-001** · _feat_ · frontend — [Cloudflare tunnel previews](docs/changelog/0.2.2-001-cloudflared-tunnel-previews.md).
  Adds `bin/tunnel` (cloudflared quick tunnel over Rails-served built assets) and
  allows `*.trycloudflare.com` in development host authorization.

## 0.2.1

- **0.2.1-001** · _fix_ · auth, deploy — [Enforce production SSL](docs/changelog/0.2.1-001-enforce-production-ssl.md).
  Re-enables assume_ssl/force_ssl so session cookies ship Secure with HSTS.
- **0.2.1-002** · _fix_ · riffrec — [Rename capture key to RIFFREC_PUBLIC_KEY](docs/changelog/0.2.1-002-riffrec-public-key-rename.md).
  Browser-shipped key moves from env.secret to env.clear; no secret-shaped naming.
- **0.2.1-003** · _fix_ · auth, agent-conventions — [Sign-in submit test + AGENTS.md module list](docs/changelog/0.2.1-003-signin-submit-test-and-agents-module-list.md).

## 0.2.0

- **0.2.0-001** · _feat_ · ruby_native — [Add Ruby Native module](docs/changelog/0.2.0-001-add-ruby-native-module.md).
  Registers rubynative.com as a house module for native iOS/Android distribution;
  documentation-first, no gem or license in the template.

## 0.1.0

- **0.1.0-001** · _feat_ · all modules — [Initial template](docs/changelog/0.1.0-001-initial-template.md).
  Establishes the born-complete baseline: Rails 8.1 + Inertia/React + Kamal + the
  house modules (frontend, auth, jobs, testing, ci, deploy, ruby_llm,
  serialization, riffrec, agent-conventions).
