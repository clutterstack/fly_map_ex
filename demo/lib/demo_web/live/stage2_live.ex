defmodule DemoWeb.Stage2Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  import DemoWeb.Components.MapWithCodeComponent
  import DemoWeb.Components.DemoNavigation

  def mount(_params, _session, socket) do
    marker_groups = [
      %{
        nodes: ["sjc", "fra"],
        style: FlyMapEx.Style.operational(),
        label: "Production Servers"
      },
      %{
        nodes: ["ams", "lhr"],
        style: :warning,
        label: "Maintenance Mode"
      },
      %{
        nodes: ["ord"],
        style: FlyMapEx.Style.danger(),
        label: "Failed Nodes"
      },
      %{
        nodes: ["nrt", "syd"],
        style: FlyMapEx.Style.inactive(),
        label: "Offline Nodes"
      }
    ]

    {:ok, assign(socket, marker_groups: marker_groups)}
  end

  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:stage2} />
    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 2: Multiple Groups & Styling</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Demonstrating semantic styling with multiple marker groups representing different server states.
        </p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Map Display -->
        <div class="space-y-4">
          <h2 class="text-xl font-semibold text-gray-700">Interactive Map</h2>
          <div class="p-4 bg-gray-50 rounded-lg">
            <FlyMapEx.render
              marker_groups={@marker_groups}
              background={FlyMapEx.Theme.responsive_background()}
            />
          </div>

          <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h3 class="font-semibold text-blue-800 mb-2">Interactive Features</h3>
            <ul class="text-blue-700 text-sm space-y-1">
              <li>• Click legend items to toggle group visibility</li>
              <li>• Notice how colours remain consistent when toggling</li>
              <li>• Each group has semantic meaning and appropriate styling</li>
              <li>• Animated markers draw attention to critical states</li>
            </ul>
          </div>
        </div>

        <!-- Code and Info Display -->
        <div class="space-y-4">
          <h2 class="text-xl font-semibold text-gray-700">Code Example</h2>
          <% {_map_attrs, code_string} = DemoWeb.Components.MapWithCodeComponent.build_map_and_code(%{marker_groups: @marker_groups, background: FlyMapEx.Theme.responsive_background()}) %>
          <div class="bg-gray-50 rounded-lg p-4">
            <pre class="text-sm text-gray-800 overflow-x-auto"><code><%= code_string %></code></pre>
          </div>

          <div class="bg-green-50 border border-green-200 rounded-lg p-4">
            <h3 class="font-semibold text-green-800 mb-2">Semantic Styles</h3>
            <div class="space-y-2 text-sm">
              <div class="flex items-center space-x-2">
                <div class="w-3 h-3 rounded-full animate-pulse" style="background-color: #10b981;">
                </div>
                <span class="text-green-700">
                  <strong>operational()</strong> - Emerald, animated - Running services
                </span>
              </div>
              <div class="flex items-center space-x-2">
                <div class="w-3 h-3 rounded-full" style="background-color: #f59e0b;"></div>
                <span class="text-green-700">
                  <strong>warning()</strong> - Amber, static - Needs attention
                </span>
              </div>
              <div class="flex items-center space-x-2">
                <div class="w-3 h-3 rounded-full animate-pulse" style="background-color: #ef4444;">
                </div>
                <span class="text-green-700">
                  <strong>danger()</strong> - Red, pulse animation - Critical issues
                </span>
              </div>
              <div class="flex items-center space-x-2">
                <div class="w-3 h-3 rounded-full" style="background-color: #6b7280;"></div>
                <span class="text-green-700">
                  <strong>inactive()</strong> - Gray, static - Not running
                </span>
              </div>
            </div>
          </div>

          <div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
            <h3 class="font-semibold text-purple-800 mb-2">Key Features</h3>
            <ul class="text-purple-700 text-sm space-y-1">
              <li>• <strong>Multiple Groups:</strong> Organize nodes by purpose or state</li>
              <li>
                • <strong>Semantic Styling:</strong> Meaningful colours convey status at a glance
              </li>
              <li>
                • <strong>Colour Consistency:</strong> Groups maintain their colours when toggled
              </li>
              <li>
                • <strong>Animation Logic:</strong> Critical states get attention with animation
              </li>
              <li>
                • <strong>Legend Integration:</strong>
                Built-in legend shows all groups with toggle controls
              </li>
            </ul>
          </div>

        </div>
      </div>

      <!-- Navigation -->
      <div class="mt-8 flex justify-between">
        <.link navigate={~p"/stage1"} class="btn btn-outline">
          ← Stage 1: Basic Display
        </.link>
        <.link navigate={~p"/stage3"} class="btn btn-primary">
          Stage 3: Themes & Backgrounds →
        </.link>
      </div>
    </div>
    """
  end
end
