defmodule DemoWeb.Stage4Live do
  use DemoWeb, :live_view

  import DemoWeb.Components.DemoNavigation
  import DemoWeb.Components.InteractiveControls
  import DemoWeb.Components.ProgressiveDisclosure
  import DemoWeb.Components.SidebarLayout
  import DemoWeb.Components.SidebarNavigation

  def mount(_params, _session, socket) do
    # Default scenario: monitoring dashboard
    marker_groups = [
      %{
        nodes: ["sjc", "fra", "ams", "lhr"],
        style: FlyMapEx.Style.operational(),
        label: "Production Servers"
      },
      %{
        nodes: ["syd", "nrt"],
        style: FlyMapEx.Style.warning(),
        label: "Maintenance Windows"
      }
    ]

    tabs = [
      %{key: "guided", label: "Guided Scenarios", content: get_static_tab_content("guided")},
      %{key: "freeform", label: "Freeform Builder", content: get_static_tab_content("freeform")},
      %{key: "export", label: "Export & Integration", content: get_static_tab_content("export")}
    ]

    {:ok,
     assign(socket,
       marker_groups: marker_groups,
       current_tab: "guided",
       current_scenario: "monitoring",
       tabs: tabs,
       custom_groups: [],
       export_format: "heex"
     )}
  end

  def handle_event("switch_scenario", %{"option" => scenario}, socket) do
    marker_groups = get_scenario_config(scenario)
    {:noreply, assign(socket, current_scenario: scenario, marker_groups: marker_groups)}
  end

  def handle_event("switch_tab", %{"option" => tab}, socket) do
    marker_groups = case tab do
      "guided" -> get_scenario_config(socket.assigns.current_scenario)
      "freeform" -> socket.assigns.custom_groups
      "export" -> socket.assigns.marker_groups
      _ -> socket.assigns.marker_groups
    end
    {:noreply, assign(socket, current_tab: tab, marker_groups: marker_groups)}
  end

  def handle_event("switch_format", %{"option" => format}, socket) do
    {:noreply, assign(socket, export_format: format)}
  end

  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:stage4} />
        <.sidebar_layout>
      <:sidebar>
        <.sidebar_navigation current_page={:stage4} tabs={@tabs} current_tab={@current_tab} />
      </:sidebar>

      <:main>

    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-base-content">Stage 4: Interactive Builder</h1>
        </div>
        <p class="text-base-content/70 mb-6">
          Apply your knowledge to build real-world map configurations with guided scenarios, freeform building, and code export.
        </p>
      </div>

      <!-- Full Width Map (Above the Fold) -->
      <div class="mb-8 p-6 bg-base-200 rounded-lg">
        <FlyMapEx.render
          marker_groups={@marker_groups}
          theme={:responsive}
          layout={:side_by_side}
        />
      </div>

      <!-- Side-by-Side: Tabbed Info Panel & Code Examples -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        <!-- Tabbed Info Panel -->
        <div>
          <.tabbed_info_panel
            tabs={@tabs}
            current={@current_tab}
            event="switch_tab"
            show_tabs={false}
          />
        </div>

        <!-- Code Examples Panel -->
        <div>
          <div class="bg-base-100 border border-base-300 rounded-lg overflow-hidden">
            <div class="bg-base-200 px-4 py-3 border-b border-base-300">
              <h3 class="font-semibold text-base-content">Generated Code</h3>
            </div>
            <div class="p-4">
              <pre class="text-sm text-base-content overflow-x-auto bg-base-200 p-3 rounded"><code><%= get_generated_code(@current_tab, @current_scenario, @marker_groups, @export_format) %></code></pre>
            </div>

            <!-- Quick Stats -->
            <div class="bg-primary/10 border-t border-base-300 px-4 py-3">
              <div class="text-sm text-primary">
                <strong>Current:</strong> <%= get_current_description(@current_tab, @current_scenario) %> •
                Format: <%= String.upcase(@export_format) %> •
                <%= length(@marker_groups) %> groups • <%= count_total_nodes(@marker_groups) %> nodes
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Progressive Disclosure for Advanced Topics -->
      <.learn_more_section
        topics={get_advanced_topics()}
      />

      <!-- Navigation -->
      <div class="mt-8 flex justify-between">
        <.link navigate={~p"/stage3"} class="inline-block bg-neutral text-neutral-content px-6 py-2 rounded-lg hover:bg-neutral/80 transition-colors">
          ← Stage 3: Map Themes
        </.link>
        <.link navigate={~p"/"} class="inline-block bg-success text-success-content px-6 py-2 rounded-lg hover:bg-success/80 transition-colors">
          Complete Tour →
        </.link>
      </div>
    </div>
              </:main>
    </.sidebar_layout>

    """
  end

  # Static HTML content generation functions
  defp get_static_tab_content("guided") do
    """
    <div class="space-y-6">
      <div>
        <h3 class="font-semibold text-base-content mb-3">Guided Scenarios</h3>
        <p class="text-base-content/70 text-sm mb-4">
          Learn by building real-world map configurations with step-by-step guidance.
          Each scenario demonstrates common patterns and best practices.
        </p>
      </div>

      <div class="space-y-4">
        <div class="bg-primary/10 border border-primary/20 rounded-lg p-4">
          <h4 class="font-medium text-primary mb-2">Monitoring Dashboard</h4>
          <p class="text-sm text-primary/80 mb-2">Track service health across multiple regions with status indicators.</p>
          <button 
            phx-click="switch_scenario" 
            phx-value-option="monitoring"
            class="bg-primary text-primary-content px-3 py-1 rounded text-sm hover:bg-primary/80 transition-colors"
          >
            Load Scenario
          </button>
          <ul class="text-sm text-primary/80 mt-2 space-y-1">
            <li>• Production servers marked as operational</li>
            <li>• Maintenance windows highlighted with warnings</li>
            <li>• Clear legend for status interpretation</li>
          </ul>
        </div>

        <div class="bg-success/10 border border-success/20 rounded-lg p-4">
          <h4 class="font-medium text-success mb-2">Deployment Map</h4>
          <p class="text-sm text-success/80 mb-2">Visualize application rollouts and deployment status across regions.</p>
          <button 
            phx-click="switch_scenario" 
            phx-value-option="deployment"
            class="bg-success text-success-content px-3 py-1 rounded text-sm hover:bg-success/80 transition-colors"
          >
            Load Scenario
          </button>
          <ul class="text-sm text-success/80 mt-2 space-y-1">
            <li>• Active deployments with animated markers</li>
            <li>• Completed deployments in stable states</li>
            <li>• Pending regions awaiting deployment</li>
          </ul>
        </div>

        <div class="bg-secondary/10 border border-secondary/20 rounded-lg p-4">
          <h4 class="font-medium text-secondary mb-2">Status Board</h4>
          <p class="text-sm text-secondary/80 mb-2">Create a comprehensive status overview for incident response and monitoring.</p>
          <button 
            phx-click="switch_scenario" 
            phx-value-option="status"
            class="bg-secondary text-secondary-content px-3 py-1 rounded text-sm hover:bg-secondary/80 transition-colors"
          >
            Load Scenario
          </button>
          <ul class="text-sm text-secondary/80 mt-2 space-y-1">
            <li>• Critical issues highlighted with danger styling</li>
            <li>• Healthy services marked as operational</li>
            <li>• Maintenance and acknowledged states</li>
          </ul>
        </div>
      </div>

      <div class="bg-success/10 border border-success/20 rounded-lg p-4">
        <p class="text-sm text-success">
          <strong>Learning approach:</strong> Each scenario builds on concepts from previous stages,
          combining marker groups, styling, and theming into practical applications.
        </p>
      </div>
    </div>
    """
  end

  defp get_static_tab_content("freeform") do
    """
    <div class="space-y-6">
      <div>
        <h3 class="font-semibold text-base-content mb-3">Freeform Builder</h3>
        <p class="text-base-content/70 text-sm mb-4">
          Build custom map configurations from scratch with full creative control.
          Perfect for unique requirements and experimental designs.
        </p>
      </div>

      <div class="space-y-4">
        <div class="bg-primary/10 border border-primary/20 rounded-lg p-4">
          <h4 class="font-medium text-primary mb-2">Interactive Region Selection</h4>
          <p class="text-sm text-primary/80 mb-2">Click regions on the map to build your marker groups dynamically.</p>
          <ul class="text-sm text-primary space-y-1">
            <li>• Visual region picker with live preview</li>
            <li>• Drag and drop group organization</li>
            <li>• Real-time code generation</li>
          </ul>
          <div class="mt-2 text-xs text-primary/70">
            <em>Coming in Phase 2: Enhanced Interactivity</em>
          </div>
        </div>

        <div class="bg-success/10 border border-success/20 rounded-lg p-4">
          <h4 class="font-medium text-success mb-2">Custom Group Builder</h4>
          <p class="text-sm text-success/80 mb-2">Create marker groups with custom styling and labels.</p>
          <ul class="text-sm text-success space-y-1">
            <li>• Add/remove regions with search and autocomplete</li>
            <li>• Live style customization with sliders and pickers</li>
            <li>• Group management with reordering and duplication</li>
          </ul>
          <div class="mt-2 text-xs text-success/70">
            <em>Coming in Phase 2: Enhanced Interactivity</em>
          </div>
        </div>

        <div class="bg-secondary/10 border border-secondary/20 rounded-lg p-4">
          <h4 class="font-medium text-secondary mb-2">Live Preview Canvas</h4>
          <p class="text-sm text-secondary/80 mb-2">See your changes instantly as you build.</p>
          <ul class="text-sm text-secondary space-y-1">
            <li>• Real-time map updates during editing</li>
            <li>• Side-by-side comparison views</li>
            <li>• Undo/redo functionality</li>
          </ul>
          <div class="mt-2 text-xs text-secondary/70">
            <em>Coming in Phase 2: Enhanced Interactivity</em>
          </div>
        </div>
      </div>

      <div class="bg-warning/10 border border-warning/20 rounded-lg p-4">
        <p class="text-sm text-warning">
          <strong>Current functionality:</strong> Use the guided scenarios to explore different configurations.
          Full freeform building tools will be added in Phase 2 with interactive controls and live editing.
        </p>
      </div>
    </div>
    """
  end

  defp get_static_tab_content("export") do
    """
    <div class="space-y-6">
      <div>
        <h3 class="font-semibold text-base-content mb-3">Export & Integration</h3>
        <p class="text-base-content/70 text-sm mb-4">
          Generate production-ready code in multiple formats for seamless integration
          into your Phoenix LiveView applications.
        </p>
      </div>

      <div class="space-y-4">
        <div class="bg-primary/10 border border-primary/20 rounded-lg p-4">
          <h4 class="font-medium text-primary mb-2">Export Formats</h4>
          <p class="text-sm text-primary/80 mb-2">Choose the format that best fits your integration needs:</p>
          <div class="flex gap-2 mb-2">
            <button 
              phx-click="switch_format" 
              phx-value-option="heex"
              class="bg-primary text-primary-content px-3 py-1 rounded text-sm hover:bg-primary/80 transition-colors"
            >
              HEEx Template
            </button>
            <button 
              phx-click="switch_format" 
              phx-value-option="elixir"
              class="bg-primary text-primary-content px-3 py-1 rounded text-sm hover:bg-primary/80 transition-colors"
            >
              Elixir Module
            </button>
            <button 
              phx-click="switch_format" 
              phx-value-option="json"
              class="bg-primary text-primary-content px-3 py-1 rounded text-sm hover:bg-primary/80 transition-colors"
            >
              JSON Config
            </button>
          </div>
          <ul class="text-sm text-primary space-y-1">
            <li>• <strong>HEEx:</strong> Direct template integration</li>
            <li>• <strong>Elixir:</strong> Reusable function modules</li>
            <li>• <strong>JSON:</strong> Configuration-driven approach</li>
          </ul>
        </div>

        <div class="bg-success/10 border border-success/20 rounded-lg p-4">
          <h4 class="font-medium text-success mb-2">Integration Patterns</h4>
          <p class="text-sm text-success/80 mb-2">Common integration approaches:</p>
          <ul class="text-sm text-success space-y-1">
            <li>• <strong>Direct Embed:</strong> Copy HEEx template into your LiveView</li>
            <li>• <strong>Function Component:</strong> Create reusable components</li>
            <li>• <strong>Configuration Module:</strong> Centralize map configurations</li>
            <li>• <strong>Dynamic Loading:</strong> Load configurations from database</li>
          </ul>
        </div>

        <div class="bg-secondary/10 border border-secondary/20 rounded-lg p-4">
          <h4 class="font-medium text-secondary mb-2">Production Considerations</h4>
          <p class="text-sm text-secondary/80 mb-2">Important factors for production deployment:</p>
          <ul class="text-sm text-secondary space-y-1">
            <li>• <strong>Performance:</strong> Optimize for rendering speed</li>
            <li>• <strong>Maintainability:</strong> Structure for easy updates</li>
            <li>• <strong>Scalability:</strong> Handle growing data sets</li>
            <li>• <strong>Accessibility:</strong> Ensure inclusive design</li>
          </ul>
        </div>

        <div class="bg-warning/10 border border-warning/20 rounded-lg p-4">
          <h4 class="font-medium text-warning mb-2">Copy to Clipboard</h4>
          <p class="text-sm text-warning/80 mb-2">Generated code is ready for immediate use:</p>
          <div class="mt-2 text-xs text-warning/70">
            <em>Coming in Phase 2: One-click clipboard integration</em>
          </div>
        </div>
      </div>

      <div class="bg-success/10 border border-success/20 rounded-lg p-4">
        <p class="text-sm text-success">
          <strong>Integration tip:</strong> Start with HEEx templates for quick prototyping,
          then extract to Elixir modules for production applications with multiple maps.
        </p>
      </div>
    </div>
    """
  end

  defp get_static_tab_content(_), do: "<div>Unknown tab content</div>"

  # Scenario configurations
  defp get_scenario_config("monitoring") do
    [
      %{
        nodes: ["sjc", "fra", "ams", "lhr"],
        style: FlyMapEx.Style.operational(),
        label: "Production Servers"
      },
      %{
        nodes: ["syd", "nrt"],
        style: FlyMapEx.Style.warning(),
        label: "Maintenance Windows"
      }
    ]
  end

  defp get_scenario_config("deployment") do
    [
      %{
        nodes: ["sjc", "fra"],
        style: FlyMapEx.Style.operational(),
        label: "Deployed v2.1.0"
      },
      %{
        nodes: ["ams", "lhr"],
        style: FlyMapEx.Style.active(),
        label: "Deploying v2.1.0"
      },
      %{
        nodes: ["syd", "nrt", "dfw"],
        style: FlyMapEx.Style.inactive(),
        label: "Pending Deployment"
      }
    ]
  end

  defp get_scenario_config("status") do
    [
      %{
        nodes: ["sjc", "fra", "ams"],
        style: FlyMapEx.Style.operational(),
        label: "Healthy Services"
      },
      %{
        nodes: ["lhr"],
        style: FlyMapEx.Style.danger(),
        label: "Critical Issues"
      },
      %{
        nodes: ["syd"],
        style: FlyMapEx.Style.warning(),
        label: "Degraded Performance"
      },
      %{
        nodes: ["nrt"],
        style: FlyMapEx.Style.info(),
        label: "Acknowledged Issues"
      }
    ]
  end

  defp get_scenario_config(_), do: []

  # Helper functions for the template
  defp get_current_description(tab, scenario) do
    case tab do
      "guided" -> "#{String.capitalize(scenario)} scenario"
      "freeform" -> "Custom builder (Phase 2)"
      "export" -> "Code export tools"
      _ -> "Interactive builder"
    end
  end

  defp count_total_nodes(marker_groups) do
    marker_groups
    |> Enum.map(&length(Map.get(&1, :nodes, [])))
    |> Enum.sum()
  end

  defp get_generated_code(tab, scenario, marker_groups, format) do
    case {tab, format} do
      {"guided", "heex"} ->
        get_heex_template(marker_groups, scenario)
      {"guided", "elixir"} ->
        get_elixir_module(marker_groups, scenario)
      {"guided", "json"} ->
        get_json_config(marker_groups, scenario)
      {"export", "heex"} ->
        get_heex_template(marker_groups, "export")
      {"export", "elixir"} ->
        get_elixir_module(marker_groups, "export")
      {"export", "json"} ->
        get_json_config(marker_groups, "export")
      _ ->
        get_heex_template(marker_groups, "default")
    end
  end

  defp get_heex_template(marker_groups, context) do
    groups_code = marker_groups
    |> Enum.map(fn group ->
      nodes = Enum.map(group.nodes, &"\"#{&1}\"") |> Enum.join(", ")
      style = format_style_for_heex(group.style)
      "      %{\n        nodes: [#{nodes}],\n        style: #{style},\n        label: \"#{group.label}\"\n      }"
    end)
    |> Enum.join(",\n")

    "# #{String.capitalize(context)} Map Configuration\n<FlyMapEx.render\n  marker_groups={[\n#{groups_code}\n  ]}\n  theme={:responsive}\n  layout={:side_by_side}\n/>\n\n# Add this to your LiveView template\n# Remember to import FlyMapEx in your view module"
  end

  defp get_elixir_module(marker_groups, context) do
    groups_code = marker_groups
    |> Enum.map(fn group ->
      nodes = Enum.map(group.nodes, &"\"#{&1}\"") |> Enum.join(", ")
      style = format_style_for_elixir(group.style)
      "      %{\n        nodes: [#{nodes}],\n        style: #{style},\n        label: \"#{group.label}\"\n      }"
    end)
    |> Enum.join(",\n")

    "# #{String.capitalize(context)} Map Module\ndefmodule YourApp.MapConfigs do\n  @moduledoc \"\"\"\n  Centralized map configurations for #{context} displays\n  \"\"\"\n\n  def #{context}_map_groups do\n    [\n#{groups_code}\n    ]\n  end\n\n  def render_#{context}_map(assigns) do\n    ~H\"\"\"\n    <FlyMapEx.render\n      marker_groups={#{context}_map_groups()}\n      theme={:responsive}\n      layout={:side_by_side}\n    />\n    \"\"\"\n  end\nend\n\n# Usage in your LiveView:\n# import YourApp.MapConfigs\n# <.render_#{context}_map />"
  end

  defp get_json_config(marker_groups, context) do
    groups_json = marker_groups
    |> Enum.map(fn group ->
      "    {\n      \"nodes\": [#{group.nodes |> Enum.map(&"\"#{&1}\"") |> Enum.join(", ")}],\n      \"style\": #{format_style_for_json(group.style)},\n      \"label\": \"#{group.label}\"\n    }"
    end)
    |> Enum.join(",\n")

    "{\n  \"name\": \"#{String.capitalize(context)} Map Configuration\",\n  \"theme\": \"responsive\",\n  \"layout\": \"side_by_side\",\n  \"marker_groups\": [\n#{groups_json}\n  ]\n}\n\n# Use with a JSON loader function:\n# def load_config(config_name) do\n#   config = Jason.decode!(File.read!(\"configs/\#{config_name}.json\"))\n#   # Transform JSON to Elixir structures\n# end"
  end

  defp format_style_for_heex(style) do
    case style do
      %{style_key: key} -> "FlyMapEx.Style.#{key}()"
      _ -> "FlyMapEx.Style.operational()"
    end
  end

  defp format_style_for_elixir(style) do
    case style do
      %{style_key: key} -> "FlyMapEx.Style.#{key}()"
      _ -> "FlyMapEx.Style.operational()"
    end
  end

  defp format_style_for_json(style) do
    case style do
      %{style_key: key} -> "\"#{key}\""
      _ -> "\"operational\""
    end
  end

  defp get_advanced_topics do
    [
      %{
        id: "scenario-templates",
        title: "Building Scenario Templates",
        description: "Create reusable templates for common map configurations",
        content: "<p class='text-sm text-base-content/70 mb-4'>Learn to build maintainable template systems for recurring map patterns.</p><ul class='text-sm text-base-content/70 space-y-2'><li>• <strong>Template Structure:</strong> Design flexible, parameterized configurations</li><li>• <strong>Validation:</strong> Ensure template consistency and error handling</li><li>• <strong>Documentation:</strong> Create clear usage guides for template consumers</li></ul>"
      },
      %{
        id: "integration-patterns",
        title: "Production Integration Patterns",
        description: "Best practices for deploying maps in production applications",
        content: "<p class='text-sm text-base-content/70 mb-4'>Proven patterns for integrating FlyMapEx into production Phoenix applications.</p><ul class='text-sm text-base-content/70 space-y-2'><li>• <strong>Data Loading:</strong> Efficient strategies for dynamic marker group loading</li><li>• <strong>Caching:</strong> Optimize performance with smart caching approaches</li><li>• <strong>Error Handling:</strong> Graceful degradation for missing regions or data</li></ul>"
      },
      %{
        id: "advanced-customization",
        title: "Advanced Customization Techniques",
        description: "Extend FlyMapEx with custom components and behaviors",
        content: "<p class='text-sm text-base-content/70 mb-4'>Advanced techniques for building custom map experiences beyond standard configurations.</p><ul class='text-sm text-base-content/70 space-y-2'><li>• <strong>Custom Styles:</strong> Create entirely custom marker and map styles</li><li>• <strong>Interactive Elements:</strong> Add click handlers and hover effects</li><li>• <strong>Animation Control:</strong> Fine-tune animations for specific use cases</li></ul>"
      }
    ]
  end
end
