# frozen_string_literal: true

# Base controller for every Inertia-rendered page. Controllers inherit from this
# (never ApplicationController directly), so each new page automatically receives
# the shared props defined here — a page cannot ship ungated by omission.
#
# Later modules extend the shared surface: U4 (auth) adds the authentication gate,
# U10 (riffrec) adds the feedback-capture props.
class InertiaController < ApplicationController
  # Flash messages, surfaced to every page as a plain hash keyed by type.
  inertia_share flash: -> { flash.to_hash }

  # Active locale, so pages can render language-aware copy without a round trip.
  inertia_share locale: -> { I18n.locale.to_s }
end
