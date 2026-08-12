# frozen_string_literal: true

# Base controller for every Inertia-rendered page. Controllers inherit from this
# (never ApplicationController directly), so each new page automatically receives
# the shared props defined here AND the authentication gate — a page cannot ship
# ungated, or without shared context, by omission.
#
# To make a page public, call `allow_unauthenticated_access` (see HomeController,
# SessionsController).
class InertiaController < ApplicationController
  # Authentication gate, default-on. `before_action :require_authentication` runs
  # for every subclass unless it opts out with `allow_unauthenticated_access`.
  include Authentication

  # Flash messages, surfaced to every page as a plain hash keyed by type.
  inertia_share flash: -> { flash.to_hash }

  # Active locale, so pages can render language-aware copy without a round trip.
  inertia_share locale: -> { I18n.locale.to_s }
end
