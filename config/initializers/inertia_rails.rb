# frozen_string_literal: true

InertiaRails.configure do |config|
  # Lambda so the asset version is re-read on each request rather than frozen at
  # boot — a rebuilt frontend invalidates client history without a server restart.
  config.version = -> { ViteRuby.digest }
  config.encrypt_history = true
  config.always_include_errors_hash = true
  config.use_script_element_for_initial_page = true
  config.use_data_inertia_head_attribute = true
end
