# frozen_string_literal: true

# Demo landing page proving the Inertia round trip: a Rails controller renders a
# snake_case page identifier and passes props the React component reads directly.
class HomeController < InertiaController
  def index
    render inertia: "home/index", props: { name: "Compound Stack" }
  end
end
