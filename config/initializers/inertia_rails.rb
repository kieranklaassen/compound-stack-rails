# frozen_string_literal: true

InertiaRails.configure do |config|
  # Lambda so the asset version is re-read on each request rather than frozen at
  # boot — a rebuilt frontend invalidates client history without a server restart.
  config.version = -> { ViteRuby.digest }
  config.encrypt_history = true
  config.always_include_errors_hash = true
  config.use_script_element_for_initial_page = true
  config.use_data_inertia_head_attribute = true

  # --- SSR: wired but disabled by default (KTD5) ---
  # Everything SSR needs is in place — the entrypoint branches CSR/SSR on
  # data-server-rendered, the render call is bounded by
  # config/initializers/inertia_ssr_timeout.rb, and the layout emits
  # inertia_ssr_head. Turning SSR on is env-only: build the bundle
  # (`npm run build:ssr`) and set INERTIA_SSR_ENABLED=true — no code change.
  config.ssr_enabled = ActiveModel::Type::Boolean.new.cast(ENV.fetch("INERTIA_SSR_ENABLED", false))
  config.ssr_url = ENV.fetch("INERTIA_SSR_URL", "http://localhost:13714")
  config.ssr_bundle = Rails.root.join("public/vite-ssr/ssr.js").to_s

  # On any SSR failure, log the failing component and fall back to CSR rather
  # than surfacing an error to the user (ssr_raise_on_error stays false).
  config.on_ssr_error = lambda do |error, page|
    Rails.logger.error(
      "[inertia-rails] SSR render failed for #{page&.dig(:component) || 'unknown component'}, " \
      "falling back to CSR: #{error.message}"
    )
  end
end
