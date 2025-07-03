defmodule DemoWeb.Stage1Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  import DemoWeb.Components.MapWithCodeComponent
  import DemoWeb.Components.DemoNavigation

  def mount(_params, _session, socket) do
    single_region = [
      %{
        nodes: ["sjc"],
        style: :primary,
        label: "Single Server"
      }
    ]

    multiple_regions = [
      %{
        nodes: ["sjc", "fra", "ams", "lhr"],
        style: :primary,
        label: "Global Deployment"
      }
    ]

    generic_markers = [
      %{
        nodes: [
          %{coordinates: {37.7749, -122.4194}, label: "San Francisco"},
          %{coordinates: {50.1109, 8.6821}, label: "Frankfurt"}
        ],
        style: :secondary,
        label: "Custom Locations"
      }
    ]

    {:ok, assign(socket,
      single_region: single_region,
      multiple_regions: multiple_regions,
      generic_markers: generic_markers,
      show_multiple: false,
      show_generic: false
    )}
  end

  def handle_event("toggle_multiple", _params, socket) do
    {:noreply, assign(socket, show_multiple: !socket.assigns.show_multiple)}
  end

  def handle_event("toggle_generic", _params, socket) do
    {:noreply, assign(socket, show_generic: !socket.assigns.show_generic)}
  end

  defp current_marker_groups(assigns) do
    cond do
      assigns.show_generic -> assigns.generic_markers
      assigns.show_multiple -> assigns.multiple_regions
      true -> assigns.single_region
    end
  end

  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:stage1} />
    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 1: Basic Map Display</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Interactive demonstration of FlyMapEx scalability and syntax options.
        </p>

        <div class="mb-6 space-y-3">
          <div class="flex gap-4">
            <button
              phx-click="toggle_multiple"
              class={"px-4 py-2 rounded-lg transition-colors " <>
                if(@show_multiple, do: "bg-blue-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300")}
            >
              <%= if @show_multiple, do: "Single Region", else: "Multiple Regions" %>
            </button>

            <button
              phx-click="toggle_generic"
              class={"px-4 py-2 rounded-lg transition-colors " <>
                if(@show_generic, do: "bg-green-600 text-white", else: "bg-gray-200 text-gray-700 hover:bg-gray-300")}
            >
              <%= if @show_generic, do: "Fly Regions", else: "Generic Markers" %>
            </button>
          </div>
        </div>
      </div>

      <.map_with_code
        marker_groups={current_marker_groups(assigns)}
        theme={:responsive}
        map_title="Interactive Map Demo"
      >
        <:extra_content>
          <div class="space-y-4">
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h3 class="font-semibold text-blue-800 mb-2">Current Configuration</h3>
              <ul class="text-blue-700 text-sm space-y-1">
                <li>• <strong>Scale:</strong> <%= if @show_multiple, do: "4 regions", else: "1 region" %></li>
                <li>• <strong>Syntax:</strong> <%= if @show_generic, do: "Generic lat/lng coordinates", else: "Fly.io region codes" %></li>
                <li>• <strong>Style:</strong> <%= if @show_generic, do: "Secondary (green)", else: "Primary (blue)" %></li>
              </ul>
            </div>

            <div class="bg-gray-50 border border-gray-200 rounded-lg p-4">
              <h3 class="font-semibold text-gray-800 mb-2">Code Comparison</h3>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                <div>
                  <h4 class="font-medium text-gray-700 mb-1">Fly.io Regions (Shorthand)</h4>
                  <pre class="bg-white p-2 rounded border text-gray-800 overflow-x-auto"><code><%= ~s|%{
  nodes: ["sjc", "fra"],
  style: :primary,
  label: "My Servers"
}| %></code></pre>
                </div>
                <div>
                  <h4 class="font-medium text-gray-700 mb-1">Generic Markers (Coordinates)</h4>
                  <pre class="bg-white p-2 rounded border text-gray-800 overflow-x-auto"><code><%= ~s|%{
  nodes: [
    %{coordinates: {37.7749, -122.4194},
      label: "San Francisco"}
  ],
  style: :secondary,
  label: "Custom Locations"
}| %></code></pre>
                </div>
              </div>
            </div>
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
