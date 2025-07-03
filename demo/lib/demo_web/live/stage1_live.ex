defmodule DemoWeb.Stage1Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  import DemoWeb.Components.MapWithCodeComponent
  import DemoWeb.Components.DemoNavigation
  import DemoWeb.Components.InteractiveControls
  import DemoWeb.Components.ProgressiveDisclosure

  def mount(_params, _session, socket) do
    # Define the progressive examples according to the plan
    examples = %{
      single_coordinates: [
        %{
          nodes: [%{coordinates: {37.7749, -122.4194}, label: "San Francisco"}],
          style: :primary,
          label: "Single Node"
        }
      ],
      single_region: [
        %{
          nodes: ["sjc"],
          style: :primary,
          label: "Single Server"
        }
      ],
      multiple_nodes: [
        %{
          nodes: ["sjc", "fra", "ams", "lhr"],
          style: :primary,
          label: "Global Deployment"
        }
      ],
      multiple_groups: [
        %{
          nodes: ["sjc", "fra"],
          style: :primary,
          label: "Production Servers"
        },
        %{
          nodes: ["ams", "lhr"],
          style: :secondary,
          label: "Staging Environment"
        }
      ]
    }

    # Interactive control options
    options = [
      %{key: "single_coordinates", label: "Single Node (Coordinates)", description: "Basic coordinate-based marker"},
      %{key: "single_region", label: "Single Node (Fly Region)", description: "Using Fly.io region shorthand"},
      %{key: "multiple_nodes", label: "Multiple Nodes", description: "Multiple nodes in one group"},
      %{key: "multiple_groups", label: "Multiple Groups", description: "Multiple groups with different purposes"}
    ]

    {:ok, assign(socket,
      examples: examples,
      options: options,
      current_example: "single_coordinates"
    )}
  end

  def handle_event("switch_example", %{"option" => option}, socket) do
    {:noreply, assign(socket, current_example: option)}
  end

  defp current_marker_groups(assigns) do
    Map.get(assigns.examples, String.to_atom(assigns.current_example), [])
  end

  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:stage1} />
    <div class="container mx-auto p-8">
      <!-- Stage Title & Progress -->
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 1: Defining Marker Groups</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Learn the fundamental data structure and syntax options for FlyMapEx marker groups.
        </p>
      </div>

      <!-- Key Concept Explanation (Above the Fold) -->
      <.info_panel title="Key Concepts" color="blue" class="mb-6">
        <ul class="text-sm space-y-1">
          <li>• <strong>Basic Structure:</strong> Marker groups contain nodes, styling, and labels</li>
          <li>• <strong>Fly Region Shorthand:</strong> Use "sjc", "fra" instead of coordinates</li>
          <li>• <strong>Custom Coordinates:</strong> Specify exact lat/lng for any location</li>
          <li>• <strong>Multiple Groups:</strong> Organize nodes by purpose or environment</li>
        </ul>
      </.info_panel>

      <!-- Interactive Controls & Presets -->
      <div class="mb-6">
        <h3 class="text-lg font-semibold text-gray-800 mb-3">Try Different Configurations:</h3>
        <.preset_buttons
          options={@options}
          current={@current_example}
          event="switch_example"
        />
      </div>

      <!-- Live Map Preview & Generated Code -->
      <.map_with_code
        marker_groups={current_marker_groups(assigns)}
        map_title="Interactive Map Demo"
      >
        <:extra_content>
          <div class="space-y-4">
            <.info_panel title="Current Configuration" color="blue">
              <ul class="text-sm space-y-1">
                <li>• <strong>Example:</strong> <%= get_current_description(@current_example) %></li>
                <li>• <strong>Groups:</strong> <%= length(current_marker_groups(assigns)) %> group(s)</li>
                <li>• <strong>Total Nodes:</strong> <%= count_total_nodes(current_marker_groups(assigns)) %></li>
                <li>• <strong>Syntax:</strong> <%= get_syntax_type(@current_example) %></li>
              </ul>
            </.info_panel>

            <.code_comparison
              title="Code Comparison"
              comparisons={[
                %{
                  title: "Fly.io Regions (Shorthand)",
                  code: ~s|%{
  nodes: ["sjc", "fra"],
  style: :primary,
  label: "My Servers"
}|
                },
                %{
                  title: "Generic Markers (Coordinates)",
                  code: ~s|%{
  nodes: [
    %{coordinates: {37.7749, -122.4194},
      label: "San Francisco"}
  ],
  style: :secondary,
  label: "Custom Locations"
}|
                }
              ]}
            />
          </div>
        </:extra_content>
      </.map_with_code>

      <!-- Progressive Disclosure for Advanced Topics -->
      <.learn_more_section
        topics={get_advanced_topics()}
      />

      <!-- Navigation -->
      <div class="mt-8 flex justify-between">
        <.link navigate={~p"/"} class="inline-block bg-gray-600 text-white px-6 py-2 rounded-lg hover:bg-gray-700 transition-colors">
          ← Back to Home
        </.link>
        <.link navigate={~p"/stage2"} class="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors">
          Next: Stage 2 - Styling Markers →
        </.link>
      </div>
    </div>
    """
  end

  # Helper functions for the template
  defp get_current_description(example) do
    case example do
      "single_coordinates" -> "Single node with custom coordinates"
      "single_region" -> "Single node using Fly.io region code"
      "multiple_nodes" -> "Multiple nodes in one group"
      "multiple_groups" -> "Multiple groups with different purposes"
      _ -> "Unknown example"
    end
  end

  defp count_total_nodes(marker_groups) do
    Enum.reduce(marker_groups, 0, fn group, acc ->
      nodes = group[:nodes] || []
      acc + length(nodes)
    end)
  end

  defp get_syntax_type(example) do
    case example do
      "single_coordinates" -> "Custom coordinates"
      "single_region" -> "Fly.io region codes"
      "multiple_nodes" -> "Fly.io region codes"
      "multiple_groups" -> "Fly.io region codes"
      _ -> "Mixed"
    end
  end

  defp get_advanced_topics do
    [
      %{
        id: "coordinate-systems",
        title: "Understanding Coordinate Systems",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-gray-700">
            FlyMapEx supports two coordinate systems for maximum flexibility:
          </p>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <h4 class="font-semibold text-gray-800 mb-2">WGS84 Geographic Coordinates</h4>
              <ul class="text-sm text-gray-600 space-y-1">
                <li>• Standard latitude and longitude</li>
                <li>• Range: -90 to 90 (latitude), -180 to 180 (longitude)</li>
                <li>• Example: {37.7749, -122.4194} for San Francisco</li>
                <li>• Use when you need precise custom locations</li>
              </ul>
            </div>
            <div>
              <h4 class="font-semibold text-gray-800 mb-2">Fly.io Region Codes</h4>
              <ul class="text-sm text-gray-600 space-y-1">
                <li>• Pre-defined 3-letter codes</li>
                <li>• Examples: "sjc", "fra", "ams", "lhr"</li>
                <li>• Automatically resolved to exact coordinates</li>
                <li>• Use for Fly.io infrastructure mapping</li>
              </ul>
            </div>
          </div>
        </div>
        """
      },
      %{
        id: "data-structure",
        title: "Marker Group Data Structure",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-gray-700">
            Each marker group follows a consistent structure:
          </p>
          <pre class="bg-gray-100 p-4 rounded-lg text-sm"><code>%{
  nodes: [list_of_nodes],    # Required: nodes to display
  style: style_specification, # Optional: visual styling
  label: "Group Name"        # Required: legend label
}</code></pre>
          <div class="mt-4">
            <h4 class="font-semibold text-gray-800 mb-2">Node Specifications</h4>
            <div class="space-y-2 text-sm">
              <div>
                <strong>Region Code:</strong> <code class="bg-gray-100 px-1 rounded">"sjc"</code>
              </div>
              <div>
                <strong>Custom Node:</strong> <code class="bg-gray-100 px-1 rounded">%{coordinates: {lat, lng}, label: "Name"}</code>
              </div>
              <div>
                <strong>Mixed:</strong> <code class="bg-gray-100 px-1 rounded">["sjc", %{coordinates: {40.7128, -74.0060}, label: "NYC"}]</code>
              </div>
            </div>
          </div>
        </div>
        """
      },
      %{
        id: "production-tips",
        title: "Production Usage Tips",
        content: ~s"""
        <div class="space-y-4">
          <div>
            <h4 class="font-semibold text-gray-800 mb-2">Performance Considerations</h4>
            <ul class="text-sm text-gray-600 space-y-1">
              <li>• Groups with fewer than 20 nodes render efficiently</li>
              <li>• Use region codes when possible for smaller bundle size</li>
              <li>• Consider grouping related nodes for better organization</li>
            </ul>
          </div>
          <div>
            <h4 class="font-semibold text-gray-800 mb-2">Common Patterns</h4>
            <ul class="text-sm text-gray-600 space-y-1">
              <li>• <strong>Environment-based:</strong> Production, Staging, Development</li>
              <li>• <strong>Service-based:</strong> API Servers, Databases, CDN</li>
              <li>• <strong>Status-based:</strong> Healthy, Warning, Error</li>
              <li>• <strong>Region-based:</strong> US East, EU West, Asia Pacific</li>
            </ul>
          </div>
        </div>
        """
      }
    ]
  end
end
