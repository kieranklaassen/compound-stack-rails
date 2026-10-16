# Module: ruby_llm

`ruby_llm` is a first-class default: a unified API over OpenAI, Anthropic, and
Gemini. It boots test-safe with no keys — each provider is simply unavailable
until a key is set.

The template pins the gem to the **2.2 line by git ref**, not to a released
version. 2.2 is unreleased: RubyGems tops out at 2.1.1 and the gem's own
`version.rb` still reads `2.1.1` on main, while main carries the whole 2.2
feature set. So `RubyLLM::VERSION` reports `2.1.1` here and only the ref
identifies the pin — `test/initializers/ruby_llm_test.rb` asserts the revision
in `Gemfile.lock` for that reason. A released 2.2 gem supersedes the ref.

## What this module is

- `config/initializers/ruby_llm.rb` reads keys from `ENV` first, then encrypted
  credentials (guarded so a missing master key never raises the boot).
- `default_model` defaults to `gemini-2.5-flash` (`RUBY_LLM_MODEL` to override);
  `request_timeout` defaults to 60s (`RUBY_LLM_REQUEST_TIMEOUT`).
- No `model_registry_class` or `use_new_acts_as`: 2.0 removed both settings
  (setting them only logs a warning). In Rails the model registry reads a
  `ruby_llm_models` table when one exists and otherwise falls back to the bundled
  JSON catalog; the template ships no such table. Opt a model into persisted
  chats with `acts_as_chat` / `acts_as_message` as usual.
- 2.x emits instrumentation only through `config.instrumenter`; its Railtie sets
  that to `ActiveSupport::Notifications`, so the subscriber below works unchanged.
- A `chat.ruby_llm` `ActiveSupport::Notifications` subscriber logs one structured
  line per completion (model, duration, token buckets) into the normal Rails log.
  It reads `:response_tokens` (which the gem fills once the completion returns)
  and falls back to `:tokens`, then logs `RubyLLM::Tokens#to_h`. There is no
  `:total_tokens` payload key in any 2.x version — that name exists only inside
  provider wire parsing — and `to_h` is already compacted, so a bucket the
  provider did not report is absent rather than zero.

## Files (the module boundary)

- `Gemfile` — `gem "ruby_llm", github: "crmne/ruby_llm", ref: "<sha>"`
- `config/initializers/ruby_llm.rb`
- `.env.example` — the `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` / `GEMINI_API_KEY` /
  `RUBY_LLM_MODEL` / `RUBY_LLM_REQUEST_TIMEOUT` placeholder names.
- `test/initializers/ruby_llm_test.rb`

## Adopt into an existing app

1. Add the gem at the same ref this template pins (see `Gemfile`). Taking an
   unreleased ref means your `bundle install` and image builds need git access
   to `github.com/crmne/ruby_llm`, which no release tag protects; move to the
   released gem once 2.2 ships.
2. Copy `config/initializers/ruby_llm.rb` and the `.env.example` LLM entries.
3. Set at least one provider key in `ENV` or credentials to make a provider live.

## Verify adoption

- `bin/rails test test/initializers/ruby_llm_test.rb` (boots with no keys; the
  default model and timeout fall back correctly; the notification subscriber logs).

## Opt-ins & non-adoptions

- **Persistence is an opt-in, and the generator is destructive here.** The
  template ships no `ruby_llm_*` tables, no agents, prompts or skills
  directories, and no committed agent skill. Running `bin/rails g
  ruby_llm:install` in a clone would overwrite the initializer above with a
  four-line stub and write an `ApplicationAgent` whose `chat_model Chat` raises
  `NameError` on eager load, because this template has no `Chat` model. An app
  that wants persisted chats runs the generator, then restores this
  initializer's key/credential handling and the subscriber, and adds its own
  `Chat`/`Message` models with `acts_as_chat` / `acts_as_message`.

- **`app/tools` means two different things.** The gem claims `app/tools` as its
  convention directory for `RubyLLM::Tool` subclasses; this template already
  uses it for the WebMCP registry (`ApplicationTool < MCP::Tool`,
  `ToolRegistry`, `WhoamiTool`). Nothing collides today because the template
  declares no ruby_llm tools, but an app adopting both has to separate them —
  that is the app's call, not the template's.

- **Code execution exists and is not armed.** The gem can run model-authored
  code in an MXC sandbox, reached through `config.sandbox`,
  `Chat#with_code_execution(sandbox:)` or `Agent.code_execution sandbox:`.
  None is set here, and `config.sandbox` in particular makes boot raise without
  a working sandbox, which would break this template's boot-with-nothing
  guarantee. Arming it needs Bubblewrap in the runtime image.

- **Extra providers** ship as separate gems on the 2.x provider API, for example
  `ruby_llm-typesafe` (needs `ruby_llm >= 2.0`). Add the gem plus a small
  initializer that sets its key from `ENV`.

- **`leva`** (LLM eval harness) is an optional add-on. Add the gem and
  `mount Leva::Engine => "/leva"` in `config/routes.rb` when you need eval runs.
- **`rails_js_logger` is intentionally NOT used** — it does not exist as a
  maintained gem; frontend logging goes through the browser console / Vite.
