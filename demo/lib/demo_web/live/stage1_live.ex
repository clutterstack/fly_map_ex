defmodule DemoWeb.Stage1Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  import DemoWeb.Components.MapWithCodeComponent

  def mount(_params, _session, socket) do
    marker_groups = [
      %{
        nodes: ["sjc", "fra", "ams", "lhr"],
        style: :primary,
        label: "My Servers"
      }
    ]

    {:ok, assign(socket, marker_groups: marker_groups)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 1: Basic Map Display</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Minimal setup showing basic FlyMapEx functionality with a single region group.
        </p>
      </div>

      <.map_with_code
        marker_groups={@marker_groups}
        background={FlyMapEx.Theme.responsive_background()}
        map_title="Map Visualization"
      >
        <:extra_content>
          <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h3 class="font-semibold text-blue-800 mb-2">Key Features</h3>
            <ul class="text-blue-700 text-sm space-y-1">
              <li>• Single region group with default styling</li>
              <li>• Basic Fly.io region codes</li>
              <li>• Default theme and minimal configuration</li>
              <li>• Simple marker placement on world map</li>
            </ul>
          </div>
        </:extra_content>
      </.map_with_code>

      <div class="mt-8 text-center">
        <.link
          navigate="/stage2"
          class="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
        >
          Next: Stage 2 - Multiple Groups & Styling →
        </.link>
      </div>
    </div>
    """
  end
end
