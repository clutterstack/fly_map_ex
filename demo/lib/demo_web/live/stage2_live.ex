defmodule DemoWeb.Stage2Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  import DemoWeb.Components.MapWithCodeComponent
  import DemoWeb.Components.DemoNavigation
  import DemoWeb.Components.InteractiveControls
  import DemoWeb.Components.ProgressiveDisclosure

  def mount(_params, _session, socket) do
    # Define the progressive examples according to the plan
    examples = %{
      automatic: [
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.cycle(0),
          label: "Production Servers"
        },
        %{
          nodes: ["ams", "lhr"],
          style: FlyMapEx.Style.cycle(1),
          label: "Staging Environment"
        },
        %{
          nodes: ["ord"],
          style: FlyMapEx.Style.cycle(2),
          label: "Development"
        },
        %{
          nodes: ["nrt", "syd"],
          style: FlyMapEx.Style.cycle(3),
          label: "Testing"
        }
      ],
      semantic: [
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.operational(),
          label: "Production Servers"
        },
        %{
          nodes: ["ams", "lhr"],
          style: FlyMapEx.Style.warning(),
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
      ],
      custom: [
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.custom("#10b981", size: 8, animation: :pulse, glow: true),
          label: "High-Performance Servers"
        },
        %{
          nodes: ["ams", "lhr"],
          style: FlyMapEx.Style.custom("#f59e0b", size: 6, animation: :fade, glow: false),
          label: "Standard Servers"
        },
        %{
          nodes: ["ord"],
          style: FlyMapEx.Style.custom("#ef4444", size: 10, animation: :pulse, glow: true),
          label: "Critical Alerts"
        },
        %{
          nodes: ["nrt"],
          style: FlyMapEx.Style.custom("#6b7280", size: 4, animation: :none, glow: false),
          label: "Maintenance"
        }
      ],
      mixed: [
        %{
          nodes: ["sjc", "fra"],
          style: FlyMapEx.Style.operational(),
          label: "Production (Semantic)"
        },
        %{
          nodes: ["ams", "lhr"],
          style: FlyMapEx.Style.cycle(1),
          label: "Staging (Auto-Cycle)"
        },
        %{
          nodes: ["ord"],
          style: FlyMapEx.Style.custom("#9333ea", size: 8, animation: :pulse, glow: true),
          label: "Special Deploy (Custom)"
        },
        %{
          nodes: ["nrt", "syd"],
          style: :inactive,
          label: "Offline (Atom)"
        }
      ]
    }

    # Interactive control options
    options = [
      %{key: "automatic", label: "Automatic Styling", description: "Color cycling for multiple groups"},
      %{key: "semantic", label: "Semantic Presets", description: "Meaningful styles for server states"},
      %{key: "custom", label: "Custom Parameters", description: "Size, animation, and glow modifications"},
      %{key: "mixed", label: "Mixed Approaches", description: "Combining different styling methods"}
    ]

    # Custom parameters for the custom example
    custom_params = %{
      size: 6,
      animation: :none,
      glow: false,
      color: "#3b82f6"
    }

    {:ok, assign(socket,
      examples: examples,
      options: options,
      current_example: "automatic",
      custom_params: custom_params
    )}
  end

  def handle_event("switch_example", %{"option" => option}, socket) do
    {:noreply, assign(socket, current_example: option)}
  end

  def handle_event("update_param", %{"param" => param, "value" => value}, socket) do
    updated_params = case param do
      "size" -> Map.put(socket.assigns.custom_params, :size, String.to_integer(value))
      "animation" -> Map.put(socket.assigns.custom_params, :animation, String.to_atom(value))
      "glow" -> Map.put(socket.assigns.custom_params, :glow, value == "true")
      "color" -> Map.put(socket.assigns.custom_params, :color, value)
      _ -> socket.assigns.custom_params
    end

    {:noreply, assign(socket, custom_params: updated_params)}
  end

  def handle_event("apply_preset", %{"preset" => preset}, socket) do
    updated_example = case preset do
      "operational" -> "semantic"
      "warning" -> "semantic"
      "danger" -> "semantic"
      "inactive" -> "semantic"
      _ -> socket.assigns.current_example
    end

    {:noreply, assign(socket, current_example: updated_example)}
  end

  defp current_marker_groups(assigns) do
    Map.get(assigns.examples, String.to_atom(assigns.current_example), [])
  end

  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:stage2} />
    <div class="container mx-auto p-8">
      <!-- Stage Title & Progress -->
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 2: Styling Markers</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Master visual customization and semantic meaning through FlyMapEx's comprehensive styling system.
        </p>
      </div>

      <!-- Key Concept Explanation (Above the Fold) -->
      <.info_panel title="Key Concepts" color="blue" class="mb-6">
        <ul class="text-sm space-y-1">
          <li>• <strong>Automatic Styling:</strong> Use `FlyMapEx.Style.cycle/1` for consistent color cycling</li>
          <li>• <strong>Semantic Presets:</strong> Meaningful styles like operational(), warning(), danger(), inactive()</li>
          <li>• <strong>Custom Parameters:</strong> Modify size, animation, glow, and color for any preset</li>
          <li>• <strong>Mixed Approaches:</strong> Combine different styling methods in one configuration</li>
        </ul>
      </.info_panel>

      <!-- Interactive Controls & Presets -->
      <div class="mb-6">
        <h3 class="text-lg font-semibold text-gray-800 mb-3">Try Different Styling Approaches:</h3>
        <.preset_buttons
          options={@options}
          current={@current_example}
          event="switch_example"
        />
      </div>

      <!-- Live Map Preview & Generated Code -->
      <.map_with_code
        marker_groups={current_marker_groups(assigns)}
        map_title="Interactive Styling Demo"
      >
        <:extra_content>
          <div class="space-y-4">
            <.info_panel title="Current Configuration" color="blue">
              <ul class="text-sm space-y-1">
                <li>• <strong>Approach:</strong> <%= get_current_description(@current_example) %></li>
                <li>• <strong>Groups:</strong> <%= length(current_marker_groups(assigns)) %> group(s)</li>
                <li>• <strong>Total Nodes:</strong> <%= count_total_nodes(current_marker_groups(assigns)) %></li>
                <li>• <strong>Styling Method:</strong> <%= get_styling_method(@current_example) %></li>
              </ul>
            </.info_panel>

            <!-- Interactive Features Panel -->
            <div class="bg-purple-50 border border-purple-200 rounded-lg p-4">
              <h3 class="font-semibold text-purple-800 mb-2">Interactive Features</h3>
              <ul class="text-purple-700 text-sm space-y-1">
                <li>• <strong>Legend Toggles:</strong> Click any group to show/hide markers</li>
                <li>• <strong>Color Consistency:</strong> Groups maintain their colors when toggled</li>
                <li>• <strong>Animation Preview:</strong> See pulse and fade effects in real-time</li>
                <li>• <strong>Style Comparison:</strong> Switch between examples to see differences</li>
                <li>• <strong>Code Generation:</strong> View the exact code for each configuration</li>
              </ul>
            </div>
          </div>
        </:extra_content>
      </.map_with_code>

      <!-- Progressive Disclosure for Advanced Topics -->
      <.learn_more_section
        topics={get_advanced_topics()}
      />

      <!-- Navigation -->
      <div class="mt-8 flex justify-between">
        <.link navigate={~p"/stage1"} class="inline-block bg-gray-600 text-white px-6 py-2 rounded-lg hover:bg-gray-700 transition-colors">
          ← Stage 1: Defining Marker Groups
        </.link>
        <.link navigate={~p"/stage3"} class="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors">
          Next: Stage 3 - Map Themes →
        </.link>
      </div>
    </div>
    """
  end

  # Helper functions for the template
  defp get_current_description(example) do
    case example do
      "automatic" -> "Automatic color cycling for multiple groups"
      "semantic" -> "Semantic presets for meaningful server states"
      "custom" -> "Custom parameters for size, animation, and glow"
      "mixed" -> "Mixed approaches combining different methods"
      _ -> "Unknown example"
    end
  end

  defp get_styling_method(example) do
    case example do
      "automatic" -> "FlyMapEx.Style.cycle/1"
      "semantic" -> "Semantic function calls"
      "custom" -> "FlyMapEx.Style.custom/2"
      "mixed" -> "Mixed function calls and atoms"
      _ -> "Unknown"
    end
  end

  defp count_total_nodes(marker_groups) do
    Enum.reduce(marker_groups, 0, fn group, acc ->
      nodes = group[:nodes] || []
      acc + length(nodes)
    end)
  end

  defp get_advanced_topics do
    [
      %{
        id: "style-functions",
        title: "Style Function Reference",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-gray-700">
            FlyMapEx provides multiple approaches to styling markers:
          </p>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <h4 class="font-semibold text-gray-800 mb-2">Automatic Cycling</h4>
              <ul class="text-sm text-gray-600 space-y-1">
                <li>• <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.cycle(0)</code> - Blue</li>
                <li>• <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.cycle(1)</code> - Green</li>
                <li>• <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.cycle(2)</code> - Red</li>
                <li>• Cycles through 12 predefined colors</li>
              </ul>
            </div>
            <div>
              <h4 class="font-semibold text-gray-800 mb-2">Semantic Presets</h4>
              <ul class="text-sm text-gray-600 space-y-1">
                <li>• <code class="bg-gray-100 px-1 rounded">operational()</code> - Running services</li>
                <li>• <code class="bg-gray-100 px-1 rounded">warning()</code> - Needs attention</li>
                <li>• <code class="bg-gray-100 px-1 rounded">danger()</code> - Critical issues</li>
                <li>• <code class="bg-gray-100 px-1 rounded">inactive()</code> - Not running</li>
              </ul>
            </div>
          </div>
        </div>
        """
      },
      %{
        id: "custom-styling",
        title: "Custom Style Parameters",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-gray-700">
            Build completely custom styles with <code class="bg-gray-100 px-1 rounded">FlyMapEx.Style.custom/2</code>:
          </p>
          <pre class="bg-gray-100 p-4 rounded-lg text-sm"><code>FlyMapEx.Style.custom("#3b82f6", [
  size: 10,        # radius in pixels
  animation: :pulse,   # :none, :pulse, :fade
  glow: true       # enable glow effect
])</code></pre>
          <div class="mt-4">
            <h4 class="font-semibold text-gray-800 mb-2">Available Parameters</h4>
            <div class="space-y-2 text-sm">
              <div>
                <strong>size:</strong> Marker radius in pixels (default: 6)
              </div>
              <div>
                <strong>animation:</strong> :none, :pulse, :fade (default: :none)
              </div>
              <div>
                <strong>glow:</strong> Boolean for glow effect (default: false)
              </div>
            </div>
          </div>
        </div>
        """
      },
      %{
        id: "style-performance",
        title: "Performance & Best Practices",
        content: ~s"""
        <div class="space-y-4">
          <div>
            <h4 class="font-semibold text-gray-800 mb-2">Performance Considerations</h4>
            <ul class="text-sm text-gray-600 space-y-1">
              <li>• Animated markers use CSS animations for smooth performance</li>
              <li>• Glow effects add minimal overhead with box-shadow</li>
              <li>• Use semantic presets for consistent styling across your app</li>
              <li>• Custom colors are validated at compile time</li>
            </ul>
          </div>
          <div>
            <h4 class="font-semibold text-gray-800 mb-2">Styling Strategies</h4>
            <ul class="text-sm text-gray-600 space-y-1">
              <li>• <strong>Automatic:</strong> Use cycle() for consistent multi-group colors</li>
              <li>• <strong>Semantic:</strong> Use presets for meaningful status indicators</li>
              <li>• <strong>Custom:</strong> Use custom() for brand-specific styling</li>
              <li>• <strong>Mixed:</strong> Combine approaches for complex scenarios</li>
            </ul>
          </div>
        </div>
        """
      },
      %{
        id: "production-config",
        title: "Production Configuration",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-gray-700">
            Configure default styling in your application:
          </p>
          <pre class="bg-gray-100 p-4 rounded-lg text-sm"><code># config/config.exs
config :fly_map_ex,
  default_style: :operational,
  custom_presets: %{
    brand_primary: FlyMapEx.Style.custom("#your-brand-color", [
      size: 8,
      animation: :pulse,
      glow: true
    ])
  }</code></pre>
          <div class="mt-4">
            <h4 class="font-semibold text-gray-800 mb-2">Style Normalization</h4>
            <p class="text-sm text-gray-600">
              FlyMapEx automatically normalizes various style formats:
            </p>
            <ul class="text-sm text-gray-600 space-y-1 mt-2">
              <li>• Atoms (`:operational`) → style maps</li>
              <li>• Function calls (`operational()`) → style maps</li>
              <li>• Keyword lists → normalized style maps</li>
              <li>• Custom maps → validated and normalized</li>
            </ul>
          </div>
        </div>
        """
      }
    ]
  end
end
